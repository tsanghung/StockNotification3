import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../domain/entities/stock.dart';

class StockRemoteDatasource {
  final Dio _dio;

  StockRemoteDatasource(this._dio);

  // 快取 Yahoo TW 爬蟲結果（同一次 fetchAllStocks 只爬一次）
  Map<String, Stock>? _yahooScrapeCache;

  Future<List<Stock>> fetchAllStocks() async {
    // 預先爬取 Yahoo TW 頁面，取得四大指數
    _yahooScrapeCache = await _scrapeYahooTwWorldIndices();

    final futures = ApiConstants.stockSymbols.map((info) async {
      switch (info['type']) {
        case 'yahoo_scrape':
          return _yahooScrapeCache?[info['apiSymbol']];
        case 'twelve':
          return _fetchTwelveData(
            apiSymbol: info['apiSymbol']!,
            displaySymbol: info['symbol']!,
            displayName: info['name']!,
          );
        case 'twse':
          return _fetchTwse(
            exCh: info['apiSymbol']!,
            displaySymbol: info['symbol']!,
            displayName: info['name']!,
          );
        default:
          return null;
      }
    }).toList();

    final results = await Future.wait(futures, eagerError: false);
    return results.whereType<Stock>().toList();
  }

  /// 爬取 https://tw.stock.yahoo.com/world-indices/ 取得四大指數
  Future<Map<String, Stock>> _scrapeYahooTwWorldIndices() async {
    final result = <String, Stock>{};
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(milliseconds: 20000);

      final uri = Uri.parse(ApiConstants.yahooTwWorldIndices);
      final request = await client.getUrl(uri);
      request.headers.set('User-Agent',
          'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36');
      request.headers.set('Accept-Language', 'zh-TW,zh;q=0.9');
      final response = await request.close();
      final html = await response.transform(utf8.decoder).join();
      client.close();

      // 逐一解析每個指數
      for (final info in ApiConstants.worldIndexSymbols) {
        final htmlKey = info['htmlKey']!;
        final symbol  = info['symbol']!;
        final name    = info['name']!;

        final stock = _parseIndexFromHtml(html, htmlKey, symbol, name);
        if (stock != null) result[htmlKey] = stock;
      }
    } catch (_) {}
    return result;
  }

  /// 從 HTML 中解析單一指數資料
  /// HTML 結構：
  ///   價格：C($c-trend-down)">46,584.46</span>
  ///   漲跌：C($c-trend-down)"><span ...></span>85.42</span>
  ///   漲跌%：C($c-trend-down)"><span ...></span>0.18%</span>
  Stock? _parseIndexFromHtml(String html, String htmlKey, String symbol, String name) {
    try {
      final keyMarker = '^$htmlKey';
      final keyIdx = html.indexOf(keyMarker);
      if (keyIdx < 0) return null;

      final segment = html.substring(keyIdx, keyIdx + 2000);

      // 判斷第一個漲跌方向（道瓊是 down，其他可能是 up）
      final firstDownIdx = segment.indexOf('c-trend-down');
      final firstUpIdx   = segment.indexOf('c-trend-up');
      bool isDown;
      if (firstDownIdx < 0 && firstUpIdx < 0) return null;
      if (firstDownIdx < 0) isDown = false;
      else if (firstUpIdx < 0) isDown = true;
      else isDown = firstDownIdx < firstUpIdx;
      final sign = isDown ? -1.0 : 1.0;

      // 價格：緊接在第一個 c-trend-X)"> 後面的數字（不含 <span>）
      final priceRegex = RegExp(r'c-trend-(?:down|up)\)">([0-9,]+\.?[0-9]*)');
      final priceMatch = priceRegex.firstMatch(segment);
      if (priceMatch == null) return null;
      final price = double.tryParse(priceMatch.group(1)!.replaceAll(',', '')) ?? 0.0;
      if (price == 0) return null;

      // 漲跌點數 & 漲跌幅：在 <span ...></span> 後面的數字
      // 格式：C($c-trend-X)"><span [^/]*/><數字>
      final changeRegex = RegExp(
        r'c-trend-(?:down|up)\)">'
        r'<span[^>]*/>'   // 三角形裝飾 span（自閉合）
        r'([0-9,]+\.?[0-9]*)',
      );
      final changeMatches = changeRegex.allMatches(segment).toList();

      double change = 0.0;
      double changePercent = 0.0;

      if (changeMatches.isNotEmpty) {
        change = (double.tryParse(
              changeMatches[0].group(1)!.replaceAll(',', ''),
            ) ?? 0.0) * sign;
      }
      if (changeMatches.length >= 2) {
        changePercent = (double.tryParse(
              changeMatches[1].group(1)!.replaceAll(',', ''),
            ) ?? 0.0) * sign;
      }

      return Stock(
        symbol: symbol,
        name: name,
        price: price,
        change: change,
        changePercent: changePercent,
      );
    } catch (_) {
      return null;
    }
  }

  /// Twelve Data API：台積電 ADR
  Future<Stock?> _fetchTwelveData({
    required String apiSymbol,
    required String displaySymbol,
    required String displayName,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.twelveDataQuote,
        queryParameters: {
          'symbol': apiSymbol,
          'apikey': ApiConstants.twelveDataApiKey,
        },
      );
      final data = response.data as Map<String, dynamic>;
      if (data['status'] == 'error') return null;

      final price         = _toDouble(data['close']);
      final change        = _toDouble(data['change']);
      final changePercent = _toDouble(data['percent_change']);
      if (price == 0) return null;

      return Stock(
        symbol: displaySymbol,
        name: displayName,
        price: price,
        change: change,
        changePercent: changePercent,
      );
    } catch (_) {
      return null;
    }
  }

  /// 台灣證交所即時 API（台股加權指數）
  Future<Stock?> _fetchTwse({
    required String exCh,
    required String displaySymbol,
    required String displayName,
  }) async {
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(milliseconds: 15000),
        receiveTimeout: const Duration(milliseconds: 30000),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36',
          'Referer': 'https://mis.twse.com.tw/',
          'Accept': '*/*',
        },
        responseType: ResponseType.plain,
      ));

      final response = await dio.get(
        'https://mis.twse.com.tw/stock/api/getStockInfo.jsp',
        queryParameters: {'ex_ch': exCh, 'json': '1', 'delay': '0'},
      );

      final Map<String, dynamic> json = jsonDecode(response.data as String);
      final msgArray = json['msgArray'] as List?;
      if (msgArray == null || msgArray.isEmpty) return null;

      final item     = msgArray.first as Map<String, dynamic>;
      final priceStr = (item['z'] as String?)?.trim() ?? '-';
      final prevStr  = (item['y'] as String?)?.trim() ?? '0';

      double price;
      if (priceStr == '-' || priceStr.isEmpty) {
        final h = double.tryParse((item['h'] as String?)?.trim() ?? '') ?? 0.0;
        final l = double.tryParse((item['l'] as String?)?.trim() ?? '') ?? 0.0;
        price = (h > 0 && l > 0) ? (h + l) / 2 : (double.tryParse(prevStr) ?? 0.0);
      } else {
        price = double.tryParse(priceStr) ?? 0.0;
      }
      if (price == 0) return null;

      final prev   = double.tryParse(prevStr) ?? 0.0;
      final change = prev != 0 ? price - prev : 0.0;
      final pct    = prev != 0 ? (change / prev) * 100 : 0.0;

      return Stock(
        symbol: displaySymbol,
        name: displayName,
        price: price,
        change: change,
        changePercent: pct,
      );
    } catch (_) {
      return null;
    }
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}

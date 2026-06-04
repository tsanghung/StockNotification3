import 'package:dio/dio.dart';
import 'package:xml/xml.dart';

import '../../core/constants/api_constants.dart';
import '../../domain/entities/news_item.dart';
import '../models/news_model.dart';
import 'translate_datasource.dart';

class NewsRemoteDatasource {
  final Dio _dio;
  final TranslateDatasource _translator;

  NewsRemoteDatasource(this._dio, this._translator);

  /// 從三個 RSS 來源同時抓取新聞（對應 news.js）
  Future<List<NewsItem>> fetchAllNews() async {
    final results = await Future.wait([
      _fetchYahooFinanceRss(),
      _fetchGoogleNewsAiRss(),
      _fetchYahooTwRss(),
    ]);

    return results.expand((list) => list).toList();
  }

  /// Yahoo Finance 國際財經 RSS（英文 → 翻譯後歸類為政經）
  Future<List<NewsItem>> _fetchYahooFinanceRss() async {
    try {
      final items = await _parseRss(ApiConstants.yahooFinanceRss);
      final titles = items.map((i) => i.title).toList();
      final translated = await _translator.translateBatch(titles);

      return List.generate(items.length, (i) {
        return items[i].copyWith(title: translated[i]).toEntity();
      }).where((n) => n.title.isNotEmpty).take(8).toList();
    } catch (_) {
      return [];
    }
  }

  /// Google News AI 趨勢 RSS（英文 → 翻譯後歸類為 AI 趨勢）
  Future<List<NewsItem>> _fetchGoogleNewsAiRss() async {
    try {
      final items = await _parseRss(ApiConstants.googleNewsAiRss, category: NewsCategory.aiTrends);
      final titles = items.map((i) => i.title).toList();
      final translated = await _translator.translateBatch(titles);

      return List.generate(items.length, (i) {
        return items[i].copyWith(title: translated[i]).toEntity();
      }).where((n) => n.title.isNotEmpty).take(8).toList();
    } catch (_) {
      return [];
    }
  }

  /// Yahoo 台灣財經 RSS（中文，依關鍵字分類為台股盤前或美股盤後）
  Future<List<NewsItem>> _fetchYahooTwRss() async {
    try {
      // 先以 politicsEconomy 作預設，後續根據關鍵字重新指定分類
      final items = await _parseRss(ApiConstants.yahooTwFinanceRss);
      final categorized = <NewsModel>[];

      for (final item in items) {
        final title = item.title;

        final isUsRecap = ApiConstants.usMarketRecapKeywords
            .any((kw) => title.contains(kw));
        final isTwPre = ApiConstants.twMarketPreKeywords
            .any((kw) => title.contains(kw));

        if (isUsRecap) {
          categorized.add(NewsModel(
            title: title,
            url: item.url,
            category: NewsCategory.usMarketRecap,
            publishTime: item.publishTime,
          ));
        } else if (isTwPre) {
          categorized.add(NewsModel(
            title: title,
            url: item.url,
            category: NewsCategory.twMarketPre,
            publishTime: item.publishTime,
          ));
        }
      }

      return categorized.take(10).map((m) => m.toEntity()).toList();
    } catch (_) {
      return [];
    }
  }

  /// 解析 RSS XML，回傳 NewsModel 列表
  Future<List<NewsModel>> _parseRss(
    String url, {
    NewsCategory category = NewsCategory.politicsEconomy, // NOSONAR
  }) async {
    final response = await _dio.get<String>(url);
    final xmlString = response.data ?? '';
    final document = XmlDocument.parse(xmlString);

    return document.findAllElements('item').take(12).map((item) {
      final title = _extractText(item, 'title');
      final link  = _extractLink(item);
      final pubDateStr = _extractText(item, 'pubDate');

      return NewsModel(
        title: title,
        url: link,
        category: category,
        publishTime: _parsePubDate(pubDateStr),
      );
    }).where((n) => n.title.isNotEmpty && n.url.isNotEmpty).toList();
  }

  String _extractText(XmlElement item, String tagName) {
    try {
      final el = item.findElements(tagName).firstOrNull;
      if (el == null) return '';
      // 處理 CDATA
      final cdata = el.children
          .whereType<XmlCDATA>()
          .map((c) => c.value)
          .join();
      if (cdata.isNotEmpty) return cdata.trim();
      return el.innerText.trim();
    } catch (_) {
      return '';
    }
  }

  String _extractLink(XmlElement item) {
    // 先找 <link> 標籤，Google News RSS 的 link 是文字節點而非元素
    try {
      final linkEl = item.findElements('link').firstOrNull;
      if (linkEl != null) {
        final text = linkEl.innerText.trim();
        if (text.startsWith('http')) return text;
      }
    } catch (_) {}

    // fallback: 找 <guid>
    try {
      final guid = item.findElements('guid').firstOrNull?.innerText.trim() ?? '';
      if (guid.startsWith('http')) return guid;
    } catch (_) {}

    return '';
  }

  DateTime? _parsePubDate(String pubDateStr) {
    if (pubDateStr.isEmpty) return null;
    try {
      // RFC 2822 格式，例如 "Mon, 07 Apr 2025 10:00:00 +0800"
      return DateTime.parse(pubDateStr);
    } catch (_) {
      return null;
    }
  }
}

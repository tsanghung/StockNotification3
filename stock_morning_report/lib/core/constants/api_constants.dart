class ApiConstants {
  // Yahoo 台灣國際指數頁面（爬蟲來源）
  static const String yahooTwWorldIndices = 'https://tw.stock.yahoo.com/world-indices/';

  // Twelve Data API（台積電 ADR）
  static const String twelveDataQuote = 'https://api.twelvedata.com/quote';
  static const String twelveDataApiKey = '671c87ebf20c4bc4b26f3a754c66ef73';

  // Yahoo Finance v7（備用）
  static const String yahooFinanceQuote =
      'https://query1.finance.yahoo.com/v7/finance/quote';
  static const String yahooFinanceQuoteAlt =
      'https://query2.finance.yahoo.com/v7/finance/quote';

  // RSS 新聞來源
  static const String yahooFinanceRss =
      'https://finance.yahoo.com/news/rssindex';
  static const String googleNewsAiRss =
      'https://news.google.com/rss/search?q=AI+semiconductor+chip&hl=en-US&gl=US&ceid=US:en';
  static const String yahooTwFinanceRss =
      'https://tw.news.yahoo.com/rss/finance';

  // Google Translate 非官方端點（與 google-translate-api-next 相同原理）
  static const String googleTranslate =
      'https://translate.googleapis.com/translate_a/single';

  // 請求逾時設定（毫秒）
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 30000;

  // 股票代號清單
  // finnhubSymbol：Finnhub API 使用的代號
  // symbol：顯示用代號
  // name：顯示名稱
  // 四大美股指數從 Yahoo 台灣爬蟲，key = HTML 內的符號字串
  static const List<Map<String, String>> worldIndexSymbols = [
    {'htmlKey': 'DJI',  'symbol': 'DJI',  'name': '道瓊工業指數'},
    {'htmlKey': 'GSPC', 'symbol': 'SPX',  'name': 'S&P 500 指數'},
    {'htmlKey': 'IXIC', 'symbol': 'IXIC', 'name': 'NASDAQ 指數'},
    {'htmlKey': 'SOX',  'symbol': 'SOX',  'name': '費城半導體指數'},
  ];

  static const List<Map<String, String>> stockSymbols = [
    {'apiSymbol': 'DJI',        'symbol': 'DJI',   'name': '道瓊工業指數',   'type': 'yahoo_scrape'},
    {'apiSymbol': 'GSPC',       'symbol': 'SPX',   'name': 'S&P 500 指數',  'type': 'yahoo_scrape'},
    {'apiSymbol': 'IXIC',       'symbol': 'IXIC',  'name': 'NASDAQ 指數',   'type': 'yahoo_scrape'},
    {'apiSymbol': 'SOX',        'symbol': 'SOX',   'name': '費城半導體指數', 'type': 'yahoo_scrape'},
    {'apiSymbol': 'TSM',        'symbol': 'TSM',   'name': '台積電 ADR',    'type': 'twelve'},
    {'apiSymbol': 'tse_t00.tw', 'symbol': 'TAIEX', 'name': '台股加權指數',  'type': 'twse'},
  ];

  // 台股盤前關鍵字（對應 news.js）
  static const List<String> twMarketPreKeywords = ['台股', '盤前', '重點', '法人', '開盤'];

  // 美股盤後關鍵字（對應 news.js）
  static const List<String> usMarketRecapKeywords = ['美股', '盤後', '收盤', '終場', '道瓊', 'S&P'];
}

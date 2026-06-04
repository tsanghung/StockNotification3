/// 新聞分類（對應 generator.js 內的分類鍵）
enum NewsCategory {
  usMarketRecap,    // 美股盤後回顧
  twMarketPre,      // 台股盤前重點
  politicsEconomy,  // 國內外政經
  aiTrends,         // AI 產業趨勢
}

extension NewsCategoryExtension on NewsCategory {
  String get displayName {
    switch (this) {
      case NewsCategory.usMarketRecap:   return '美股盤後回顧';
      case NewsCategory.twMarketPre:     return '台股盤前重點';
      case NewsCategory.politicsEconomy: return '國內外政經';
      case NewsCategory.aiTrends:        return 'AI 產業趨勢';
    }
  }
}

/// 新聞項目實體
class NewsItem {
  final String title;
  final String url;
  final NewsCategory category;
  final DateTime? publishTime;

  const NewsItem({
    required this.title,
    required this.url,
    required this.category,
    this.publishTime,
  });
}

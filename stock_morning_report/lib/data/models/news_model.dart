import '../../domain/entities/news_item.dart';

/// RSS item 的資料模型
class NewsModel {
  final String title;
  final String url;
  final NewsCategory category;
  final DateTime? publishTime;

  const NewsModel({
    required this.title,
    required this.url,
    required this.category,
    this.publishTime,
  });

  NewsItem toEntity() {
    return NewsItem(
      title: title,
      url: url,
      category: category,
      publishTime: publishTime,
    );
  }

  NewsModel copyWith({String? title}) {
    return NewsModel(
      title: title ?? this.title,
      url: url,
      category: category,
      publishTime: publishTime,
    );
  }
}

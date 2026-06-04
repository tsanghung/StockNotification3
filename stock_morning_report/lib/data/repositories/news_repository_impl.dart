import '../../domain/entities/news_item.dart';
import '../datasources/news_remote_datasource.dart';

class NewsRepositoryImpl {
  final NewsRemoteDatasource _datasource;

  NewsRepositoryImpl(this._datasource);

  Future<List<NewsItem>> fetchNews() => _datasource.fetchAllNews();
}

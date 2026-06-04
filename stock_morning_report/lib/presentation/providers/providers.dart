import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../data/datasources/news_remote_datasource.dart';
import '../../data/datasources/stock_remote_datasource.dart';
import '../../data/datasources/translate_datasource.dart';
import '../../data/repositories/news_repository_impl.dart';
import '../../data/repositories/stock_repository_impl.dart';
import '../../domain/entities/news_item.dart';
import '../../domain/entities/stock.dart';

// ─── Dio (HTTP client) ────────────────────────────────────────────────────────

/// 主 Dio：用於 Finnhub JSON API 及 RSS
final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
    receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
    headers: {
      'User-Agent':
          'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      'Accept': 'application/json, text/xml, */*',
    },
    responseType: ResponseType.json,
  ));
});

/// RSS 用 Dio（回傳 XML 純文字）
final rssDioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
    receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
    headers: {'User-Agent': 'Mozilla/5.0'},
    responseType: ResponseType.plain,
  ));
});

/// 翻譯用 Dio（接受 JSON 陣列回應）
final translateDioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
    receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
    headers: {'User-Agent': 'Mozilla/5.0'},
    responseType: ResponseType.json,
  ));
});

// ─── Datasources ──────────────────────────────────────────────────────────────

final translateDatasourceProvider = Provider<TranslateDatasource>((ref) {
  return TranslateDatasource(ref.watch(translateDioProvider));
});

final stockDatasourceProvider = Provider<StockRemoteDatasource>((ref) {
  return StockRemoteDatasource(ref.watch(dioProvider));
});

final newsDatasourceProvider = Provider<NewsRemoteDatasource>((ref) {
  return NewsRemoteDatasource(
    ref.watch(rssDioProvider),  // RSS 用 plain text Dio
    ref.watch(translateDatasourceProvider),
  );
});

// ─── Repositories ─────────────────────────────────────────────────────────────

final stockRepositoryProvider = Provider<StockRepositoryImpl>((ref) {
  return StockRepositoryImpl(ref.watch(stockDatasourceProvider));
});

final newsRepositoryProvider = Provider<NewsRepositoryImpl>((ref) {
  return NewsRepositoryImpl(ref.watch(newsDatasourceProvider));
});

// ─── Feature Providers ────────────────────────────────────────────────────────

/// 股票資料（非同步，啟動 APP 後自動觸發）
final stocksProvider = FutureProvider<List<Stock>>((ref) async {
  return ref.watch(stockRepositoryProvider).fetchStocks();
});

/// 新聞資料（非同步，啟動 APP 後自動觸發）
final newsProvider = FutureProvider<List<NewsItem>>((ref) async {
  return ref.watch(newsRepositoryProvider).fetchNews();
});

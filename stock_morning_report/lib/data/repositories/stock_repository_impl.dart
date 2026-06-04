import '../../domain/entities/stock.dart';
import '../datasources/stock_remote_datasource.dart';

class StockRepositoryImpl {
  final StockRemoteDatasource _datasource;

  StockRepositoryImpl(this._datasource);

  Future<List<Stock>> fetchStocks() => _datasource.fetchAllStocks();
}

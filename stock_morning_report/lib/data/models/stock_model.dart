import '../../domain/entities/stock.dart';

/// Yahoo Finance v7 /quote API 回應的反序列化模型
class StockModel {
  final String symbol;
  final double regularMarketPrice;
  final double regularMarketChange;
  final double regularMarketChangePercent;

  const StockModel({
    required this.symbol,
    required this.regularMarketPrice,
    required this.regularMarketChange,
    required this.regularMarketChangePercent,
  });

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      symbol: (json['symbol'] as String?) ?? '',
      regularMarketPrice: _toDouble(json['regularMarketPrice']),
      regularMarketChange: _toDouble(json['regularMarketChange']),
      regularMarketChangePercent: _toDouble(json['regularMarketChangePercent']),
    );
  }

  /// 轉換為 domain entity，帶入顯示名稱
  Stock toEntity(String displayName) {
    return Stock(
      symbol: symbol,
      name: displayName,
      price: regularMarketPrice,
      change: regularMarketChange,
      changePercent: regularMarketChangePercent,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}

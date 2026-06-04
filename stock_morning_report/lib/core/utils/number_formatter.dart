import 'package:intl/intl.dart';

class NumberFormatter {
  static final _priceFormatter = NumberFormat('#,##0.00');
  static final _largeFormatter = NumberFormat('#,##0.00');

  /// 格式化股價（含千分位）
  static String formatPrice(double price) {
    if (price >= 1000) {
      return NumberFormat('#,##0.00').format(price);
    }
    return _priceFormatter.format(price);
  }

  /// 格式化漲跌點數（加上正負號）
  static String formatChange(double change) {
    final sign = change >= 0 ? '+' : '';
    return '$sign${_largeFormatter.format(change)}';
  }

  /// 格式化漲跌幅（加上正負號與百分比）
  static String formatChangePercent(double percent) {
    final sign = percent >= 0 ? '+' : '';
    return '$sign${percent.toStringAsFixed(2)}%';
  }
}

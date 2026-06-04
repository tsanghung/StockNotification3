/// 股票資料實體
class Stock {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final double changePercent;

  const Stock({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.changePercent,
  });

  /// 台股慣例：正數為上漲（紅色）
  bool get isUp => change > 0;
  bool get isDown => change < 0;
  bool get isFlat => change == 0;
}

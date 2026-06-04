import 'package:flutter/material.dart';

import '../../domain/entities/stock.dart';
import 'stock_card.dart';

/// 股票卡片 2 欄格狀排列（對應 CSS grid-template-columns: repeat(auto-fit, minmax(180px, 1fr))）
class StockGrid extends StatelessWidget {
  final List<Stock> stocks;

  const StockGrid({super.key, required this.stocks});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
        ),
        itemCount: stocks.length,
        itemBuilder: (context, index) {
          return StockCard(stock: stocks[index]);
        },
      ),
    );
  }
}

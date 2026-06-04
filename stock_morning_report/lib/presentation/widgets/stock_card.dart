import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/number_formatter.dart';
import '../../domain/entities/stock.dart';

/// 個股卡片（對應 HTML 的 .card.stock-card）
class StockCard extends StatelessWidget {
  final Stock stock;

  const StockCard({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final changeColor = stock.isUp
        ? AppColors.priceUp
        : stock.isDown
            ? AppColors.priceDown
            : AppColors.priceFlat;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 股票代號
          Text(
            stock.symbol.replaceAll('^', '').replaceAll('=F', ''),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          // 股票名稱
          Text(
            stock.name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          // 股價
          Text(
            NumberFormatter.formatPrice(stock.price),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          // 漲跌點數 + 百分比
          Row(
            children: [
              Icon(
                stock.isUp
                    ? Icons.arrow_upward_rounded
                    : stock.isDown
                        ? Icons.arrow_downward_rounded
                        : Icons.remove_rounded,
                color: changeColor,
                size: 14,
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  '${NumberFormatter.formatChange(stock.change)}  '
                  '${NumberFormatter.formatChangePercent(stock.changePercent)}',
                  style: TextStyle(
                    color: changeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

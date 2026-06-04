import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../domain/entities/news_item.dart';
import '../../domain/entities/stock.dart';
import '../providers/providers.dart';
import '../widgets/error_banner.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/news_section.dart';
import '../widgets/stock_grid.dart';

/// 主畫面：啟動後自動查詢股市與新聞資料
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stocksAsync = ref.watch(stocksProvider);
    final newsAsync   = ref.watch(newsProvider);

    // 兩個 provider 皆在載入中 → 顯示骨架屏
    if (stocksAsync.isLoading && newsAsync.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(child: LoadingOverlay()),
      );
    }

    // 兩個 provider 皆失敗 → 顯示錯誤畫面
    if (stocksAsync.hasError && newsAsync.hasError) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: ErrorBanner(
            message: stocksAsync.error.toString(),
            onRetry: () {
              ref.invalidate(stocksProvider);
              ref.invalidate(newsProvider);
            },
          ),
        ),
      );
    }

    final stocks = stocksAsync.valueOrNull ?? [];
    final news   = newsAsync.valueOrNull   ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.cardBg,
          onRefresh: () async {
            ref.invalidate(stocksProvider);
            ref.invalidate(newsProvider);
            // 等待兩個 provider 完成
            await Future.wait([
              ref.read(stocksProvider.future).catchError((_) => <Stock>[]),
              ref.read(newsProvider.future).catchError((_) => <NewsItem>[]),
            ]);
          },
          child: CustomScrollView(
            slivers: [
              // ── App Bar ─────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _AppHeader(),
              ),

              // ── 股票區塊 ─────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: _buildSectionTitle('市場概覽'),
                ),
              ),
              SliverToBoxAdapter(
                child: stocksAsync.isLoading
                    ? _buildMiniLoading()
                    : stocksAsync.hasError
                        ? _buildSectionError('股市資料', () => ref.invalidate(stocksProvider))
                        : StockGrid(stocks: stocks),
              ),

              // ── 新聞區塊 ─────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: newsAsync.isLoading
                    ? _buildMiniLoading()
                    : newsAsync.hasError
                        ? _buildSectionError('新聞資料', () => ref.invalidate(newsProvider))
                        : Column(
                            children: [
                              NewsSection(
                                title: '盤勢重點回顧',
                                categories: const [
                                  NewsCategory.usMarketRecap,
                                  NewsCategory.twMarketPre,
                                ],
                                allNews: news,
                              ),
                              NewsSection(
                                title: '焦點新聞',
                                categories: const [
                                  NewsCategory.politicsEconomy,
                                  NewsCategory.aiTrends,
                                ],
                                allNews: news,
                              ),
                            ],
                          ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ShaderMask(
        shaderCallback: (bounds) =>
            AppColors.headerGradient.createShader(bounds),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMiniLoading() {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
    );
  }

  Widget _buildSectionError(String section, VoidCallback onRetry) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: AppColors.priceDown, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '無法取得$section，點擊重試',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              child: const Text('重試',
                  style: TextStyle(color: AppColors.accent)),
            ),
          ],
        ),
      ),
    );
  }
}

/// 頂部標題列
class _AppHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy年MM月dd日 EEEE', 'zh_TW').format(now);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.headerGradient.createShader(bounds),
            child: Text(
              '每日晨報',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateStr,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '下拉可重新整理',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

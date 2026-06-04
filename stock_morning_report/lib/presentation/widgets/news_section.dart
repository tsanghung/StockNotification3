import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../domain/entities/news_item.dart';
import 'news_item_tile.dart';

/// 新聞區塊，包含標題與子分類（對應 HTML 的 .section.news-section）
class NewsSection extends StatelessWidget {
  final String title;
  final List<NewsCategory> categories;
  final List<NewsItem> allNews;

  const NewsSection({
    super.key,
    required this.title,
    required this.categories,
    required this.allNews,
  });

  @override
  Widget build(BuildContext context) {
    // 從全部新聞中篩選此區塊的分類
    final sectionNews = allNews
        .where((n) => categories.contains(n.category))
        .toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 區塊標題
          _SectionHeader(title: title),
          const SizedBox(height: 12),

          // 各子分類
          ...categories.map((cat) {
            final catNews = sectionNews
                .where((n) => n.category == cat)
                .toList();
            return _CategoryBlock(category: cat, news: catNews);
          }),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ShaderMask(
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
      ],
    );
  }
}

class _CategoryBlock extends StatelessWidget {
  final NewsCategory category;
  final List<NewsItem> news;

  const _CategoryBlock({required this.category, required this.news});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 子分類標題
          Text(
            category.displayName,
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.cardBorder, height: 1),

          if (news.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                '目前無重大更新',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
            )
          else
            ...news.map((item) => Column(
                  children: [
                    NewsItemTile(item: item),
                    if (item != news.last)
                      const Divider(
                        color: AppColors.cardBorder,
                        height: 1,
                        indent: 15,
                      ),
                  ],
                )),
        ],
      ),
    );
  }
}

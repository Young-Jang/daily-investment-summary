import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../summary/models/summary_model.dart';

class SummaryCard extends StatelessWidget {
  final SummaryModel summary;

  const SummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sentimentColor = AppTheme.sentimentColor(summary.marketSentiment);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => context.push('/detail', extra: summary),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단: 카테고리 + 날짜
              Row(
                children: [
                  Text(
                    '${_categoryIcon(summary.category)} ${summary.categoryDisplayName}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    summary.summaryDate,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 제목
              Text(
                summary.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // 본문 미리보기
              Text(
                _stripMarkdown(summary.content),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Chip 영역: 시장감정 + 키워드
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  // 시장감정 Chip
                  Chip(
                    label: Text(
                      summary.marketSentimentDisplayName,
                      style: TextStyle(
                        color: sentimentColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: sentimentColor.withOpacity(0.1),
                    side: BorderSide(color: sentimentColor.withOpacity(0.4)),
                    visualDensity: VisualDensity.compact,
                  ),

                  // 키워드 Chip
                  ...summary.keywords.map(
                    (kw) => Chip(
                      label: Text(kw,
                          style: const TextStyle(fontSize: 11)),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _categoryIcon(String category) => switch (category) {
        'STOCK' => '📈',
        'COIN' => '🪙',
        'RESOURCE' => '🛢️',
        'REAL_ESTATE' => '🏠',
        _ => '📊',
      };

  /// 마크다운 기호 제거 (미리보기용)
  String _stripMarkdown(String markdown) {
    return markdown
        .replaceAll(RegExp(r'#{1,6}\s'), '')
        .replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'$1')
        .replaceAll(RegExp(r'\*(.+?)\*'), r'$1')
        .replaceAll(RegExp(r'^[-*]\s', multiLine: true), '')
        .replaceAll(RegExp(r'\n{2,}'), '\n')
        .trim();
  }
}

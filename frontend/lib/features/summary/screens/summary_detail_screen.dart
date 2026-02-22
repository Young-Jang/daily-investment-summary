import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../models/summary_model.dart';

class SummaryDetailScreen extends StatelessWidget {
  final SummaryModel summary;

  const SummaryDetailScreen({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sentimentColor = AppTheme.sentimentColor(summary.marketSentiment);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_categoryIcon(summary.category)} ${summary.categoryDisplayName}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더: 날짜 + 감정 뱃지
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 14, color: theme.colorScheme.outline),
                const SizedBox(width: 4),
                Text(
                  summary.summaryDate,
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: theme.colorScheme.outline),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: sentimentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: sentimentColor.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      Text(_sentimentIcon(summary.marketSentiment),
                          style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        summary.marketSentimentDisplayName,
                        style: TextStyle(
                          color: sentimentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 제목
            Text(
              summary.title,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),

            const Divider(height: 24),

            // Markdown 본문
            MarkdownBody(
              data: summary.content,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                h2: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
                h3: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
                p: theme.textTheme.bodyMedium?.copyWith(height: 1.7),
                listBullet: theme.textTheme.bodyMedium,
                blockSpacing: 12,
                listIndent: 20,
              ),
              onTapLink: (text, href, title) async {
                if (href != null) {
                  final uri = Uri.tryParse(href);
                  if (uri != null && await canLaunchUrl(uri)) {
                    launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                }
              },
            ),

            // 출처 URL 섹션
            if (summary.sourceUrls.isNotEmpty) ...[
              const Divider(height: 32),
              Text(
                '📎 출처',
                style: theme.textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...summary.sourceUrls.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: GestureDetector(
                        onTap: () async {
                          final uri = Uri.tryParse(e.value.trim());
                          if (uri != null && await canLaunchUrl(uri)) {
                            launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          }
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${e.key + 1}. ',
                                style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontSize: 13)),
                            Expanded(
                              child: Text(
                                e.value.trim(),
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontSize: 13,
                                  decoration: TextDecoration.underline,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            ],

            const SizedBox(height: 40),
          ],
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

  String _sentimentIcon(String sentiment) => switch (sentiment) {
        'POSITIVE' => '📈',
        'NEGATIVE' => '📉',
        _ => '➡️',
      };
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../summary/providers/summary_provider.dart';
import '../../summary/models/summary_model.dart';
import '../widgets/date_selector.dart';
import '../widgets/summary_card.dart';
import '../widgets/summary_shimmer.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final dateStr = formatDateParam(selectedDate);

    return DefaultTabController(
      length: AppConstants.categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            '일일 투자 정보 요약',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            // 새로고침
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: '새로고침',
              onPressed: () => ref.invalidate(summariesByDateProvider(dateStr)),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 48),
            child: Column(
              children: [
                // 날짜 선택기
                const DateSelector(),
                // 카테고리 탭
                TabBar(
                  isScrollable: false,
                  tabs: AppConstants.categories
                      .map((c) => Tab(text: '${c.icon} ${c.label}'))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: AppConstants.categories
              .map((c) => _CategoryTabContent(
                    dateStr: dateStr,
                    categoryKey: c.key,
                    categoryLabel: c.label,
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _CategoryTabContent extends ConsumerWidget {
  final String dateStr;
  final String categoryKey;
  final String categoryLabel;

  const _CategoryTabContent({
    required this.dateStr,
    required this.categoryKey,
    required this.categoryLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(
      summaryByCategoryProvider((date: dateStr, category: categoryKey)),
    );

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(summariesByDateProvider(dateStr));
      },
      child: summaryAsync.when(
        data: (summary) => summary != null
            ? _DataView(summary: summary)
            : _EmptyView(dateStr: dateStr, label: categoryLabel),
        loading: () => const SummaryShimmer(),
        error: (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(summariesByDateProvider(dateStr)),
        ),
      ),
    );
  }
}

class _DataView extends StatelessWidget {
  final SummaryModel summary;
  const _DataView({required this.summary});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 8),
        SummaryCard(summary: summary),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String dateStr;
  final String label;
  const _EmptyView({required this.dateStr, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined,
              size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            '$dateStr\n$label 요약 데이터가 없습니다.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text('데이터를 불러올 수 없습니다.',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}

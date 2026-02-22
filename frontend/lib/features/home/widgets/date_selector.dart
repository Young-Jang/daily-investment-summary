import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../summary/providers/summary_provider.dart';

class DateSelector extends ConsumerWidget {
  const DateSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 이전 날짜
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => ref.read(selectedDateProvider.notifier).state =
                selectedDate.subtract(const Duration(days: 1)),
          ),

          // 날짜 표시 (탭하면 DatePicker)
          GestureDetector(
            onTap: () => _pickDate(context, ref, selectedDate),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 16, color: colorScheme.onPrimaryContainer),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(selectedDate),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 다음 날짜 (오늘 이후 불가)
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _isToday(selectedDate)
                ? null
                : () =>
                    ref.read(selectedDateProvider.notifier).state =
                        selectedDate.add(const Duration(days: 1)),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Future<void> _pickDate(
      BuildContext context, WidgetRef ref, DateTime current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      locale: const Locale('ko', 'KR'),
    );
    if (picked != null) {
      ref.read(selectedDateProvider.notifier).state = picked;
    }
  }
}

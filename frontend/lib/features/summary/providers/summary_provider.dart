import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/app_constants.dart';
import '../models/summary_model.dart';

// 현재 선택된 날짜 상태
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// 날짜별 요약 목록 (캐싱 포함)
final summariesByDateProvider =
    FutureProvider.family<List<SummaryModel>, String>((ref, dateStr) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.get<List<dynamic>>(
    AppConstants.summariesEndpoint,
    params: {'date': dateStr},
  );
  final list = response.data ?? [];
  return list
      .map((e) => SummaryModel.fromJson(e as Map<String, dynamic>))
      .toList();
});

// 특정 날짜 + 카테고리 필터
final summaryByCategoryProvider =
    Provider.family<AsyncValue<SummaryModel?>, ({String date, String category})>(
        (ref, args) {
  final summariesAsync = ref.watch(summariesByDateProvider(args.date));
  return summariesAsync.whenData(
    (list) => list.where((s) => s.category == args.category).firstOrNull,
  );
});

// 날짜 포맷 헬퍼
String formatDateParam(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
String formatDateDisplay(DateTime date) =>
    DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(date);

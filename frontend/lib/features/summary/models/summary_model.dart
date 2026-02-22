class SummaryModel {
  final int id;
  final String category;
  final String categoryDisplayName;
  final String summaryDate;
  final String title;
  final String content;
  final String? sourceUrl;
  final String marketSentiment;
  final String marketSentimentDisplayName;
  final String createdAt;

  const SummaryModel({
    required this.id,
    required this.category,
    required this.categoryDisplayName,
    required this.summaryDate,
    required this.title,
    required this.content,
    this.sourceUrl,
    required this.marketSentiment,
    required this.marketSentimentDisplayName,
    required this.createdAt,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) => SummaryModel(
        id: json['id'] as int,
        category: json['category'] as String,
        categoryDisplayName: json['categoryDisplayName'] as String,
        summaryDate: json['summaryDate'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        sourceUrl: json['sourceUrl'] as String?,
        marketSentiment: json['marketSentiment'] as String,
        marketSentimentDisplayName: json['marketSentimentDisplayName'] as String,
        createdAt: json['createdAt'] as String,
      );

  /// 마크다운 본문에서 bullet point 키워드 추출 (Chip용)
  List<String> get keywords {
    final regex = RegExp(r'^[-*]\s+(.{2,15}?)(?:[：:。\n]|$)', multiLine: true);
    return regex
        .allMatches(content)
        .map((m) => m.group(1)?.trim() ?? '')
        .where((s) => s.isNotEmpty)
        .take(4)
        .toList();
  }

  /// 출처 URL 목록 (줄바꿈으로 구분된 문자열 → 리스트)
  List<String> get sourceUrls =>
      sourceUrl?.split('\n').where((s) => s.trim().isNotEmpty).toList() ?? [];
}

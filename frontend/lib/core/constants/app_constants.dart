class AppConstants {
  AppConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const String summariesEndpoint = '/api/v1/summaries';

  static const List<CategoryInfo> categories = [
    CategoryInfo(key: 'STOCK',       label: '주식',  icon: '📈'),
    CategoryInfo(key: 'COIN',        label: '코인',  icon: '🪙'),
    CategoryInfo(key: 'RESOURCE',    label: '자원',  icon: '🛢️'),
    CategoryInfo(key: 'REAL_ESTATE', label: '부동산', icon: '🏠'),
  ];
}

class CategoryInfo {
  final String key;
  final String label;
  final String icon;
  const CategoryInfo({required this.key, required this.label, required this.icon});
}

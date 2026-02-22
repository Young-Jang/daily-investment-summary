import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'features/home/screens/home_screen.dart';
import 'features/summary/models/summary_model.dart';
import 'features/summary/screens/summary_detail_screen.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/detail',
      builder: (context, state) {
        final summary = state.extra as SummaryModel;
        return SummaryDetailScreen(summary: summary);
      },
    ),
  ],
);

class InvestmentSummaryApp extends ConsumerWidget {
  const InvestmentSummaryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: '일일 투자 정보 요약',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      locale: const Locale('ko', 'KR'),
      supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
      localizationsDelegates: const [
        // flutter_localizations 패키지 추가 시 활성화
        // GlobalMaterialLocalizations.delegate,
        // GlobalWidgetsLocalizations.delegate,
        // GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}

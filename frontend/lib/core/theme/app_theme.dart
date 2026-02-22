import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const _primaryColor = Color(0xFF1A56DB);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryColor,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        tabBarTheme: const TabBarTheme(
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: TextStyle(fontSize: 14),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryColor,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
        tabBarTheme: const TabBarTheme(
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: TextStyle(fontSize: 14),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

  // 시장 감정 색상
  static Color sentimentColor(String sentiment) => switch (sentiment) {
        'POSITIVE' => const Color(0xFF16A34A),
        'NEGATIVE' => const Color(0xFFDC2626),
        _ => const Color(0xFF6B7280),
      };
}

import 'package:flutter/material.dart';

enum AppThemeMode { light, dark, pink }

class AppTheme {
  AppTheme._();

  // ── Light ──
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepOrange,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFFAF8F5),
      cardTheme: CardTheme(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // ── Dark ──
  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepOrange,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      cardTheme: CardTheme(
        elevation: 0,
        color: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // ── Pink ──
  static ThemeData get pinkTheme {
    const pink = Color(0xFFE91E63);
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: pink,
        brightness: Brightness.light,
        primary: pink,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFFFF0F3),
      cardTheme: CardTheme(
        elevation: 0,
        color: const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static ThemeData getTheme(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return lightTheme;
      case AppThemeMode.dark:
        return darkTheme;
      case AppThemeMode.pink:
        return pinkTheme;
    }
  }
}

import 'package:flutter/material.dart';

class AppTheme {
  static const background = Color(0xFF070B0A);
  static const surface = Color(0xFF111815);
  static const surface2 = Color(0xFF19221D);
  static const border = Color(0xFF2B3931);
  static const primary = Color(0xFFE8D99B);
  static const accent = Color(0xFF8EC9A7);
  static const blue = Color(0xFF8EC9A7);
  static const text = Color(0xFFF4F1E6);
  static const muted = Color(0xFFA1ADA4);

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: primary,
      onPrimary: const Color(0xFF15160F),
      secondary: accent,
      onSecondary: const Color(0xFF0D1711),
      tertiary: const Color(0xFFC7BA83),
      onTertiary: const Color(0xFF17150D),
      surface: surface,
      onSurface: text,
      outline: border,
      outlineVariant: border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      fontFamily: 'SF Pro Display',
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        surfaceTintColor: Colors.transparent,
      ),
      iconTheme: const IconThemeData(color: accent),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: background,
        indicatorColor: accent.withValues(alpha: 0.18),
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 11, color: text),
        ),
      ),
      cardTheme: const CardThemeData(
        color: surface,
        margin: EdgeInsets.zero,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: surface2,
      ),
    );
  }
}

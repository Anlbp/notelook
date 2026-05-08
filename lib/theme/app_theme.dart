import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.dark,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surfaceContainerHighest,
        foregroundColor: scheme.onSurface,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerHigh,
        elevation: 1,
      ),
    );
  }
}

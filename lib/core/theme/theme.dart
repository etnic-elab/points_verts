import 'package:dynamic_color/dynamic_color.dart' show ColorSchemeHarmonization;
import 'package:flutter/material.dart';

class AppTheme {
  //TODO(msimonart): Change to appropriate color
  static const _primaryColor = Color(0xFF3A97C9);

  static ColorScheme get lightColorScheme {
    return ColorScheme.fromSeed(
      seedColor: _primaryColor,
    );
  }

  static ColorScheme get darkColorScheme {
    return ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.dark,
    );
  }

  static ThemeData _createThemeData(ColorScheme colorScheme) {
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData light(ColorScheme? dynamicColorScheme) {
    final colorScheme = dynamicColorScheme?.harmonized() ?? lightColorScheme;
    return _createThemeData(colorScheme);
  }

  static ThemeData dark(ColorScheme? dynamicColorScheme) {
    final colorScheme = dynamicColorScheme?.harmonized() ?? darkColorScheme;
    return _createThemeData(colorScheme);
  }
}

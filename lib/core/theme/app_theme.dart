import 'package:flutter/material.dart';

import 'ningyou_colors.dart';
import 'ningyou_radius.dart';
import 'ningyou_text_styles.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    return _build(NingyouColors.light.palette);
  }

  static ThemeData get dark {
    return _build(NingyouColors.dark.palette);
  }

  static ThemeData _build(NingyouPalette palette) {
    final textTheme = NingyouTextStyles.textTheme(
      palette.text,
      palette.textMuted,
      palette.textSubtle,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: palette.brightness,
      colorScheme: palette.scheme,
      scaffoldBackgroundColor: palette.background,
      textTheme: textTheme,
      extensions: [NingyouColors(palette: palette)],
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: palette.background,
        foregroundColor: palette.text,
        titleTextStyle: textTheme.titleMedium,
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NingyouRadius.xl),
          side: BorderSide(color: palette.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.accent,
          foregroundColor: palette.onAccent,
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        hintStyle: textTheme.bodyMedium?.copyWith(color: palette.textSubtle),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NingyouRadius.lg),
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NingyouRadius.lg),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NingyouRadius.lg),
          borderSide: BorderSide(color: palette.accent, width: 1.4),
        ),
      ),
    );
  }
}

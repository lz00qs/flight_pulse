import 'package:flutter/material.dart';

class AppColors {
  // Light Palette
  static const Color primary = Color(0xFF2876E2);
  static const Color onPrimary = Colors.white;

  static const Color backgroundLight = Color(0xFFF6F8FB);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceSecondaryLight = Color(0xFFEDF1F6);
  static const Color borderLight = Color(0xFFDDE3EA);

  static const Color textPrimaryLight = Color(0xFF172331);
  static const Color textSecondaryLight = Color(0xFF637184);
  static const Color textTertiaryLight = Color(0xFF8B98A9);

  // Dark Palette
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceSecondaryDark = Color(0xFF334155);
  static const Color borderDark = Color(0xFF334155);

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF64748B);

  // Status colors
  static const Color success = Color(0xFF168565);
  static const Color priceDown = Color(0xFF168565);
  static const Color priceUp = Color(0xFFD97706);
  static const Color error = Color(0xFFB94649);
}

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        surface: AppColors.surfaceLight,
        outline: AppColors.borderLight,
        error: AppColors.error,
      ),
      fontFamily: 'Inter',
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.borderLight),
        ),
      ),
      dividerColor: AppColors.borderLight,
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        surface: AppColors.surfaceDark,
        outline: AppColors.borderDark,
        error: AppColors.error,
      ),
      fontFamily: 'Inter',
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.borderDark),
        ),
      ),
      dividerColor: AppColors.borderDark,
    );
  }
}

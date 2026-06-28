import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData lightForLocale(Locale locale) {
    final isAr = locale.languageCode == 'ar';
    final textTheme =
        isAr ? GoogleFonts.cairoTextTheme() : GoogleFonts.poppinsTextTheme();
    return light.copyWith(textTheme: textTheme);
  }

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: AppColors.white,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      );
}

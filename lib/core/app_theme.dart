import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_constants.dart';

/// CookSnap Theme Configuration
/// Material 3 based theme with custom component styles
class AppTheme {
  AppTheme._();

  static TextTheme _buildTighterTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(letterSpacing: -2.0, height: 0.95, fontWeight: FontWeight.w900),
      displayMedium: base.displayMedium?.copyWith(letterSpacing: -1.6, height: 0.95, fontWeight: FontWeight.w900),
      displaySmall: base.displaySmall?.copyWith(letterSpacing: -1.2, height: 1.0, fontWeight: FontWeight.w800),
      headlineLarge: base.headlineLarge?.copyWith(letterSpacing: -1.2, height: 1.0, fontWeight: FontWeight.w800),
      headlineMedium: base.headlineMedium?.copyWith(letterSpacing: -1.0, height: 1.0, fontWeight: FontWeight.w800),
      headlineSmall: base.headlineSmall?.copyWith(letterSpacing: -0.8, height: 1.05, fontWeight: FontWeight.w700),
      titleLarge: base.titleLarge?.copyWith(letterSpacing: -0.8, height: 1.05, fontWeight: FontWeight.w700),
      titleMedium: base.titleMedium?.copyWith(letterSpacing: -0.6, height: 1.05, fontWeight: FontWeight.w700),
      titleSmall: base.titleSmall?.copyWith(letterSpacing: -0.5, height: 1.1, fontWeight: FontWeight.w600),
      bodyLarge: base.bodyLarge?.copyWith(letterSpacing: -0.5, height: 1.15),
      bodyMedium: base.bodyMedium?.copyWith(letterSpacing: -0.4, height: 1.15),
      bodySmall: base.bodySmall?.copyWith(letterSpacing: -0.3, height: 1.15),
      labelLarge: base.labelLarge?.copyWith(letterSpacing: -0.5, fontWeight: FontWeight.w700),
      labelMedium: base.labelMedium?.copyWith(letterSpacing: -0.4, fontWeight: FontWeight.w600),
      labelSmall: base.labelSmall?.copyWith(letterSpacing: -0.3, fontWeight: FontWeight.w500),
    );
  }

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.workSansTextTheme(ThemeData.light().textTheme);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.workSans().fontFamily,
      textTheme: _buildTighterTextTheme(baseTextTheme),
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.textOnPrimary,
        tertiary: AppColors.accent,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: AppColors.textOnPrimary,
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          minimumSize: const Size(double.infinity, AppConstants.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.6,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize: const Size(double.infinity, AppConstants.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.6,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMd,
          vertical: AppConstants.spacingMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: const TextStyle(
          color: AppColors.textHint,
          fontSize: 14,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
        surfaceTintColor: Colors.transparent,
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
    );
  }
}

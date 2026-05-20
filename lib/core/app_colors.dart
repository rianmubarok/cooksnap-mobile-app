import 'package:flutter/material.dart';

/// CookSnap color palette
/// Warm, food-inspired colors with orange as primary
class AppColors {
  AppColors._();

  // Primary - Warm Orange
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFF8F5E);
  static const Color primaryDark = Color(0xFFE55A2B);

  // Secondary - Deep Green (fresh/organic feel)
  static const Color secondary = Color(0xFF2D6A4F);
  static const Color secondaryLight = Color(0xFF40916C);
  static const Color secondaryDark = Color(0xFF1B4332);

  // Accent - Golden Yellow
  static const Color accent = Color(0xFFFFC300);
  static const Color accentLight = Color(0xFFFFD60A);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textHint = Color(0xFFADB5BD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF06D6A0);
  static const Color warning = Color(0xFFFFB703);
  static const Color error = Color(0xFFEF476F);
  static const Color info = Color(0xFF118AB2);

  // Borders & Dividers
  static const Color border = Color(0xFFE9ECEF);
  static const Color divider = Color(0xFFDEE2E6);

  // Shadows
  static const Color shadow = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFFFF8F5E)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFF6B35), Color(0xFFFF8F5E), Color(0xFFFFC300)],
  );

  static const LinearGradient onboardingGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF3E0), Color(0xFFFFFFFF)],
  );
}

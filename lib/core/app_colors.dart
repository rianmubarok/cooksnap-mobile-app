import 'package:flutter/material.dart';

/// CookSnap color palette
/// Warm, food-inspired colors with orange as primary
class AppColors {
  AppColors._();

  // Primary - Forest Green (organic & premium)
  static const Color primary = Color(0xFF143B16);
  static const Color primaryLight = Color(0xFF2E6331);
  static const Color primaryDark = Color(0xFF0A220B);

  // Secondary - Lime Green (fresh contrast)
  static const Color secondary = Color(0xFFA7EE6A);
  static const Color secondaryLight = Color(0xFFC3FA89);
  static const Color secondaryDark = Color(0xFF7CAF4C);

  // Accent - Custom Highlight
  static const Color accent = Color(0xFFA7EE6A);
  static const Color accentLight = Color(0xFFC3FA89);

  // Neutrals
  static const Color white = Color(0xFFFFFAF5);
  static const Color background = Color(0xFFFFFAF5);
  static const Color surface = Color(0xFFFFFAF5);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF555555);
  static const Color textHint = Color(0xFF888888);
  static const Color textOnPrimary = Color(0xFFFFFAF5);

  // Status
  static const Color success = Color(0xFF2EC4B6);
  static const Color warning = Color(0xFFFF9F1C);
  static const Color error = Color(0xFFE71D36);
  static const Color info = Color(0xFF011627);

  // Borders & Dividers
  static const Color border = Color(0xFFE2DDD9);
  static const Color divider = Color(0xFFECE7E2);

  // Shadows
  static const Color shadow = Colors.transparent;
  static const Color shadowDark = Colors.transparent;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF2E6331)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, primaryDark],
  );

  static const LinearGradient onboardingGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF7F5F0), Color(0xFFFFFAF5)],
  );
}

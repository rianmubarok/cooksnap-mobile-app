/// CookSnap Design Constants
/// Spacing, radius, sizing, and animation durations
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'CookSnap';
  static const String appTagline = 'Foto, Masak, Nikmati!';
  static const String appVersion = '1.0.0';

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Padding
  static const double paddingScreen = 20.0;
  static const double paddingCard = 16.0;

  // Border Radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusRound = 100.0;

  // Icon Size
  static const double iconSm = 18.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // Button Height
  static const double buttonHeight = 52.0;
  static const double buttonHeightSmall = 40.0;
  
  // Element Sizing
  static const double chipHeight = 36.0;
  static const double searchBarHeight = 60.0;
  static const double recipeImageHeight = 350.0;

  // Animation Durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Duration splashDuration = Duration(seconds: 3);

  // Elevation
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
}

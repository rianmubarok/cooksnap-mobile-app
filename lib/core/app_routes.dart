import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/scanner/scanner_screen.dart';
import '../screens/recipe/recipe_detail_screen.dart';
import '../screens/favorite/favorite_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/recipe_recommendation_screen.dart';

/// App Route Names
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String scanner = '/scanner';
  static const String recipeDetail = '/recipe-detail';
  static const String favorite = '/favorite';
  static const String profile = '/profile';
  static const String recipeRecommendation = '/recipe-recommendation';

  /// Route map for MaterialApp
  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        onboarding: (context) => const OnboardingScreen(),
        login: (context) => const LoginScreen(),
        register: (context) => const RegisterScreen(),
        home: (context) => const HomeScreen(),
        scanner: (context) => const ScannerScreen(),
        recipeDetail: (context) => const RecipeDetailScreen(),
        favorite: (context) => const FavoriteScreen(),
        profile: (context) => const ProfileScreen(),
      };
}

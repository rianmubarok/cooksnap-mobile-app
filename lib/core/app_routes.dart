import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/shell/main_shell_screen.dart';
import '../screens/scanner/scanner_screen.dart';
import '../screens/recipe/recipe_detail_screen.dart';
import '../screens/recipe/recipe_recommendation_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/search/search_result_screen.dart';

/// App route names and MaterialApp route map.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String scanner = '/scanner';
  static const String recipeDetail = '/recipe-detail';
  static const String recipeRecommendation = '/recipe-recommendation';
  static const String search = '/search';
  static const String searchResult = '/search-result';

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        onboarding: (context) => const OnboardingScreen(),
        login: (context) => const LoginScreen(),
        register: (context) => const RegisterScreen(),
        home: (context) => const MainShellScreen(),
        scanner: (context) => const ScannerScreen(),
        recipeDetail: (context) => const RecipeDetailScreen(),
        recipeRecommendation: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final ingredients = args is List<String> ? args : <String>[];
          return RecipeRecommendationScreen(ingredients: ingredients);
        },
        search: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final query = args is String ? args : '';
          return SearchScreen(initialQuery: query);
        },
        searchResult: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final query = args is String ? args : '';
          return SearchResultScreen(query: query);
        },
      };
}

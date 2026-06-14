import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/verify_email_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/help_screen.dart';
import '../screens/profile/about_screen.dart';
import '../screens/shell/main_shell_screen.dart';
import '../screens/scanner/scanner_screen.dart';
import '../screens/recipe/recipe_detail_screen.dart';
import '../screens/recipe/recipe_recommendation_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/search/search_result_screen.dart';
import '../screens/recipe/popular_recipes_screen.dart';
import '../models/recipe_model.dart';

/// App route names and MaterialApp route map.
class AppRoutes {
  AppRoutes._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verifyEmail = '/verify-email';
  static const String editProfile = '/edit-profile';
  static const String help = '/help';
  static const String about = '/about';
  static const String home = '/home';
  static const String scanner = '/scanner';
  static const String recipeDetail = '/recipe-detail';
  static const String recipeRecommendation = '/recipe-recommendation';
  static const String search = '/search';
  static const String searchResult = '/search-result';
  static const String popularRecipes = '/popular-recipes';

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        onboarding: (context) => const OnboardingScreen(),
        login: (context) => const LoginScreen(),
        register: (context) => const RegisterScreen(),
        forgotPassword: (context) => const ForgotPasswordScreen(),
        verifyEmail: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final email = args is String ? args : '';
          return VerifyEmailScreen(email: email);
        },
        editProfile: (context) => const EditProfileScreen(),
        help: (context) => const HelpScreen(),
        about: (context) => const AboutScreen(),
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
        popularRecipes: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final recipes = args is List<Recipe> ? args : <Recipe>[];
          return PopularRecipesScreen(recipes: recipes);
        },
      };
}

import 'package:flutter/material.dart';
import '../core/app_routes.dart';

extension RecipeNavigation on BuildContext {
  void openRecipeDetail(String recipeId) {
    Navigator.pushNamed(this, AppRoutes.recipeDetail, arguments: recipeId);
  }
}

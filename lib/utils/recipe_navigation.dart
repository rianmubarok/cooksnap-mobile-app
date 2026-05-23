import 'package:flutter/material.dart';
import '../core/app_routes.dart';

extension RecipeNavigation on BuildContext {
  void openRecipeDetail(String recipeId, [List<String>? availableIngredients]) {
    Navigator.pushNamed(
      this, 
      AppRoutes.recipeDetail, 
      arguments: {
        'id': recipeId,
        'availableIngredients': availableIngredients,
      },
    );
  }
}

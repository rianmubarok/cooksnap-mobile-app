import 'package:flutter/foundation.dart';
import '../data/repositories/recipe_repository.dart';
import '../models/recipe_model.dart';

/// Manages favorite recipe IDs — sync with PocketBase later.
class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider(this._recipeRepository);

  final RecipeRepository _recipeRepository;
  final List<String> _favoriteRecipeIds = [];

  List<String> get favoriteRecipeIds => List.unmodifiable(_favoriteRecipeIds);

  List<Recipe> get favoriteRecipes {
    return _favoriteRecipeIds
        .map(_recipeRepository.getRecipeById)
        .whereType<Recipe>()
        .toList();
  }

  bool isFavorite(String recipeId) => _favoriteRecipeIds.contains(recipeId);

  void toggleFavorite(String recipeId) {
    if (_favoriteRecipeIds.contains(recipeId)) {
      _favoriteRecipeIds.remove(recipeId);
    } else {
      _favoriteRecipeIds.add(recipeId);
    }
    notifyListeners();
  }

  int get favoriteCount => _favoriteRecipeIds.length;
}

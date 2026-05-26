import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/recipe_repository.dart';
import '../models/recipe_model.dart';

/// Manages favorite recipe IDs — sync with PocketBase later.
class FavoritesProvider extends ChangeNotifier {
  static const String _prefsKey = 'favorite_recipe_ids';

  FavoritesProvider(this._recipeRepository) {
    _loadFavorites();
  }

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
    _saveFavorites();
    notifyListeners();
  }

  int get favoriteCount => _favoriteRecipeIds.length;

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_prefsKey);
    if (saved != null) {
      _favoriteRecipeIds
        ..clear()
        ..addAll(saved);
      notifyListeners();
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _favoriteRecipeIds);
  }
}

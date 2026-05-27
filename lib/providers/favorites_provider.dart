import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repositories/recipe_repository.dart';
import '../models/recipe_model.dart';

/// Manages favorite recipe state.
///
/// Favorite **IDs** are persisted locally (SharedPreferences).
/// The corresponding [Recipe] objects are loaded asynchronously from
/// the repository via [getRecipesByIds] — a single batch call that maps
/// cleanly to a PocketBase `?filter=id="a"||id="b"` query.
class FavoritesProvider extends ChangeNotifier {
  static const String _idsKey = 'favorite_recipe_ids';

  FavoritesProvider(this._repo) {
    _loadFromPrefs();
  }

  final RecipeRepository _repo;

  final List<String> _favoriteRecipeIds = [];
  List<Recipe> _favoriteRecipes = [];
  bool _isLoading = false;

  List<String> get favoriteRecipeIds => List.unmodifiable(_favoriteRecipeIds);
  List<Recipe> get favoriteRecipes => _favoriteRecipes;
  bool get isLoading => _isLoading;
  int get favoriteCount => _favoriteRecipeIds.length;

  bool isFavorite(String recipeId) => _favoriteRecipeIds.contains(recipeId);

  // ── Internal helpers ─────────────────────────────────────────────────────

  Future<void> _loadFromPrefs() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_idsKey);
    if (saved != null) {
      _favoriteRecipeIds
        ..clear()
        ..addAll(saved);
    }

    await _reloadRecipes();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _reloadRecipes() async {
    if (_favoriteRecipeIds.isEmpty) {
      _favoriteRecipes = [];
      return;
    }
    // Single batch call — in PocketBase this becomes one API request.
    _favoriteRecipes = await _repo.getRecipesByIds(_favoriteRecipeIds);
  }

  Future<void> _saveIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_idsKey, _favoriteRecipeIds);
  }

  // ── Public API ────────────────────────────────────────────────────────────

  Future<void> toggleFavorite(String recipeId) async {
    if (_favoriteRecipeIds.contains(recipeId)) {
      _favoriteRecipeIds.remove(recipeId);
    } else {
      _favoriteRecipeIds.add(recipeId);
    }

    // Persist IDs immediately, then reload recipe objects.
    await _saveIds();
    await _reloadRecipes();
    notifyListeners();
  }
}

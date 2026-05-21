import 'package:flutter/foundation.dart';

/// FavoritesProvider — Manages favorite recipe state
/// TODO Genard: Connect to PocketBase favorites collection
class FavoritesProvider extends ChangeNotifier {
  final List<String> _favoriteRecipeIds = [];

  List<String> get favoriteRecipeIds => List.unmodifiable(_favoriteRecipeIds);

  // Dummy list to support the UI for now
  List<Map<String, dynamic>> get favorites => _favoriteRecipeIds.isEmpty
      ? []
      : [
          {
            'id': '1',
            'name': 'Nasi Goreng Special',
            'cookingTime': '20 min',
            'difficulty': 'Easy',
            'emoji': '🍚',
          },
        ];

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

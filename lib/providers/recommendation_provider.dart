import 'package:flutter/foundation.dart';

import '../data/repositories/recipe_repository.dart';
import '../domain/usecases/get_recipe_recommendations.dart';
import '../services/recipe_recommendation_service.dart';

/// Manages the state of the recipe recommendation screen.
///
/// [RecipeRepository] is injected at construction time — no more passing
/// `repo` on every [setInputs] call, which simplifies the UI code.
class RecommendationProvider extends ChangeNotifier {
  RecommendationProvider(RecipeRepository repo)
      : _usecase = GetRecipeRecommendations(repo);

  final GetRecipeRecommendations _usecase;

  RecommendationViewData? _data;
  RecommendationViewData? get data => _data;

  bool _isComputing = false;
  bool get isComputing => _isComputing;

  bool _hasError = false;
  bool get hasError => _hasError;

  List<String> _lastIngredients = const [];
  List<String> _lastPantryItems = const [];

  /// Monotonically increasing token to detect stale results when
  /// [setInputs] is called multiple times in quick succession.
  int _computationVersion = 0;

  /// Triggers a new recommendation computation.
  ///
  /// - Skips if inputs haven't changed since the last call.
  /// - Sets [isComputing] to `true` immediately (triggers loading UI).
  /// - Heavy work runs off-thread inside the repository's isolate.
  /// - Stale results (from a superseded computation) are discarded.
  Future<void> setInputs({
    required List<String> currentIngredients,
    required List<String> pantryItems,
  }) async {
    if (listEquals(_lastIngredients, currentIngredients) &&
        listEquals(_lastPantryItems, pantryItems)) {
      return;
    }

    _lastIngredients = List.unmodifiable(currentIngredients);
    _lastPantryItems = List.unmodifiable(pantryItems);

    // Claim this computation slot; any previous async call that resolves
    // later will see a different version number and discard its result.
    final myVersion = ++_computationVersion;

    _isComputing = true;
    _hasError = false;
    notifyListeners();

    try {
      final result = await _usecase.call(
        currentIngredients: currentIngredients,
        pantryItems: pantryItems,
      );

      if (myVersion != _computationVersion) return; // superseded — discard

      _data = result;
    } catch (_) {
      // Network error — expose to UI for retry
      if (myVersion == _computationVersion) _hasError = true;
    } finally {
      if (myVersion == _computationVersion) {
        _isComputing = false;
        notifyListeners();
      }
    }
  }

  void reset() {
    _computationVersion++; // invalidate any in-flight computation
    _data = null;
    _isComputing = false;
    _hasError = false;
    _lastIngredients = const [];
    _lastPantryItems = const [];
    notifyListeners();
  }
}

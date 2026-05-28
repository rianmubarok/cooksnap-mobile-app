import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/pocketbase_client.dart';
import '../data/repositories/recipe_repository.dart';
import '../models/recipe_model.dart';

/// Manages favorite recipe state, backed by the PocketBase `favorites`
/// collection.
///
/// Favorites are stored as records `{ user_id, recipe_id }` in PocketBase,
/// so they are **synced across devices** whenever the user logs in.
///
/// ## Optimistic UI
/// [toggleFavorite] updates local state immediately before the network call
/// completes, so the heart icon flips instantly. If the network call fails,
/// the state is rolled back and an error is rethrown.
class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider(this._repo) {
    // Listen to PocketBase auth changes to auto-load / clear favorites.
    _authSubscription = PocketBaseClient.instance.authStore.onChange.listen(
      (_) => _onAuthChanged(),
    );
    _onAuthChanged();
  }

  final RecipeRepository _repo;

  /// Map of `recipeId → favoriteRecordId` (PB record ID needed for deletion).
  final Map<String, String> _favoriteRecordMap = {};

  /// Fully-loaded Recipe objects for the favorites list screen.
  List<Recipe> _favoriteRecipes = [];
  bool _isLoading = false;

  // Auth listener cleanup
  // ignore: cancel_subscriptions
  late final StreamSubscription<dynamic> _authSubscription;

  // ── Public getters ────────────────────────────────────────────────────────

  List<String> get favoriteRecipeIds =>
      List.unmodifiable(_favoriteRecordMap.keys);
  List<Recipe> get favoriteRecipes => _favoriteRecipes;
  bool get isLoading => _isLoading;
  int get favoriteCount => _favoriteRecordMap.length;

  bool isFavorite(String recipeId) => _favoriteRecordMap.containsKey(recipeId);

  // ── Auth lifecycle ────────────────────────────────────────────────────────

  void _onAuthChanged() {
    final pb = PocketBaseClient.instance;
    if (pb.authStore.isValid && pb.authStore.record != null) {
      final userId = pb.authStore.record!.id;
      _loadFromPocketBase(userId);
    } else {
      _clearState();
    }
  }

  void _clearState() {
    _favoriteRecordMap.clear();
    _favoriteRecipes = [];
    _isLoading = false;
    notifyListeners();
  }

  // ── Internal helpers ──────────────────────────────────────────────────────

  Future<void> _loadFromPocketBase(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _favoriteRecordMap
        ..clear()
        ..addAll(await _repo.getFavoriteRecords(userId));

      await _reloadRecipes();
    } catch (e) {
      debugPrint('FavoritesProvider: failed to load favorites: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _reloadRecipes() async {
    if (_favoriteRecordMap.isEmpty) {
      _favoriteRecipes = [];
      return;
    }
    // Single batch call — maps to one PocketBase API request.
    _favoriteRecipes = await _repo.getRecipesByIds(
      _favoriteRecordMap.keys.toList(),
    );
  }

  // ── Public API ────────────────────────────────────────────────────────────

  Future<void> toggleFavorite(String recipeId) async {
    final pb = PocketBaseClient.instance;
    if (!pb.authStore.isValid || pb.authStore.record == null) return;

    final userId = pb.authStore.record!.id;

    if (isFavorite(recipeId)) {
      // ── Remove favorite ──────────────────────────────────────────────────
      final favoriteRecordId = _favoriteRecordMap[recipeId]!;

      // Optimistic update
      _favoriteRecordMap.remove(recipeId);
      _favoriteRecipes.removeWhere((r) => r.id == recipeId);
      notifyListeners();

      try {
        await _repo.removeFavorite(favoriteRecordId);
      } catch (e) {
        // Roll back on error
        debugPrint('FavoritesProvider: failed to remove favorite: $e');
        await _loadFromPocketBase(userId);
        rethrow;
      }
    } else {
      // ── Add favorite ─────────────────────────────────────────────────────
      // Optimistic placeholder — we don't have the PB record ID yet,
      // so use a temporary key that will be replaced after the API call.
      _favoriteRecordMap[recipeId] = '__pending__';
      notifyListeners();

      try {
        final pbRecordId = await _repo.addFavorite(userId, recipeId);
        _favoriteRecordMap[recipeId] = pbRecordId;
        await _reloadRecipes();
        notifyListeners();
      } catch (e) {
        // Roll back on error
        debugPrint('FavoritesProvider: failed to add favorite: $e');
        _favoriteRecordMap.remove(recipeId);
        notifyListeners();
        rethrow;
      }
    }
  }

  /// Force-reload favorites from PocketBase (e.g., after pull-to-refresh).
  Future<void> refresh() async {
    final pb = PocketBaseClient.instance;
    if (!pb.authStore.isValid || pb.authStore.record == null) return;
    await _loadFromPocketBase(pb.authStore.record!.id);
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}

import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../models/recipe_model.dart';
import '../../utils/string_utils.dart';
import '../dummy/dummy_recipe_source.dart';
import 'recipe_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Top-level helpers for compute() — must be top-level (not closures/methods)
// so Flutter can spawn them in a background isolate.
// ─────────────────────────────────────────────────────────────────────────────

/// Argument bundle passed to the background isolate for recommendation matching.
/// All fields are plain Dart objects (no native handles) — safely sendable.
class _MatchArgs {
  final List<Recipe> recipes;
  final List<String> detectedIngredients;

  const _MatchArgs({
    required this.recipes,
    required this.detectedIngredients,
  });
}

/// Runs inside a background isolate — heavy O(recipes × ingredients) matching.
List<RecipeRecommendation> _matchRecipesToIngredients(_MatchArgs args) {
  final detected = args.detectedIngredients
      .map((i) => i.trim().toLowerCase())
      .where((i) => i.isNotEmpty)
      .toList();

  final recommendations = <RecipeRecommendation>[];

  for (final recipe in args.recipes) {
    var matched = 0;
    var partialMatched = 0;
    String? firstMissing;

    for (final required in recipe.ingredients) {
      final reqNameLower = required.name.toLowerCase();
      final found = detected.any(
        (item) => StringUtils.ingredientMatches(reqNameLower, item),
      );

      if (found) {
        matched++;
      } else {
        firstMissing ??= required.name;

        // Partial: shares a significant word (length > 3)
        final reqWords =
            reqNameLower.split(RegExp(r'\s+')).where((w) => w.length > 3);
        final isPartial = detected.any((item) {
          final itemWords = item
              .toLowerCase()
              .split(RegExp(r'\s+'))
              .where((w) => w.length > 3);
          return reqWords.any((rw) => itemWords.contains(rw));
        });

        if (isPartial) partialMatched++;
      }
    }

    if (matched == 0) continue;

    final total = recipe.ingredients.length;
    final percentage = ((matched / total) * 100).round();

    recommendations.add(
      RecipeRecommendation(
        recipe: recipe,
        matchPercentage: percentage,
        matchText: percentage >= 100
            ? 'Semua bahan tersedia!'
            : 'Kurang ${total - matched} bahan',
        missingIngredientName: percentage >= 100 ? null : firstMissing,
        matchedCount: matched,
        partialMatchedCount: partialMatched,
      ),
    );
  }

  recommendations.sort((a, b) {
    final pctCompare = b.matchPercentage.compareTo(a.matchPercentage);
    if (pctCompare != 0) return pctCompare;

    final countCompare = b.matchedCount.compareTo(a.matchedCount);
    if (countCompare != 0) return countCompare;

    final partialCompare =
        b.partialMatchedCount.compareTo(a.partialMatchedCount);
    if (partialCompare != 0) return partialCompare;

    // Tie-break: prefer simpler (fewer-ingredient) recipes
    return a.recipe.ingredients.length.compareTo(b.recipe.ingredients.length);
  });

  return recommendations;
}

// ─────────────────────────────────────────────────────────────────────────────
// DummyRecipeRepository
// ─────────────────────────────────────────────────────────────────────────────

/// In-memory implementation backed by [DummyRecipeSource].
///
/// All methods return instant [Future]s so the API is identical to what a real
/// [PocketBaseRecipeRepository] will expose. Swap this in [AppProviders] when
/// the backend is ready — zero changes needed in UI code.
class DummyRecipeRepository implements RecipeRepository {
  /// Parse once at construction — O(n) upfront, O(1) everywhere else.
  late final List<Recipe> _recipes =
      DummyRecipeSource.recipes.map(Recipe.fromMap).toList();

  /// O(1) lookup index.
  late final Map<String, Recipe> _recipesById = {
    for (final r in _recipes) r.id: r,
  };

  // ── RecipeRepository interface ───────────────────────────────────────────

  @override
  Future<List<Recipe>> getRecipes({
    int page = 1,
    int perPage = 20,
    String? tag,
    String? difficulty,
  }) async {
    var result = _recipes.where((r) {
      if (tag != null && tag.isNotEmpty && !r.tags.contains(tag)) return false;
      if (difficulty != null &&
          difficulty.isNotEmpty &&
          r.difficulty != difficulty) {
        return false;
      }
      return true;
    }).toList();

    final start = (page - 1) * perPage;
    if (start >= result.length) return [];
    return result.sublist(start, min(start + perPage, result.length));
  }

  @override
  Future<List<Recipe>> searchRecipes(String query, {int perPage = 30}) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    final words = q.split(' ').where((w) => w.isNotEmpty).toList();
    final scoredResults = <MapEntry<Recipe, int>>[];

    for (final r in _recipes) {
      final nameLower = r.recipeName.toLowerCase();
      int score = 0;

      if (nameLower == q) {
        score += 100;
      } else if (nameLower.contains(q)) {
        score += 50;
      }

      for (final w in words) {
        if (nameLower.contains(w)) score += 10;
        if (r.tags.any((t) => t.toLowerCase().contains(w))) score += 5;
        if (r.ingredients.any((i) => i.name.toLowerCase().contains(w))) {
          score += 2;
        }
      }

      if (score > 0) scoredResults.add(MapEntry(r, score));
    }

    scoredResults.sort((a, b) => b.value.compareTo(a.value));
    return scoredResults.take(perPage).map((e) => e.key).toList();
  }

  @override
  Future<Recipe?> getRecipeById(String id) async => _recipesById[id];

  @override
  Future<List<Recipe>> getAllRecipes() async => List.unmodifiable(_recipes);

  @override
  Future<List<Recipe>> getRecipesByIds(List<String> ids) async {
    return ids.map((id) => _recipesById[id]).whereType<Recipe>().toList();
  }

  @override
  Future<List<RecipeRecommendation>> getRecommendationsForIngredients(
    List<String> detectedIngredients,
  ) async {
    if (detectedIngredients.isEmpty) return [];

    // Run matching in a background isolate — keeps UI thread responsive
    // even when dataset grows to hundreds of recipes.
    return compute(
      _matchRecipesToIngredients,
      _MatchArgs(
        recipes: _recipes,
        detectedIngredients: detectedIngredients,
      ),
    );
  }
}

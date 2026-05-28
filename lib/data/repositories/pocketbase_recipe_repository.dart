import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../core/pocketbase_client.dart';
import '../../models/recipe_model.dart';
import '../../utils/string_utils.dart';
import 'recipe_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Top-level helpers for compute() 
// ─────────────────────────────────────────────────────────────────────────────

class _MatchArgs {
  final List<Recipe> recipes;
  final List<String> detectedIngredients;

  const _MatchArgs({
    required this.recipes,
    required this.detectedIngredients,
  });
}

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

    return a.recipe.ingredients.length.compareTo(b.recipe.ingredients.length);
  });

  return recommendations;
}

// ─────────────────────────────────────────────────────────────────────────────
// PocketBaseRecipeRepository
// ─────────────────────────────────────────────────────────────────────────────

class PocketBaseRecipeRepository implements RecipeRepository {
  final pb = PocketBaseClient.instance;
  
  // Cache all recipes in memory to speed up recommendations
  List<Recipe>? _allRecipesCache;

  // Convert a RecordModel to our Recipe model
  Recipe _recordToRecipe(RecordModel record) {
    final map = record.toJson();
    // PocketBase json fields are already parsed into List/Map when calling toJson()
    // if they were stored correctly as JSON fields.
    return Recipe.fromMap(map);
  }

  @override
  Future<List<Recipe>> getRecipes({
    int page = 1,
    int perPage = 20,
    String? tag,
    String? difficulty,
  }) async {
    final filters = <String>[];
    if (tag != null && tag.isNotEmpty) {
      filters.add('tags ~ "$tag"');
    }
    if (difficulty != null && difficulty.isNotEmpty) {
      filters.add('difficulty = "$difficulty"');
    }

    final filterString = filters.isEmpty ? '' : filters.join(' && ');

    try {
      final records = await pb.collection('recipes').getList(
        page: page,
        perPage: perPage,
        filter: filterString,
        sort: '-created', // Newest first
      );
      
      return records.items.map(_recordToRecipe).toList();
    } catch (e) {
      debugPrint('Error getting recipes: $e');
      return [];
    }
  }

  @override
  Future<List<Recipe>> searchRecipes(String query, {int perPage = 30}) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    try {
      // In PocketBase, we can search multiple fields
      // For a better fuzzy search, we'll download all and filter locally, 
      // OR we can do a simple filter query.
      // Let's use PocketBase filter to query recipe_name, tags, or ingredients
      // NOTE: 'ingredients' is a JSON field, searching inside JSON requires ~ operator.
      final filterString = 'recipe_name ~ "$q" || tags ~ "$q" || ingredients ~ "$q"';
      
      final records = await pb.collection('recipes').getList(
        page: 1,
        perPage: perPage,
        filter: filterString,
      );

      return records.items.map(_recordToRecipe).toList();
    } catch (e) {
      debugPrint('Error searching recipes: $e');
      return [];
    }
  }

  @override
  Future<Recipe?> getRecipeById(String id) async {
    try {
      final record = await pb.collection('recipes').getOne(id);
      return _recordToRecipe(record);
    } catch (e) {
      debugPrint('Error getting recipe by id: $e');
      return null;
    }
  }

  @override
  Future<List<Recipe>> getAllRecipes() async {
    if (_allRecipesCache != null) return _allRecipesCache!;
    
    try {
      final records = await pb.collection('recipes').getFullList();
      _allRecipesCache = records.map(_recordToRecipe).toList();
      return _allRecipesCache!;
    } catch (e) {
      debugPrint('Error getting all recipes: $e');
      return [];
    }
  }

  @override
  Future<List<Recipe>> getRecipesByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    
    try {
      final filterString = ids.map((id) => 'id = "$id"').join(' || ');
      final records = await pb.collection('recipes').getFullList(
        filter: filterString,
      );
      return records.map(_recordToRecipe).toList();
    } catch (e) {
      debugPrint('Error getting recipes by ids: $e');
      return [];
    }
  }

  @override
  Future<List<RecipeRecommendation>> getRecommendationsForIngredients(
    List<String> detectedIngredients,
  ) async {
    if (detectedIngredients.isEmpty) return [];

    final recipes = await getAllRecipes();

    return compute(
      _matchRecipesToIngredients,
      _MatchArgs(
        recipes: recipes,
        detectedIngredients: detectedIngredients,
      ),
    );
  }
}

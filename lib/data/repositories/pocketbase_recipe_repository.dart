import 'dart:io';
import 'dart:math' as dart_math;

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
    final missingIngredients = <String>[];

    for (final required in recipe.ingredients) {
      final reqNameLower = required.name.toLowerCase();
      final found = detected.any(
        (item) => StringUtils.ingredientMatches(reqNameLower, item),
      );

      if (found) {
        matched++;
      } else {
        firstMissing ??= required.name;
        missingIngredients.add(required.name);

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
    final missingCount = total - matched;
    final percentage = ((matched / total) * 100).round();

    String matchText;
    if (percentage >= 100) {
      matchText = 'Semua bahan tersedia!';
    } else if (missingCount <= 2 && missingIngredients.isNotEmpty) {
      final names = missingIngredients
          .map((e) => StringUtils.capitalizeWords(e))
          .join(', ');
      matchText = 'Kurang: $names';
    } else {
      matchText = 'Kurang $missingCount bahan';
    }

    recommendations.add(
      RecipeRecommendation(
        recipe: recipe,
        matchPercentage: percentage,
        matchText: matchText,
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
// Network error helper
// ─────────────────────────────────────────────────────────────────────────────

/// Returns `true` when [e] looks like a connectivity / network error that the
/// UI should surface as "Tidak ada koneksi" rather than swallowing silently.
bool _isNetworkError(Object e) {
  if (e is SocketException) return true;
  if (e is HandshakeException) return true;
  if (e is ClientException) {
    final msg = e.toString();
    return msg.contains('SocketException') ||
        msg.contains('Connection refused') ||
        msg.contains('Failed host lookup') ||
        msg.contains('Network is unreachable') ||
        msg.contains('Connection timed out') ||
        msg.contains('XMLHttpRequest error');
  }
  return false;
}

// ─────────────────────────────────────────────────────────────────────────────
// PocketBaseRecipeRepository
// ─────────────────────────────────────────────────────────────────────────────

class PocketBaseRecipeRepository implements RecipeRepository {
  final pb = PocketBaseClient.instance;
  
  // Cache all recipes in memory to speed up recommendations
  List<Recipe>? _allRecipesCache;

  // Convert a RecordModel to our Recipe model
  Recipe? _recordToRecipeSafe(RecordModel record) {
    final map = record.toJson();
    try {
      return Recipe.fromMap(map);
    } catch (e) {
      debugPrint('Skip invalid recipe record ${record.id}: $e');
      return null;
    }
  }

  @override
  Future<List<Recipe>> getRecipes({
    int page = 1,
    int perPage = 20,
    String? tag,
    String? difficulty,
    String sort = '-created',
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
        sort: sort,
      );
      
      return records.items
          .map(_recordToRecipeSafe)
          .whereType<Recipe>()
          .toList();
    } catch (e) {
      debugPrint('Error getting recipes: $e');
      if (_isNetworkError(e)) rethrow;
      return [];
    }
  }

  @override
  Future<List<Recipe>> searchRecipes(
    String query, {
    int perPage = 30,
    String? difficulty,
    int? maxCookingTime,
  }) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    try {
      var filterString =
          '(recipe_name ~ "$q" || tags ~ "$q" || ingredients ~ "$q")';
      
      if (difficulty != null && difficulty.isNotEmpty) {
        filterString += ' && difficulty = "$difficulty"';
      }
      if (maxCookingTime != null) {
        filterString += ' && cooking_time <= $maxCookingTime';
      }
      
      final records = await pb.collection('recipes').getList(
        page: 1,
        perPage: perPage,
        filter: filterString,
      );

      return records.items
          .map(_recordToRecipeSafe)
          .whereType<Recipe>()
          .toList();
    } catch (e) {
      debugPrint('Error searching recipes: $e');
      if (_isNetworkError(e)) rethrow;
      return [];
    }
  }

  @override
  Future<Recipe?> getRecipeById(String id) async {
    try {
      final record = await pb.collection('recipes').getOne(id);
      return _recordToRecipeSafe(record);
    } catch (e) {
      debugPrint('Error getting recipe by id: $e');
      if (_isNetworkError(e)) rethrow;
      return null;
    }
  }

  @override
  Future<List<Recipe>> getAllRecipes() async {
    try {
      final records = await pb.collection('recipes').getFullList();
      _allRecipesCache = records
          .map(_recordToRecipeSafe)
          .whereType<Recipe>()
          .toList();
      return _allRecipesCache!;
    } catch (e) {
      debugPrint('Error getting all recipes: $e');
      if (_isNetworkError(e)) rethrow;
      return [];
    }
  }

  @override
  Future<List<String>> getAllUniqueTags({int? seed}) async {
    try {
      final records = await pb.collection('recipes').getFullList(
        fields: 'tags',
      );
      
      final tagCounts = <String, int>{};
      for (final r in records) {
        final tags = r.data['tags'];
        if (tags is List) {
          for (final tag in tags) {
            final t = tag.toString().trim();
            if (t.isNotEmpty) {
              tagCounts[t] = (tagCounts[t] ?? 0) + 1;
            }
          }
        }
      }
      
      final rand = dart_math.Random(seed ?? DateTime.now().millisecondsSinceEpoch);
      final sorted = tagCounts.keys.toList()
        ..sort((a, b) {
          final diff = tagCounts[b]!.compareTo(tagCounts[a]!);
          if (diff != 0) return diff;
          return rand.nextBool() ? 1 : -1;
        });
        
      return sorted;
    } catch (e) {
      debugPrint('Error getting unique tags: $e');
      if (_isNetworkError(e)) rethrow;
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
      return records
          .map(_recordToRecipeSafe)
          .whereType<Recipe>()
          .toList();
    } catch (e) {
      debugPrint('Error getting recipes by ids: $e');
      if (_isNetworkError(e)) rethrow;
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

  // ── Favorites CRUD ───────────────────────────────────────────────────────

  @override
  Future<Map<String, String>> getFavoriteRecords(String userId) async {
    try {
      final records = await pb.collection('favorites').getFullList(
        filter: 'user_id = "$userId"',
      );
      return {
        for (final r in records)
          (r.data['recipe_id'] as String? ?? r.get<String>('recipe_id')): r.id,
      };
    } catch (e) {
      debugPrint('Error getting favorite records: $e');
      return {};
    }
  }

  @override
  Future<String> addFavorite(String userId, String recipeId) async {
    final record = await pb.collection('favorites').create(body: {
      'user_id': userId,
      'recipe_id': recipeId,
    });
    return record.id;
  }

  @override
  Future<void> removeFavorite(String favoriteRecordId) async {
    await pb.collection('favorites').delete(favoriteRecordId);
  }
}

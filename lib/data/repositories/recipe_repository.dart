import '../../models/recipe_model.dart';

/// Abstract contract for recipe data access.
///
/// All methods are [Future]-based so any implementation can use either:
/// - In-memory dummy data (returns instant futures)
/// - Network / PocketBase calls (returns real async futures)
///
/// To migrate to PocketBase, create a `PocketBaseRecipeRepository` that
/// implements this interface and swap it in [AppProviders.build()].
abstract class RecipeRepository {
  /// Paginated recipe list — used by Home & Browse screens.
  ///
  /// [page] is 1-indexed. [tag] and [difficulty] are optional filters.
  /// When using PocketBase: maps to `?page=X&perPage=Y&filter=tags~"tag"`.
  Future<List<Recipe>> getRecipes({
    int page = 1,
    int perPage = 20,
    String? tag,
    String? difficulty,
  });

  /// Full-text search across recipe names, tags, and ingredients.
  ///
  /// Returns up to [perPage] results, ranked by relevance score.
  /// When using PocketBase: maps to `?filter=recipe_name~"q"&perPage=X`.
  Future<List<Recipe>> searchRecipes(String query, {int perPage = 30});

  /// Fetch a single recipe by its ID — used by the Detail screen.
  Future<Recipe?> getRecipeById(String id);

  /// Load **all** recipes — used by the recommendation engine for
  /// in-memory ingredient matching. Cache and invalidate periodically
  /// when using PocketBase to avoid loading thousands of records on every scan.
  Future<List<Recipe>> getAllRecipes();

  /// Batch-fetch multiple recipes by their IDs — used by Favorites.
  ///
  /// When using PocketBase: maps to `?filter=id="a"||id="b"||...`.
  Future<List<Recipe>> getRecipesByIds(List<String> ids);

  /// Compute ingredient-based recommendations off the UI thread.
  ///
  /// [detectedIngredients] is the **combined** list of scanned + pantry items.
  /// Heavy matching runs inside a background isolate via `compute()`.
  Future<List<RecipeRecommendation>> getRecommendationsForIngredients(
    List<String> detectedIngredients,
  );

  // ── Favorites CRUD ────────────────────────────────────────────────────────

  /// Load all favorite records for [userId].
  /// Returns a map of `recipeId → favoriteRecordId` (PocketBase record ID
  /// needed for deletion).
  Future<Map<String, String>> getFavoriteRecords(String userId);

  /// Create a favorite record linking [userId] to [recipeId].
  /// Returns the new PocketBase record ID.
  Future<String> addFavorite(String userId, String recipeId);

  /// Delete the favorite record identified by [favoriteRecordId].
  Future<void> removeFavorite(String favoriteRecordId);
}

import '../../data/repositories/recipe_repository.dart';
import '../../services/recipe_recommendation_service.dart';

/// Use-case: compute ingredient-based recipe recommendations.
///
/// Orchestrates the two-step flow:
/// 1. Heavy matching runs off the UI thread inside [RecipeRepository]
///    (via `compute()` in the dummy impl, or a server query in PocketBase impl).
/// 2. Lightweight bucketing runs synchronously on the result.
class GetRecipeRecommendations {
  final RecipeRepository _repo;

  const GetRecipeRecommendations(this._repo);

  Future<RecommendationViewData> call({
    required List<String> currentIngredients,
    required List<String> pantryItems,
  }) async {
    // Combine all available ingredients for the matching step so pantry
    // essentials contribute to the match percentage.
    final allIngredients = [...currentIngredients, ...pantryItems];

    final allRecommendations =
        await _repo.getRecommendationsForIngredients(allIngredients);

    // Bucketing is O(n) and synchronous — no need for an isolate.
    return RecipeRecommendationService.bucket(
      allRecommendations: allRecommendations,
      currentIngredients: currentIngredients,
      pantryItems: pantryItems,
    );
  }
}

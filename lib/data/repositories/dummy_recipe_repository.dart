import '../../models/recipe_model.dart';
import '../../utils/string_utils.dart';
import '../dummy/dummy_recipe_source.dart';
import 'recipe_repository.dart';

class DummyRecipeRepository implements RecipeRepository {
  late final List<Recipe> _recipes =
      DummyRecipeSource.recipes.map(Recipe.fromMap).toList();

  /// O(1) lookup index by recipe id.
  late final Map<String, Recipe> _recipesById = {
    for (final r in _recipes) r.id: r,
  };

  @override
  List<Recipe> getAllRecipes() => List.unmodifiable(_recipes);

  @override
  Recipe? getRecipeById(String id) => _recipesById[id];

  @override
  List<RecipeRecommendation> getRecommendationsForIngredients(
    List<String> detectedIngredients,
  ) {
    if (detectedIngredients.isEmpty) return [];

    final detected = detectedIngredients
        .map((i) => i.trim())
        .where((i) => i.isNotEmpty)
        .toList();

    final recommendations = <RecipeRecommendation>[];

    for (final recipe in _recipes) {
      var matched = 0;
      String? firstMissing;

      for (final required in recipe.ingredients) {
        final found = detected.any(
          (item) => StringUtils.ingredientMatches(required.name, item),
        );
        if (found) {
          matched++;
        } else {
          firstMissing ??= required.name;
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
        ),
      );
    }

    recommendations.sort(
      (a, b) => b.matchPercentage.compareTo(a.matchPercentage),
    );

    return recommendations;
  }
}

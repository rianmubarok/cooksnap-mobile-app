import '../../models/recipe_model.dart';
import '../dummy/dummy_recipe_source.dart';
import 'recipe_repository.dart';

class DummyRecipeRepository implements RecipeRepository {
  late final List<Recipe> _recipes =
      DummyRecipeSource.recipes.map(Recipe.fromMap).toList();

  late final List<RecipeCategory> _categories = DummyRecipeSource.categories
      .map(RecipeCategory.fromMap)
      .toList();

  /// O(1) lookup index by recipe id.
  late final Map<String, Recipe> _recipesById = {
    for (final r in _recipes) r.id: r,
  };

  @override
  List<Recipe> getAllRecipes() => List.unmodifiable(_recipes);

  @override
  List<RecipeCategory> getCategories() => List.unmodifiable(_categories);

  @override
  Recipe? getRecipeById(String id) => _recipesById[id];

  @override
  List<Recipe> getRecipesByCategory(String categoryName) {
    if (categoryName == 'Semua') return getAllRecipes();
    return _recipes.where((r) => r.category == categoryName).toList();
  }

  @override
  List<RecipeRecommendation> getRecommendationsForIngredients(
    List<String> detectedIngredients,
  ) {
    if (detectedIngredients.isEmpty) return [];

    final normalizedDetected = detectedIngredients
        .map((i) => i.toLowerCase().trim())
        .where((i) => i.isNotEmpty)
        .toList();

    final recommendations = <RecipeRecommendation>[];

    for (final recipe in _recipes) {
      final recipeIngredientNames = recipe.ingredients
          .map((i) => i.name.toLowerCase())
          .toList();

      var matched = 0;
      String? firstMissing;

      for (final required in recipeIngredientNames) {
        final found = normalizedDetected.any(
          (detected) =>
              required.contains(detected) || detected.contains(required),
        );
        if (found) {
          matched++;
        } else {
          firstMissing ??= recipe.ingredients
              .firstWhere((i) => i.name.toLowerCase() == required)
              .name;
        }
      }

      if (matched == 0) continue;

      final total = recipeIngredientNames.length;
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

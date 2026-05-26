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
          
          // If they share any significant word (length > 3)
          final reqWords = reqNameLower.split(RegExp(r'\s+')).where((w) => w.length > 3);
          final isPartial = detected.any((item) {
            final itemWords = item.toLowerCase().split(RegExp(r'\s+')).where((w) => w.length > 3);
            return reqWords.any((rw) => itemWords.contains(rw));
          });
          
          if (isPartial) {
            partialMatched++;
          }
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

      final partialCompare = b.partialMatchedCount.compareTo(a.partialMatchedCount);
      if (partialCompare != 0) return partialCompare;

      // Break ties by fewest total ingredients (simpler recipes show first)
      return a.recipe.ingredients.length.compareTo(b.recipe.ingredients.length);
    });

    return recommendations;
  }
}

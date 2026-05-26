import '../data/repositories/recipe_repository.dart';
import '../models/recipe_model.dart';
import '../utils/string_utils.dart';

/// View-model output for the recipe recommendation screen.
class RecommendationViewData {
  final List<RecipeRecommendation> specific;
  final List<RecipeRecommendation> combined;
  final List<String> suggestions;
  final int validTotal;
  final List<String> displayedIngredients;

  const RecommendationViewData({
    required this.specific,
    required this.combined,
    required this.suggestions,
    required this.validTotal,
    required this.displayedIngredients,
  });
}

/// Buckets recommendations and computes ingredient suggestions.
class RecipeRecommendationService {
  RecipeRecommendationService._();

  static RecommendationViewData compute({
    required RecipeRepository repo,
    required List<String> currentIngredients,
    required List<String> pantryItems,
  }) {
    final displayedIngredients = currentIngredients
        .where((i) => !StringUtils.listContainsIngredient(pantryItems, i))
        .toList();

    final allRecommendations =
        repo.getRecommendationsForIngredients(currentIngredients);

    final specific = <RecipeRecommendation>[];
    final combined = <RecipeRecommendation>[];
    var validTotal = 0;

    for (final rec in allRecommendations) {
      final usesManual = displayedIngredients.isEmpty ||
          rec.recipe.ingredients.any(
            (ing) => displayedIngredients.any(
              (manual) => StringUtils.ingredientMatches(ing.name, manual),
            ),
          );

      if (!usesManual) continue;
      validTotal++;

      final usesEssential = rec.recipe.ingredients.any(
        (ing) => pantryItems.any(
          (pantry) => StringUtils.ingredientMatches(ing.name, pantry),
        ),
      );

      if (usesEssential) {
        combined.add(rec);
      } else {
        specific.add(rec);
      }
    }

    final suggestions = _computeSuggestions(
      allRecommendations: allRecommendations,
      currentIngredients: currentIngredients,
      pantryItems: pantryItems,
      validTotal: validTotal,
      displayedCount: displayedIngredients.length,
    );

    return RecommendationViewData(
      specific: specific,
      combined: combined,
      suggestions: suggestions,
      validTotal: validTotal,
      displayedIngredients: displayedIngredients,
    );
  }

  static List<String> _computeSuggestions({
    required List<RecipeRecommendation> allRecommendations,
    required List<String> currentIngredients,
    required List<String> pantryItems,
    required int validTotal,
    required int displayedCount,
  }) {
    if (validTotal > 3 && displayedCount > 2) return const [];

    final missingCounts = <String, int>{};

    for (final rec in allRecommendations) {
      for (final ing in rec.recipe.ingredients) {
        final hasIng =
            StringUtils.listContainsIngredient(currentIngredients, ing.name) ||
                StringUtils.listContainsIngredient(pantryItems, ing.name);

        if (!hasIng) {
          missingCounts[ing.name] = (missingCounts[ing.name] ?? 0) + 1;
        }
      }
    }

    final sorted = missingCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted
        .take(6)
        .map((e) => e.key)
        .where(
          (suggested) =>
              !StringUtils.listContainsIngredient(currentIngredients, suggested),
        )
        .toList();
  }
}

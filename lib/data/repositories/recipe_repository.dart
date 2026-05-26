import '../../models/recipe_model.dart';

abstract class RecipeRepository {
  List<Recipe> getAllRecipes();

  Recipe? getRecipeById(String id);

  List<RecipeRecommendation> getRecommendationsForIngredients(
    List<String> detectedIngredients,
  );
}

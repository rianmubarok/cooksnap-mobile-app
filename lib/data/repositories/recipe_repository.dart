import '../../models/recipe_model.dart';

abstract class RecipeRepository {
  List<Recipe> getAllRecipes();

  List<RecipeCategory> getCategories();

  Recipe? getRecipeById(String id);

  List<Recipe> getRecipesByCategory(String categoryName);

  List<RecipeRecommendation> getRecommendationsForIngredients(
    List<String> detectedIngredients,
  );
}

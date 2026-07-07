import '../data/dummy/dummy_ingredients.dart';

/// Emoji labels for ingredient category accordion headers.
class IngredientCategoryEmoji {
  IngredientCategoryEmoji._();

  static String forCategory(String category) =>
      DummyIngredients.categoryIcons[category] ?? '📦';
}

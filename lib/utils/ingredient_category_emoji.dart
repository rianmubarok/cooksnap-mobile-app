/// Emoji labels for ingredient category accordion headers.
class IngredientCategoryEmoji {
  IngredientCategoryEmoji._();

  static const Map<String, String> _map = {
    'Sumber Protein': '🍗',
    'Sayuran': '🥬',
    'Bumbu': '🧄',
    'Bumbu Dasar': '🧂',
    'Karbohidrat': '🍚',
    'Susu & Olahan Susu': '🥛',
    'Buah': '🍎',
    'Tepung': '🌾',
    'Lainnya': '🧊',
  };

  static String forCategory(String category) => _map[category] ?? '🛒';
}

/// Emoji labels for ingredient category accordion headers.
class IngredientCategoryEmoji {
  IngredientCategoryEmoji._();

  static const Map<String, String> _map = {
    'Sumber Protein': '🍗',
    'Seafood': '🍤',
    'Sayuran': '🥬',
    'Jamur': '🍄',
    'Bumbu': '🧄',
    'Bumbu Dasar': '🧂',
    'Karbohidrat': '🍚',
    'Kacang & Biji': '🥜',
    'Susu & Olahan Susu': '🥛',
    'Buah': '🍎',
    'Tepung': '🌾',
    'Lainnya': '🧊',
  };

  static String forCategory(String category) => _map[category] ?? '🛒';
}

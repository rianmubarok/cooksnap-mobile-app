import '../data/dummy/dummy_ingredients.dart';
import 'string_utils.dart';

/// Memetakan input bebas ke nama bahan resmi dari katalog.
class IngredientResolver {
  IngredientResolver._();

  static List<String> _catalog = DummyIngredients.items;

  /// Daftar bahan resmi untuk autocomplete.
  static List<String> get catalog => List.unmodifiable(_catalog);

  /// Perbarui katalog (misal dari PocketBase secara asinkron)
  static void updateCatalog(List<String> newItems) {
    _catalog = newItems;
  }

  /// Cari saran autocomplete berdasarkan query.
  static List<String> search(String query, {int limit = 30}) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];

    final q = trimmed.toLowerCase();
    return _catalog
        .where((item) => item.toLowerCase().contains(q))
        .take(limit)
        .toList();
  }

  /// Kembalikan nama resmi dari katalog, atau null jika tidak dikenali.
  static String? resolve(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    // Cocok persis (abaikan kapitalisasi)
    for (final item in _catalog) {
      if (item.toLowerCase() == trimmed.toLowerCase()) return item;
    }

    // Koreksi typo (Levenshtein)
    final typoMatches = _catalog
        .where((item) => StringUtils.isSimilar(item, trimmed))
        .toList();
    if (typoMatches.length == 1) return typoMatches.first;
    if (typoMatches.isNotEmpty) {
      return _closestByDistance(trimmed, typoMatches);
    }

    // Cocok sebagian kata (mis. "ayam" → "Ayam")
    final partialMatches = _catalog
        .where((item) => StringUtils.ingredientMatches(item, trimmed))
        .toList();
    if (partialMatches.length == 1) return partialMatches.first;
    if (partialMatches.isNotEmpty) {
      partialMatches.sort((a, b) => a.length.compareTo(b.length));
      return partialMatches.first;
    }

    return null;
  }

  static String _closestByDistance(String input, List<String> candidates) {
    candidates.sort(
      (a, b) => StringUtils.levenshteinDistance(input, a)
          .compareTo(StringUtils.levenshteinDistance(input, b)),
    );
    return candidates.first;
  }
}

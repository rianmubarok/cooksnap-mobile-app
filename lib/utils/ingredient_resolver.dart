import '../data/dummy/dummy_ingredients.dart';
import 'string_utils.dart';

/// Memetakan input bebas ke nama bahan resmi dari katalog dan daftar koreksi (ingredient_corrections).
class IngredientResolver {
  IngredientResolver._();

  static List<String> _catalog = DummyIngredients.items;

  /// Kamus koreksi / alias (bisa bawaan + di-update dari PocketBase / Admin)
  /// Format key selalu lowercase: { 'alias/typo': 'Nama Resmi di Katalog' }
  static Map<String, String> _corrections = {
    'telor': 'Telur Ayam',
    'cabe': 'Cabai Merah',
    'cabe merah': 'Cabai Merah',
    'cabe rawit': 'Cabai Rawit',
    'bawang mrh': 'Bawang Merah',
    'bawang pth': 'Bawang Putih',
    'micin': 'Penyedap Rasa',
    'penyedap': 'Penyedap Rasa',
    'masako': 'Kaldu Ayam',
    'royco': 'Kaldu Ayam',
  };

  /// Daftar bahan resmi untuk autocomplete.
  static List<String> get catalog => List.unmodifiable(_catalog);

  /// Daftar pemetaan koreksi bahan.
  static Map<String, String> get corrections => Map.unmodifiable(_corrections);

  /// Perbarui katalog & pemetaan koreksi (misal dari PocketBase secara asinkron)
  static void updateCatalog(
    List<String> newItems, {
    Map<String, String>? newCorrections,
  }) {
    _catalog = newItems;
    if (newCorrections != null && newCorrections.isNotEmpty) {
      _corrections = {
        ..._corrections,
        ...newCorrections.map((k, v) => MapEntry(k.toLowerCase(), v)),
      };
    }
  }

  /// Tambahkan atau perbarui pemetaan koreksi bahan secara terpisah
  static void updateCorrections(Map<String, String> newCorrections) {
    if (newCorrections.isNotEmpty) {
      _corrections = {
        ..._corrections,
        ...newCorrections.map((k, v) => MapEntry(k.toLowerCase(), v)),
      };
    }
  }

  /// Cari saran autocomplete berdasarkan query dari katalog & riwayat koreksi.
  static List<String> search(String query, {int limit = 30}) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];

    final q = trimmed.toLowerCase();
    final results = <String>{};

    // 1. Prioritas 1: Cocok dari Ingredient Corrections (alias/typo -> canonical)
    _corrections.forEach((alias, canonical) {
      if (alias.contains(q)) {
        results.add(canonical);
      }
    });

    // 2. Prioritas 2: Cocok substring dari Katalog Resmi
    for (final item in _catalog) {
      if (item.toLowerCase().contains(q)) {
        results.add(item);
      }
    }

    return results.take(limit).toList();
  }

  /// Kembalikan nama resmi dari katalog atau pemetaan koreksi, atau null jika tidak dikenali.
  static String? resolve(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    final lower = trimmed.toLowerCase();

    // 1. Cocok persis di katalog resmi
    for (final item in _catalog) {
      if (item.toLowerCase() == lower) return item;
    }

    // 2. Cocok persis di kamus koreksi (alias / typo umum)
    if (_corrections.containsKey(lower)) {
      return _corrections[lower];
    }

    // 3. Koreksi typo (Levenshtein) ke katalog resmi
    final typoMatches = _catalog
        .where((item) => StringUtils.isSimilar(item, trimmed))
        .toList();
    if (typoMatches.length == 1) return typoMatches.first;
    if (typoMatches.isNotEmpty) {
      return _closestByDistance(trimmed, typoMatches);
    }

    // 4. Koreksi typo (Levenshtein) ke kamus koreksi
    final correctionMatches = _corrections.keys
        .where((alias) => StringUtils.isSimilar(alias, trimmed))
        .toList();
    if (correctionMatches.isNotEmpty) {
      final closestAlias = _closestByDistance(trimmed, correctionMatches);
      return _corrections[closestAlias];
    }

    // 5. Cocok sebagian kata di katalog resmi
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


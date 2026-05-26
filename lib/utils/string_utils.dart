class StringUtils {
  /// Simple Levenshtein distance for string similarity
  static int levenshteinDistance(String a, String b) {
    a = a.toLowerCase();
    b = b.toLowerCase();

    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    List<int> v0 = List<int>.generate(b.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(b.length + 1, 0);

    for (int i = 0; i < a.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < b.length; j++) {
        int cost = (a[i] == b[j]) ? 0 : 1;
        v1[j + 1] = [v1[j] + 1, v0[j + 1] + 1, v0[j] + cost].reduce((min, e) => min < e ? min : e);
      }

      for (int j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }

    return v1[b.length];
  }

  /// Check if two strings are similar, useful for detecting typos in ingredients.
  static bool isSimilar(String a, String b) {
    a = a.trim().toLowerCase();
    b = b.trim().toLowerCase();
    if (a == b) return true;

    int dist = levenshteinDistance(a, b);
    int maxLength = a.length > b.length ? a.length : b.length;

    // Allow 1 typo for words with 4 or more characters
    if (dist == 1 && maxLength >= 4) return true;
    
    // Allow 2 typos for words with 7 or more characters
    if (dist == 2 && maxLength >= 7) return true;

    return false;
  }

  /// Word-set matching for ingredient-to-recipe comparison.
  ///
  /// Returns true if [userIng] semantically matches [recipeIng] without
  /// false positives from naive substring matching.
  ///
  /// Strategy: all words in the shorter string must appear (as whole words)
  /// in the longer string.
  ///
  /// Examples:
  ///   "Ayam"        ↔ "Dada Ayam"      → ✅ "ayam" ∈ ["dada","ayam"]
  ///   "Telur Ayam"  ↔ "Telur"          → ✅ "telur" ∈ ["telur","ayam"]
  ///   "Bawang Putih"↔ "Bawang Goreng"  → ❌ "putih" ∉ ["bawang","goreng"]
  ///   "Daun Bawang" ↔ "Bawang Putih"   → ❌ "daun" ∉ ["bawang","putih"]
  ///   "Tepung Beras"↔ "Tepung Terigu"  → ❌ "beras" ∉ ["tepung","terigu"]
  ///   "Ayam Kampung"↔ "Dada Ayam"      → ❌ "kampung" ∉ ["dada","ayam"]
  static bool ingredientMatches(String recipeIng, String userIng) {
    recipeIng = recipeIng.trim().toLowerCase();
    userIng = userIng.trim().toLowerCase();

    if (recipeIng == userIng) return true;

    final recipeWords = recipeIng.split(RegExp(r'\s+'));
    final userWords = userIng.split(RegExp(r'\s+'));

    // Direction 1: all user words present in recipe words
    // e.g., user="ayam" vs recipe="dada ayam"
    if (userWords.every((w) => recipeWords.contains(w))) return true;

    // Direction 2: all recipe words present in user words
    // e.g., recipe="telur" vs user="telur ayam"
    if (recipeWords.every((w) => userWords.contains(w))) return true;

    return false;
  }

  /// True if [list] contains an entry that matches [ingredient].
  static bool listContainsIngredient(List<String> list, String ingredient) {
    return list.any((item) => ingredientMatches(ingredient, item));
  }

  /// Capitalizes the first letter of each word in a string.
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

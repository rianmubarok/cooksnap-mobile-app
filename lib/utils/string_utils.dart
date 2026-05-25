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
}

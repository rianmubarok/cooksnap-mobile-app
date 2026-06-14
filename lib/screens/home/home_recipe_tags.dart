

/// Tag filter definition for the home screen chip row.
class HomeRecipeTag {
  final String label;
  final String? query; // Null indicates "Semua" (no filter)

  const HomeRecipeTag({
    required this.label,
    this.query,
  });
}

/// Maximum number of tag chips shown after "Semua" (excludes "Semua").
const int _kMaxTagChips = 10;

/// Builds the chip list from popular tags.
///
/// - "Semua" always comes first.
/// - Each label is Title-cased for display.
List<HomeRecipeTag> buildHomeRecipeTags(List<String> popularTags, {int? seed}) {
  // If we want to shuffle the popular tags before picking the top N:
  // (In practice, we just pick the top _kMaxTagChips if they are already sorted by popularity)
  final selected = popularTags.take(_kMaxTagChips).toList();

  return [
    const HomeRecipeTag(label: 'Semua', query: null),
    for (final tag in selected)
      HomeRecipeTag(
        label: _capitalize(tag),
        query: tag,
      ),
  ];
}

/// Capitalizes the first letter of each word in [text].
String _capitalize(String text) {
  if (text.isEmpty) return text;
  return text
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}


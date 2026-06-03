import 'dart:math';
import '../../models/recipe_model.dart';

/// Tag filter definition for the home screen chip row.
class HomeRecipeTag {
  final String label;
  final bool Function(Recipe recipe) matcher;

  const HomeRecipeTag({
    required this.label,
    required this.matcher,
  });
}

/// Maximum number of tag chips shown after "Semua" (excludes "Semua").
const int _kMaxTagChips = 10;

/// Builds the chip list from all available recipe tags.
///
/// - "Semua" always comes first.
/// - Tags are collected from [Recipe.tags], de-duplicated, then shuffled so
///   a random subset is shown each time (e.g., on pull-to-refresh).
/// - Each label is Title-cased for display.
List<HomeRecipeTag> buildHomeRecipeTags(List<Recipe> recipes, {int? seed}) {
  // Count frequency of each tag
  final tagCounts = <String, int>{};
  for (final recipe in recipes) {
    for (final tag in recipe.tags) {
      final normalized = tag.trim();
      if (normalized.isNotEmpty) {
        tagCounts[normalized] = (tagCounts[normalized] ?? 0) + 1;
      }
    }
  }

  // Sort by frequency (descending). Jika frekuensi sama, acak posisinya (tie-breaker)
  final rand = Random(seed);
  final sortedTags = tagCounts.keys.toList()
    ..sort((a, b) {
      final diff = tagCounts[b]!.compareTo(tagCounts[a]!);
      if (diff != 0) return diff;
      return rand.nextBool() ? 1 : -1;
    });

  // Pick at most [_kMaxTagChips] most popular tags
  final selected = sortedTags.take(_kMaxTagChips).toList();

  return [
    const HomeRecipeTag(label: 'Semua', matcher: _matchAll),
    for (final tag in selected)
      HomeRecipeTag(
        label: _capitalize(tag),
        matcher: (recipe) => recipe.tags.any(
          (t) => t.trim().toLowerCase() == tag.toLowerCase(),
        ),
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

bool _matchAll(Recipe _) => true;

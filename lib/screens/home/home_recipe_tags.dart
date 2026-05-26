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

/// Default home screen recipe tag filters.
const List<HomeRecipeTag> kHomeRecipeTags = [
  HomeRecipeTag(label: 'Semua', matcher: _matchAll),
  HomeRecipeTag(label: 'Cepat', matcher: _matchCepat),
  HomeRecipeTag(label: 'Sehat', matcher: _matchSehat),
  HomeRecipeTag(label: 'Indonesia', matcher: _matchIndonesia),
  HomeRecipeTag(label: 'Minuman', matcher: _matchMinuman),
  HomeRecipeTag(label: 'Penutup', matcher: _matchPenutup),
  HomeRecipeTag(label: 'Mudah', matcher: _matchMudah),
];

bool _matchAll(Recipe _) => true;
bool _matchCepat(Recipe r) => r.tags.contains('Cepat');
bool _matchSehat(Recipe r) => r.tags.contains('Sehat');
bool _matchIndonesia(Recipe r) => r.tags.contains('Indonesia');
bool _matchMinuman(Recipe r) => r.tags.contains('Minuman');
bool _matchPenutup(Recipe r) => r.tags.contains('Penutup');
bool _matchMudah(Recipe r) => r.tags.contains('Mudah');

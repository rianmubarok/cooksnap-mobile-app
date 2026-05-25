import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_routes.dart';
import '../../core/app_text_styles.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../models/recipe_model.dart';
import '../../providers/user_provider.dart';
import '../../widgets/common/app_chip.dart';
import '../../widgets/common/section_action_link.dart';
import '../../widgets/recipe/recipe_card_horizontal.dart';
import '../../widgets/recipe/recipe_card_grid.dart';
import '../../widgets/search/recipe_search_field.dart';

/// Tag filter definition for the main filter chips row.
class _RecipeTag {
  final String label;
  final bool Function(Recipe recipe) matcher;

  const _RecipeTag({
    required this.label,
    required this.matcher,
  });
}

/// Home tab — recipes, categories, and sections.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTagIndex = 0; // 0 = Semua
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  static final List<_RecipeTag> _tags = [
    _RecipeTag(label: 'Semua',     matcher: (_) => true),
    _RecipeTag(label: 'Cepat',     matcher: (r) => r.tags.contains('Cepat')),
    _RecipeTag(label: 'Sehat',     matcher: (r) => r.tags.contains('Sehat')),
    _RecipeTag(label: 'Indonesia', matcher: (r) => r.tags.contains('Indonesia')),
    _RecipeTag(label: 'Minuman',   matcher: (r) => r.tags.contains('Minuman')),
    _RecipeTag(label: 'Dessert',   matcher: (r) => r.tags.contains('Dessert')),
    _RecipeTag(label: 'Mudah',     matcher: (r) => r.tags.contains('Mudah')),
  ];

  late List<_RecipeTag> _displayTags;

  @override
  void initState() {
    super.initState();
    _displayTags = List.from(_tags);
  }

  List<Recipe> _applyTagFilter(List<Recipe> recipes) {
    if (_selectedTagIndex == 0) return recipes;
    return recipes.where(_displayTags[_selectedTagIndex].matcher).toList();
  }

  @override
  Widget build(BuildContext context) {
    final recipeRepo = context.watch<RecipeRepository>();
    final allRecipes = recipeRepo.getAllRecipes();
    final filteredRecipes = _applyTagFilter(allRecipes);

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _onRefresh,
            color: AppColors.primary,
            backgroundColor: AppColors.cardBackground,
            strokeWidth: 2.5,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingScreen,
                      vertical: 12,
                    ),
                    child: RecipeSearchField(
                      onSubmitted: (query) {
                        if (query.trim().isNotEmpty) {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.search,
                            arguments: query.trim(),
                          );
                        }
                      },
                    ),
                  ),
                  _buildTagChips(),
                  _buildSectionTitle('Resep Populer', topPadding: 16),
                  _buildPopularRecipes(filteredRecipes),
                  _buildSectionTitle('Resep Terbaru', topPadding: 20, showAction: false),
                  _buildRecentRecipes(filteredRecipes),
                  const SizedBox(height: AppConstants.spacingXl),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {
        final rest = _displayTags.sublist(1);
        rest.shuffle();
        _displayTags = [_displayTags.first, ...rest];
        _selectedTagIndex = 0; // reset ke Semua
      });
    }
  }

  Widget _buildHeader(BuildContext context) {
    final firstName = context.watch<UserProvider>().firstName;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingScreen,
        AppConstants.spacingMd,
        AppConstants.paddingScreen,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hi! $firstName', style: AppTextStyles.greeting),
          const SizedBox(height: AppConstants.spacingSm),
          const Text(
            'Mau masak apa hari ini?',
            style: AppTextStyles.headlineDisplay,
          ),
        ],
      ),
    );
  }

  /// Single-select tag filter chips.
  Widget _buildTagChips() {
    return SizedBox(
      height: AppConstants.chipHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingScreen,
        ),
        itemCount: _displayTags.length,
        itemBuilder: (context, index) {
          final tag = _displayTags[index];
          final isSelected = index == _selectedTagIndex;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AppChip(
              label: tag.label,
              selected: isSelected,
              onTap: () => setState(() => _selectedTagIndex = index),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, {double topPadding = 24.0, bool showAction = true}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppConstants.paddingScreen,
        topPadding,
        AppConstants.paddingScreen,
        16.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.sectionTitle),
          if (showAction) const SectionActionLink(label: 'Lihat Semua'),
        ],
      ),
    );
  }

  Widget _buildPopularRecipes(List<Recipe> recipes) {
    if (recipes.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingScreen,
        ),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          return RecipeCardHorizontal(recipe: recipes[index]);
        },
      ),
    );
  }

  Widget _buildRecentRecipes(List<Recipe> recipes) {
    final recent = recipes.take(10).toList();

    if (recent.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingScreen,
          vertical: 24,
        ),
        child: Center(
          child: Text(
            'Tidak ada resep yang cocok\ndengan filter yang dipilih.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(height: 1.6),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingScreen,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recent.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (context, index) {
          return RecipeCardGrid(recipe: recent[index]);
        },
      ),
    );
  }
}

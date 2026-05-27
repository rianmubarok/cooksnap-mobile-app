import 'dart:math';
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
import '../../widgets/common/section_header_row.dart';
import '../../widgets/home/home_header.dart';
import '../../widgets/recipe/recipe_card_horizontal.dart';
import '../../widgets/recipe/recipe_card_grid.dart';
import '../../widgets/recipe/recipe_grid.dart';
import '../../widgets/search/recipe_search_field.dart';
import 'home_recipe_tags.dart';

/// Maximum recipes shown in the horizontal "Resep Populer" row.
const int _kPopularLimit = 10;

/// Maximum recipes shown in the "Untuk Kamu" grid section.
const int _kRecentGridLimit = 10;

/// Home tab — recipes, categories, and sections.
class HomeScreen extends StatefulWidget {
  final ScrollController? scrollController;
  final GlobalKey<RefreshIndicatorState>? refreshKey;

  const HomeScreen({
    super.key,
    this.scrollController,
    this.refreshKey,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTagIndex = 0;
  late List<HomeRecipeTag> _displayTags;

  List<Recipe> _allRecipes = [];
  bool _isLoading = true;
  late int _seed;

  @override
  void initState() {
    super.initState();
    _seed = DateTime.now().millisecondsSinceEpoch;
    _displayTags = List.from(kHomeRecipeTags);
    _loadRecipes();
  }

  /// Fetches all recipes from the repository (instant for dummy,
  /// network call for PocketBase) and caches them in state.
  Future<void> _loadRecipes() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final recipes =
        await context.read<RecipeRepository>().getAllRecipes();

    if (!mounted) return;
    setState(() {
      _allRecipes = recipes;
      _isLoading = false;
    });
  }

  List<Recipe> _applyTagFilter(List<Recipe> recipes) {
    if (_selectedTagIndex == 0) return recipes;
    return recipes.where(_displayTags[_selectedTagIndex].matcher).toList();
  }

  Future<void> _onRefresh() async {
    final rest = _displayTags.sublist(1)..shuffle();
    setState(() {
      _displayTags = [_displayTags.first, ...rest];
      _selectedTagIndex = 0;
      _seed = DateTime.now().millisecondsSinceEpoch;
    });
    await _loadRecipes();
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecipes = _applyTagFilter(_allRecipes);
    final popularRecipes = filteredRecipes.take(_kPopularLimit).toList();
    
    // Create a deterministically shuffled list for the "Untuk Kamu" section
    final random = Random(_seed);
    final forYouRecipes = List<Recipe>.from(filteredRecipes)..shuffle(random);

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            key: widget.refreshKey,
            onRefresh: _onRefresh,
            color: AppColors.primary,
            backgroundColor: AppColors.cardBackground,
            strokeWidth: 2.5,
            child: CustomScrollView(
              controller: widget.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: HomeHeader(
                    firstName: context.watch<UserProvider>().firstName,
                  ),
                ),
                SliverAppBar(
                  floating: true,
                  snap: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  automaticallyImplyLeading: false,
                  toolbarHeight: 120,
                  flexibleSpace: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingScreen,
                          vertical: 12,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.search,
                              arguments: '',
                            );
                          },
                          child: const AbsorbPointer(
                            child: RecipeSearchField(),
                          ),
                        ),
                      ),
                      _TagFilterRow(
                        tags: _displayTags,
                        selectedIndex: _selectedTagIndex,
                        onSelected: (index) =>
                            setState(() => _selectedTagIndex = index),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: _isLoading
                      ? const _LoadingSkeleton()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionHeader(
                              title: 'Resep Populer',
                              topPadding: 16,
                              onSeeAll: () => Navigator.pushNamed(
                                context,
                                AppRoutes.search,
                                arguments: '',
                              ),
                            ),
                            // Limit to [_kPopularLimit] — avoids rendering
                            // all recipes in one horizontal ListView.
                            _PopularRecipesRow(
                              recipes: popularRecipes,
                            ),
                            const _SectionHeader(
                              title: 'Untuk Kamu',
                              topPadding: 20,
                            ),
                            _RecentRecipesGrid(
                              recipes: forYouRecipes
                                  .take(_kRecentGridLimit)
                                  .toList(),
                            ),
                            const SizedBox(height: AppConstants.spacingXl),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _TagFilterRow extends StatelessWidget {
  final List<HomeRecipeTag> tags;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _TagFilterRow({
    required this.tags,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppConstants.chipHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingScreen,
        ),
        itemCount: tags.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AppChip(
              label: tags[index].label,
              selected: index == selectedIndex,
              onTap: () => onSelected(index),
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final double topPadding;
  final VoidCallback? onSeeAll;

  const _SectionHeader({
    required this.title,
    this.topPadding = 24,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppConstants.paddingScreen,
        topPadding,
        AppConstants.paddingScreen,
        16,
      ),
      child: SectionHeaderRow(
        title: title,
        actionLabel: onSeeAll == null ? null : 'Lihat Semua',
        onAction: onSeeAll,
      ),
    );
  }
}

class _PopularRecipesRow extends StatelessWidget {
  final List<Recipe> recipes;

  const _PopularRecipesRow({required this.recipes});

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingScreen,
        ),
        itemCount: recipes.length,
        itemBuilder: (context, index) =>
            RecipeCardHorizontal(recipe: recipes[index]),
      ),
    );
  }
}

class _RecentRecipesGrid extends StatelessWidget {
  final List<Recipe> recipes;

  const _RecentRecipesGrid({required this.recipes});

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingScreen,
          vertical: 24,
        ),
        child: Center(
          child: Text(
            'Tidak ada resep yang cocok\ndengan filter yang dipilih.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingScreen,
      ),
      child: RecipeGrid(
        recipes: recipes,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, recipe) => RecipeCardGrid(recipe: recipe),
      ),
    );
  }
}

/// Placeholder skeleton shown while recipes are loading.
class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

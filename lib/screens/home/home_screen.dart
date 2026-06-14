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
import '../../widgets/common/offline_error_view.dart';
import '../../widgets/common/skeleton_loader.dart';
import '../../widgets/home/home_header.dart';
import '../../widgets/recipe/recipe_card_horizontal.dart';
import '../../widgets/recipe/recipe_card_grid.dart';
import '../../widgets/recipe/recipe_grid.dart';
import '../../widgets/search/recipe_search_field.dart';
import 'home_recipe_tags.dart';

/// Maximum recipes shown in the horizontal "Resep Populer" row.
const int _kPopularLimit = 10;

/// Initial and incremental count for the "Untuk Kamu" infinite scroll.
const int _kInitialGridCount = 10;
const int _kLoadMoreCount = 10;
bool _matchAllTag(Recipe _) => true;

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
  bool _hasError = false;
  bool _isLoadingMore = false;
  int _displayedCount = _kInitialGridCount;
  late int _seed;

  @override
  void initState() {
    super.initState();
    _seed = DateTime.now().millisecondsSinceEpoch;
    _displayTags = const [HomeRecipeTag(label: 'Semua', matcher: _matchAllTag)];
    _loadRecipes();
  }

  Future<void> _loadMore(List<Recipe> forYouRecipes) async {
    if (_isLoadingMore) return;
    if (_displayedCount >= forYouRecipes.length) return;

    setState(() => _isLoadingMore = true);
    // Simulate a brief delay so the loading indicator is visible
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      _displayedCount =
          (_displayedCount + _kLoadMoreCount).clamp(0, forYouRecipes.length);
      _isLoadingMore = false;
    });
  }

  /// Fetches all recipes from the repository (instant for dummy,
  /// network call for PocketBase) and caches them in state.
  Future<void> _loadRecipes() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final recipes =
          await context.read<RecipeRepository>().getAllRecipes();
      if (!mounted) return;
      setState(() {
        _allRecipes = recipes;
        _displayTags = buildHomeRecipeTags(recipes, seed: _seed);
        if (_selectedTagIndex >= _displayTags.length) {
          _selectedTagIndex = 0;
        }
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  List<Recipe> _applyTagFilter(List<Recipe> recipes) {
    if (_selectedTagIndex == 0) return recipes;
    return recipes.where(_displayTags[_selectedTagIndex].matcher).toList();
  }

  Future<void> _onRefresh() async {
    final selectedTag = _displayTags[_selectedTagIndex];
    final rest = _displayTags.sublist(1)..shuffle();
    final newTags = [_displayTags.first, ...rest];
    final newSelectedIndex = newTags.indexOf(selectedTag);

    setState(() {
      _displayTags = newTags;
      _selectedTagIndex = newSelectedIndex;
      _seed = DateTime.now().millisecondsSinceEpoch;
      _displayedCount = _kInitialGridCount;
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
    final displayedRecipes = forYouRecipes.take(_displayedCount).toList();
    final hasMore = _displayedCount < forYouRecipes.length;

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            key: widget.refreshKey,
            onRefresh: _onRefresh,
            color: AppColors.primary,
            backgroundColor: AppColors.cardBackground,
            strokeWidth: 2.5,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (!_isLoading &&
                    hasMore &&
                    notification is ScrollUpdateNotification) {
                  final metrics = notification.metrics;
                  if (metrics.pixels >= metrics.maxScrollExtent * 0.85) {
                    _loadMore(forYouRecipes);
                  }
                }
                return false;
              },
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
                          onSelected: (index) => setState(() {
                            _selectedTagIndex = index;
                            _displayedCount = _kInitialGridCount;
                          }),
                        ),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _isLoading
                        ? const _LoadingSkeleton()
                        : _hasError
                            ? SizedBox(
                                height: 420,
                                child: OfflineErrorView(
                                  onRetry: _loadRecipes,
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _SectionHeader(
                                    title: 'Resep Populer',
                                    topPadding: 16,
                                    onSeeAll: () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.popularRecipes,
                                      arguments: filteredRecipes,
                                    ),
                                  ),
                                  _PopularRecipesRow(
                                    recipes: popularRecipes,
                                  ),
                                  const _SectionHeader(
                                    title: 'Untuk Kamu',
                                    topPadding: 20,
                                  ),
                                  _RecentRecipesGrid(
                                    recipes: displayedRecipes,
                                  ),
                                  if (_isLoadingMore)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    )
                                  else if (hasMore)
                                    const SizedBox(height: 8),
                                  const SizedBox(height: AppConstants.spacingXl),
                                ],
                              ),
                  ),
                ],
              ),
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
    return const HomeScreenSkeleton();
  }
}

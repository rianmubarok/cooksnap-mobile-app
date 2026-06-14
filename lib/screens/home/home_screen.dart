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
const int _kPerPage = 20;

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

  List<Recipe> _popularRecipes = [];
  List<Recipe> _forYouRecipes = [];
  bool _isLoading = true;
  bool _hasError = false;
  bool _isLoadingMore = false;
  
  bool _hasMoreForYou = true;
  late int _seed;

  @override
  void initState() {
    super.initState();
    _seed = DateTime.now().millisecondsSinceEpoch;
    _displayTags = const [HomeRecipeTag(label: 'Semua', query: null)];
    _loadInitialData();
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMoreForYou) return;

    setState(() => _isLoadingMore = true);
    
    try {
      final tagQuery = _displayTags[_selectedTagIndex].query;
      final newRecipes = await context.read<RecipeRepository>().getRecipes(
        page: 1, // Always page 1 for @random
        perPage: _kPerPage,
        tag: tagQuery,
        sort: '@random',
      );
      
      if (!mounted) return;
      setState(() {
        final existingIds = _forYouRecipes.map((e) => e.id).toSet();
        final uniqueNew = newRecipes.where((r) => !existingIds.contains(r.id)).toList();
        _forYouRecipes.addAll(uniqueNew);
        // Infinite scroll for @random never really ends unless there are very few items, 
        // but we'll stop if it returns 0 new unique items to avoid infinite empty loops
        if (uniqueNew.isEmpty && newRecipes.isNotEmpty) {
           // We might have just hit duplicates, try again next scroll
           _hasMoreForYou = true;
        } else {
           _hasMoreForYou = newRecipes.isNotEmpty;
        }
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
        // Optionally handle load more error
      });
    }
  }

  /// Fetches initial tags and first page of recipes
  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final repo = context.read<RecipeRepository>();
      
      // Fetch tags dynamically to ensure refresh logic and tie-breakers work
      final tags = await repo.getAllUniqueTags(seed: _seed);
      if (mounted) {
        // Find what was selected before we rebuild the tags list
        final previousSelectedTagQuery = _displayTags[_selectedTagIndex].query;

        _displayTags = buildHomeRecipeTags(tags, seed: _seed);
        
        // Try to maintain the selected tag, or fallback to "Semua" (0)
        final newIndex = _displayTags.indexWhere((t) => t.query == previousSelectedTagQuery);
        _selectedTagIndex = newIndex != -1 ? newIndex : 0;
      }

      final tagQuery = _displayTags[_selectedTagIndex].query;
      
      // Resep Populer: Newest recipes
      final popular = await repo.getRecipes(
        page: 1, 
        perPage: _kPopularLimit, 
        tag: tagQuery,
        sort: '-created',
      );

      // Untuk Kamu: Random recipes
      final forYou = await repo.getRecipes(
        page: 1, 
        perPage: _kPerPage, 
        tag: tagQuery,
        sort: '@random',
      );

      if (!mounted) return;
      setState(() {
        _popularRecipes = popular;
        _forYouRecipes = forYou;
        _hasMoreForYou = forYou.isNotEmpty;
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

  Future<void> _onRefresh() async {
    setState(() {
      _seed = DateTime.now().millisecondsSinceEpoch;
    });
    await _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {

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
                    _hasMoreForYou &&
                    notification is ScrollUpdateNotification) {
                  final metrics = notification.metrics;
                  if (metrics.pixels >= metrics.maxScrollExtent * 0.85) {
                    _loadMore();
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
                            _loadInitialData();
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
                                  onRetry: _loadInitialData,
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
                                      arguments: _popularRecipes, // pass all popular
                                    ),
                                  ),
                                  _PopularRecipesRow(
                                    recipes: _popularRecipes,
                                  ),
                                  const _SectionHeader(
                                    title: 'Untuk Kamu',
                                    topPadding: 20,
                                  ),
                                  _RecentRecipesGrid(
                                    recipes: _forYouRecipes,
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
                                  else if (_hasMoreForYou)
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
        itemBuilder: (context, recipe) => RecipeCardGrid(
          key: ValueKey(recipe.id),
          recipe: recipe,
        ),
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

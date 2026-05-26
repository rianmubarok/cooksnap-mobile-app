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
import '../../widgets/home/home_header.dart';
import '../../widgets/recipe/recipe_card_horizontal.dart';
import '../../widgets/recipe/recipe_card_grid.dart';
import '../../widgets/search/recipe_search_field.dart';
import 'home_recipe_tags.dart';

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

  @override
  void initState() {
    super.initState();
    _displayTags = List.from(kHomeRecipeTags);
  }

  List<Recipe> _applyTagFilter(List<Recipe> recipes) {
    if (_selectedTagIndex == 0) return recipes;
    return recipes.where(_displayTags[_selectedTagIndex].matcher).toList();
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      final rest = _displayTags.sublist(1)..shuffle();
      _displayTags = [_displayTags.first, ...rest];
      _selectedTagIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecipes =
        _applyTagFilter(context.read<RecipeRepository>().getAllRecipes());

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
                  child: Column(
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
                      _PopularRecipesRow(recipes: filteredRecipes),
                      const _SectionHeader(
                        title: 'Untuk Kamu',
                        topPadding: 20,
                      ),
                      _RecentRecipesGrid(recipes: filteredRecipes),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.sectionTitle),
          if (onSeeAll != null)
            SectionActionLink(label: 'Lihat Semua', onTap: onSeeAll),
        ],
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
            style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingScreen,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = (constraints.maxWidth - 12) / 2;
          // Calculate exact height needed: itemWidth (image) + ~86px for text and chips
          final itemHeight = itemWidth + 86;
          final aspectRatio = itemWidth / itemHeight;

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recent.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: aspectRatio,
            ),
            itemBuilder: (context, index) =>
                RecipeCardGrid(recipe: recent[index]),
          );
        },
      ),
    );
  }
}

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
import '../../widgets/recipe/recipe_list_tile.dart';
import '../../widgets/search/recipe_search_field.dart';

/// Home tab — recipes, categories, and sections.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    final recipeRepo = context.watch<RecipeRepository>();
    final categories = recipeRepo.getCategories();
    final selectedCategory = categories[_selectedCategoryIndex].name;
    final recipes = recipeRepo.getRecipesByCategory(selectedCategory);

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
                    padding: const EdgeInsets.all(AppConstants.paddingScreen),
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
                  _buildCategories(categories),
                  _buildSectionTitle('Resep Populer'),
                  _buildPopularRecipes(recipes),
                  _buildSectionTitle('Resep Terbaru'),
                  _buildRecentRecipes(recipes),
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
    if (mounted) setState(() {});
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

  Widget _buildCategories(List<RecipeCategory> categories) {
    return SizedBox(
      height: AppConstants.chipHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingScreen,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = index == _selectedCategoryIndex;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: AppChip(
              label: category.name,
              selected: isSelected,
              onTap: () => setState(() => _selectedCategoryIndex = index),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingScreen,
        AppConstants.spacingLg,
        AppConstants.paddingScreen,
        AppConstants.spacingMd,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.sectionTitle),
          const SectionActionLink(label: 'Lihat Semua'),
        ],
      ),
    );
  }

  Widget _buildPopularRecipes(List<Recipe> recipes) {
    return SizedBox(
      height: 240,
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
    final recent = recipes.take(3).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingScreen,
      ),
      itemCount: recent.length,
      itemBuilder: (context, index) {
        return RecipeListTile(recipe: recent[index]);
      },
    );
  }
}

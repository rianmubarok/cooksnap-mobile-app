import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_routes.dart';
import '../../core/app_text_styles.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../models/recipe_model.dart';
import '../../providers/user_provider.dart';
import '../../widgets/recipe/recipe_card_horizontal.dart';
import '../../widgets/recipe/recipe_list_tile.dart';

/// Home tab — recipes, categories, and sections.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    final recipeRepo = context.watch<RecipeRepository>();
    final categories = recipeRepo.getCategories();
    final selectedCategory = categories[_selectedCategoryIndex].name;
    final recipes = recipeRepo.getRecipesByCategory(selectedCategory);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                  _buildSearchBar(context),
                _buildCategories(categories),
                _buildSectionTitle('Resep Populer', 'Lihat Semua'),
                _buildPopularRecipes(recipes),
                _buildSectionTitle('Resep Terbaru', 'Lihat Semua'),
                _buildRecentRecipes(recipes),
                const SizedBox(height: AppConstants.spacingXl),
              ],
            ),
          ),
        ),
      ],
    );
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

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingScreen),
      child: Material(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Container(
          height: AppConstants.searchBarHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              const Icon(Icons.search_rounded,
                  color: AppColors.textHint, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Cari Resep',
                    hintStyle: TextStyle(
                        color: AppColors.textHint, fontSize: 18),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
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
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(List<RecipeCategory> categories) {
    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingScreen,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = index == _selectedCategoryIndex;

          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryIndex = index),
            child: AnimatedContainer(
              duration: AppConstants.animFast,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:
                    isSelected ? AppColors.primary : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                category.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, String action) {
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
          Text(
            action,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
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

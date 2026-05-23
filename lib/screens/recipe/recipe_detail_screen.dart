import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/recipe/recipe_info_chip.dart';
import '../../widgets/navigation/circular_header_button.dart';

class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    String recipeId = '1';
    List<String> availableIngredients = [];
    
    if (args is String) {
      recipeId = args;
    } else if (args is Map) {
      recipeId = args['id'] as String;
      availableIngredients = (args['availableIngredients'] as List<String>?) ?? [];
    }

    final recipe = context.watch<RecipeRepository>().getRecipeById(recipeId);

    if (recipe == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
        ),
        body: const Center(child: Text('Resep tidak ditemukan')),
      );
    }

    final isFavorite =
        context.watch<FavoritesProvider>().isFavorite(recipeId);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: AppConstants.recipeImageHeight,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            title: const Text(
              'Detail Resep',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            leadingWidth: 40 + AppConstants.paddingScreen,
            leading: Padding(
              padding: const EdgeInsets.only(left: AppConstants.paddingScreen),
              child: Center(
                child: CircularHeaderButton(
                  icon: Icons.arrow_back_ios_new,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: AppConstants.paddingScreen),
                child: Center(
                  child: CircularHeaderButton(
                    icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                    iconColor: isFavorite ? Colors.red : null,
                    onPressed: () {
                      context.read<FavoritesProvider>().toggleFavorite(recipeId);
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.primary, AppColors.primaryLight],
                      ),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 40),
                          Text('🍽️', style: TextStyle(fontSize: 72)),
                          SizedBox(height: 8),
                          Text(
                            'Foto Resep',
                            style: TextStyle(color: Colors.white54, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Top black gradient overlay for safe area and header
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 120, // Covers safe area + app bar
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingScreen),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.recipeName,
                    style: AppTextStyles.headlineDisplay,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        RecipeInfoChip(
                          icon: Icons.access_time,
                          text: recipe.cookingTimeLabel,
                        ),
                        const SizedBox(width: AppConstants.spacingXl),
                        RecipeInfoChip(
                          icon: Icons.restaurant,
                          text: recipe.difficulty,
                        ),
                        const SizedBox(width: AppConstants.spacingXl),
                        RecipeInfoChip(
                          icon: Icons.label_outline,
                          text: recipe.category,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXl),
                  const Text(
                    'Deskripsi',
                    style: AppTextStyles.sectionTitle,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  Text(
                    recipe.description,
                    style: AppTextStyles.bodySmall.copyWith(height: 1.6),
                  ),
                  const SizedBox(height: AppConstants.spacingXl),
                  const Text(
                    'Bahan-bahan',
                    style: AppTextStyles.sectionTitle,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  Column(
                    children: List.generate(recipe.ingredients.length, (
                      index,
                      ) {
                      final ing = recipe.ingredients[index];
                      bool isAvailable = false;
                      for (var ai in availableIngredients) {
                        if (ing.name.toLowerCase().contains(ai.toLowerCase()) || 
                            ai.toLowerCase().contains(ing.name.toLowerCase())) {
                          isAvailable = true;
                          break;
                        }
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isAvailable ? AppColors.chipBackground : const Color(0xFFD9D9D9),
                                shape: BoxShape.circle,
                              ),
                              child: isAvailable 
                                  ? const Icon(Icons.check, size: 16, color: AppColors.primary)
                                  : Center(
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF666666),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                ing.name,
                                style: AppTextStyles.labelMedium.copyWith(
                                  decoration: TextDecoration.underline,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              '${ing.quantity} ${ing.unit}',
                              style: AppTextStyles.labelMedium,
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppConstants.spacingXl),
                  const Text(
                    'Instruksi',
                    style: AppTextStyles.sectionTitle,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  ...List.generate(
                    recipe.steps.length,
                    (index) => _StepItem(
                      stepNumber: index + 1,
                      instruction: recipe.steps[index],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// _InfoChip removed — use shared RecipeInfoChip(outlined: true) instead.

class _StepItem extends StatelessWidget {
  final int stepNumber;
  final String instruction;

  const _StepItem({required this.stepNumber, required this.instruction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingXl), // Increased gap per step
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFD9D9D9),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              instruction,
              style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}


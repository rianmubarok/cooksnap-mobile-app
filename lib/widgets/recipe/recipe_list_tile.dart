import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../models/recipe_model.dart';
import '../../utils/recipe_navigation.dart';
import 'recipe_info_chip.dart';
import 'recipe_thumbnail.dart';

/// Horizontal list tile for a recipe. Used on the home screen and search results.
class RecipeListTile extends StatelessWidget {
  final Recipe recipe;
  final Widget? trailing;

  const RecipeListTile({super.key, required this.recipe, this.trailing});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.openRecipeDetail(recipe.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
        child: Row(
          children: [
            RecipeThumbnailBox(size: 72, imageUrl: recipe.imageUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.recipeName, style: AppTextStyles.labelLarge),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      RecipeInfoChip(
                        icon: Icons.timer_outlined,
                        text: recipe.cookingTimeLabel,
                      ),
                      const SizedBox(width: 12),
                      RecipeInfoChip(
                        icon: Icons.restaurant_menu_outlined,
                        text: recipe.difficulty,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

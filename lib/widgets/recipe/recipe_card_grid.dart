import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../models/recipe_model.dart';
import '../../utils/recipe_navigation.dart';
import 'recipe_info_chip.dart';
import 'recipe_thumbnail.dart';

/// Vertical recipe card for 2-column grid layout. No border.
class RecipeCardGrid extends StatelessWidget {
  final Recipe recipe;

  const RecipeCardGrid({super.key, required this.recipe});

  bool get _hasImage =>
      recipe.imageUrl != null && recipe.imageUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.openRecipeDetail(recipe.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            child: AspectRatio(
              aspectRatio: 1.0,
              child: _hasImage
                  ? Image.network(
                      recipe.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        child: const RecipeThumbnail(iconSize: 40),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: AppColors.primary.withValues(alpha: 0.06),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      child: const RecipeThumbnail(iconSize: 40),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          // Title
          Text(
            recipe.recipeName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          // Info chips
          Row(
            children: [
              RecipeInfoChip(
                icon: Icons.timer_outlined,
                text: recipe.cookingTimeLabel,
              ),
              const SizedBox(width: 8),
              RecipeInfoChip(
                icon: Icons.restaurant_menu_outlined,
                text: recipe.difficulty,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

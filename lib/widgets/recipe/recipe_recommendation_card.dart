import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_routes.dart';
import '../../models/recipe_model.dart';
import 'recipe_thumbnail.dart';

class RecipeRecommendationCard extends StatelessWidget {
  final RecipeRecommendation recommendation;

  const RecipeRecommendationCard({
    super.key,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    final recipe = recommendation.recipe;
    final isFullMatch = recommendation.isFullMatch;
    final progressColor =
        isFullMatch ? AppColors.success : AppColors.brandOrange;
    final textColor = progressColor;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.recipeDetail,
        arguments: recipe.id,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                child: Container(
                  width: 80,
                  height: 80,
                  color: AppColors.primary.withValues(alpha: 0.08),
                  child: const RecipeThumbnail(iconSize: 40),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.recipeName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          recipe.cookingTimeLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.restaurant,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            recipe.difficulty,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (recommendation.missingIngredientName != null)
                      Row(
                        children: [
                          Icon(Icons.info_outline, size: 12, color: textColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              recommendation.matchText,
                              style: TextStyle(
                                fontSize: 11,
                                color: textColor,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        recommendation.matchText,
                        style: TextStyle(
                          fontSize: 11,
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (recommendation.missingIngredientName != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 2),
                        child: Text(
                          recommendation.missingIngredientName!,
                          style: TextStyle(
                            fontSize: 10,
                            color: textColor.withValues(alpha: 0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: recommendation.matchPercentage / 100,
                              backgroundColor:
                                  progressColor.withValues(alpha: 0.2),
                              color: progressColor,
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${recommendation.matchPercentage}%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: progressColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textHint),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

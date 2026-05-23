import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../models/recipe_model.dart';
import '../../utils/recipe_navigation.dart';
import 'recipe_info_chip.dart';
import 'recipe_thumbnail.dart';

class RecipeRecommendationCard extends StatelessWidget {
  final RecipeRecommendation recommendation;
  final List<String>? userIngredients;

  const RecipeRecommendationCard({
    super.key,
    required this.recommendation,
    this.userIngredients,
  });

  @override
  Widget build(BuildContext context) {
    final recipe = recommendation.recipe;
    final isFullMatch = recommendation.isFullMatch;
    final progressColor =
        isFullMatch ? AppColors.success : AppColors.brandOrange;

    return GestureDetector(
      onTap: () => context.openRecipeDetail(recipe.id, userIngredients),
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
                child: RecipeThumbnailBox(size: 80, imageUrl: recipe.imageUrl),
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
                      style: AppTextStyles.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        RecipeInfoChip(
                          icon: Icons.access_time,
                          text: recipe.cookingTimeLabel,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RecipeInfoChip(
                            icon: Icons.restaurant,
                            text: recipe.difficulty,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _MatchInfo(
                      recommendation: recommendation,
                      color: progressColor,
                    ),
                    const SizedBox(height: 4),
                    _MatchProgressBar(
                      recommendation: recommendation,
                      color: progressColor,
                    ),
                  ],
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textHint),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

class _MatchInfo extends StatelessWidget {
  final RecipeRecommendation recommendation;
  final Color color;

  const _MatchInfo({required this.recommendation, required this.color});

  @override
  Widget build(BuildContext context) {
    if (recommendation.missingIngredientName != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 12, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  recommendation.matchText,
                  style: AppTextStyles.labelMedium.copyWith(color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 2),
            child: Text(
              recommendation.missingIngredientName!,
              style: AppTextStyles.labelMedium.copyWith(
                color: color.withValues(alpha: 0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Text(
      recommendation.matchText,
      style: AppTextStyles.labelMedium.copyWith(color: color),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _MatchProgressBar extends StatelessWidget {
  final RecipeRecommendation recommendation;
  final Color color;

  const _MatchProgressBar({required this.recommendation, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: recommendation.matchPercentage / 100,
              backgroundColor: color.withValues(alpha: 0.2),
              color: color,
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${recommendation.matchPercentage}%',
          style: AppTextStyles.labelMedium.copyWith(color: color),
        ),
      ],
    );
  }
}

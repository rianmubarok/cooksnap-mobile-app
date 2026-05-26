import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../models/recipe_model.dart';
import '../../utils/recipe_navigation.dart';
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
        height: 170,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 16, left: 16, right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                    Text(
                      recipe.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall,
                    ),
                    if (!recommendation.isFullMatch) ...[
                      const SizedBox(height: 12),
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
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 150,
              child: recipe.imageUrl != null && recipe.imageUrl!.trim().isNotEmpty
                  ? Image.network(
                      recipe.imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary.withValues(alpha: 0.4),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        child: const RecipeThumbnail(iconSize: 48),
                      ),
                    )
                  : Container(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      child: const RecipeThumbnail(iconSize: 48),
                    ),
            ),
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
    return Row(
      children: [
        Icon(
          recommendation.isFullMatch ? Icons.check_circle_outline : Icons.info_outline,
          size: 14,
          color: color,
        ),
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

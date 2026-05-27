import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../models/recipe_model.dart';
import '../../utils/recipe_navigation.dart';
import '../common/app_text.dart';
import 'recipe_thumbnail.dart';

class RecipeCardHorizontal extends StatelessWidget {
  final Recipe recipe;

  const RecipeCardHorizontal({super.key, required this.recipe});

  bool get _hasImage =>
      recipe.imageUrl != null && recipe.imageUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.openRecipeDetail(recipe.id),
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _hasImage
                  ? Image.network(
                      recipe.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const ColoredBox(
                        color: AppColors.cardBackground,
                        child: RecipeThumbnail(),
                      ),
                    )
                  : Container(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      child: const RecipeThumbnail(),
                    ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 100,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: AppText(
                  recipe.recipeName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  variant: AppTextVariant.h3,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

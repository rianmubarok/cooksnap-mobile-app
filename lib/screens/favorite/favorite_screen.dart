import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_routes.dart';
import '../../models/recipe_model.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/navigation/tab_page_scaffold.dart';
import '../../widgets/recipe/recipe_thumbnail.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>().favoriteRecipes;

    return TabPageScaffold(
      title: 'Resep Favorit',
      body: favorites.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(AppConstants.paddingScreen),
              itemCount: favorites.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppConstants.spacingMd),
              itemBuilder: (context, index) {
                return _FavoriteCard(recipe: favorites[index]);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border,
              size: 48,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: AppConstants.spacingLg),
          const Text(
            'Belum ada resep favorit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          const Text(
            'Simpan resep kesukaanmu di sini\nagar mudah ditemukan kembali',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Recipe recipe;

  const _FavoriteCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.recipeDetail,
        arguments: recipe.id,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingCard),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              ),
              child: const RecipeThumbnail(iconSize: 32),
            ),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.recipeName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 14, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        recipe.cookingTimeLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Icon(Icons.restaurant,
                          size: 14, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        recipe.difficulty,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.favorite, color: Colors.red, size: 22),
          ],
        ),
      ),
    );
  }
}

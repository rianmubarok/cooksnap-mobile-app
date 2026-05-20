import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_routes.dart';
import 'package:provider/provider.dart';
import '../../providers/favorites_provider.dart';
/// Favorite Screen — Shows list of saved/favorited recipes
/// TODO Genard: Replace dummy data with PocketBase favorites query
class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>().favorites;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: const Text(
          'Resep Favorit',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: favorites.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(AppConstants.paddingScreen),
              itemCount: favorites.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppConstants.spacingMd),
              itemBuilder: (context, index) {
                return _buildFavoriteCard(context, favorites[index]);
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
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.favorite_border,
                size: 48,
                color: AppColors.textHint,
              ),
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

  Widget _buildFavoriteCard(
      BuildContext context, Map<String, dynamic> recipe) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context, 
          AppRoutes.recipeDetail, 
          arguments: recipe['id'] ?? '1'
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingCard),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Image placeholder
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              ),
              child: Center(
                child: Text(
                  recipe['emoji'] as String,
                  style: const TextStyle(fontSize: 36),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingMd),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe['name'] as String,
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
                        recipe['cookingTime'] as String,
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
                        recipe['difficulty'] as String,
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
            // Favorite icon
            const Icon(Icons.favorite, color: Colors.red, size: 22),
          ],
        ),
      ),
    );
  }
}

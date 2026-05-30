import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../models/recipe_model.dart';
import '../../providers/favorites_provider.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/recipe_navigation.dart';
import '../common/app_text.dart';
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
          Stack(
            children: [
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
              Positioned(
                top: 8,
                right: 8,
                child: _FavoriteButton(recipe: recipe),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Title
          AppText(
            recipe.recipeName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            variant: AppTextVariant.bodyMediumSemibold,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
          const SizedBox(height: 6),
          // Info chips
          Row(
            children: [
              RecipeInfoChip(
                icon: LucideIcons.clock,
                text: recipe.cookingTimeLabel,
              ),
              const SizedBox(width: 8),
              RecipeInfoChip(
                icon: LucideIcons.utensils,
                text: recipe.difficulty,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  final Recipe recipe;
  const _FavoriteButton({required this.recipe});

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> {
  bool _isToggling = false;

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final isFavorite = favoritesProvider.isFavorite(widget.recipe.id);

    return GestureDetector(
      onTap: () async {
        if (_isToggling) return;
        setState(() => _isToggling = true);
        final willBeFavorite = !isFavorite;
        try {
          await favoritesProvider.toggleFavorite(widget.recipe.id);
          if (context.mounted) {
            showAppSnackBar(
              context,
              willBeFavorite
                  ? 'Resep ditambahkan ke favorit'
                  : 'Resep dihapus dari favorit',
              variant: AppSnackBarVariant.success,
            );
          }
        } catch (e) {
          if (context.mounted) {
            showAppSnackBar(
              context,
              'Gagal memperbarui favorit: ${e.toString()}',
              variant: AppSnackBarVariant.error,
              duration: const Duration(seconds: 4),
            );
          }
        } finally {
          if (context.mounted) {
            setState(() => _isToggling = false);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : const Color(0xFF1F2937),
          size: 18,
        ),
      ),
    );
  }
}


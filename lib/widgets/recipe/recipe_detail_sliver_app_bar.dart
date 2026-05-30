import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../models/recipe_model.dart';
import '../common/app_text.dart';
import '../navigation/circular_header_button.dart';

/// Collapsing header with recipe image and favorite action.
class RecipeDetailSliverAppBar extends StatelessWidget {
  final Recipe recipe;
  final bool isFavorite;
  final VoidCallback onBack;
  final VoidCallback onToggleFavorite;

  const RecipeDetailSliverAppBar({
    super.key,
    required this.recipe,
    required this.isFavorite,
    required this.onBack,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: AppConstants.recipeImageHeight,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      title: const AppText(
        'Detail Resep',
        variant: AppTextVariant.sectionTitle,
        color: AppColors.white,
      ),
      leadingWidth: 40 + AppConstants.paddingScreen,
      leading: Padding(
        padding: const EdgeInsets.only(left: AppConstants.paddingScreen),
        child: Center(
          child: CircularHeaderButton(
            icon: LucideIcons.chevronLeft,
            onPressed: onBack,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppConstants.paddingScreen),
          child: Center(
            child: _FavoriteSvgButton(
              isFavorite: isFavorite,
              onPressed: onToggleFavorite,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _RecipeHeroImage(imageUrl: recipe.imageUrl),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 120,
              child: DecoratedBox(
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
    );
  }
}

class _RecipeHeroImage extends StatelessWidget {
  final String? imageUrl;

  const _RecipeHeroImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _PlaceholderHero(),
      );
    }
    return const _PlaceholderHero();
  }
}

class _PlaceholderHero extends StatelessWidget {
  const _PlaceholderHero();

  @override
  Widget build(BuildContext context) {
    return Container(
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
            AppText(
              '🍽️',
              variant: AppTextVariant.emojiHero,
            ),
            SizedBox(height: 8),
            AppText(
              'Foto Resep',
              variant: AppTextVariant.bodyMedium,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteSvgButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onPressed;

  const _FavoriteSvgButton({
    required this.isFavorite,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : const Color(0xFF1F2937),
          size: 22,
        ),
      ),
    );
  }
}


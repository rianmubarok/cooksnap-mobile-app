import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../models/recipe_model.dart';
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
      title: const Text(
        'Detail Resep',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      leadingWidth: 40 + AppConstants.paddingScreen,
      leading: Padding(
        padding: const EdgeInsets.only(left: AppConstants.paddingScreen),
        child: Center(
          child: CircularHeaderButton(
            icon: Icons.arrow_back_ios_new,
            onPressed: onBack,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppConstants.paddingScreen),
          child: Center(
            child: CircularHeaderButton(
              icon: isFavorite ? Icons.favorite : Icons.favorite_border,
              iconColor: isFavorite ? Colors.red : null,
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
            Text('🍽️', style: TextStyle(fontSize: 72)),
            SizedBox(height: 8),
            Text(
              'Foto Resep',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

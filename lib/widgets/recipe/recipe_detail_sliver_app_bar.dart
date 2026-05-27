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
    final fillColor = isFavorite ? '#F44336' : 'none';
    final strokeColor = isFavorite ? '#F44336' : '#1F2937';
    
    final String svgString = '''
<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="$fillColor" stroke="$strokeColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z"/>
</svg>
''';

    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
        icon: SvgPicture.string(
          svgString,
          width: 22,
          height: 22,
        ),
        onPressed: onPressed,
      ),
    );
  }
}

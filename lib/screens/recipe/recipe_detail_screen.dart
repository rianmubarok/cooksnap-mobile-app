import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../models/recipe_model.dart';
import '../../providers/favorites_provider.dart';
import '../../utils/placeholder_snackbar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/recipe/recipe_detail_sliver_app_bar.dart';
import '../../widgets/recipe/recipe_info_chip.dart';
import '../../widgets/recipe/recipe_ingredients_section.dart';
import '../../widgets/recipe/recipe_steps_section.dart';

class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({super.key});

  static ({String id, List<String> ingredients}) _parseArgs(Object? args) {
    if (args is String) return (id: args, ingredients: []);
    if (args is Map) {
      return (
        id: args['id'] as String,
        ingredients: (args['availableIngredients'] as List<String>?) ?? [],
      );
    }
    return (id: '1', ingredients: []);
  }

  @override
  Widget build(BuildContext context) {
    final parsed = _parseArgs(ModalRoute.of(context)?.settings.arguments);
    final recipe =
        context.read<RecipeRepository>().getRecipeById(parsed.id);

    if (recipe == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
        ),
        body: const Center(child: Text('Resep tidak ditemukan')),
      );
    }

    final isFavorite =
        context.watch<FavoritesProvider>().isFavorite(parsed.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          RecipeDetailSliverAppBar(
            recipe: recipe,
            isFavorite: isFavorite,
            onBack: () => Navigator.pop(context),
            onToggleFavorite: () =>
                context.read<FavoritesProvider>().toggleFavorite(parsed.id),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingScreen),
              child: _RecipeDetailBody(
                recipe: recipe,
                availableIngredients: parsed.ingredients,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeDetailBody extends StatelessWidget {
  final Recipe recipe;
  final List<String> availableIngredients;

  const _RecipeDetailBody({
    required this.recipe,
    required this.availableIngredients,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(recipe.recipeName, style: AppTextStyles.headlineDisplay),
        const SizedBox(height: AppConstants.spacingMd),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              RecipeInfoChip(
                icon: LucideIcons.clock,
                text: recipe.cookingTimeLabel,
              ),
              const SizedBox(width: AppConstants.spacingXl),
              RecipeInfoChip(
                icon: LucideIcons.utensils,
                text: recipe.difficulty,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('Deskripsi', style: AppTextStyles.sectionTitle),
        const SizedBox(height: AppConstants.spacingMd),
        Text(
          recipe.description,
          style: AppTextStyles.bodyMedium.copyWith(
            height: 1.6,
            color: AppColors.grey666,
          ),
        ),
        const SizedBox(height: 20),
        RecipeIngredientsSection(
          ingredients: recipe.ingredients,
          availableIngredients: availableIngredients,
        ),
        const SizedBox(height: 20),
        RecipeStepsSection(steps: recipe.steps),
        if (recipe.sourceUrl != null && recipe.sourceUrl!.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text('Sumber', style: AppTextStyles.sectionTitle),
          const SizedBox(height: AppConstants.spacingMd),
          _SourceLink(url: recipe.sourceUrl!),
        ],
        if (recipe.videoUrl != null && recipe.videoUrl!.isNotEmpty) ...[
          const SizedBox(height: 20),
          PrimaryButton(
            text: 'Lihat Video',
            icon: LucideIcons.playCircle,
            useGradient: true,
            onPressed: () => showPlaceholderSnackBar(
              context,
              'Pemutaran video segera hadir',
            ),
          ),
          const SizedBox(height: AppConstants.spacingXl),
        ],
      ],
    );
  }
}

class _SourceLink extends StatelessWidget {
  final String url;

  const _SourceLink({required this.url});

  String get _displayLabel {
    final host = Uri.tryParse(url)?.host;
    if (host != null && host.isNotEmpty) {
      return host.replaceFirst('www.', '');
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () => showPlaceholderSnackBar(context, 'Membuka sumber segera hadir'),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.link, size: 20, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                _displayLabel,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

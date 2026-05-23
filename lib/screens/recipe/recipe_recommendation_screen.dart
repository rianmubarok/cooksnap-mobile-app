import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_decorations.dart';
import '../../core/app_text_styles.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../models/recipe_model.dart';
import '../../widgets/common/empty_state_view.dart';
import '../../widgets/ingredient/ingredient_tag_chip.dart';
import '../../widgets/recipe/recipe_recommendation_card.dart';

class RecipeRecommendationScreen extends StatefulWidget {
  final List<String> ingredients;

  const RecipeRecommendationScreen({super.key, required this.ingredients});

  @override
  State<RecipeRecommendationScreen> createState() =>
      _RecipeRecommendationScreenState();
}

class _RecipeRecommendationScreenState
    extends State<RecipeRecommendationScreen> {
  late final List<RecipeRecommendation> _recommendations;

  @override
  void initState() {
    super.initState();
    _recommendations = context
        .read<RecipeRepository>()
        .getRecommendationsForIngredients(widget.ingredients);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Resep Rekomendasi'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: Container(
        decoration: AppDecorations.pageBackground,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingScreen),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_recommendations.length} resep cocok dengan ${widget.ingredients.length} bahan kamu',
                      style: AppTextStyles.subtitleMuted,
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    _IngredientsPanel(ingredients: widget.ingredients),
                    const SizedBox(height: AppConstants.spacingLg),
                  ],
                ),
              ),
            ),
            if (_recommendations.isEmpty)
              const SliverFillRemaining(
                child: EmptyStateView(
                  icon: Icons.restaurant_menu_outlined,
                  title: 'Belum ada resep yang cocok',
                  subtitle: 'Coba scan bahan lain atau tambah bahan manual',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingScreen,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: RecipeRecommendationCard(
                        recommendation: _recommendations[index],
                        userIngredients: widget.ingredients,
                      ),
                    ),
                    childCount: _recommendations.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppConstants.spacingXl),
            ),
          ],
        ),
      ),
    );
  }
}

class _IngredientsPanel extends StatelessWidget {
  final List<String> ingredients;

  const _IngredientsPanel({required this.ingredients});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingCard),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bahan yang kamu punya:',
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ingredients.isEmpty
                ? [
                    const Text(
                      'Tidak ada bahan',
                      style: AppTextStyles.bodySmall,
                    ),
                  ]
                : ingredients
                    .map((i) => IngredientTagChip(label: i))
                    .toList(),
          ),
        ],
      ),
    );
  }
}

import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../core/app_decorations.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../providers/pantry_provider.dart';
import '../../services/recipe_recommendation_service.dart';
import '../../widgets/common/empty_state_view.dart';
import '../../widgets/ingredient/ingredient_tag_chip.dart';
import '../../widgets/ingredient/suggestion_chip.dart';
import '../../widgets/recipe/recipe_recommendation_card.dart';
import '../../widgets/navigation/circular_header_button.dart';

class RecipeRecommendationScreen extends StatefulWidget {
  final List<String> ingredients;

  const RecipeRecommendationScreen({super.key, required this.ingredients});

  @override
  State<RecipeRecommendationScreen> createState() =>
      _RecipeRecommendationScreenState();
}

class _RecipeRecommendationScreenState
    extends State<RecipeRecommendationScreen> {
  late List<String> _currentIngredients;
  final Set<String> _selectedSuggestions = {};

  @override
  void initState() {
    super.initState();
    _currentIngredients = List.from(widget.ingredients);
  }

  void _applySuggestions() {
    setState(() {
      _currentIngredients.addAll(_selectedSuggestions);
      _selectedSuggestions.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<RecipeRepository>();
    final pantryItems = context.watch<PantryProvider>().items;

    final data = RecipeRecommendationService.compute(
      repo: repo,
      currentIngredients: _currentIngredients,
      pantryItems: pantryItems,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context, _currentIngredients);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        floatingActionButton: _selectedSuggestions.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: _applySuggestions,
                backgroundColor: AppColors.chipBackground,
                elevation: 0,
                highlightElevation: 0,
                focusElevation: 0,
                hoverElevation: 0,
                icon: const Icon(LucideIcons.check, color: AppColors.primary),
                label: Text(
                  'Simpan Perubahan',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: AppConstants.paddingScreen),
            child: UnconstrainedBox(
              child: CircularHeaderButton(
                icon: LucideIcons.chevronLeft,
                onPressed: () => Navigator.pop(context, _currentIngredients),
              ),
            ),
          ),
          leadingWidth: 72,
          title: Text(
            'Resep Rekomendasi',
            style: AppTextStyles.h3.copyWith(color: AppColors.primary),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.chipBackground, AppColors.background],
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primary,
          elevation: 0,
        ),
        body: ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: const [
                  Colors.transparent,
                  Colors.black,
                ],
                stops: [0.0, bounds.height > 0 ? 24.0 / bounds.height : 0.05],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: CustomScrollView(
              slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.paddingScreen,
                  AppConstants.paddingScreen,
                  AppConstants.paddingScreen,
                  AppConstants.spacingLg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${data.validTotal} resep cocok dengan ${data.displayedIngredients.length} bahan kamu',
                      style: AppTextStyles.sectionTitle,
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    _IngredientsPanel(ingredients: data.displayedIngredients),
                  ],
                ),
              ),
            ),
            if (data.validTotal == 0)
              const SliverFillRemaining(
                child: EmptyStateView(
                  icon: LucideIcons.utensils,
                  title: 'Belum ada resep yang cocok',
                  subtitle:
                      'Coba pindai bahan lain atau tambah bahan manual',
                ),
              )
            else ...[
              if (data.specific.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppConstants.paddingScreen,
                      0,
                      AppConstants.paddingScreen,
                      16,
                    ),
                    child: Text(
                      'Siap Dibuat',
                      style: AppTextStyles.sectionTitle,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingScreen,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: EdgeInsets.only(
                          bottom: index == data.specific.length - 1 ? 24 : 16,
                        ),
                        child: RecipeRecommendationCard(
                          recommendation: data.specific[index],
                          userIngredients: _currentIngredients,
                        ),
                      ),
                      childCount: data.specific.length,
                    ),
                  ),
                ),
              ],
              if (data.suggestions.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.paddingScreen,
                      0,
                      AppConstants.paddingScreen,
                      24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Apakah Kamu Punya',
                          style: AppTextStyles.sectionTitle,
                        ),
                        const SizedBox(height: AppConstants.spacingMd),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: data.suggestions.map((ing) {
                            final isSelected =
                                _selectedSuggestions.contains(ing);
                            return SuggestionChip(
                              label: ing,
                              isSelected: isSelected,
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedSuggestions.remove(ing);
                                  } else {
                                    _selectedSuggestions.add(ing);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              if (data.combined.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppConstants.paddingScreen,
                      0,
                      AppConstants.paddingScreen,
                      16,
                    ),
                    child: Text(
                      'Butuh Tambahan Bahan',
                      style: AppTextStyles.sectionTitle,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingScreen,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: EdgeInsets.only(
                          bottom: index == data.combined.length - 1 ? 24 : 16,
                        ),
                        child: RecipeRecommendationCard(
                          recommendation: data.combined[index],
                          userIngredients: _currentIngredients,
                        ),
                      ),
                      childCount: data.combined.length,
                    ),
                  ),
                ),
              ],
            ],
            const SliverToBoxAdapter(
              child: SizedBox(height: AppConstants.spacingXl),
            ),
          ],
        ),
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
    if (ingredients.isEmpty) {
      return const Text(
        'Tidak ada bahan',
        style: AppTextStyles.bodyMedium,
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ingredients.map((i) => IngredientTagChip(label: i)).toList(),
    );
  }
}

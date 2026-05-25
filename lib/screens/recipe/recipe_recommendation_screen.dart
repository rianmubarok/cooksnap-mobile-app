import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../models/recipe_model.dart';
import '../../providers/pantry_provider.dart';
import '../../widgets/common/empty_state_view.dart';
import '../../widgets/ingredient/ingredient_tag_chip.dart';
import '../../widgets/ingredient/suggestion_chip.dart';
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
  late List<String> _currentIngredients;
  final Set<String> _selectedSuggestions = {};
  List<String>? _cachedSuggestions;

  @override
  void initState() {
    super.initState();
    _currentIngredients = List.from(widget.ingredients);
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<RecipeRepository>();
    final pantryItems = context.watch<PantryProvider>().items;
    final displayedIngredients = _currentIngredients
        .where((i) => !pantryItems.contains(i))
        .toList();

    final allRecommendations = repo.getRecommendationsForIngredients(_currentIngredients);

    final specificRecommendations = <RecipeRecommendation>[];
    final combinedRecommendations = <RecipeRecommendation>[];
    int validTotalRecommendations = 0;

    for (var rec in allRecommendations) {
      // Must use at least one manual ingredient if any were specifically chosen
      final usesManual = displayedIngredients.isEmpty || rec.recipe.ingredients.any((ing) {
        final ingName = ing.name.toLowerCase();
        return displayedIngredients.any((manual) {
          final manualLower = manual.toLowerCase();
          return ingName.contains(manualLower) || manualLower.contains(ingName);
        });
      });

      if (!usesManual) continue;
      validTotalRecommendations++;

      final usesEssential = rec.recipe.ingredients.any((ing) {
        final ingName = ing.name.toLowerCase();
        return pantryItems.any((pantry) {
          final pantryLower = pantry.toLowerCase();
          return ingName.contains(pantryLower) || pantryLower.contains(ingName);
        });
      });

      if (usesEssential) {
        combinedRecommendations.add(rec);
      } else {
        specificRecommendations.add(rec);
      }
    }

    if (_cachedSuggestions == null) {
      if (validTotalRecommendations <= 3 || displayedIngredients.length <= 2) {
        final missingCounts = <String, int>{};
        
        for (var rec in allRecommendations) {
          for (var ing in rec.recipe.ingredients) {
            final ingName = ing.name.toLowerCase();
            
            final hasIng = _currentIngredients.any((c) {
              final cLower = c.toLowerCase();
              return ingName.contains(cLower) || cLower.contains(ingName);
            }) || pantryItems.any((p) {
              final pLower = p.toLowerCase();
              return ingName.contains(pLower) || pLower.contains(ingName);
            });
                           
            if (!hasIng) {
              final properName = ing.name;
              missingCounts[properName] = (missingCounts[properName] ?? 0) + 1;
            }
          }
        }
        
        final sortedMissing = missingCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
          
        _cachedSuggestions = sortedMissing.take(6).map((e) => e.key).toList();
      } else {
        _cachedSuggestions = [];
      }
    }
    
    // Filter _cachedSuggestions so it doesn't show things the user already added manually
    final suggestedIngredients = _cachedSuggestions!.where((suggested) {
      final sLower = suggested.toLowerCase();
      return !_currentIngredients.any((c) {
        final cLower = c.toLowerCase();
        return sLower.contains(cLower) || cLower.contains(sLower);
      });
    }).toList();

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _currentIngredients);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        floatingActionButton: _selectedSuggestions.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: () {
                  setState(() {
                    _currentIngredients.addAll(_selectedSuggestions);
                    _selectedSuggestions.clear();
                  });
                },
                backgroundColor: AppColors.primary,
                elevation: 0,
                highlightElevation: 0,
                focusElevation: 0,
                hoverElevation: 0,
                icon: const Icon(Icons.check, color: AppColors.white),
                label: Text(
                  'Simpan Perubahan',
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.white),
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _currentIngredients),
          ),
          title: Text(
            'Resep Rekomendasi',
            style: AppTextStyles.h3.copyWith(color: AppColors.textOnPrimary),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
        ),
        body: CustomScrollView(
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
                    const Text('Dipilih', style: AppTextStyles.sectionTitle),
                    const SizedBox(height: AppConstants.spacingMd),
                    _IngredientsPanel(ingredients: displayedIngredients),
                    const SizedBox(height: AppConstants.spacingSm),
                    Text(
                      '$validTotalRecommendations resep cocok dengan ${displayedIngredients.length} bahan kamu',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            if (validTotalRecommendations == 0)
              const SliverFillRemaining(
                child: EmptyStateView(
                  icon: Icons.restaurant_menu_outlined,
                  title: 'Belum ada resep yang cocok',
                  subtitle: 'Coba scan bahan lain atau tambah bahan manual',
                ),
              )
            else ...[
              if (specificRecommendations.isNotEmpty) ...[
                // Selalu tampilkan header Resep Spesifik
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppConstants.paddingScreen, 0, AppConstants.paddingScreen, 16),
                    child: const Text(
                      'Resep Spesifik',
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
                          bottom: index == specificRecommendations.length - 1 ? 24 : 16,
                        ),
                        child: RecipeRecommendationCard(
                          recommendation: specificRecommendations[index],
                          userIngredients: _currentIngredients,
                        ),
                      ),
                      childCount: specificRecommendations.length,
                    ),
                  ),
                ),
              ],

              if (suggestedIngredients.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppConstants.paddingScreen, 0, AppConstants.paddingScreen, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Saran', style: AppTextStyles.sectionTitle),
                        const SizedBox(height: AppConstants.spacingMd),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: suggestedIngredients.map((ing) {
                            final isSelected = _selectedSuggestions.contains(ing);
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

              if (combinedRecommendations.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppConstants.paddingScreen, 0, AppConstants.paddingScreen, 16),
                    child: const Text(
                      'Ditambah Bahan Dasar',
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
                          bottom: index == combinedRecommendations.length - 1 ? 24 : 16,
                        ),
                        child: RecipeRecommendationCard(
                          recommendation: combinedRecommendations[index],
                          userIngredients: _currentIngredients,
                        ),
                      ),
                      childCount: combinedRecommendations.length,
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
        style: AppTextStyles.bodySmall,
      );
    }
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ingredients
          .map((i) => IngredientTagChip(label: i))
          .toList(),
    );
  }
}

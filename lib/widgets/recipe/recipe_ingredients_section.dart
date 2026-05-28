import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../models/recipe_model.dart';
import '../../utils/string_utils.dart';
import '../common/app_text.dart';
import '../ingredient/ingredient_wiki_sheet.dart';

/// Ingredients list with availability indicators.
class RecipeIngredientsSection extends StatefulWidget {
  final List<RecipeIngredient> ingredients;
  final List<String> availableIngredients;

  const RecipeIngredientsSection({
    super.key,
    required this.ingredients,
    this.availableIngredients = const [],
  });

  @override
  State<RecipeIngredientsSection> createState() =>
      _RecipeIngredientsSectionState();
}

class _RecipeIngredientsSectionState extends State<RecipeIngredientsSection> {
  final Set<String> _checkedIngredients = {};

  @override
  void initState() {
    super.initState();
    if (widget.availableIngredients.isNotEmpty) {
      for (final ing in widget.ingredients) {
        if (widget.availableIngredients.any(
            (ai) => StringUtils.ingredientMatches(ing.name, ai))) {
          _checkedIngredients.add(ing.name);
        }
      }
    }
  }

  void _toggleIngredient(String name) {
    setState(() {
      if (_checkedIngredients.contains(name)) {
        _checkedIngredients.remove(name);
      } else {
        _checkedIngredients.add(name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText('Bahan-bahan', variant: AppTextVariant.sectionTitle),
        const SizedBox(height: AppConstants.spacingMd),
        ...widget.ingredients.map((ing) {
          final isChecked = _checkedIngredients.contains(ing.name);
          return Container(
            margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              border: Border.all(color: AppColors.border),
            ),
            child: GestureDetector(
              onTap: () => _toggleIngredient(ing.name),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isChecked
                            ? AppColors.chipBackground
                            : const Color(0xFFD9D9D9),
                        shape: BoxShape.circle,
                      ),
                      child: isChecked
                          ? const Icon(LucideIcons.check,
                              size: 16, color: AppColors.primary)
                          : Center(
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF666666),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            showIngredientWikiSheet(context, ing.name),
                        child: AppText(
                          ing.name,
                          variant: AppTextVariant.bodyMedium,
                          decoration: TextDecoration.underline,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    AppText(
                      '${ing.quantity} ${ing.unit}',
                      variant: AppTextVariant.bodyMedium,
                      color: AppColors.grey666,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

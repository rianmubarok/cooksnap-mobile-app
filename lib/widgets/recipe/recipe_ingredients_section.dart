import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../models/recipe_model.dart';
import '../../utils/string_utils.dart';

/// Ingredients list with availability indicators.
class RecipeIngredientsSection extends StatelessWidget {
  final List<RecipeIngredient> ingredients;
  final List<String> availableIngredients;

  const RecipeIngredientsSection({
    super.key,
    required this.ingredients,
    this.availableIngredients = const [],
  });

  bool _isAvailable(RecipeIngredient ing) {
    if (availableIngredients.isEmpty) return false;
    return availableIngredients.any(
      (ai) => StringUtils.ingredientMatches(ing.name, ai),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Bahan-bahan', style: AppTextStyles.sectionTitle),
        const SizedBox(height: AppConstants.spacingMd),
        ...ingredients.map((ing) {
          final isAvailable = _isAvailable(ing);
          return Container(
            margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? AppColors.chipBackground
                        : const Color(0xFFD9D9D9),
                    shape: BoxShape.circle,
                  ),
                  child: isAvailable
                      ? const Icon(LucideIcons.check, size: 16, color: AppColors.primary)
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
                  child: Text(
                    ing.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      decoration: TextDecoration.underline,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '${ing.quantity} ${ing.unit}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey666,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

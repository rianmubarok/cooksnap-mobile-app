import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../common/app_text.dart';
import '../common/section_action_link.dart';
import 'removable_ingredient_chip.dart';

/// Selected ingredients list with clear-all action.
class SelectedIngredientsPanel extends StatelessWidget {
  final List<String> ingredients;
  final VoidCallback onClearAll;
  final ValueChanged<String> onRemove;

  const SelectedIngredientsPanel({
    super.key,
    required this.ingredients,
    required this.onClearAll,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AppText('Dipilih', variant: AppTextVariant.sectionTitle),
            Opacity(
              opacity: ingredients.isNotEmpty ? 1.0 : 0.0,
              child: SectionActionLink(
                label: 'Hapus semua',
                onTap: ingredients.isNotEmpty ? onClearAll : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingMd),
        if (ingredients.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: ingredients
                .map(
                  (ingredient) => RemovableIngredientChip(
                    label: ingredient,
                    onRemove: () => onRemove(ingredient),
                  ),
                )
                .toList(),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              border: Border.all(color: AppColors.border),
            ),
            alignment: Alignment.center,
            child: const AppText(
              'Belum ada bahan yang ditambahkan',
              variant: AppTextVariant.bodySmall,
            ),
          ),
      ],
    );
  }
}

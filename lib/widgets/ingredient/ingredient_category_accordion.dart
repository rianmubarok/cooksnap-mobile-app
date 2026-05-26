import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import 'ingredient_selectable_chip.dart';
import 'suggestion_chip.dart';

/// Expandable category card for browsing ingredients by group.
class IngredientCategoryAccordion extends StatefulWidget {
  final String category;
  final String emoji;
  final List<String> ingredients;
  final List<String> pantryItems;
  final List<String> selectedIngredients;
  final ValueChanged<String> onIngredientTap;

  const IngredientCategoryAccordion({
    super.key,
    required this.category,
    required this.emoji,
    required this.ingredients,
    required this.pantryItems,
    required this.selectedIngredients,
    required this.onIngredientTap,
  });

  @override
  State<IngredientCategoryAccordion> createState() =>
      _IngredientCategoryAccordionState();
}

class _IngredientCategoryAccordionState
    extends State<IngredientCategoryAccordion> {
  bool _isExpanded = false;

  Widget _chip(String ingredient) {
    return IngredientSelectableChip(
      label: ingredient,
      selectedIngredients: widget.selectedIngredients,
      pantryItems: widget.pantryItems,
      onTap: () => widget.onIngredientTap(ingredient),
    );
  }

  @override
  Widget build(BuildContext context) {
    final preview = widget.ingredients.take(4).toList();
    final remaining = widget.ingredients.length - 4;

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        '${widget.emoji} ${widget.category}',
                        style: AppTextStyles.h4.copyWith(
                          fontFamily: AppTextStyles.fontFamily,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  sizeCurve: Curves.easeInOut,
                  firstChild: SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...preview.map(_chip),
                        if (remaining > 0)
                          SuggestionChip(
                            label: '$remaining lainnya',
                            onTap: () => setState(() => _isExpanded = true),
                          ),
                      ],
                    ),
                  ),
                  secondChild: SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.ingredients.map(_chip).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

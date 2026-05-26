import 'package:flutter/material.dart';
import '../../utils/string_utils.dart';
import 'suggestion_chip.dart';

/// Suggestion chip that respects selected list and pantry essentials.
class IngredientSelectableChip extends StatelessWidget {
  final String label;
  final List<String> selectedIngredients;
  final List<String> pantryItems;
  final VoidCallback? onTap;

  const IngredientSelectableChip({
    super.key,
    required this.label,
    required this.selectedIngredients,
    required this.pantryItems,
    this.onTap,
  });

  bool get _isDisabled {
    final inSelection = selectedIngredients.any(
      (e) =>
          StringUtils.ingredientMatches(e, label) ||
          StringUtils.isSimilar(e, label),
    );
    final inPantry = StringUtils.listContainsIngredient(pantryItems, label);
    return inSelection || inPantry;
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _isDisabled ? 0.35 : 1.0,
      child: SuggestionChip(
        label: label,
        onTap: _isDisabled ? null : onTap,
      ),
    );
  }
}

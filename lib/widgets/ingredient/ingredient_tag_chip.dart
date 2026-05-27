import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../utils/string_utils.dart';
import '../common/app_text.dart';

/// Read-only ingredient tag (e.g. recommendation panel).
class IngredientTagChip extends StatelessWidget {
  final String label;

  const IngredientTagChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppConstants.chipHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText(
            StringUtils.capitalizeWords(label),
            variant: AppTextVariant.bodyMedium,
            color: AppColors.white,
          ),
        ],
      ),
    );
  }
}

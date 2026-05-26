import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../utils/string_utils.dart';

/// Read-only ingredient tag (e.g. recommendation panel).
class IngredientTagChip extends StatelessWidget {
  final String label;

  const IngredientTagChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppConstants.chipHeight,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            StringUtils.capitalizeWords(label),
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.white),
          ),
        ],
      ),
    );
  }
}

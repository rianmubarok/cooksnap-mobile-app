import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../utils/string_utils.dart';

/// Chip bahan terpilih — lebar mengikuti teks (hug content), bukan pill kategori.
class RemovableIngredientChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const RemovableIngredientChip({
    super.key,
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppConstants.chipHeight,
      padding: const EdgeInsets.only(left: 14, right: 8),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            StringUtils.capitalizeWords(label),
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.white),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.chipBackground,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

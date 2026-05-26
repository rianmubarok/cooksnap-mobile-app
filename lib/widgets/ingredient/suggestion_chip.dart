import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';

/// Chip saran — lebar mengikuti teks, gaya netral seperti sebelumnya.
class SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isSelected;

  const SuggestionChip({
    super.key,
    required this.label,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppConstants.chipHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ] else
              Text(
                '+ $label',
                style: AppTextStyles.bodyMedium,
              ),
          ],
        ),
      ),
    );
  }
}

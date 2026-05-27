import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../common/app_text.dart';

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
          borderRadius: BorderRadius.circular(AppConstants.radiusRound),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(LucideIcons.check, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              AppText(
                label,
                variant: AppTextVariant.bodyMedium,
                color: AppColors.primary,
              ),
            ] else
              AppText(
                '+ $label',
                variant: AppTextVariant.bodyMedium,
              ),
          ],
        ),
      ),
    );
  }
}

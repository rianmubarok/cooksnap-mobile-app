import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../common/app_text.dart';

/// Compact icon + label chip used across recipe cards and detail screens.
///
/// Set [outlined] to `true` to get a bordered pill style (used on
/// [RecipeDetailScreen]). The default compact style is used inside list tiles
/// and recommendation cards.
class RecipeInfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  /// When `true`, wraps the chip in a bordered pill container (detail screen).
  /// When `false` (default), renders as a plain Row with icon + text.
  final bool outlined;

  const RecipeInfoChip({
    super.key,
    required this.icon,
    required this.text,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: outlined ? 16 : 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        AppText(
          text,
          variant:
              outlined ? AppTextVariant.labelLarge : AppTextVariant.bodyMedium,
          color: AppColors.textSecondary,
        ),
      ],
    );

    if (!outlined) return content;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: content,
    );
  }
}

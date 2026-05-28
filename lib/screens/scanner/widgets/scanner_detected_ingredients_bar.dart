import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_constants.dart';
import '../../../core/app_text_styles.dart';
import '../../../widgets/ingredient/ingredient_tag_chip.dart';

/// Persistent bar showing detected ingredients on the scanner screen.
class ScannerDetectedIngredientsBar extends StatelessWidget {
  final List<String> ingredients;
  final VoidCallback onTap;

  const ScannerDetectedIngredientsBar({
    super.key,
    required this.ingredients,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (ingredients.isEmpty) return const SizedBox.shrink();

    return Material(
      color: AppColors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.paddingScreen,
            AppConstants.spacingMd,
            AppConstants.paddingScreen,
            AppConstants.spacingSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppColors.chipBackground,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.check, size: 14, color: AppColors.primary),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Bahan terdeteksi (${ingredients.length})',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    LucideIcons.chevronUp,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingSm),
              SizedBox(
                height: AppConstants.chipHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: ingredients.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return IngredientTagChip(label: ingredients[index]);
                  },
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ketuk untuk lihat detail',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';

/// Floating scan + search bar at the bottom of the manual ingredient tab.
class ManualIngredientActionBar extends StatelessWidget {
  final VoidCallback onScan;
  final VoidCallback onFindRecipes;

  const ManualIngredientActionBar({
    super.key,
    required this.onScan,
    required this.onFindRecipes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppConstants.paddingScreen,
        12,
        AppConstants.paddingScreen,
        MediaQuery.paddingOf(context).bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: AppConstants.buttonHeight,
            height: AppConstants.buttonHeight,
            child: FilledButton(
              onPressed: onScan,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                ),
              ),
              child: const Icon(Icons.camera_alt_outlined, size: 24),
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: FilledButton.icon(
              onPressed: onFindRecipes,
              icon: const Icon(Icons.search_rounded, size: 24),
              label: const Text('Cari Resep'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.chipBackground,
                foregroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(AppConstants.buttonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                ),
                textStyle: AppTextStyles.buttonLarge.copyWith(
                  color: AppColors.primary,
                  fontFamily: AppTextStyles.fontFamily,
                  letterSpacing: -0.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

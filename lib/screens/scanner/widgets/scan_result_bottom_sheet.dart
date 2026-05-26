import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_strings.dart';
import '../../../core/app_constants.dart';
import '../../../core/app_routes.dart';
import '../../../core/app_text_styles.dart';
import '../../../providers/ai_detection_provider.dart';
import '../../../widgets/common/bottom_sheet_handle.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/ingredient/ingredient_tag_chip.dart';

void showScanResultBottomSheet(
  BuildContext context, {
  VoidCallback? onRescan,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppConstants.radiusXl),
      ),
    ),
    builder: (sheetContext) {
      return DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) {
          return Consumer<AiDetectionProvider>(
            builder: (context, provider, child) {
              return Padding(
                padding: const EdgeInsets.all(AppConstants.paddingScreen),
                child: ListView(
                  controller: scrollController,
                  children: [
                    const BottomSheetHandle(),
                    if (provider.isLoading) ...[
                      const SizedBox(height: 40),
                      const Center(child: CircularProgressIndicator()),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'AI sedang menganalisis bahan...',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ] else if (provider.hasError) ...[
                      const SizedBox(height: 20),
                      Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        provider.errorMessage ?? 'Terjadi kesalahan',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        text: 'Tutup',
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ] else if (provider.hasResult) ...[
                      Text(
                        'Bahan Terdeteksi (${provider.detectedIngredients.length})',
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: AppConstants.spacingMd),
                      if (provider.detectedIngredients.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Tidak ada bahan makanan yang terdeteksi.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySmall,
                          ),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: provider.detectedIngredients
                              .map(
                                (ingredient) =>
                                    IngredientTagChip(label: ingredient),
                              )
                              .toList(),
                        ),
                      const SizedBox(height: AppConstants.spacingLg),
                      PrimaryButton(
                        text: 'Cari Resep dari Bahan Ini',
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          Navigator.pushNamed(
                            context,
                            AppRoutes.recipeRecommendation,
                            arguments: provider.detectedIngredients,
                          );
                        },
                        icon: Icons.search,
                      ),
                      const SizedBox(height: AppConstants.spacingMd),
                      SecondaryButton(
                        text: AppStrings.rescan,
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          onRescan?.call();
                        },
                        icon: Icons.refresh,
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}


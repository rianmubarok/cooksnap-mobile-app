import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_constants.dart';
import '../../../core/app_routes.dart';
import '../../../providers/ai_detection_provider.dart';
import '../../../widgets/custom_button.dart';

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
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.divider,
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusRound,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingLg),
                    if (provider.isLoading) ...[
                      const SizedBox(height: 40),
                      const Center(child: CircularProgressIndicator()),
                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          'AI sedang menganalisis bahan...',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ] else if (provider.hasError) ...[
                      const SizedBox(height: 20),
                      Icon(Icons.error_outline,
                          size: 60, color: Colors.red.shade400),
                      const SizedBox(height: 16),
                      Text(
                        provider.errorMessage ?? 'Terjadi kesalahan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
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
                        'Bahan Terdeteksi 🎯 (${provider.detectedIngredients.length})',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingMd),
                      if (provider.detectedIngredients.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Tidak ada bahan makanan yang terdeteksi.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      else
                        ...provider.detectedIngredients.map(
                          (ingredient) => _DetectedIngredientTile(
                            name: ingredient,
                          ),
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
                        useGradient: true,
                        icon: Icons.search,
                      ),
                      const SizedBox(height: AppConstants.spacingMd),
                      SecondaryButton(
                        text: 'Scan Ulang',
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

class _DetectedIngredientTile extends StatelessWidget {
  final String name;

  const _DetectedIngredientTile({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Row(
        children: [
          const Text('✅', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppConstants.radiusRound),
            ),
            child: const Text(
              'AI Detected',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

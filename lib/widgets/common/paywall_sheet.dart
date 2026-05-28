import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../providers/user_provider.dart';
import 'bottom_sheet_handle.dart';
import '../custom_button.dart';
import 'app_text.dart';
import '../../utils/app_snackbar.dart';

void showPaywallSheet(BuildContext context, {bool isLimitReached = false}) {
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
      return Padding(
        padding: EdgeInsets.only(
          left: AppConstants.paddingScreen,
          right: AppConstants.paddingScreen,
          top: AppConstants.paddingScreen,
          bottom: MediaQuery.of(sheetContext).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BottomSheetHandle(),
            const SizedBox(height: AppConstants.spacingMd),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF7E6), // Light gold/orange background
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.crown,
                size: 48,
                color: Color(0xFFF59E0B), // Gold color
              ),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            AppText(
              isLimitReached ? 'Limit Harian Tercapai' : 'Upgrade ke CookSnap PRO',
              variant: AppTextVariant.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingSm),
            AppText(
              isLimitReached
                  ? 'Anda telah menggunakan 3x pemindaian AI gratis untuk hari ini. Upgrade ke CookSnap PRO untuk akses AI tanpa batas.'
                  : 'Dapatkan akses pemindaian AI tanpa batas, rekomendasi resep eksklusif, dan fitur premium lainnya.',
              variant: AppTextVariant.bodyMedium,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
              height: 1.5,
            ),
            const SizedBox(height: AppConstants.spacingXl),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                color: const Color(0xFFFFFBEB),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText('CookSnap PRO', variant: AppTextVariant.h4),
                        SizedBox(height: 4),
                        AppText('Akses AI Scanner sepuasnya', variant: AppTextVariant.bodySmall, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                  AppText('Rp 15.000', variant: AppTextVariant.h3, color: Color(0xFFD97706)),
                  AppText('/bln', variant: AppTextVariant.bodySmall, color: AppColors.textSecondary),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacingXl),
            PrimaryButton(
              text: 'Upgrade Sekarang',
              onPressed: () async {
                final userProvider = context.read<UserProvider>();
                await userProvider.upgradeToPremium();
                if (sheetContext.mounted) {
                  Navigator.pop(sheetContext);
                  showAppSnackBar(
                    sheetContext,
                    'Berhasil upgrade ke PRO!',
                    variant: AppSnackBarVariant.success,
                  );
                }
              },
            ),
            const SizedBox(height: AppConstants.spacingMd),
            SecondaryButton(
              text: 'Nanti Saja',
              onPressed: () => Navigator.pop(sheetContext),
            ),
            const SizedBox(height: AppConstants.spacingXl),
          ],
        ),
      );
    },
  );
}

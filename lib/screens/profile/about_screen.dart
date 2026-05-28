import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/common/app_text.dart';
import '../../widgets/navigation/circular_header_button.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: AppConstants.paddingScreen),
          child: UnconstrainedBox(
            child: CircularHeaderButton(
              icon: LucideIcons.chevronLeft,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        leadingWidth: 72,
        title: const AppText(
          'Tentang Aplikasi',
          variant: AppTextVariant.h3,
          color: AppColors.primary,
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(AppConstants.paddingScreen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24),
            AppText(
              AppConstants.appName,
              variant: AppTextVariant.headlineDisplay,
            ),
            SizedBox(height: 8),
            AppText(
              'Versi 1.0.0',
              variant: AppTextVariant.bodyMedium,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 32),
            AppText(
              'Cooksnap adalah aplikasi resep masakan yang memudahkan Anda menemukan inspirasi memasak berdasarkan bahan-bahan yang Anda miliki di dapur. Dengan fitur pemindai cerdas, Anda dapat dengan mudah mengetahui resep apa saja yang bisa dibuat dari bahan-bahan tersebut.',
              variant: AppTextVariant.bodyMedium,
              height: 1.6,
            ),
            SizedBox(height: 48),
            AppText(
              '© 2026 Cooksnap Team.\nHak Cipta Dilindungi.',
              variant: AppTextVariant.caption,
              color: AppColors.textHint,
              height: 1.5,
            ),
          ],
        ),
      ),
    );
  }
}

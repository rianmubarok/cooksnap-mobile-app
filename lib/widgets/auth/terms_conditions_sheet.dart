import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../common/app_text.dart';
import '../common/bottom_sheet_handle.dart';
import '../custom_button.dart';

class TermsConditionsSheet extends StatelessWidget {
  const TermsConditionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingScreen),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXl),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: BottomSheetHandle()),
            const SizedBox(height: AppConstants.spacingLg),
            const AppText(
              'Syarat & Ketentuan',
              variant: AppTextVariant.h3,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText(
                      'Selamat datang di CookSnap. Dengan menggunakan aplikasi ini, Anda menyetujui syarat dan ketentuan berikut:',
                      variant: AppTextVariant.bodyMedium,
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    _buildSection('1. Penggunaan Aplikasi', 'CookSnap membantu Anda memindai bahan makanan dan memberikan rekomendasi resep yang relevan. Gunakan aplikasi ini untuk mempermudah pengalaman memasak Anda.'),
                    _buildSection('2. Akses Kamera & Privasi', 'Aplikasi memerlukan akses kamera dan galeri untuk fitur pemindaian bahan. Gambar yang dipindai hanya diproses untuk mengenali bahan dan tidak disebarluaskan.'),
                    _buildSection('3. Tahap Pengembangan', 'Aplikasi CookSnap saat ini masih dalam tahap pengembangan (Beta). Beberapa fitur mungkin belum berfungsi dengan sempurna atau dapat berubah di masa mendatang.'),
                    _buildSection('4. Akun & Keamanan', 'Data akun Anda seperti nama dan email disimpan secara aman. Kami tidak akan membagikan informasi pribadi Anda kepada pihak ketiga tanpa persetujuan Anda.'),
                    const SizedBox(height: AppConstants.spacingLg),
                    PrimaryButton(
                      text: 'Mengerti',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            title,
            variant: AppTextVariant.bodyMedium,
          ),
          const SizedBox(height: 4),
          AppText(
            content,
            variant: AppTextVariant.bodyMedium,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

void showTermsConditionsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: const TermsConditionsSheet(),
      ),
    ),
  );
}

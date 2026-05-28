import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_routes.dart';
import '../../widgets/auth/auth_screen_layout.dart';
import '../../widgets/common/app_text.dart';
import '../../widgets/custom_button.dart';

class VerifyEmailScreen extends StatelessWidget {
  final String email;

  const VerifyEmailScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return AuthScreenLayout(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: AppConstants.spacingXxl),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.mailCheck,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingXl),
          const AppText(
            'Verifikasi Email Anda',
            variant: AppTextVariant.h3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingMd),
          AppText(
            'Kami telah mengirimkan tautan verifikasi ke email:\n$email\n\nSilakan cek kotak masuk atau folder spam Anda, lalu klik tautan tersebut untuk mengaktifkan akun.',
            variant: AppTextVariant.bodyMedium,
            color: AppColors.textSecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingXxl),
          PrimaryButton(
            text: 'Kembali ke Masuk',
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}

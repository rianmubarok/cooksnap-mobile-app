import 'package:flutter/material.dart';
import '../../core/app_constants.dart';
import '../common/app_text.dart';

/// Footer row on auth screens: "Belum punya akun? Daftar"
class AuthFooterLink extends StatelessWidget {
  final String prompt;
  final String actionLabel;
  final VoidCallback onTap;

  const AuthFooterLink({
    super.key,
    required this.prompt,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingScreen,
        0,
        AppConstants.paddingScreen,
        AppConstants.spacingXl,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText(prompt, variant: AppTextVariant.bodySmall),
          GestureDetector(
            onTap: onTap,
            child: AppText(actionLabel, variant: AppTextVariant.link),
          ),
        ],
      ),
    );
  }
}

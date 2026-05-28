import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_constants.dart';
import '../core/app_text_styles.dart';
import '../widgets/common/app_text.dart';

enum AppSnackBarVariant { info, success, warning, error }



void showAppSnackBar(
  BuildContext context,
  String message, {
  AppSnackBarVariant variant = AppSnackBarVariant.info,
  Duration duration = const Duration(seconds: 2),
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  messenger.showSnackBar(
      SnackBar(
        content: AppText(
          message,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 32, left: AppConstants.paddingScreen, right: AppConstants.paddingScreen),
        duration: duration,
        backgroundColor: AppColors.chipBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
      ),
    );
}


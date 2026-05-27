import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_constants.dart';
import '../core/app_text_styles.dart';
import '../widgets/common/app_text.dart';

enum AppSnackBarVariant { info, success, warning, error }

Color _backgroundFor(AppSnackBarVariant variant) {
  switch (variant) {
    case AppSnackBarVariant.success:
      return AppColors.success;
    case AppSnackBarVariant.warning:
      return AppColors.warning;
    case AppSnackBarVariant.error:
      return AppColors.error;
    case AppSnackBarVariant.info:
      return AppColors.info;
  }
}

void showAppSnackBar(
  BuildContext context,
  String message, {
  AppSnackBarVariant variant = AppSnackBarVariant.info,
  Duration duration = const Duration(seconds: 2),
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: AppText(
          message,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textOnPrimary),
        ),
        behavior: SnackBarBehavior.floating,
        duration: duration,
        backgroundColor: _backgroundFor(variant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
      ),
    );
}


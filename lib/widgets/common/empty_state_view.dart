import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';

/// Centered empty-state placeholder for lists and tabs.
class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final bool showIconCircle;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.showIconCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingScreen,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIconCircle)
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: iconColor ?? AppColors.textHint,
                ),
              )
            else
              Icon(
                icon,
                size: 72,
                color: (iconColor ?? AppColors.textHint).withValues(alpha: 0.5),
              ),
            SizedBox(
              height: showIconCircle
                  ? AppConstants.spacingLg
                  : AppConstants.spacingMd,
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: showIconCircle
                  ? AppTextStyles.h3
                  : AppTextStyles.h4.copyWith(
                      color: AppColors.textSecondary,
                    ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(height: 1.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

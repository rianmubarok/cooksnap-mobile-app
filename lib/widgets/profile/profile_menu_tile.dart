import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../common/app_text.dart';

/// Single row in the profile settings list.
class ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;
  final Color? iconColor;
  final bool hasBadge;

  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
    this.iconColor,
    this.hasBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
        padding: const EdgeInsets.all(AppConstants.paddingCard),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: iconColor ??
                      (isDestructive ? AppColors.error : AppColors.textHint),
                ),
                if (hasBadge)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD97706),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: AppText(
                title,
                variant: AppTextVariant.bodyMedium,
                color: isDestructive ? AppColors.error : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

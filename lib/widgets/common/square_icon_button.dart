import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';

/// Square primary action button (e.g. add ingredient).
class SquareIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final double size;

  const SquareIconButton({
    super.key,
    required this.onPressed,
    this.icon = Icons.add_rounded,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: AppColors.white, size: size * 0.47),
        ),
      ),
    );
  }
}

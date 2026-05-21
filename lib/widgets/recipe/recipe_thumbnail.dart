import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class RecipeThumbnail extends StatelessWidget {
  final double iconSize;

  const RecipeThumbnail({super.key, this.iconSize = 48});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.restaurant_menu_rounded,
        size: iconSize,
        color: AppColors.primary.withValues(alpha: 0.35),
      ),
    );
  }
}

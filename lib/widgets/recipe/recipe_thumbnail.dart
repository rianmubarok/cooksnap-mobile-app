import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';

/// Placeholder thumbnail for recipes that have no [imageUrl].
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

/// Rounded square recipe image or placeholder.
class RecipeThumbnailBox extends StatelessWidget {
  final double size;
  final double? iconSize;
  final String? imageUrl;

  const RecipeThumbnailBox({
    super.key,
    this.size = 72,
    this.iconSize,
    this.imageUrl,
  });

  bool get _hasImage =>
      imageUrl != null && imageUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      child: Container(
        width: size,
        height: size,
        color: AppColors.primary.withValues(alpha: 0.08),
        child: _hasImage
            ? Image.network(
                imageUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => RecipeThumbnail(
                  iconSize: iconSize ?? size * 0.44,
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: size * 0.3,
                      height: size * 0.3,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                    ),
                  );
                },
              )
            : RecipeThumbnail(iconSize: iconSize ?? size * 0.44),
      ),
    );
  }
}

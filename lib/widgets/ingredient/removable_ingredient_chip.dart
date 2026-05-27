import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../utils/string_utils.dart';
import '../common/app_text.dart';

/// Chip bahan terpilih — lebar mengikuti teks (hug content), bukan pill kategori.
class RemovableIngredientChip extends StatefulWidget {
  final String label;
  final VoidCallback onRemove;

  const RemovableIngredientChip({
    super.key,
    required this.label,
    required this.onRemove,
  });

  @override
  State<RemovableIngredientChip> createState() =>
      _RemovableIngredientChipState();
}

class _RemovableIngredientChipState extends State<RemovableIngredientChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleRemove() async {
    if (_controller.isAnimating || _controller.isDismissed) return;
    await _controller.reverse();
    if (mounted) {
      widget.onRemove();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Container(
          height: AppConstants.chipHeight,
          padding: const EdgeInsets.only(left: 16, right: 8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppConstants.radiusRound),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                StringUtils.capitalizeWords(widget.label),
                variant: AppTextVariant.bodyMedium,
                color: AppColors.white,
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: _handleRemove,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.chipBackground,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.x,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

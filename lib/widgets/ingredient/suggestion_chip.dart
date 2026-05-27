import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../common/app_text.dart';

/// Chip saran — lebar mengikuti teks, gaya netral seperti sebelumnya.
class SuggestionChip extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool animateOutOnTap;

  const SuggestionChip({
    super.key,
    required this.label,
    this.onTap,
    this.isSelected = false,
    this.animateOutOnTap = false,
  });

  @override
  State<SuggestionChip> createState() => _SuggestionChipState();
}

class _SuggestionChipState extends State<SuggestionChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (widget.onTap == null || _controller.isAnimating || _controller.isDismissed) return;
    
    if (widget.animateOutOnTap) {
      await _controller.reverse();
    }
    
    if (mounted) {
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: GestureDetector(
          onTap: _handleTap,
          child: Container(
            height: AppConstants.chipHeight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppConstants.radiusRound),
              border: Border.all(
                color: widget.isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isSelected) ...[
                  const Icon(LucideIcons.check, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  AppText(
                    widget.label,
                    variant: AppTextVariant.bodyMedium,
                    color: AppColors.primary,
                  ),
                ] else
                  AppText(
                    '+ ${widget.label}',
                    variant: AppTextVariant.bodyMedium,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

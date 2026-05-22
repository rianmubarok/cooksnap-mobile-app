import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_constants.dart';

/// Primary filled button with gradient option
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool useGradient;
  final IconData? icon;
  final double iconSize;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.useGradient = false,
    this.icon,
    this.iconSize = 20,
  });

  static const double _disabledBackgroundOpacity = 0.45;

  LinearGradient _primaryGradient({required bool enabled}) {
    final opacity = enabled ? 1.0 : _disabledBackgroundOpacity;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.primary.withValues(alpha: opacity),
        const Color(0xFF2E6331).withValues(alpha: opacity),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;

    if (useGradient) {
      return Container(
        height: AppConstants.buttonHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: _primaryGradient(enabled: enabled),
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: AppColors.white, size: iconSize),
                          const SizedBox(width: AppConstants.spacingSm),
                        ],
                        Text(
                          text,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.6,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      );
    }

    return Opacity(
      opacity: enabled ? 1.0 : _disabledBackgroundOpacity,
      child: SizedBox(
        width: double.infinity,
        height: AppConstants.buttonHeight,
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: iconSize),
                      const SizedBox(width: AppConstants.spacingSm),
                    ],
                    Text(text),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Secondary outlined button
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppConstants.buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: AppConstants.spacingSm),
            ],
            Text(text),
          ],
        ),
      ),
    );
  }
}


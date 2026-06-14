import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import 'app_text.dart';

/// Displayed when a screen fails to load data — typically due to no internet
/// connection or a server error.
///
/// Shows an animated icon, descriptive message, and an optional [onRetry]
/// callback that the parent screen uses to re-trigger the fetch.
class OfflineErrorView extends StatefulWidget {
  final VoidCallback? onRetry;
  final String title;
  final String subtitle;

  const OfflineErrorView({
    super.key,
    this.onRetry,
    this.title = 'Tidak ada koneksi',
    this.subtitle =
        'Periksa koneksi internet kamu\nlalu coba lagi.',
  });

  @override
  State<OfflineErrorView> createState() => _OfflineErrorViewState();
}

class _OfflineErrorViewState extends State<OfflineErrorView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingScreen * 1.5,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.chipBackground,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    LucideIcons.wifiOff,
                    size: 42,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingLg),
              AppText(
                widget.title,
                variant: AppTextVariant.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
              if (widget.onRetry != null) ...[
                const SizedBox(height: AppConstants.spacingXl),
                _RetryButton(onRetry: widget.onRetry!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RetryButton extends StatefulWidget {
  final VoidCallback onRetry;
  const _RetryButton({required this.onRetry});

  @override
  State<_RetryButton> createState() => _RetryButtonState();
}

class _RetryButtonState extends State<_RetryButton> {
  bool _isRetrying = false;

  Future<void> _handleRetry() async {
    if (_isRetrying) return;
    setState(() => _isRetrying = true);
    // Brief delay to show the spinner before the parent re-fetches
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      widget.onRetry();
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) setState(() => _isRetrying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppConstants.buttonHeight,
      child: ElevatedButton.icon(
        onPressed: _isRetrying ? null : _handleRetry,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.primaryLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingXl,
          ),
        ),
        icon: _isRetrying
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textOnPrimary,
                ),
              )
            : const Icon(LucideIcons.refreshCw, size: 18),
        label: Text(
          _isRetrying ? 'Mencoba...' : 'Coba Lagi',
          style: AppTextStyles.buttonLarge,
        ),
      ),
    );
  }
}

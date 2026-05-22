import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_constants.dart';
import '../../../providers/ai_detection_provider.dart';

class ScannerControlsBar extends StatelessWidget {
  final bool hasImage;
  final VoidCallback onGallery;
  final VoidCallback onCapture;
  final VoidCallback onClear;

  const ScannerControlsBar({
    super.key,
    required this.hasImage,
    required this.onGallery,
    required this.onCapture,
    required this.onClear,
  });

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur segera hadir'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.scannerDark,
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingScreen,
        AppConstants.spacingMd,
        AppConstants.paddingScreen,
        AppConstants.spacingXl,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(
            icon: Icons.photo_library_outlined,
            label: 'Galeri',
            onTap: onGallery,
          ),
          GestureDetector(
            onTap: onCapture,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 4),
              ),
              child: Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Consumer<AiDetectionProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Padding(
                          padding: EdgeInsets.all(14),
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 3,
                          ),
                        );
                      }
                      return Icon(
                        hasImage ? Icons.search : Icons.camera,
                        color: AppColors.white,
                        size: 28,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          hasImage
              ? _ActionButton(
                  icon: Icons.close,
                  label: 'Batal',
                  onTap: onClear,
                )
              : _ActionButton(
                  icon: Icons.flip_camera_ios_outlined,
                  label: 'Flip',
                  onTap: () => _showComingSoon(context),
                ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: AppColors.white, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppColors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

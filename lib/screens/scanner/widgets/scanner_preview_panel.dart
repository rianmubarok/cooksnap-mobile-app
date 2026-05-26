import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_constants.dart';
import '../../../core/app_text_styles.dart';

class ScannerPreviewPanel extends StatelessWidget {
  final Uint8List? imageBytes;
  final CameraController? cameraController;
  final bool isCameraInitialized;

  const ScannerPreviewPanel({
    super.key, 
    this.imageBytes,
    this.cameraController,
    this.isCameraInitialized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          color: AppColors.scannerDark,
          child: imageBytes != null
              ? Image.memory(
                  imageBytes!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
              : isCameraInitialized && cameraController != null
                  ? SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: CameraPreview(cameraController!),
                    )
                  : const SizedBox(),
        ),
        if (imageBytes == null)
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.6),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  ),
                  child: Stack(
                    children: [
                      const _ScannerCorner(
                        alignment: Alignment.topLeft,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(AppConstants.radiusLg)),
                      ),
                      const _ScannerCorner(
                        alignment: Alignment.topRight,
                        borderRadius: BorderRadius.only(topRight: Radius.circular(AppConstants.radiusLg)),
                      ),
                      const _ScannerCorner(
                        alignment: Alignment.bottomLeft,
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(AppConstants.radiusLg)),
                      ),
                      const _ScannerCorner(
                        alignment: Alignment.bottomRight,
                        borderRadius: BorderRadius.only(bottomRight: Radius.circular(AppConstants.radiusLg)),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              LucideIcons.camera,
                              color: AppColors.white,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Arahkan kamera ke\nbahan makanan',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppConstants.spacingMd,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: Text(
              'AI akan mendeteksi bahan makanan secara otomatis',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScannerCorner extends StatelessWidget {
  final Alignment alignment;
  final BorderRadius borderRadius;

  const _ScannerCorner({
    required this.alignment,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border(
            top: alignment == Alignment.topLeft ||
                    alignment == Alignment.topRight
                ? const BorderSide(color: AppColors.primary, width: 3)
                : BorderSide.none,
            bottom: alignment == Alignment.bottomLeft ||
                    alignment == Alignment.bottomRight
                ? const BorderSide(color: AppColors.primary, width: 3)
                : BorderSide.none,
            left: alignment == Alignment.topLeft ||
                    alignment == Alignment.bottomLeft
                ? const BorderSide(color: AppColors.primary, width: 3)
                : BorderSide.none,
            right: alignment == Alignment.topRight ||
                    alignment == Alignment.bottomRight
                ? const BorderSide(color: AppColors.primary, width: 3)
                : BorderSide.none,
          ),
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

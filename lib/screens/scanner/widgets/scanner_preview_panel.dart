import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_constants.dart';

class ScannerPreviewPanel extends StatelessWidget {
  final Uint8List? imageBytes;

  const ScannerPreviewPanel({super.key, this.imageBytes});

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
              : Column(
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
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusLg),
                      ),
                      child: const Stack(
                        children: [
                          _ScannerCorner(
                            alignment: Alignment.topLeft,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(AppConstants.radiusLg),
                            ),
                          ),
                          _ScannerCorner(
                            alignment: Alignment.topRight,
                            borderRadius: BorderRadius.only(
                              topRight:
                                  Radius.circular(AppConstants.radiusLg),
                            ),
                          ),
                          _ScannerCorner(
                            alignment: Alignment.bottomLeft,
                            borderRadius: BorderRadius.only(
                              bottomLeft:
                                  Radius.circular(AppConstants.radiusLg),
                            ),
                          ),
                          _ScannerCorner(
                            alignment: Alignment.bottomRight,
                            borderRadius: BorderRadius.only(
                              bottomRight:
                                  Radius.circular(AppConstants.radiusLg),
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt_outlined,
                                  color: AppColors.white,
                                  size: 48,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Arahkan kamera ke\nbahan makanan',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
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
            child: const Text(
              'AI akan mendeteksi bahan makanan secara otomatis',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.white, fontSize: 14),
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

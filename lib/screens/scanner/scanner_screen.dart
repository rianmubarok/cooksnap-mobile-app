import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/custom_button.dart';

/// Scanner Screen — Camera view for ingredient detection
/// Static UI only (camera integration later)
class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Scan Bahan Makanan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_off_rounded),
            onPressed: () {
              // TODO: Toggle flash
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Camera Preview Placeholder
          Expanded(
            child: Stack(
              children: [
                // Simulated Camera View
                Container(
                  width: double.infinity,
                  color: const Color(0xFF1A1A2E),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Scanner Frame
                      Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.6),
                            width: 2,
                          ),
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusLg),
                        ),
                        child: Stack(
                          children: [
                            // Corner Accents
                            _buildCorner(
                                Alignment.topLeft, const BorderRadius.only(topLeft: Radius.circular(AppConstants.radiusLg))),
                            _buildCorner(
                                Alignment.topRight, const BorderRadius.only(topRight: Radius.circular(AppConstants.radiusLg))),
                            _buildCorner(
                                Alignment.bottomLeft, const BorderRadius.only(bottomLeft: Radius.circular(AppConstants.radiusLg))),
                            _buildCorner(
                                Alignment.bottomRight, const BorderRadius.only(bottomRight: Radius.circular(AppConstants.radiusLg))),

                            // Center Icon
                            const Center(
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

                // Bottom instruction
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
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: const Text(
                      'AI akan mendeteksi bahan makanan secara otomatis',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Controls
          Container(
            color: const Color(0xFF1A1A2E),
            padding: const EdgeInsets.fromLTRB(
              AppConstants.paddingScreen,
              AppConstants.spacingMd,
              AppConstants.paddingScreen,
              AppConstants.spacingXl,
            ),
            child: Column(
              children: [
                // Action Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Gallery
                    _buildActionButton(
                      Icons.photo_library_outlined,
                      'Galeri',
                      () {
                        // TODO: Pick from gallery
                      },
                    ),

                    // Capture Button
                    GestureDetector(
                      onTap: () {
                        // TODO: Capture photo
                        _showDetectionResult(context);
                      },
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.white,
                            width: 4,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera,
                              color: AppColors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Flip Camera
                    _buildActionButton(
                      Icons.flip_camera_ios_outlined,
                      'Flip',
                      () {
                        // TODO: Flip camera
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(Alignment alignment, BorderRadius borderRadius) {
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

  Widget _buildActionButton(
      IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: AppColors.white, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetectionResult(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXl),
        ),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(AppConstants.paddingScreen),
              child: ListView(
                controller: scrollController,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusRound),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingLg),

                  const Text(
                    'Bahan Terdeteksi 🎯',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingMd),

                  // Detected Ingredients (Dummy)
                  _buildDetectedItem('🥚', 'Telur', '90% akurat'),
                  _buildDetectedItem('🧅', 'Bawang Merah', '85% akurat'),
                  _buildDetectedItem('🧄', 'Bawang Putih', '88% akurat'),
                  _buildDetectedItem('🌶️', 'Cabai', '82% akurat'),
                  _buildDetectedItem('🍚', 'Nasi', '95% akurat'),

                  const SizedBox(height: AppConstants.spacingLg),

                  PrimaryButton(
                    text: 'Cari Resep dari Bahan Ini',
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Navigate to recipe results
                    },
                    useGradient: true,
                    icon: Icons.search,
                  ),

                  const SizedBox(height: AppConstants.spacingMd),

                  SecondaryButton(
                    text: 'Scan Ulang',
                    onPressed: () => Navigator.pop(context),
                    icon: Icons.refresh,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetectedItem(
      String emoji, String name, String accuracy) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.15),
              borderRadius:
                  BorderRadius.circular(AppConstants.radiusRound),
            ),
            child: Text(
              accuracy,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

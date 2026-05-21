import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/custom_button.dart';
import '../../providers/ai_detection_provider.dart';
import '../recipe_recommendation_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  Uint8List? _imageBytes;

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImage = image;
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Gagal memilih gambar: ${e.toString()}');
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImage = image;
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Gagal mengambil foto: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _scanIngredients() async {
    if (_selectedImage == null) {
      _pickImageFromCamera();
      return;
    }

    final provider = context.read<AiDetectionProvider>();
    _showDetectionResult(context); // Show bottom sheet immediately for loading
    await provider.scanIngredients(_selectedImage!);
  }

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
                  child: _imageBytes != null
                      ? Image.memory(
                          _imageBytes!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        )
                      : Column(
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
                                borderRadius: BorderRadius.circular(
                                    AppConstants.radiusLg),
                              ),
                              child: Stack(
                                children: [
                                  // Corner Accents
                                  _buildCorner(Alignment.topLeft,
                                      const BorderRadius.only(topLeft: Radius.circular(AppConstants.radiusLg))),
                                  _buildCorner(Alignment.topRight,
                                      const BorderRadius.only(topRight: Radius.circular(AppConstants.radiusLg))),
                                  _buildCorner(Alignment.bottomLeft,
                                      const BorderRadius.only(bottomLeft: Radius.circular(AppConstants.radiusLg))),
                                  _buildCorner(Alignment.bottomRight,
                                      const BorderRadius.only(bottomRight: Radius.circular(AppConstants.radiusLg))),

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
                      _pickImageFromGallery,
                    ),

                    // Capture Button
                    GestureDetector(
                      onTap: _scanIngredients,
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
                            child: Consumer<AiDetectionProvider>(
                              builder: (context, provider, child) {
                                if (provider.isLoading) {
                                  return const Padding(
                                    padding: EdgeInsets.all(14.0),
                                    child: CircularProgressIndicator(
                                      color: AppColors.white,
                                      strokeWidth: 3,
                                    ),
                                  );
                                }
                                return Icon(
                                  _imageBytes != null ? Icons.search : Icons.camera,
                                  color: AppColors.white,
                                  size: 28,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Clear / Flip Camera
                    _imageBytes != null
                        ? _buildActionButton(
                            Icons.close,
                            'Batal',
                            () {
                              setState(() {
                                _imageBytes = null;
                                _selectedImage = null;
                              });
                            },
                          )
                        : _buildActionButton(
                            Icons.flip_camera_ios_outlined,
                            'Flip',
                            () {},
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
            return Consumer<AiDetectionProvider>(
              builder: (context, provider, child) {
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
                            borderRadius: BorderRadius.circular(
                                AppConstants.radiusRound),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingLg),

                      if (provider.isLoading) ...[
                        const SizedBox(height: 40),
                        const Center(child: CircularProgressIndicator()),
                        const SizedBox(height: 16),
                        const Center(
                          child: Text(
                            'AI sedang menganalisis bahan...',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ] else if (provider.hasError) ...[
                        const SizedBox(height: 20),
                        Icon(Icons.error_outline,
                            size: 60, color: Colors.red.shade400),
                        const SizedBox(height: 16),
                        Text(
                          provider.errorMessage ?? 'Terjadi kesalahan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          text: 'Tutup',
                          onPressed: () => Navigator.pop(context),
                        ),
                      ] else if (provider.hasResult) ...[
                        Text(
                          'Bahan Terdeteksi 🎯 (${provider.detectedIngredients.length})',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingMd),
                        if (provider.detectedIngredients.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Tidak ada bahan makanan yang terdeteksi.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        else
                          ...provider.detectedIngredients.map((ingredient) =>
                              _buildDetectedItem('✅', ingredient, 'AI Detected')),
                        const SizedBox(height: AppConstants.spacingLg),
                        PrimaryButton(
                          text: 'Cari Resep dari Bahan Ini',
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RecipeRecommendationScreen(
                                  ingredients: provider.detectedIngredients,
                                ),
                              ),
                            );
                          },
                          useGradient: true,
                          icon: Icons.search,
                        ),
                        const SizedBox(height: AppConstants.spacingMd),
                        SecondaryButton(
                          text: 'Scan Ulang',
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              _selectedImage = null;
                              _imageBytes = null;
                            });
                          },
                          icon: Icons.refresh,
                        ),
                      ]
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDetectedItem(String emoji, String name, String tag) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
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
              borderRadius: BorderRadius.circular(AppConstants.radiusRound),
            ),
            child: Text(
              tag,
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

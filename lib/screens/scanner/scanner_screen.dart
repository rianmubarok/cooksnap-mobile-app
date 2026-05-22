import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/ai_detection_provider.dart';
import 'widgets/scan_result_bottom_sheet.dart';
import 'widgets/scanner_controls_bar.dart';
import 'widgets/scanner_preview_panel.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  Uint8List? _imageBytes;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image == null) return;
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImage = image;
        _imageBytes = bytes;
      });
    } catch (e) {
      _showErrorSnackBar(
        source == ImageSource.camera
            ? 'Gagal mengambil foto: $e'
            : 'Gagal memilih gambar: $e',
      );
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
      _imageBytes = null;
    });
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
      await _pickImage(ImageSource.camera);
      return;
    }

    // Reset state terlebih dahulu agar bottom sheet langsung menampilkan
    // state loading ketika pertama kali dibuka.
    final provider = context.read<AiDetectionProvider>();
    provider.reset();

    // Buka bottom sheet dan mulai scan secara bersamaan.
    showScanResultBottomSheet(context, onRescan: _clearImage);
    provider.scanIngredients(_selectedImage!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scannerDark,
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
      ),
      body: Column(
        children: [
          Expanded(child: ScannerPreviewPanel(imageBytes: _imageBytes)),
          ScannerControlsBar(
            hasImage: _imageBytes != null,
            onGallery: () => _pickImage(ImageSource.gallery),
            onCapture: _scanIngredients,
            onClear: _clearImage,
          ),
        ],
      ),
    );
  }
}

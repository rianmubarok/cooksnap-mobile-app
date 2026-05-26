import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../../providers/ai_detection_provider.dart';
import 'widgets/scan_result_bottom_sheet.dart';
import 'widgets/scanner_controls_bar.dart';
import 'widgets/scanner_detected_ingredients_bar.dart';
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
  
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras!.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar('Gagal menginisialisasi kamera: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

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
    context.read<AiDetectionProvider>().reset();
    setState(() {
      _selectedImage = null;
      _imageBytes = null;
    });
  }

  void _handleRescan() {
    _clearImage();
  }

  void _openScanResultsSheet() {
    showScanResultBottomSheet(context, onRescan: _handleRescan);
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

  Future<void> _pickAndScan(ImageSource source) async {
    await _pickImage(source);
    if (_selectedImage != null) {
      _startScanning(forceRescan: true);
    }
  }

  Future<void> _takePictureAndScan() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      _showErrorSnackBar('Kamera belum siap');
      return;
    }
    
    try {
      final XFile image = await _cameraController!.takePicture();
      final bytes = await image.readAsBytes();
      
      setState(() {
        _selectedImage = image;
        _imageBytes = bytes;
      });
      
      _startScanning(forceRescan: true);
    } catch (e) {
      _showErrorSnackBar('Gagal mengambil foto: $e');
    }
  }

  void _startScanning({bool forceRescan = false}) {
    final provider = context.read<AiDetectionProvider>();

    // Hasil scan tetap di provider; buka sheet tanpa reset jika sudah ada hasil.
    if (!forceRescan && provider.hasResult) {
      _openScanResultsSheet();
      return;
    }

    provider.reset();
    _openScanResultsSheet();
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
          AppStrings.scanIngredientsTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ScannerPreviewPanel(
              imageBytes: _imageBytes,
              cameraController: _cameraController,
              isCameraInitialized: _isCameraInitialized,
            ),
          ),
          Consumer<AiDetectionProvider>(
            builder: (context, provider, _) {
              if (!provider.hasResult) return const SizedBox.shrink();
              return ScannerDetectedIngredientsBar(
                ingredients: provider.detectedIngredients,
                onTap: _openScanResultsSheet,
              );
            },
          ),
          ScannerControlsBar(
            hasImage: _imageBytes != null,
            onGallery: () => _pickAndScan(ImageSource.gallery),
            onCapture: () => _selectedImage == null
                ? _takePictureAndScan()
                : () => _startScanning(forceRescan: true),
            onClear: _clearImage,
          ),
        ],
      ),
    );
  }
}


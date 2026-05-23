import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/scan_result_model.dart';
import '../services/ai_detection_service.dart';

enum DetectionState { idle, loading, success, error }

/// Manages the AI ingredient-detection flow.
///
/// [AiDetectionService] is injected via the constructor so the provider
/// can be unit-tested with a mock service without hitting the real API.
class AiDetectionProvider extends ChangeNotifier {
  AiDetectionProvider(this._aiDetectionService);

  final AiDetectionService _aiDetectionService;

  DetectionState _state = DetectionState.idle;
  ScanResult? _scanResult;
  String? _errorMessage;

  DetectionState get state => _state;
  ScanResult? get scanResult => _scanResult;
  String? get errorMessage => _errorMessage;
  List<String> get detectedIngredients =>
      _scanResult?.detectedIngredients ?? [];
  bool get isLoading => _state == DetectionState.loading;
  bool get hasError => _state == DetectionState.error;
  bool get hasResult => _state == DetectionState.success && _scanResult != null;

  Future<void> scanIngredients(XFile image) async {
    _state = DetectionState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _aiDetectionService.detectIngredients(image);
      _scanResult = result;

      if (result.isSuccess) {
        _state = DetectionState.success;
        _errorMessage = null;
      } else {
        _state = DetectionState.error;
        _errorMessage = result.errorMessage ?? 'Terjadi kesalahan tidak diketahui';
      }
    } catch (e) {
      _state = DetectionState.error;
      _errorMessage = 'Gagal memproses gambar: ${e.toString()}';
      _scanResult = ScanResult.error(_errorMessage!);
    }

    notifyListeners();
  }

  void reset() {
    _state = DetectionState.idle;
    _scanResult = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    if (_state == DetectionState.error) {
      _state = DetectionState.idle;
      _errorMessage = null;
      notifyListeners();
    }
  }
}

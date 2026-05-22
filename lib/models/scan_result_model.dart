class ScanResult {
  final List<String> detectedIngredients;
  final DateTime scanTimestamp;
  final bool isSuccess;
  final String? errorMessage;

  ScanResult({
    required this.detectedIngredients,
    required this.scanTimestamp,
    required this.isSuccess,
    this.errorMessage,
  });

  factory ScanResult.success(List<String> ingredients) {
    return ScanResult(
      detectedIngredients: ingredients,
      scanTimestamp: DateTime.now(),
      isSuccess: true,
      errorMessage: null,
    );
  }

  factory ScanResult.error(String message) {
    return ScanResult(
      detectedIngredients: [],
      scanTimestamp: DateTime.now(),
      isSuccess: false,
      errorMessage: message,
    );
  }
}

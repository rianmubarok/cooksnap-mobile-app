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

  Map<String, dynamic> toJson() {
    return {
      'detectedIngredients': detectedIngredients,
      'scanTimestamp': scanTimestamp.toIso8601String(),
      'isSuccess': isSuccess,
      'errorMessage': errorMessage,
    };
  }

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      detectedIngredients: List<String>.from(json['detectedIngredients'] ?? []),
      scanTimestamp: DateTime.parse(json['scanTimestamp']),
      isSuccess: json['isSuccess'] ?? false,
      errorMessage: json['errorMessage'],
    );
  }
}

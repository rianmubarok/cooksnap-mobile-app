class ApiConfig {
  static const String geminiApiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static const String geminiModel = 'gemini-2.5-flash';
  static const String geminiApiKey = 'AIzaSyAvMNsdheDPKFIcj7csx6aYvaLjOfdFvmk';

  static String get geminiVisionEndpoint =>
      '$geminiApiBaseUrl/models/$geminiModel:generateContent?key=$geminiApiKey';
}

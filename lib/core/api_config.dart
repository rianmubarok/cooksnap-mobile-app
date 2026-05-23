import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static const String geminiApiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static const String geminiModel = 'gemini-2.5-flash';
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static String get geminiVisionEndpoint =>
      '$geminiApiBaseUrl/models/$geminiModel:generateContent?key=$geminiApiKey';
}

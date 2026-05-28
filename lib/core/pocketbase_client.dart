import 'dart:io' show Platform;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocketbase/pocketbase.dart';

/// Singleton wrapper for PocketBase client.
class PocketBaseClient {
  PocketBaseClient._();

  static PocketBase? _instance;

  /// Returns the initialized PocketBase instance.
  static PocketBase get instance {
    if (_instance == null) {
      String defaultUrl = 'http://127.0.0.1:8090';
      
      // Jika berjalan di Android Emulator, 127.0.0.1 adalah emulator itu sendiri.
      // Kita harus menggunakan 10.0.2.2 untuk merujuk ke komputer host (Windows).
      try {
        if (Platform.isAndroid) {
          defaultUrl = 'http://10.0.2.2:8090';
        }
      } catch (_) {}

      final String baseUrl = dotenv.env['POCKETBASE_URL'] ?? defaultUrl;
      _instance = PocketBase(baseUrl);
    }
    return _instance!;
  }

  /// Helper to get the auth store directly
  static AuthStore get authStore => instance.authStore;
}

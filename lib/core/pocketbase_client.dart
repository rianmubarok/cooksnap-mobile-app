import 'dart:io' show Platform;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton wrapper for PocketBase client.
class PocketBaseClient {
  PocketBaseClient._();

  static PocketBase? _instance;

  /// Initializes the PocketBase instance with a persistent AsyncAuthStore.
  /// This should be called in main.dart before runApp.
  static Future<void> init() async {
    if (_instance != null) return;
    
    String defaultUrl = 'http://127.0.0.1:8090';
    try {
      if (Platform.isAndroid) {
        defaultUrl = 'http://10.0.2.2:8090';
      }
    } catch (_) {}

    final String baseUrl = dotenv.env['POCKETBASE_URL'] ?? defaultUrl;
    
    final prefs = await SharedPreferences.getInstance();
    final store = AsyncAuthStore(
      save: (String data) async => prefs.setString('pb_auth', data),
      initial: prefs.getString('pb_auth'),
    );

    _instance = PocketBase(baseUrl, authStore: store);
  }

  /// Returns the initialized PocketBase instance.
  static PocketBase get instance {
    if (_instance == null) {
      // Fallback if not initialized via init()
      String defaultUrl = 'http://127.0.0.1:8090';
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

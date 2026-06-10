import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  // Singleton pattern
  RemoteConfigService._internal();
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  static RemoteConfigService get instance => _instance;

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        // Untuk development, kita set 0 agar langsung fetch tanpa cache delay
        // CATATAN: Ubah jadi misal Duration(hours: 1) jika rilis ke Play Store!
        minimumFetchInterval: kDebugMode 
            ? const Duration(seconds: 0) 
            : const Duration(hours: 1),
      ));

      // Atur nilai default sebagai fallback jika gagal fetch
      await _remoteConfig.setDefaults(const {
        "POCKETBASE_URL": "http://127.0.0.1:8090", // URL Default
      });

      // Ambil dan terapkan nilai dari server
      await _remoteConfig.fetchAndActivate();
      
      debugPrint('RemoteConfig initialized successfully. URL: $pocketbaseUrl');
    } catch (e) {
      debugPrint('Error initializing RemoteConfig: $e');
    }
  }

  // Getter untuk URL Pocketbase
  String get pocketbaseUrl {
    return _remoteConfig.getString('POCKETBASE_URL');
  }
}

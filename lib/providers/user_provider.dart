import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_strings.dart';
import '../core/pocketbase_client.dart';
import '../models/user_model.dart';

/// User profile state — connected to PocketBase auth.
class UserProvider extends ChangeNotifier {
  static const String _keyOnboarding = 'onboarding_completed';

  bool _hasCompletedOnboarding = false;
  bool _initialized = false;
  Completer<void>? _initCompleter;

  // PocketBase client
  final pb = PocketBaseClient.instance;

  UserModel? _userModel;

  bool get isLoggedIn => pb.authStore.isValid;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get isInitialized => _initialized;
  
  // Expose fields from UserModel safely
  String get name => _userModel?.name ?? '';
  String get email => _userModel?.email ?? '';
  bool get isPremium => _userModel?.isPremium ?? false;
  int get dailyScanCount => _userModel?.dailyScanCount ?? 0;
  
  static const int freeScanLimit = 3;
  bool get canScan => isPremium || dailyScanCount < freeScanLimit;

  String get firstName {
    if (name.isEmpty) return AppStrings.defaultUserName;
    return name.split(' ').first;
  }

  UserProvider() {
    _load();
    // Listen to PocketBase auth state changes automatically
    pb.authStore.onChange.listen((e) {
      _syncUserModel();
      notifyListeners();
    });
  }

  void _syncUserModel() {
    if (pb.authStore.isValid && pb.authStore.record != null) {
      _userModel = UserModel.fromMap(pb.authStore.record!.toJson());
    } else {
      _userModel = null;
    }
  }

  Future<void> waitForInitialization() {
    if (_initialized) return Future.value();
    _initCompleter ??= Completer<void>();
    return _initCompleter!.future;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _hasCompletedOnboarding = prefs.getBool(_keyOnboarding) ?? false;
    
    _syncUserModel(); // Sync initial state from AuthStore

    // If logged in, check if dailyScanCount needs reset for a new day
    if (_userModel != null) {
      final today = DateTime.now().toIso8601String().split('T').first;
      if (_userModel!.lastScanDate != today) {
        try {
          final updatedRecord = await pb.collection('users').update(_userModel!.id, body: {
            'daily_scan_count': 0,
            'last_scan_date': today,
          });
          pb.authStore.save(pb.authStore.token, updatedRecord);
        } catch (_) {
          // Ignore network errors on init
        }
      }
    }

    _initialized = true;
    _initCompleter?.complete();
    _initCompleter = null;
    notifyListeners();
  }

  /// Perform login against PocketBase API
  Future<void> login(String email, String password) async {
    final recordAuth = await pb.collection('users').authWithPassword(email, password).timeout(const Duration(seconds: 10));
    
    // Periksa apakah email sudah diverifikasi
    final isVerified = recordAuth.record?.getBoolValue('verified') ?? false;
    if (!isVerified) {
      pb.authStore.clear(); // Hapus sesi jika belum verifikasi
      throw Exception('unverified_email');
    }
  }
  
  static const String _keyLastRegisteredEmail = 'last_registered_email';

  /// Perform registration against PocketBase API
  Future<void> register(String name, String email, String password) async {
    await pb.collection('users').create(body: {
      'name': name,
      'email': email,
      'password': password,
      'passwordConfirm': password,
    }).timeout(const Duration(seconds: 10));
    
    // Simpan email sementara untuk autofill saat login nanti
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastRegisteredEmail, email);
    
    // Request verification email (dijalankan di background agar tidak loading lama jika SMTP error)
    pb.collection('users').requestVerification(email).catchError((_) {});
  }
  
  /// Get last registered email for autofill
  Future<String?> getLastRegisteredEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastRegisteredEmail);
  }
  
  /// Clear last registered email
  Future<void> clearLastRegisteredEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLastRegisteredEmail);
  }

  Future<void> updateProfile(String name, String email) async {
    if (!isLoggedIn) return;
    final updatedRecord = await pb.collection('users').update(_userModel!.id, body: {
      'name': name,
      'email': email,
    });
    pb.authStore.save(pb.authStore.token, updatedRecord);
  }

  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboarding, true);
    notifyListeners();
  }

  Future<void> recordScan() async {
    if (!isLoggedIn) return;
    
    final today = DateTime.now().toIso8601String().split('T').first;
    int newCount = _userModel!.dailyScanCount;
    
    if (_userModel!.lastScanDate != today) {
      newCount = 1;
    } else {
      newCount++;
    }

    final updatedRecord = await pb.collection('users').update(_userModel!.id, body: {
      'daily_scan_count': newCount,
      'last_scan_date': today,
    });
    pb.authStore.save(pb.authStore.token, updatedRecord);
  }

  Future<void> upgradeToPremium() async {
    if (!isLoggedIn) return;
    final updatedRecord = await pb.collection('users').update(_userModel!.id, body: {
      'is_premium': true,
    });
    pb.authStore.save(pb.authStore.token, updatedRecord);
  }

  Future<void> logout() async {
    pb.authStore.clear();
    // authStore.onChange will fire automatically and update the UI
  }
}

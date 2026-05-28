import 'dart:async';

import 'package:flutter/foundation.dart';
import '../core/app_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User profile state — connect to PocketBase auth later.
class UserProvider extends ChangeNotifier {
  static const String _keyLoggedIn = 'user_logged_in';
  static const String _keyName = 'user_name';
  static const String _keyEmail = 'user_email';
  static const String _keyOnboarding = 'onboarding_completed';
  static const String _keyIsPremium = 'user_is_premium';
  static const String _keyDailyScanCount = 'daily_scan_count';
  static const String _keyLastScanDate = 'last_scan_date';

  String _name = '';
  String _email = '';
  bool _isLoggedIn = false;
  bool _hasCompletedOnboarding = false;
  bool _initialized = false;
  bool _isPremium = false;
  int _dailyScanCount = 0;
  String _lastScanDate = '';
  Completer<void>? _initCompleter;

  String get name => _name;
  String get email => _email;
  bool get isLoggedIn => _isLoggedIn;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get isInitialized => _initialized;
  bool get isPremium => _isPremium;
  int get dailyScanCount => _dailyScanCount;
  
  static const int freeScanLimit = 3;
  bool get canScan => _isPremium || _dailyScanCount < freeScanLimit;

  String get firstName {
    if (_name.isEmpty) return AppStrings.defaultUserName;
    return _name.split(' ').first;
  }

  UserProvider() {
    _load();
  }

  Future<void> waitForInitialization() {
    if (_initialized) return Future.value();
    _initCompleter ??= Completer<void>();
    return _initCompleter!.future;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(_keyLoggedIn) ?? false;
    _name = prefs.getString(_keyName) ?? '';
    _email = prefs.getString(_keyEmail) ?? '';
    _hasCompletedOnboarding = prefs.getBool(_keyOnboarding) ?? false;
    
    _isPremium = prefs.getBool(_keyIsPremium) ?? false;
    _dailyScanCount = prefs.getInt(_keyDailyScanCount) ?? 0;
    _lastScanDate = prefs.getString(_keyLastScanDate) ?? '';

    // Reset daily count if it's a new day
    final today = DateTime.now().toIso8601String().split('T').first;
    if (_lastScanDate != today) {
      _dailyScanCount = 0;
      _lastScanDate = today;
      await prefs.setInt(_keyDailyScanCount, 0);
      await prefs.setString(_keyLastScanDate, today);
    }

    _initialized = true;
    _initCompleter?.complete();
    _initCompleter = null;
    notifyListeners();
  }

  Future<void> setUser(String name, String email) async {
    _name = name;
    _email = email;
    _isLoggedIn = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyEmail, email);
    notifyListeners();
  }

  Future<void> updateProfile(String name, String email) async {
    _name = name;
    _email = email;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyEmail, email);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboarding, true);
    notifyListeners();
  }

  Future<void> recordScan() async {
    final today = DateTime.now().toIso8601String().split('T').first;
    if (_lastScanDate != today) {
      _dailyScanCount = 1;
      _lastScanDate = today;
    } else {
      _dailyScanCount++;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDailyScanCount, _dailyScanCount);
    await prefs.setString(_keyLastScanDate, _lastScanDate);
    notifyListeners();
  }

  Future<void> upgradeToPremium() async {
    _isPremium = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPremium, true);
    notifyListeners();
  }

  Future<void> logout() async {
    _name = '';
    _email = '';
    _isLoggedIn = false;
    _isPremium = false;
    _dailyScanCount = 0;
    _lastScanDate = '';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, false);
    await prefs.remove(_keyName);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyIsPremium);
    await prefs.remove(_keyDailyScanCount);
    await prefs.remove(_keyLastScanDate);
    notifyListeners();
  }
}

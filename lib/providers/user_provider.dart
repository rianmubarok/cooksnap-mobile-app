import 'package:flutter/foundation.dart';

/// UserProvider — Manages user profile state
/// TODO Genard: Connect to PocketBase auth and user data
class UserProvider extends ChangeNotifier {
  String _name = 'Ashab Ibnu Abdul Aziz';
  String _email = 'ashab@cooksnap.id';
  bool _isLoggedIn = false;

  String get name => _name;
  String get email => _email;
  bool get isLoggedIn => _isLoggedIn;

  void setUser(String name, String email) {
    _name = name;
    _email = email;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _name = '';
    _email = '';
    _isLoggedIn = false;
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';

/// User profile state — connect to PocketBase auth later.
class UserProvider extends ChangeNotifier {
  String _name = '';
  String _email = '';
  bool _isLoggedIn = false;

  String get name => _name;
  String get email => _email;
  bool get isLoggedIn => _isLoggedIn;

  String get firstName {
    if (_name.isEmpty) return 'User';
    return _name.split(' ').first;
  }

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

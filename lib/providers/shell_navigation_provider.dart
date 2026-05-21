import 'package:flutter/foundation.dart';

/// Tab indices for [MainShellScreen] bottom navigation.
class ShellTabs {
  ShellTabs._();

  static const int home = 0;
  static const int ingredients = 1;
  static const int favorites = 2;
  static const int profile = 3;
}

/// Controls which tab is visible in the main shell.
class ShellNavigationProvider extends ChangeNotifier {
  int _currentIndex = ShellTabs.home;

  int get currentIndex => _currentIndex;

  void selectTab(int index) {
    if (index < 0 || index > ShellTabs.profile) return;
    if (_currentIndex == index) return;
    _currentIndex = index;
    notifyListeners();
  }
}

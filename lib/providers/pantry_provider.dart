import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/string_utils.dart';

class PantryProvider extends ChangeNotifier {
  static const String _prefsKey = 'pantry_essentials';

  static const List<String> _defaultEssentials = [
    'Air',
    'Garam',
    'Gula',
    'Merica',
    'Minyak Goreng',
    'Bawang Putih',
    'Bawang Merah',
    'Penyedap Rasa',
  ];

  List<String> _items = [];

  List<String> get items => _items;

  PantryProvider() {
    _loadItems();
  }

  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final savedItems = prefs.getStringList(_prefsKey);

    if (savedItems == null) {
      _items = List.from(_defaultEssentials);
      await _saveItems();
    } else {
      _items = savedItems;
    }
    notifyListeners();
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _items);
  }

  void add(String item) {
    final trimmed = item.trim();
    if (trimmed.isEmpty) return;

    final exists = _items.any(
      (e) => StringUtils.ingredientMatches(e, trimmed),
    );
    if (!exists) {
      _items.add(trimmed);
      _saveItems();
      notifyListeners();
    }
  }

  void remove(String item) {
    _items.remove(item);
    _saveItems();
    notifyListeners();
  }

  void resetToDefault() {
    _items = List.from(_defaultEssentials);
    _saveItems();
    notifyListeners();
  }
}

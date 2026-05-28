import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocketbase/pocketbase.dart';
import '../core/pocketbase_client.dart';
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

  final pb = PocketBaseClient.instance;

  List<String> _items = [];
  final Map<String, String> _allIngredientsCache = {};
  bool _isSyncing = false;

  List<String> get items => _items;

  PantryProvider() {
    _loadItems();
    
    // Listen to AuthStore changes to sync when user logs in
    pb.authStore.onChange.listen((e) {
      if (pb.authStore.isValid) {
        _syncFromPocketBase();
      }
    });

    if (pb.authStore.isValid) {
      _syncFromPocketBase();
    }
  }

  Future<void> _fetchAllIngredients() async {
    if (_allIngredientsCache.isNotEmpty) return;
    try {
      // Fetch all ingredients to create a name-to-id mapping
      final records = await pb.collection('ingredients').getFullList();
      for (var r in records) {
        _allIngredientsCache[r.getStringValue('name')] = r.id;
      }
    } catch (e) {
      debugPrint('Error fetching ingredients cache: $e');
    }
  }

  Future<void> _syncFromPocketBase() async {
    if (_isSyncing || !pb.authStore.isValid) return;
    _isSyncing = true;

    try {
      final userId = pb.authStore.record!.id;
      final userRecord = await pb.collection('users').getOne(userId, expand: 'pantry');
      
      List<RecordModel>? expanded;
      try {
        expanded = userRecord.get<List<RecordModel>>('expand.pantry');
      } catch (_) {}
      
      if (expanded != null && expanded.isNotEmpty) {
        final pbItems = expanded.map((r) => r.getStringValue('name')).toList();
        
        // Merge PocketBase items with local items (avoid duplicates)
        final combined = Set<String>.from(_items)..addAll(pbItems);
        _items = combined.toList();
        
        await _saveItemsToPrefs(); // Save merged list locally
        notifyListeners();
        
        // Push merged list back to PocketBase to ensure 100% sync
        await _pushToPocketBase();
      } else {
        // If PocketBase is empty but we have local items, push them
        if (_items.isNotEmpty) {
          await _pushToPocketBase();
        }
      }
    } catch (e) {
      debugPrint('Error syncing pantry from PB: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _pushToPocketBase() async {
    if (!pb.authStore.isValid) return;
    try {
      await _fetchAllIngredients();
      
      // Map names to IDs
      final ids = _items
          .map((name) => _allIngredientsCache[name])
          .whereType<String>() // Removes nulls
          .toList();

      final userId = pb.authStore.record!.id;
      await pb.collection('users').update(userId, body: {
        'pantry': ids,
      });
    } catch (e) {
      debugPrint('Error pushing pantry to PB: $e');
    }
  }

  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final savedItems = prefs.getStringList(_prefsKey);

    if (savedItems == null) {
      _items = List.from(_defaultEssentials);
      await _saveItemsToPrefs();
    } else {
      _items = savedItems;
    }
    notifyListeners();
  }

  Future<void> _saveItemsToPrefs() async {
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
      _saveItemsToPrefs();
      _pushToPocketBase(); // Fire and forget sync
      notifyListeners();
    }
  }

  void remove(String item) {
    _items.remove(item);
    _saveItemsToPrefs();
    _pushToPocketBase(); // Fire and forget sync
    notifyListeners();
  }

  void resetToDefault() {
    _items = List.from(_defaultEssentials);
    _saveItemsToPrefs();
    _pushToPocketBase(); // Fire and forget sync
    notifyListeners();
  }
}

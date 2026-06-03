import 'package:flutter/foundation.dart';
import '../core/pocketbase_client.dart';
import '../utils/ingredient_resolver.dart';

class IngredientProvider extends ChangeNotifier {
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Map<String, List<String>> _categories = {};
  Map<String, List<String>> get categories => _categories;

  Map<String, String> _categoryIcons = {};
  Map<String, String> get categoryIcons => _categoryIcons;

  List<String> _items = [];
  List<String> get items => _items;

  IngredientProvider() {
    loadIngredients();
  }

  Future<void> loadIngredients() async {
    _isLoading = true;
    notifyListeners();

    try {
      final pb = PocketBaseClient.instance;
      
      // Ambil daftar kategori dan ikonnya
      final catRecords = await pb.collection('ingredient_categories').getFullList(sort: 'order,name');
      final Map<String, String> catIcons = {};
      
      // Susun urutan kategori kosong berdasarkan 'order' dari database
      final Map<String, List<String>> cats = {};
      for (final c in catRecords) {
        final cName = c.getStringValue('name').trim();
        if (cName.isNotEmpty) {
          catIcons[cName] = c.getStringValue('icon').trim();
          cats[cName] = []; // inisialisasi urutan
        }
      }

      // Ambil seluruh bahan
      final records = await pb.collection('ingredients').getFullList(sort: 'category,name');
      final List<String> itms = [];

      for (final r in records) {
        final name = r.getStringValue('name').trim();
        final category = r.getStringValue('category').trim();
        if (name.isEmpty) continue;
        
        final catKey = category.isEmpty ? 'Lainnya' : category;
        cats.putIfAbsent(catKey, () => []).add(name);
        itms.add(name);
      }
      
      _categories = cats;
      _categoryIcons = catIcons;
      _items = itms;

      // Sinkronisasikan dengan resolver global
      IngredientResolver.updateCatalog(itms);
    } catch (e) {
      debugPrint('Error loading ingredients: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

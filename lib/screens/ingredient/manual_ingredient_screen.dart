import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/app_constants.dart';
import '../../core/app_routes.dart';
import '../../core/app_text_styles.dart';
import '../../providers/pantry_provider.dart';
import '../../providers/recommendation_provider.dart';
import '../../utils/ingredient_category_emoji.dart';
import '../../utils/ingredient_resolver.dart';
import '../../utils/string_utils.dart';
import '../../data/dummy/dummy_ingredients.dart';
import '../../widgets/common/square_icon_button.dart';
import '../../widgets/ingredient/ingredient_autocomplete_field.dart';
import '../../widgets/ingredient/ingredient_category_accordion.dart';
import '../../widgets/ingredient/manual_ingredient_action_bar.dart';
import '../../widgets/ingredient/selected_ingredients_panel.dart';
import '../../widgets/ingredient/suggestion_chip.dart';
import '../../widgets/navigation/circular_header_button.dart';
import '../../widgets/navigation/tab_page_scaffold.dart';
import 'pantry_essentials_sheet.dart';
import '../../utils/app_snackbar.dart';

class ManualIngredientScreen extends StatefulWidget {
  const ManualIngredientScreen({super.key});

  @override
  State<ManualIngredientScreen> createState() => _ManualIngredientScreenState();
}

class _ManualIngredientScreenState extends State<ManualIngredientScreen> {
  static const _popularSuggestions = [
    'Bawang Merah',
    'Bawang Putih',
    'Cabai Merah',
    'Ayam',
    'Telur Ayam',
    'Tomat',
    'Garam',
    'Minyak Goreng',
    'Kecap Manis',
  ];

  final TextEditingController _ingredientController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<String> _ingredients = [];

  List<String> _lastSyncedIngredients = const [];
  List<String> _lastSyncedPantry = const [];

  void _scheduleRecommendationSync(List<String> pantryItems) {
    if (listEquals(_lastSyncedIngredients, _ingredients) &&
        listEquals(_lastSyncedPantry, pantryItems)) {
      return;
    }

    _lastSyncedIngredients = List.unmodifiable(_ingredients);
    _lastSyncedPantry = List.unmodifiable(pantryItems);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<RecommendationProvider>().setInputs(
            currentIngredients: _ingredients,
            pantryItems: pantryItems,
          );
    });
  }

  @override
  void dispose() {
    _ingredientController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _fillInput(String ingredient) {
    _ingredientController.text = ingredient;
    _addIngredient();
  }

  void _showInvalidIngredientMessage(String raw) {
    showAppSnackBar(
      context,
      'Bahan "$raw" tidak dikenali. Pilih dari daftar saran atau perbaiki ejaan.',
      variant: AppSnackBarVariant.error,
      duration: const Duration(seconds: 3),
    );
  }

  void _showDuplicateMessage(String canonical, String existing) {
    showAppSnackBar(
      context,
      'Bahan "$canonical" sudah ada atau mirip dengan "$existing".',
      variant: AppSnackBarVariant.error,
    );
  }

  void _addIngredient() {
    final raw = _ingredientController.text.trim();
    if (raw.isEmpty) return;

    final canonical = IngredientResolver.resolve(raw);
    if (canonical == null) {
      _showInvalidIngredientMessage(raw);
      return;
    }

    for (final existing in _ingredients) {
      if (StringUtils.ingredientMatches(existing, canonical) ||
          StringUtils.isSimilar(existing, canonical)) {
        _showDuplicateMessage(canonical, existing);
        _ingredientController.clear();
        return;
      }
    }

    setState(() {
      _ingredients.add(canonical);
      _ingredientController.clear();
    });
  }

  void _removeIngredient(String ingredient) {
    setState(() => _ingredients.remove(ingredient));
  }

  void _clearAll() => setState(_ingredients.clear);

  Future<void> _findRecipes() async {
    if (_ingredients.isEmpty) {
      showAppSnackBar(context, 'Pilih minimal satu bahan terlebih dahulu');
      return;
    }

    final pantryItems = context.read<PantryProvider>().items;
    final allIngredients = <String>{..._ingredients, ...pantryItems}.toList();

    final result = await Navigator.pushNamed(
      context,
      AppRoutes.recipeRecommendation,
      arguments: allIngredients,
    );

    if (result is List<String> && mounted) {
      final newIngredients = <String>[];
      for (final item in result) {
        if (StringUtils.listContainsIngredient(pantryItems, item)) continue;
        final canonical = IngredientResolver.resolve(item) ?? item;
        final duplicate = newIngredients.any(
          (e) => StringUtils.ingredientMatches(e, canonical),
        );
        if (!duplicate) newIngredients.add(canonical);
      }
      setState(() {
        _ingredients
          ..clear()
          ..addAll(newIngredients);
      });
    }
  }

  List<String> _filterSuggestions(List<String> pantryItems) {
    return _popularSuggestions
        .where(
          (i) =>
              !_ingredients.any(
                (existing) => StringUtils.ingredientMatches(existing, i),
              ) &&
              !StringUtils.listContainsIngredient(pantryItems, i),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final pantryItems = context.watch<PantryProvider>().items;
    _scheduleRecommendationSync(pantryItems);

    final recommendationProvider = context.watch<RecommendationProvider>();
    final data = recommendationProvider.data;

    List<String> suggestions;
    if (data != null && data.suggestions.isNotEmpty) {
      suggestions = data.suggestions;
    } else {
      suggestions = _filterSuggestions(pantryItems);
    }

    return Stack(
      children: [
        TabPageScaffold(
          title: 'Bahan apa yang kamu punya?',
          action: CircularHeaderButton(
            icon: LucideIcons.moreVertical,
            onPressed: () => showPantryEssentialsSheet(context),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingScreen,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppConstants.spacingLg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: IngredientAutocompleteField(
                        controller: _ingredientController,
                        focusNode: _focusNode,
                        onAdd: _addIngredient,
                        onOptionSelected: (_) => _focusNode.requestFocus(),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingSm),
                    SquareIconButton(
                      size: 52,
                      onPressed: _addIngredient,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SelectedIngredientsPanel(
                  ingredients: _ingredients,
                  onClearAll: _clearAll,
                  onRemove: _removeIngredient,
                ),
                if (suggestions.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text('Saran', style: AppTextStyles.sectionTitle),
                  const SizedBox(height: AppConstants.spacingMd),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: suggestions
                        .map(
                          (ingredient) => SuggestionChip(
                            label: ingredient,
                            onTap: () => _fillInput(ingredient),
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 20),
                Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  child: Column(
                    children: DummyIngredients.categories.keys.map((category) {
                      return IngredientCategoryAccordion(
                        category: category,
                        emoji: IngredientCategoryEmoji.forCategory(category),
                        ingredients:
                            DummyIngredients.categories[category] ?? [],
                        pantryItems: pantryItems,
                        selectedIngredients: _ingredients,
                        onIngredientTap: _fillInput,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 96),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: ManualIngredientActionBar(
            onScan: () => Navigator.pushNamed(context, AppRoutes.scanner),
            onFindRecipes: _findRecipes,
          ),
        ),
      ],
    );
  }
}

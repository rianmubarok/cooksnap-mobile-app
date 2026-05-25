import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_routes.dart';
import '../../core/app_text_styles.dart';
import '../../providers/pantry_provider.dart';
import '../../widgets/common/section_action_link.dart';
import '../../widgets/common/square_icon_button.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/ingredient/removable_ingredient_chip.dart';
import '../../widgets/ingredient/suggestion_chip.dart';
import '../../widgets/navigation/circular_header_button.dart';
import '../../widgets/navigation/tab_page_scaffold.dart';
import '../../data/dummy/dummy_ingredients.dart';
import '../../utils/string_utils.dart';
import 'pantry_essentials_sheet.dart';

class ManualIngredientScreen extends StatefulWidget {
  const ManualIngredientScreen({super.key});

  @override
  State<ManualIngredientScreen> createState() => _ManualIngredientScreenState();
}

class _ManualIngredientScreenState extends State<ManualIngredientScreen> {
  final TextEditingController _ingredientController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<String> _ingredients = [];

  @override
  void dispose() {
    _ingredientController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addIngredient([String? valueOverride]) {
    final value = valueOverride ?? _ingredientController.text.trim();
    if (value.isEmpty) return;

    for (var existing in _ingredients) {
      if (StringUtils.isSimilar(existing, value)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bahan "$value" sudah ada atau mirip dengan "$existing".'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _ingredientController.clear();
        return;
      }
    }

    setState(() {
      _ingredients.add(value);
      _ingredientController.clear();
    });
  }

  void _removeIngredient(String ingredient) {
    setState(() => _ingredients.remove(ingredient));
  }

  void _clearAll() {
    setState(_ingredients.clear);
  }

  void _findRecipes() async {
    if (_ingredients.isEmpty) return;

    final pantryItems = context.read<PantryProvider>().items;
    final allIngredients = <String>{..._ingredients, ...pantryItems}.toList();

    final result = await Navigator.pushNamed(
      context,
      AppRoutes.recipeRecommendation,
      arguments: allIngredients,
    );

    if (result is List<String> && mounted) {
      final newIngredients = result.where((i) => !pantryItems.contains(i)).toList();
      setState(() {
        _ingredients.clear();
        _ingredients.addAll(newIngredients);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pantryItems = context.watch<PantryProvider>().items;
    final popular = ['Bawang Merah', 'Bawang Putih', 'Cabai Merah', 'Ayam', 'Telur Ayam', 'Tomat', 'Garam', 'Minyak Goreng', 'Kecap Manis'];
    final suggestions = popular
        .where((i) => 
          !_ingredients.any((existing) => StringUtils.isSimilar(existing, i)) &&
          !pantryItems.any((existing) => StringUtils.isSimilar(existing, i))
        )
        .toList();

    return TabPageScaffold(
      title: 'Bahan apa yang kamu punya?',
      action: CircularHeaderButton(
        icon: Icons.more_vert,
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
                  child: RawAutocomplete<String>(
                    textEditingController: _ingredientController,
                    focusNode: _focusNode,
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return DummyIngredients.items.where((String option) {
                        return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selection) {
                      _addIngredient(selection);
                    },
                    fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                      return CustomTextField(
                        hintText: 'Ketik nama bahan...',
                        large: true,
                        controller: controller,
                        focusNode: focusNode,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) {
                          onEditingComplete();
                          _addIngredient();
                        },
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 0.0,
                          color: AppColors.cardBackground,
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: 200,
                              maxWidth: MediaQuery.of(context).size.width - (AppConstants.paddingScreen * 2) - 50,
                            ),
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              separatorBuilder: (context, index) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final option = options.elementAt(index);
                                return InkWell(
                                  onTap: () => onSelected(option),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    child: Text(option, style: AppTextStyles.bodyMedium),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppConstants.spacingSm),
                SquareIconButton(onPressed: _addIngredient),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Dipilih', style: AppTextStyles.sectionTitle),
                Opacity(
                  opacity: _ingredients.isNotEmpty ? 1.0 : 0.0,
                  child: SectionActionLink(
                    label: 'Hapus semua',
                    onTap: _ingredients.isNotEmpty ? _clearAll : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMd),
            if (_ingredients.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: _ingredients
                    .map(
                      (ingredient) => RemovableIngredientChip(
                        label: ingredient,
                        onRemove: () => _removeIngredient(ingredient),
                      ),
                    )
                    .toList(),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  border: Border.all(color: AppColors.border),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Belum ada bahan yang ditambahkan',
                  style: AppTextStyles.bodySmall,
                ),
              ),
            if (suggestions.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text('Saran', style: AppTextStyles.sectionTitle),
              const SizedBox(height: AppConstants.spacingMd),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: suggestions
                    .map(
                      (ingredient) => SuggestionChip(
                        label: ingredient,
                        onTap: () {
                          _ingredientController.text = ingredient;
                          _addIngredient();
                        },
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: AppConstants.spacingXl),
            PrimaryButton(
              text: 'Cari Resep',
              icon: Icons.search_rounded,
              iconSize: 24,
              onPressed: _ingredients.isNotEmpty ? _findRecipes : null,
            ),
            const SizedBox(height: AppConstants.spacingXl),
          ],
        ),
      ),
    );
  }
}

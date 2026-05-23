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
import 'pantry_essentials_sheet.dart';

class ManualIngredientScreen extends StatefulWidget {
  const ManualIngredientScreen({super.key});

  @override
  State<ManualIngredientScreen> createState() => _ManualIngredientScreenState();
}

class _ManualIngredientScreenState extends State<ManualIngredientScreen> {
  final TextEditingController _ingredientController = TextEditingController();
  final List<String> _ingredients = [];

  @override
  void dispose() {
    _ingredientController.dispose();
    super.dispose();
  }

  void _addIngredient() {
    final value = _ingredientController.text.trim();
    if (value.isEmpty) return;

    final normalized = value.toLowerCase();
    final exists = _ingredients.any((i) => i.toLowerCase() == normalized);
    if (exists) {
      _ingredientController.clear();
      return;
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

  void _findRecipes() {
    if (_ingredients.isEmpty) return;

    final pantryItems = context.read<PantryProvider>().items;
    final allIngredients = <String>{..._ingredients, ...pantryItems}.toList();

    Navigator.pushNamed(
      context,
      AppRoutes.recipeRecommendation,
      arguments: allIngredients,
    );
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = ['Ayam', 'Telur', 'Bawang Merah', 'Tahu']
        .where((i) => !_ingredients.contains(i))
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
                  child: CustomTextField(
                    hintText: 'Ketik nama bahan...',
                    large: true,
                    controller: _ingredientController,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _addIngredient(),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingSm),
                SquareIconButton(onPressed: _addIngredient),
              ],
            ),
            const SizedBox(height: AppConstants.spacingLg),
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
              const SizedBox(height: AppConstants.spacingXl),
              const Text('Saran', style: AppTextStyles.sectionTitle),
              const SizedBox(height: AppConstants.spacingMd),
              Wrap(
                spacing: 8,
                runSpacing: 8,
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
              useGradient: true,
              onPressed: _ingredients.isNotEmpty ? _findRecipes : null,
            ),
            const SizedBox(height: AppConstants.spacingXl),
          ],
        ),
      ),
    );
  }
}

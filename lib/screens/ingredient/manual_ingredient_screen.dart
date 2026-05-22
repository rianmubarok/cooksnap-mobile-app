import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_routes.dart';
import '../../core/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/navigation/tab_page_scaffold.dart';

/// Tab for typing ingredients manually and getting recipe recommendations.
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
    Navigator.pushNamed(
      context,
      AppRoutes.recipeRecommendation,
      arguments: List<String>.from(_ingredients),
    );
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = ['Ayam', 'Telur', 'Bawang Merah', 'Tahu']
        .where((i) => !_ingredients.contains(i))
        .toList();

    return TabPageScaffold(
      title: 'Bahan apa yang kamu punya?',
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
                    Material(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                      child: InkWell(
                        onTap: _addIngredient,
                        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                        child: const SizedBox(
                          width: 60,
                          height: 60,
                          child: Icon(
                            Icons.add_rounded,
                            color: AppColors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingLg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dipilih',
                      style: AppTextStyles.sectionTitle,
                    ),
                    Opacity(
                      opacity: _ingredients.isNotEmpty ? 1.0 : 0.0,
                      child: GestureDetector(
                        onTap: _ingredients.isNotEmpty ? _clearAll : null,
                        child: const Text(
                          'Hapus semua',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingMd),
                if (_ingredients.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _ingredients.map((ingredient) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              ingredient,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => _removeIngredient(ingredient),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: AppColors.chipBackground,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 12,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ] else ...[
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
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
                if (suggestions.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacingXl),
                  Text(
                    'Saran',
                    style: AppTextStyles.sectionTitle,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: suggestions.map((ingredient) {
                      return GestureDetector(
                        onTap: () {
                          _ingredientController.text = ingredient;
                          _addIngredient();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            '+ $ingredient',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
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

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
    return TabPageScaffold(
      title: 'Input Bahan',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingScreen,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                Text(
                  'Ketik bahan yang kamu punya, lalu cari resep yang cocok.',
                  style: AppTextStyles.subtitleMuted,
                ),
                const SizedBox(height: AppConstants.spacingLg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CustomTextField(
                        hintText: 'Contoh: telur, tomat, bawang merah',
                        prefixIcon: Icons.soup_kitchen_outlined,
                        controller: _ingredientController,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _addIngredient(),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingSm),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Material(
                        color: AppColors.primary,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                        child: InkWell(
                          onTap: _addIngredient,
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusMd),
                          child: const SizedBox(
                            width: 52,
                            height: 52,
                            child: Icon(
                              Icons.add_rounded,
                              color: AppColors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_ingredients.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacingLg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_ingredients.length} bahan ditambahkan',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: _clearAll,
                        child: const Text(
                          'Hapus semua',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _ingredients.map((ingredient) {
                      return InputChip(
                        label: Text(ingredient),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => _removeIngredient(ingredient),
                        backgroundColor:
                            AppColors.secondary.withValues(alpha: 0.2),
                        side: BorderSide(
                          color: AppColors.secondary.withValues(alpha: 0.5),
                        ),
                        labelStyle: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }).toList(),
                  ),
                ] else ...[
                  const SizedBox(height: AppConstants.spacingXl),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.soup_kitchen_outlined,
                            size: 44,
                            color: AppColors.primary.withValues(alpha: 0.4),
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingMd),
                        const Text(
                          'Belum ada bahan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingSm),
                        const Text(
                          'Tambahkan minimal satu bahan untuk\nmendapatkan rekomendasi resep',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppConstants.spacingXl),
                PrimaryButton(
                  text: 'Cari Resep dari Bahan Ini',
                  icon: Icons.search_rounded,
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

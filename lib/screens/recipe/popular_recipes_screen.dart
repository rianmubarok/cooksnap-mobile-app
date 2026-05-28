import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../models/recipe_model.dart';
import '../../widgets/navigation/circular_header_button.dart';
import '../../widgets/recipe/recipe_card_grid.dart';
import '../../widgets/recipe/recipe_grid.dart';

class PopularRecipesScreen extends StatelessWidget {
  final List<Recipe> recipes;

  const PopularRecipesScreen({
    super.key,
    required this.recipes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: AppConstants.paddingScreen),
          child: UnconstrainedBox(
            child: CircularHeaderButton(
              icon: LucideIcons.chevronLeft,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        leadingWidth: 72,
        title: Text(
          'Resep Populer',
          style: AppTextStyles.h3.copyWith(color: AppColors.primary),
        ),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingScreen,
          ),
          child: RecipeGrid(
            recipes: recipes,
            itemBuilder: (context, recipe) => RecipeCardGrid(recipe: recipe),
          ),
        ),
      ),
    );
  }
}

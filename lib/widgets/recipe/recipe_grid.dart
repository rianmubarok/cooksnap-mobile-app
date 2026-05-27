import 'package:flutter/material.dart';

import '../../models/recipe_model.dart';
import 'recipe_card_grid.dart';

/// Standard 2-column recipe grid with consistent sizing.
///
/// Uses the same height formula across screens to avoid layout drift.
class RecipeGrid extends StatelessWidget {
  final List<Recipe> recipes;
  final EdgeInsetsGeometry padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final int crossAxisCount;
  final double spacing;
  final double extraHeight;
  final Widget Function(BuildContext context, Recipe recipe)? itemBuilder;

  const RecipeGrid({
    super.key,
    required this.recipes,
    this.padding = EdgeInsets.zero,
    this.shrinkWrap = false,
    this.physics,
    this.crossAxisCount = 2,
    this.spacing = 12,
    this.extraHeight = 86,
    this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final itemWidth = (maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;
        final itemHeight = itemWidth + extraHeight;
        final aspectRatio = itemWidth / itemHeight;

        return GridView.builder(
          padding: padding,
          shrinkWrap: shrinkWrap,
          physics: physics,
          itemCount: recipes.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: aspectRatio,
          ),
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            final builder = itemBuilder;
            if (builder != null) return builder(context, recipe);
            return RecipeCardGrid(recipe: recipe);
          },
        );
      },
    );
  }
}


import 'package:flutter/material.dart';
import '../../core/app_constants.dart';
import '../common/app_text.dart';
import 'recipe_step_item.dart';

/// Numbered cooking steps on recipe detail.
class RecipeStepsSection extends StatelessWidget {
  final List<String> steps;

  const RecipeStepsSection({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText('Instruksi', variant: AppTextVariant.sectionTitle),
        const SizedBox(height: AppConstants.spacingMd),
        ...List.generate(
          steps.length,
          (index) => Padding(
            padding: EdgeInsets.only(
              bottom: index == steps.length - 1 ? 0 : AppConstants.spacingXl,
            ),
            child: RecipeStepItem(
              stepNumber: index + 1,
              instruction: steps[index],
            ),
          ),
        ),
      ],
    );
  }
}

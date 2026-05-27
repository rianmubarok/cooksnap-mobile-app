import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../common/app_text.dart';

/// Numbered cooking instruction row on recipe detail.
class RecipeStepItem extends StatelessWidget {
  final int stepNumber;
  final String instruction;

  const RecipeStepItem({
    super.key,
    required this.stepNumber,
    required this.instruction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFFD9D9D9),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: AppText(
              '$stepNumber',
              variant: AppTextVariant.labelMediumSemibold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppText(
            instruction,
            variant: AppTextVariant.bodyMedium,
            height: 1.5,
            color: AppColors.grey666,
          ),
        ),
      ],
    );
  }
}

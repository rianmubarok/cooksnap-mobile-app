import 'package:flutter/material.dart';
import '../../core/app_text_styles.dart';

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
            child: Text(
              '$stepNumber',
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            instruction,
            style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
          ),
        ),
      ],
    );
  }
}

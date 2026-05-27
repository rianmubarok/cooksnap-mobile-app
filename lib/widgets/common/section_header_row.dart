import 'package:flutter/material.dart';

import 'app_text.dart';
import 'section_action_link.dart';

/// Standard header row for a section: title + optional action link.
class SectionHeaderRow extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeaderRow({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(title, variant: AppTextVariant.sectionTitle),
        if (actionLabel != null)
          SectionActionLink(label: actionLabel!, onTap: onAction),
      ],
    );
  }
}


import 'package:flutter/material.dart';
import '../../core/app_constants.dart';
import '../common/app_text.dart';

/// Shared header for main shell tab pages (below shell [SafeArea]).
class TabPageHeader extends StatelessWidget {
  final String title;
  final Widget? action;

  const TabPageHeader({super.key, required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingScreen,
        AppConstants.spacingMd,
        AppConstants.paddingScreen,
        AppConstants.spacingSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (action != null)
            Align(
              alignment: Alignment.centerRight,
              child: action!,
            ),
          AppText(title, variant: AppTextVariant.headlineDisplay),
        ],
      ),
    );
  }
}

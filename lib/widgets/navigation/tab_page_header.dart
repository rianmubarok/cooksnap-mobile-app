import 'package:flutter/material.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';

/// Shared header for main shell tab pages (below shell [SafeArea]).
class TabPageHeader extends StatelessWidget {
  final String title;

  const TabPageHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingScreen,
        AppConstants.spacingMd,
        AppConstants.paddingScreen,
        AppConstants.spacingSm,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: AppTextStyles.h3.copyWith(letterSpacing: -0.5),
        ),
      ),
    );
  }
}

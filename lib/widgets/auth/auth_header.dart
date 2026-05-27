import 'package:flutter/material.dart';
import '../../core/app_constants.dart';
import '../common/app_text.dart';

/// Title + subtitle block for auth screens.
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(title, variant: AppTextVariant.headlineAuth),
          const SizedBox(height: AppConstants.spacingSm),
          AppText(subtitle, variant: AppTextVariant.subtitleMuted),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/app_constants.dart';
import '../common/app_text.dart';

/// Greeting header on the home tab.
class HomeHeader extends StatelessWidget {
  final String firstName;

  const HomeHeader({super.key, required this.firstName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingScreen,
        AppConstants.spacingMd,
        AppConstants.paddingScreen,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText('Hai, $firstName!', variant: AppTextVariant.greeting),
          const SizedBox(height: AppConstants.spacingSm),
          const AppText(
            'Mau masak apa hari ini?',
            variant: AppTextVariant.headlineDisplay,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';

/// Shared scaffold layout for login and register screens.
class AuthScreenLayout extends StatelessWidget {
  final Widget child;
  final Widget? footer;

  const AuthScreenLayout({
    super.key,
    required this.child,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Container(
          color: AppColors.background,
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppConstants.paddingScreen),
                    child: child,
                  ),
                ),
                if (footer != null) footer!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}


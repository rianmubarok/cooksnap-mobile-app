import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_routes.dart';
import '../../providers/user_provider.dart';

/// Splash Screen — auto-navigates berdasarkan status login dan onboarding.
/// - Sudah login → langsung ke [AppRoutes.home]
/// - Onboarding selesai → ke [AppRoutes.login]
/// - Belum onboarding → ke [AppRoutes.onboarding]
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();
    _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    await Future.delayed(AppConstants.splashDuration);
    if (!mounted) return;

    final user = context.read<UserProvider>();
    await user.waitForInitialization();
    if (!mounted) return;

    final String route;
    if (user.isLoggedIn) {
      route = AppRoutes.home;
    } else if (user.hasCompletedOnboarding) {
      route = AppRoutes.login;
    } else {
      route = AppRoutes.onboarding;
    }

    Navigator.pushReplacementNamed(context, route);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.splashGradient,
        ),
        child: SafeArea(
          child: Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SvgPicture.asset(
                  'assets/logos/cooksnap_logo.svg',
                  width: 80,
                  height: 80,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

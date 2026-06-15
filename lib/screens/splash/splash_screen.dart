import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_routes.dart';
import '../../core/pocketbase_client.dart';
import '../../providers/user_provider.dart';
import '../../services/app_config_service.dart';
import '../../screens/maintenance/maintenance_screen.dart';
import '../../widgets/app_update_dialog.dart';
import '../../services/notification_service.dart';

/// Splash Screen — menjalankan version gate, maintenance check, lalu
/// auto-navigates berdasarkan status login dan onboarding.
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
    // Tunggu animasi splash selesai terlebih dahulu
    await Future.delayed(AppConstants.splashDuration);
    if (!mounted) return;

    // ── 1. Cek app_config dari server ──────────────────────────────────────
    final pb = PocketBaseClient.instance;
    final appConfigService = AppConfigService(pb);
    final config = await appConfigService.fetchConfig();

    if (!mounted) return;

    // ── 2. Maintenance Mode ─────────────────────────────────────────────────
    if (config != null && config.isMaintenance) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MaintenanceScreen(message: config.maintenanceMessage),
        ),
      );
      return;
    }

    // ── 3. Version Gate ─────────────────────────────────────────────────────
    if (config != null) {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version; // misal: "1.0.0"

      final isBelow = _isVersionBelow(currentVersion, config.minimumVersion);
      final isBelowLatest = _isVersionBelow(currentVersion, config.latestVersion);

      if (isBelow || (isBelowLatest && config.forceUpdate)) {
        // Hard block — tidak bisa masuk app
        if (!mounted) return;
        await AppUpdateDialog.show(
          context,
          isForced: true,
          message: config.updateMessage,
          apkUrl: config.apkUrl,
        );
        // Setelah dialog (user tidak bisa dismiss), tetap di splash — return.
        return;
      } else if (isBelowLatest) {
        // Soft block — popup rekomendasi, bisa di-skip
        if (!mounted) return;
        await AppUpdateDialog.show(
          context,
          isForced: false,
          message: config.updateMessage,
          apkUrl: config.apkUrl,
        );
        // Lanjut masuk app setelah dialog ditutup
      }
    }

    if (!mounted) return;

    // ── 4. Navigasi Normal ──────────────────────────────────────────────────
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
    NotificationService.instance.processPendingNotification();
  }

  /// Membandingkan dua versi semantik (format: "MAJOR.MINOR.PATCH").
  /// Mengembalikan `true` jika [version] lebih rendah dari [minimum].
  bool _isVersionBelow(String version, String minimum) {
    try {
      final v = _parseVersion(version);
      final m = _parseVersion(minimum);
      for (int i = 0; i < 3; i++) {
        if (v[i] < m[i]) return true;
        if (v[i] > m[i]) return false;
      }
      return false; // equal
    } catch (_) {
      return false; // gagal parse = biarkan masuk
    }
  }

  List<int> _parseVersion(String version) {
    final parts = version.trim().split('.');
    return List.generate(3, (i) => i < parts.length ? int.tryParse(parts[i]) ?? 0 : 0);
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

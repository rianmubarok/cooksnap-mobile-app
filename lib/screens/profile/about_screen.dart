import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/common/app_text.dart';
import '../../widgets/navigation/circular_header_button.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _versionString = 'Memuat versi...';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          final buildNum =
              info.buildNumber.isNotEmpty ? ' (${info.buildNumber})' : '';
          _versionString = 'Versi ${info.version}$buildNum';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _versionString = 'Versi 1.1.0';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: AppConstants.paddingScreen),
          child: UnconstrainedBox(
            child: CircularHeaderButton(
              icon: LucideIcons.chevronLeft,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        leadingWidth: 72,
        title: const AppText(
          'Tentang Aplikasi',
          variant: AppTextVariant.h3,
          color: AppColors.primary,
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingScreen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const AppText(
              AppConstants.appName,
              variant: AppTextVariant.headlineDisplay,
            ),
            const SizedBox(height: 8),
            AppText(
              _versionString,
              variant: AppTextVariant.bodyMedium,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 32),
            const AppText(
              'Cooksnap adalah aplikasi resep masakan yang memudahkan Anda menemukan inspirasi memasak berdasarkan bahan-bahan yang Anda miliki di dapur. Dengan fitur pemindai cerdas, Anda dapat dengan mudah mengetahui resep apa saja yang bisa dibuat dari bahan-bahan tersebut.',
              variant: AppTextVariant.bodyMedium,
              height: 1.6,
            ),
            const SizedBox(height: 48),
            const AppText(
              '© 2026 Cooksnap Team.\nHak Cipta Dilindungi.',
              variant: AppTextVariant.caption,
              color: AppColors.textHint,
              height: 1.5,
            ),
          ],
        ),
      ),
    );
  }
}

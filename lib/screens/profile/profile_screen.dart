import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_routes.dart';
import '../../core/app_strings.dart';
import '../../providers/user_provider.dart';
import '../../utils/placeholder_snackbar.dart';
import '../../widgets/navigation/tab_page_scaffold.dart';
import '../../widgets/common/app_confirm_dialog.dart';
import '../../widgets/profile/profile_menu_tile.dart';
import '../../widgets/common/app_text.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final userName =
        user.name.isEmpty ? AppStrings.guestUserName : user.name;
    final userEmail = user.email.isEmpty ? 'guest@cooksnap.app' : user.email;

    return TabPageScaffold(
      title: 'Profil',
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingScreen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSm),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: AppText(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'G',
                        variant: AppTextVariant.headlineDisplaySemibold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          userName,
                          variant: AppTextVariant.h3Semibold,
                        ),
                        const SizedBox(height: 4),
                        AppText(
                          userEmail,
                          variant: AppTextVariant.bodyMedium,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: AppText(
                'Pengaturan',
                variant: AppTextVariant.sectionTitle,
              ),
            ),

            ProfileMenuTile(
              icon: LucideIcons.user,
              title: 'Informasi Profil',
              onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
            ),
            ProfileMenuTile(
              icon: LucideIcons.bell,
              title: AppStrings.notificationSettings,
              onTap: () => showPlaceholderSnackBar(
                context,
                'Notifikasi segera hadir',
              ),
            ),
            ProfileMenuTile(
              icon: LucideIcons.helpCircle,
              title: AppStrings.help,
              onTap: () => Navigator.pushNamed(context, AppRoutes.help),
            ),
            ProfileMenuTile(
              icon: LucideIcons.info,
              title: 'Tentang Aplikasi',
              onTap: () => Navigator.pushNamed(context, AppRoutes.about),
            ),
            ProfileMenuTile(
              icon: LucideIcons.logOut,
              title: AppStrings.logout,
              isDestructive: true,
              onTap: () async {
                final confirmed = await AppConfirmDialog.show(
                  context,
                  title: 'Keluar',
                  message: 'Apakah Anda yakin ingin keluar dari akun Anda?',
                  confirmText: 'Keluar',
                  cancelText: 'Batal',
                  icon: LucideIcons.logOut,
                  iconColor: AppColors.error,
                );

                if (confirmed == true && context.mounted) {
                  context.read<UserProvider>().logout();
                  Navigator.of(context, rootNavigator: true)
                      .pushNamedAndRemoveUntil(
                    AppRoutes.login,
                    (route) => false,
                  );
                }
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

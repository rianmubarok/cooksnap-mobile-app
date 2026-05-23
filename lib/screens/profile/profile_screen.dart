import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_routes.dart';
import '../../core/app_text_styles.dart';
import '../../providers/user_provider.dart';
import '../../widgets/navigation/tab_page_scaffold.dart';
import '../../widgets/profile/profile_menu_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final userName = user.name.isEmpty ? 'Guest' : user.name;
    final userEmail = user.email;

    return TabPageScaffold(
      title: 'Profil',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingScreen),
        child: Column(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.secondary, width: 3),
              ),
              child: Center(
                child: Text(
                  userName[0].toUpperCase(),
                  style: AppTextStyles.headlineDisplay.copyWith(
                    fontSize: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(userName, style: AppTextStyles.h3),
            const SizedBox(height: 4),
            Text(userEmail, style: AppTextStyles.bodySmall),
            const SizedBox(height: AppConstants.spacingXl),
            ProfileMenuTile(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              onTap: () {},
            ),
            ProfileMenuTile(
              icon: Icons.notifications_none_rounded,
              title: 'Notification Settings',
              onTap: () {},
            ),
            ProfileMenuTile(
              icon: Icons.help_outline_rounded,
              title: 'Help',
              onTap: () {},
            ),
            const SizedBox(height: AppConstants.spacingMd),
            ProfileMenuTile(
              icon: Icons.logout_rounded,
              title: 'Logout',
              isDestructive: true,
              onTap: () {
                context.read<UserProvider>().logout();
                Navigator.of(context, rootNavigator: true)
                    .pushNamedAndRemoveUntil(
                  AppRoutes.login,
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

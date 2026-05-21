import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_routes.dart';
import '../../providers/user_provider.dart';
import '../../widgets/navigation/tab_page_scaffold.dart';

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
                    border: Border.all(
                      color: AppColors.secondary,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'G',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMd),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXl),
                _buildMenuItem(
                  context,
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  onTap: () {},
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.notifications_none_rounded,
                  title: 'Notification Settings',
                  onTap: () {},
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.help_outline_rounded,
                  title: 'Help',
                  onTap: () {},
                ),
                const SizedBox(height: AppConstants.spacingMd),
                _buildMenuItem(
                  context,
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  isDestructive: true,
                  onTap: () {
                    Provider.of<UserProvider>(context, listen: false).logout();
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

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
        padding: const EdgeInsets.all(AppConstants.paddingCard),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.error.withValues(alpha: 0.08)
                    : AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 22,
                  color: isDestructive ? AppColors.error : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color:
                      isDestructive ? AppColors.error : AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 22,
              color: isDestructive
                  ? AppColors.error.withValues(alpha: 0.5)
                  : AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_routes.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

/// Profile Screen — User profile and settings
/// TODO Genard: Replace dummy data with PocketBase user data
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Read from UserProvider
    final String userName =
        context.watch<UserProvider>().name.isEmpty 
            ? 'Guest' 
            : context.watch<UserProvider>().name;
    final String userEmail = context.watch<UserProvider>().email;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: const Text(
          'Profil',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingScreen),
        child: Column(
          children: [
            const SizedBox(height: AppConstants.spacingMd),

            // Avatar
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
              child: const Center(
                child: Text(
                  'A',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),

            // Name
            Text(
              userName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),

            // Email
            Text(
              userEmail,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingXl),

            // Menu Items
            _buildMenuItem(
              context,
              icon: Icons.person_outline,
              title: 'Edit Profile',
              onTap: () {
                // TODO: Navigate to edit profile
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.notifications_none_rounded,
              title: 'Notification Settings',
              onTap: () {
                // TODO: Navigate to notification settings
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.help_outline_rounded,
              title: 'Help',
              onTap: () {
                // TODO: Navigate to help
              },
            ),
            const SizedBox(height: AppConstants.spacingMd),
            _buildMenuItem(
              context,
              icon: Icons.logout_rounded,
              title: 'Logout',
              isDestructive: true,
              onTap: () {
                Provider.of<UserProvider>(context, listen: false).logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
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
                    ? AppColors.error.withOpacity(0.08)
                    : AppColors.primary.withOpacity(0.08),
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
                  ? AppColors.error.withOpacity(0.5)
                  : AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}

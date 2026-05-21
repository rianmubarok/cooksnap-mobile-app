import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_decorations.dart';
import '../core/app_routes.dart';
import '../providers/shell_navigation_provider.dart';
import '../screens/favorite/favorite_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/ingredient/manual_ingredient_screen.dart';
import '../widgets/navigation/app_bottom_nav_bar.dart';

/// Main app shell with shared bottom navigation and scanner FAB.
class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key});

  static const List<Widget> _pages = [
    HomeScreen(),
    ManualIngredientScreen(),
    FavoriteScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = context.watch<ShellNavigationProvider>().currentIndex;

    return Scaffold(
      body: Container(
        decoration: AppDecorations.pageBackground,
        child: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: currentIndex,
            children: _pages,
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 52,
        height: 52,
        child: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.scanner),
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.camera_alt_outlined,
            color: AppColors.white,
            size: 26,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: currentIndex,
        onIndexChanged: context.read<ShellNavigationProvider>().selectTab,
      ),
    );
  }
}

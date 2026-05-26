import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/app_decorations.dart';
import '../../providers/shell_navigation_provider.dart';
import '../favorite/favorite_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../ingredient/manual_ingredient_screen.dart';
import '../../widgets/navigation/app_bottom_nav_bar.dart';

/// Main app shell with shared bottom navigation across four tabs.
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
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
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: currentIndex,
        onIndexChanged: context.read<ShellNavigationProvider>().selectTab,
      ),
      ),
    );
  }
}

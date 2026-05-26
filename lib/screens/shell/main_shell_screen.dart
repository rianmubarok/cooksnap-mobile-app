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
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  final ScrollController _homeScrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _homeRefreshKey = GlobalKey<RefreshIndicatorState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(
        scrollController: _homeScrollController,
        refreshKey: _homeRefreshKey,
      ),
      const ManualIngredientScreen(),
      const FavoriteScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  void dispose() {
    _homeScrollController.dispose();
    super.dispose();
  }

  void _onBottomNavTapped(int index) {
    final provider = context.read<ShellNavigationProvider>();
    if (index == 0 && provider.currentIndex == 0) {
      if (_homeScrollController.hasClients) {
        _homeScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
        _homeRefreshKey.currentState?.show();
      }
    } else {
      provider.selectTab(index);
    }
  }

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
        onIndexChanged: _onBottomNavTapped,
      ),
      ),
    );
  }
}

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

/// Reusable bottom navigation bar with center notch for FAB.
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  static const List<AppNavItem> items = [
    AppNavItem(
      fillIconPath: 'assets/icons/nav/home_fill.svg',
      outlineIconPath: 'assets/icons/nav/home_outline.svg',
      semanticsLabel: 'Beranda',
    ),
    AppNavItem(
      fillIconPath: 'assets/icons/nav/cooking_pot_fill.svg',
      outlineIconPath: 'assets/icons/nav/cooking_pot_outline.svg',
      semanticsLabel: 'Input Bahan',
    ),
    AppNavItem(
      fillIconPath: 'assets/icons/nav/bookmark_fill.svg',
      outlineIconPath: 'assets/icons/nav/bookmark_outline.svg',
      semanticsLabel: 'Simpan',
    ),
    AppNavItem(
      fillIconPath: 'assets/icons/nav/profile_fill.svg',
      outlineIconPath: 'assets/icons/nav/profile_outline.svg',
      semanticsLabel: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBackground,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(items.length, (index) {
              return _NavTile(
                item: items[index],
                isSelected: currentIndex == index,
                onTap: () => onIndexChanged(index),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class AppNavItem {
  final String fillIconPath;
  final String outlineIconPath;
  final String semanticsLabel;

  const AppNavItem({
    required this.fillIconPath,
    required this.outlineIconPath,
    required this.semanticsLabel,
  });
}

class _NavTile extends StatelessWidget {
  final AppNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = AppColors.primary;
    final theme = Theme.of(context);
    final inactiveColor =
        theme.bottomNavigationBarTheme.unselectedItemColor ?? AppColors.textHint;

    return Semantics(
      label: item.semanticsLabel,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: SvgPicture.asset(
            isSelected ? item.fillIconPath : item.outlineIconPath,
            width: 26,
            height: 26,
            colorFilter: ColorFilter.mode(
              isSelected ? activeColor : inactiveColor,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}

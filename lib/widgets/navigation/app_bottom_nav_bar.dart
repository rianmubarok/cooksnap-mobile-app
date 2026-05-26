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
    AppNavItem(icon: Icons.home_rounded, semanticsLabel: 'Beranda'),
    AppNavItem(icon: Icons.soup_kitchen_outlined, semanticsLabel: 'Input Bahan'),
    AppNavItem(icon: Icons.bookmark_outline_rounded, semanticsLabel: 'Simpan'),
    AppNavItem(icon: Icons.person_outline_rounded, semanticsLabel: 'Profil'),
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
            children: [
              _NavTile(
                item: items[0],
                isSelected: currentIndex == 0,
                onTap: () => onIndexChanged(0),
              ),
              _NavTile(
                item: items[1],
                isSelected: currentIndex == 1,
                onTap: () => onIndexChanged(1),
              ),
              _NavTile(
                item: items[2],
                isSelected: currentIndex == 2,
                onTap: () => onIndexChanged(2),
              ),
              _NavTile(
                item: items[3],
                isSelected: currentIndex == 3,
                onTap: () => onIndexChanged(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppNavItem {
  final IconData icon;
  final String semanticsLabel;

  const AppNavItem({
    required this.icon,
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
    final color = isSelected ? AppColors.primary : AppColors.textHint;

    return Semantics(
      label: item.semanticsLabel,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Icon(item.icon, color: color, size: 26),
        ),
      ),
    );
  }
}

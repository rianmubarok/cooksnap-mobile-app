import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';

/// Muted tappable label for section headers (e.g. "Hapus semua", "Lihat Semua").
class SectionActionLink extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const SectionActionLink({
    super.key,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(color: AppColors.grey666),
      ),
    );
  }
}

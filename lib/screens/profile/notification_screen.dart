import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../widgets/common/app_confirm_dialog.dart';
import '../../widgets/common/app_text.dart';
import '../../services/notification_service.dart';
import '../../utils/recipe_navigation.dart';
import '../../widgets/navigation/circular_header_button.dart';
import '../../widgets/recipe/recipe_thumbnail.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _isEnabled = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _deliveredList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final enabled = await NotificationService.instance.isRemindersEnabled();
    // Hanya tampilkan history yang sudah benar-benar ada — jangan auto-buat dummy
    final delivered = await NotificationService.instance.getDeliveredNotifications();
    if (mounted) {
      setState(() {
        _isEnabled = enabled;
        _deliveredList = delivered;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleReminders(bool value) async {
    if (value) {
      final granted = await NotificationService.instance.requestPermissions();
      if (!granted) {
        setState(() => _isEnabled = false);
        await NotificationService.instance.setRemindersEnabled(false);
        if (mounted) {
          await AppConfirmDialog.show(
            context,
            title: 'Izin Notifikasi Dinonaktifkan',
            message:
                'Sistem HP Anda memblokir izin notifikasi Cooksnap. Silakan izinkan secara manual di Pengaturan HP -> Aplikasi -> Cooksnap -> Notifikasi agar pengingat waktu makan dapat dikirimkan.',
            confirmText: 'Mengerti',
            cancelText: 'Tutup',
          );
        }
        return;
      }
    }
    setState(() => _isEnabled = value);
    await NotificationService.instance.setRemindersEnabled(value);
    await _loadData();
  }

  String _formatMessageTime(Map<String, dynamic> item) {
    final now = DateTime.now();
    final tsStr = item['timestamp'] as String?;
    DateTime? dt;
    if (tsStr != null) {
      dt = DateTime.tryParse(tsStr);
    }

    String timeOnly = '';
    final rawTimeStr =
        (item['timeString'] ?? '').toString().replaceAll('WIB', '').trim();
    if (dt != null) {
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      timeOnly = '$h:$m';
    } else {
      timeOnly = rawTimeStr;
    }

    if (dt != null) {
      final isToday =
          now.year == dt.year && now.month == dt.month && now.day == dt.day;
      final yesterday = now.subtract(const Duration(days: 1));
      final isYesterday =
          yesterday.year == dt.year &&
              yesterday.month == dt.month &&
              yesterday.day == dt.day;

      if (isToday) {
        return timeOnly;
      } else if (isYesterday) {
        return 'Kemarin $timeOnly';
      } else {
        const months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'Mei',
          'Jun',
          'Jul',
          'Agu',
          'Sep',
          'Okt',
          'Nov',
          'Des'
        ];
        final monthName =
            (dt.month >= 1 && dt.month <= 12) ? months[dt.month - 1] : '';
        return '${dt.day} $monthName $timeOnly';
      }
    }

    return timeOnly;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: AppConstants.paddingScreen),
          child: UnconstrainedBox(
            child: CircularHeaderButton(
              icon: LucideIcons.chevronLeft,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        leadingWidth: 72,
        title: const AppText(
          'Notifikasi',
          variant: AppTextVariant.h3,
          color: AppColors.primary,
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppConstants.paddingScreen),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ChipStyledSlider(
                  value: _isEnabled,
                  onChanged: (val) => _toggleReminders(val),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                if (_deliveredList.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingScreen,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 40,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusLg),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            LucideIcons.inbox,
                            size: 40,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Belum Ada Notifikasi Masuk',
                            style: AppTextStyles.bodyMediumSemibold.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Notifikasi resep harian yang sudah muncul akan ditampilkan di sini.',
                            style: AppTextStyles.caption,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ..._deliveredList.map((item) {
                    final isRead = item['isRead'] == true;
                    final displayTime = _formatMessageTime(item);
                    final title = item['title'] ?? '';
                    final body = item['body'] ?? '';
                    final recipeId = item['recipeId'] ?? '';
                    final imageUrl = item['imageUrl'] as String?;
                    final thumbnailUrl = item['thumbnailUrl'] as String?;
                    final displayImg =
                        (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
                            ? thumbnailUrl
                            : (imageUrl ?? '');

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppConstants.paddingScreen,
                        0,
                        AppConstants.paddingScreen,
                        20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  displayTime,
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                                if (!isRead) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFD97706),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              if (!isRead) {
                                setState(() {
                                  item['isRead'] = true;
                                });
                                await NotificationService.instance
                                    .markAsRead(item['id'] ?? 0);
                              }
                              if (recipeId.toString().isNotEmpty && mounted) {
                                context.openRecipeDetail(recipeId.toString());
                              }
                            },
                            child: Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius:
                                    BorderRadius.circular(AppConstants.radiusLg),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 160,
                                    child: displayImg.isNotEmpty
                                        ? Image.network(
                                            displayImg,
                                            fit: BoxFit.cover,
                                            cacheWidth: 500,
                                            errorBuilder: (_, __, ___) =>
                                                Container(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.08),
                                              child: const RecipeThumbnail(
                                                iconSize: 48,
                                              ),
                                            ),
                                          )
                                        : Container(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.08),
                                            child: const RecipeThumbnail(
                                              iconSize: 48,
                                            ),
                                          ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles
                                              .bodyMediumSemibold
                                              .copyWith(
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          body,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
    );
  }
}

class _ChipStyledSlider extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ChipStyledSlider({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        width: 56,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppConstants.radiusRound),
          border: Border.all(
            color: value ? AppColors.primary : AppColors.border,
            width: 1.2,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: value ? AppColors.white : AppColors.border,
              shape: BoxShape.circle,
            ),
            child: value
                ? const Icon(
                    LucideIcons.check,
                    size: 12,
                    color: AppColors.primary,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

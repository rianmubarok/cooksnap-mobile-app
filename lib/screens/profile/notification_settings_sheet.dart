import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../services/notification_service.dart';
import '../../widgets/common/app_confirm_dialog.dart';
import '../../widgets/common/app_text.dart';
import '../../core/app_colors.dart';

class NotificationSettingsSheet extends StatefulWidget {
  const NotificationSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationSettingsSheet(),
    );
  }

  @override
  State<NotificationSettingsSheet> createState() => _NotificationSettingsSheetState();
}

class _NotificationSettingsSheetState extends State<NotificationSettingsSheet> {
  bool _isEnabled = true;
  bool _isLoading = true;
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final enabled = await NotificationService.instance.isRemindersEnabled();
    var history = await NotificationService.instance.getNotificationHistory();
    if (history.isEmpty && enabled) {
      await NotificationService.instance.scheduleDailyMealReminders();
      history = await NotificationService.instance.getNotificationHistory();
    }
    if (mounted) {
      setState(() {
        _isEnabled = enabled;
        _history = history;
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

  Future<void> _refreshSchedule() async {
    setState(() => _isLoading = true);
    await NotificationService.instance.scheduleDailyMealReminders();
    await _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jadwal pengingat harian diperbarui!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    LucideIcons.bell,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'Notifikasi & Pengingat',
                        variant: AppTextVariant.h3Semibold,
                      ),
                      SizedBox(height: 2),
                      AppText(
                        'Jadwal pengingat memasak harianmu',
                        variant: AppTextVariant.caption,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, color: Colors.black54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Master Toggle Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _isEnabled
                                ? AppColors.primary.withOpacity(0.06)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: _isEnabled
                                  ? AppColors.primary.withOpacity(0.3)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(
                                      'Aktifkan Pengingat Harian',
                                      variant: AppTextVariant.bodyMedium,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _isEnabled ? AppColors.primary : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    AppText(
                                      _isEnabled
                                          ? 'Dapatkan rekomendasi resep saat sarapan (07:00), siang (12:00), & malam (18:00)'
                                          : 'Pengingat otomatis non-aktif',
                                      variant: AppTextVariant.caption,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              CupertinoSwitch(
                                value: _isEnabled,
                                activeColor: AppColors.primary,
                                onChanged: _toggleReminders,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Section Title + Refresh Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const AppText(
                              'Jadwal & Rekomendasi Hari Ini',
                              variant: AppTextVariant.sectionTitle,
                            ),
                            if (_isEnabled)
                              TextButton.icon(
                                onPressed: _refreshSchedule,
                                icon: const Icon(LucideIcons.refreshCw, size: 14),
                                label: const Text('Acak Ulang'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (!_isEnabled)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: const Column(
                              children: [
                                Icon(LucideIcons.bellOff, size: 36, color: Colors.grey),
                                SizedBox(height: 12),
                                AppText(
                                  'Pengingat Masak Non-aktif',
                                  variant: AppTextVariant.bodyMedium,
                                ),
                                SizedBox(height: 4),
                                AppText(
                                  'Aktifkan toggle di atas agar jadwal resep harian muncul di sini.',
                                  variant: AppTextVariant.caption,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        else if (_history.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: AppText(
                                'Belum ada jadwal notifikasi. Klik tombol Acak Ulang.',
                                variant: AppTextVariant.caption,
                              ),
                            ),
                          )
                        else
                          Column(
                            children: _history.map((item) {
                              final mealType = item['mealType'] ?? 'Makan';
                              final emoji = item['emoji'] ?? '🔔';
                              final timeStr = item['timeString'] ?? '';
                              final title = item['title'] ?? '';
                              final body = item['body'] ?? '';
                              final recipeName = item['recipeName'] ?? '';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: Colors.grey.shade200),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Row time tag & meal type
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              emoji,
                                              style: const TextStyle(fontSize: 18),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              mealType,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                LucideIcons.clock,
                                                size: 12,
                                                color: AppColors.primary,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                timeStr,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    // Notification card title & body preview
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      body,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                        height: 1.4,
                                      ),
                                    ),
                                    if (recipeName.isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              LucideIcons.utensils,
                                              size: 13,
                                              color: AppColors.primary,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                recipeName,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

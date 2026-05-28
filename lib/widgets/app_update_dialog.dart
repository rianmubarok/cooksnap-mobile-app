import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_colors.dart';

/// Dialog yang muncul ketika ada update tersedia.
///
/// - [isForced] = `true` → Hard block, tidak ada tombol "Nanti".
/// - [isForced] = `false` → Soft block, user bisa pilih "Nanti".
class AppUpdateDialog extends StatelessWidget {
  final bool isForced;
  final String message;
  final String apkUrl;

  const AppUpdateDialog({
    super.key,
    required this.isForced,
    required this.message,
    required this.apkUrl,
  });

  /// Tampilkan dialog. Jika [isForced], back button Android akan dinonaktifkan.
  static Future<void> show(
    BuildContext context, {
    required bool isForced,
    required String message,
    required String apkUrl,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: !isForced,
        child: AppUpdateDialog(
          isForced: isForced,
          message: message,
          apkUrl: apkUrl,
        ),
      ),
    );
  }

  Future<void> _openUrl(BuildContext context) async {
    if (apkUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL download belum tersedia. Hubungi developer.'),
        ),
      );
      return;
    }
    final uri = Uri.tryParse(apkUrl);
    if (uri == null) return;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak bisa membuka link download.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(38),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.system_update_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isForced ? 'Update Wajib' : 'Update Tersedia',
                    style: const TextStyle(
                      fontFamily: 'WorkSans',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isForced
                        ? 'Versi ini tidak lagi didukung.'
                        : 'Nikmati fitur-fitur terbaru CookSnap.',
                    style: TextStyle(
                      fontFamily: 'WorkSans',
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                children: [
                  Text(
                    message,
                    style: const TextStyle(
                      fontFamily: 'WorkSans',
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Update button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _openUrl(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.download_rounded, size: 20),
                      label: const Text(
                        'Download Update',
                        style: TextStyle(
                          fontFamily: 'WorkSans',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // "Nanti" — hanya tampil kalau bukan forced
                  if (!isForced) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Nanti Saja',
                          style: TextStyle(
                            fontFamily: 'WorkSans',
                            fontSize: 15,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/common/app_text.dart';
import '../../widgets/navigation/circular_header_button.dart';
import '../../widgets/custom_button.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

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
          'Bantuan',
          variant: AppTextVariant.h3,
          color: AppColors.primary,
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingScreen),
        children: [
          const AppText(
            'Pertanyaan yang Sering Diajukan',
            variant: AppTextVariant.h3,
          ),
          const SizedBox(height: AppConstants.spacingLg),
          const _FaqAccordion(
            question: 'Bagaimana cara mencari resep dengan bahan yang saya punya?',
            answer:
                'Buka tab "Bahan" (ikon panci di bawah). Anda bisa mengetik bahan manual, memilih dari kategori, atau menggunakan tombol "Scan AI" untuk mengenali bahan melalui kamera.',
          ),
          const _FaqAccordion(
            question: 'Apa itu CookSnap PRO?',
            answer:
                'CookSnap PRO adalah langganan premium kami! Anda akan mendapatkan akses ke resep tanpa batas, akurasi Scanner AI tingkat lanjut, dan tentunya pengalaman memasak tanpa iklan.',
          ),
          const _FaqAccordion(
            question: 'Bagaimana cara menambahkan resep ke favorit?',
            answer:
                'Cukup tekan ikon hati (♡) pada kartu resep di beranda, atau ketika Anda sedang membaca detail resepnya.',
          ),
          const _FaqAccordion(
            question: 'Bagaimana cara mengedit Profil saya?',
            answer:
                'Masuk ke tab "Profil" di pojok kanan bawah, lalu pilih menu "Informasi Profil" untuk memperbarui nama dan data akun Anda.',
          ),
          const _FaqAccordion(
            question: 'Kenapa Scanner AI kurang akurat mengenali bahan saya?',
            answer:
                'Pastikan pencahayaan cukup terang dan bahan tidak saling tumpang tindih. Semakin jelas fotonya, semakin pintar AI kami mengenalinya!',
          ),
          const SizedBox(height: 32),
          const AppText(
            'Butuh bantuan lebih lanjut?',
            variant: AppTextVariant.h3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'Hubungi Kami',
            icon: LucideIcons.mail,
            onPressed: () async {
              final Uri emailLaunchUri = Uri(
                scheme: 'mailto',
                path: 'support@cooksnap.com',
                query: 'subject=Bantuan%20CookSnap%20Mobile%20App',
              );
              try {
                if (!await launchUrl(emailLaunchUri)) {
                  if (context.mounted) {
                    showAppSnackBar(context, 'Tidak dapat membuka aplikasi email.');
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  showAppSnackBar(context, 'Terjadi kesalahan saat membuka email.');
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _FaqAccordion extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqAccordion({required this.question, required this.answer});

  @override
  State<_FaqAccordion> createState() => _FaqAccordionState();
}

class _FaqAccordionState extends State<_FaqAccordion> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: GestureDetector(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppText(
                      widget.question,
                      variant: AppTextVariant.h4,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 250),
                crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                sizeCurve: Curves.easeInOut,
                firstChild: const SizedBox(width: double.infinity),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: AppText(
                      widget.answer,
                      variant: AppTextVariant.bodyMedium,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

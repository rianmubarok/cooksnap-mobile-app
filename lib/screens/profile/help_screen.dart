import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../utils/placeholder_snackbar.dart';
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
          _FaqAccordion(
            question: 'Bagaimana cara menambahkan resep ke favorit?',
            answer:
                'Anda dapat menekan ikon hati (♡) pada halaman detail resep atau di sudut kanan atas kartu resep.',
          ),
          _FaqAccordion(
            question: 'Bagaimana cara mencari resep menggunakan bahan?',
            answer:
                'Buka fitur pemindai (Scanner) untuk memindai bahan makanan Anda, atau gunakan fitur pencarian dan ketikkan bahan yang Anda miliki.',
          ),
          _FaqAccordion(
            question: 'Apakah aplikasi ini gratis?',
            answer:
                'Ya, aplikasi Cooksnap dapat diunduh dan digunakan secara gratis. Namun, mungkin ada fitur premium di masa mendatang.',
          ),
          _FaqAccordion(
            question: 'Bagaimana cara mengubah profil saya?',
            answer:
                'Anda dapat pergi ke halaman Profil, lalu pilih menu "Informasi Profil" untuk mengubah nama atau kata sandi Anda.',
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
            onPressed: () {
              showPlaceholderSnackBar(context, 'Menghubungi dukungan pelanggan segera hadir');
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

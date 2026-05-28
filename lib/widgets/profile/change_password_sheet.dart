import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../utils/app_snackbar.dart';
import '../common/app_text.dart';
import '../common/app_confirm_dialog.dart';
import '../custom_button.dart';
import '../custom_text_field.dart';

class ChangePasswordSheet extends StatefulWidget {
  const ChangePasswordSheet({super.key});

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Simpan Kata Sandi',
      message: 'Apakah Anda yakin ingin mengubah kata sandi Anda?',
      confirmText: 'Ubah',
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);

    // Simulate network request
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.pop(context);
    showAppSnackBar(
      context,
      'Kata sandi berhasil diubah',
      variant: AppSnackBarVariant.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine bottom padding for keyboard
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: AppConstants.paddingScreen,
        right: AppConstants.paddingScreen,
        top: AppConstants.paddingScreen,
        bottom: AppConstants.paddingScreen + bottomInset,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXl),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppConstants.spacingXl),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const AppText(
              'Ubah Kata Sandi',
              variant: AppTextVariant.h3,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            const AppText(
              'Masukkan kata sandi lama Anda dan buat kata sandi baru untuk mengamankan akun Anda.',
              variant: AppTextVariant.bodyMedium,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppConstants.spacingXl),
            CustomTextField(
              hintText: 'Kata Sandi Lama',
              prefixIcon: LucideIcons.lock,
              isPassword: true,
              controller: _oldPasswordController,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Wajib diisi';
                return null;
              },
            ),
            const SizedBox(height: AppConstants.spacingMd),
            CustomTextField(
              hintText: 'Kata Sandi Baru',
              prefixIcon: LucideIcons.lock,
              isPassword: true,
              controller: _newPasswordController,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Wajib diisi';
                if (value.length < 6) return 'Minimal 6 karakter';
                return null;
              },
            ),
            const SizedBox(height: AppConstants.spacingMd),
            CustomTextField(
              hintText: 'Konfirmasi Kata Sandi Baru',
              prefixIcon: LucideIcons.lock,
              isPassword: true,
              controller: _confirmPasswordController,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Wajib diisi';
                if (value != _newPasswordController.text) return 'Kata sandi tidak cocok';
                return null;
              },
            ),
            const SizedBox(height: AppConstants.spacingXxl),
            PrimaryButton(
              text: 'Simpan Kata Sandi',
              onPressed: _isLoading ? null : _handleSave,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../providers/user_provider.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/common/app_confirm_dialog.dart';
import '../../widgets/common/app_text.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/navigation/circular_header_button.dart';
import '../../widgets/profile/change_password_sheet.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>();
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    
    _nameController.addListener(_onFormChanged);
    _emailController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFormChanged);
    _emailController.removeListener(_onFormChanged);
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onFormChanged() => setState(() {});

  bool get _hasChanges {
    final user = context.read<UserProvider>();
    return _nameController.text.trim() != user.name ||
           _emailController.text.trim() != user.email;
  }

  bool get _isFormValid =>
      _nameController.text.trim().isNotEmpty &&
      _emailController.text.trim().isNotEmpty;

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;

    await context.read<UserProvider>().updateProfile(
          _nameController.text.trim(),
          _emailController.text.trim(),
        );

    setState(() => _isLoading = false);

    showAppSnackBar(
      context,
      'Profil berhasil diperbarui',
      variant: AppSnackBarVariant.success,
    );
    Navigator.pop(context);
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
        title: Text(
          'Informasi Profil',
          style: AppTextStyles.h3.copyWith(color: AppColors.primary),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingScreen),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: AppText(
                          _nameController.text.isNotEmpty 
                              ? _nameController.text[0].toUpperCase() 
                              : 'G',
                          variant: AppTextVariant.headlineDisplaySemibold,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.brandOrange,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 2),
                        ),
                        child: const Icon(
                          LucideIcons.camera,
                          color: AppColors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacingXxl),
              CustomTextField(
                hintText: 'Nama Lengkap',
                prefixIcon: LucideIcons.user,
                controller: _nameController,
                large: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Nama wajib diisi';
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingLg),
              CustomTextField(
                hintText: 'Alamat Email',
                prefixIcon: LucideIcons.mail,
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                large: true,
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Email wajib diisi';
                  if (!value.contains('@')) return 'Email tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingXxl),
              PrimaryButton(
                text: 'Simpan Perubahan',
                onPressed: _isFormValid && _hasChanges && !_isLoading 
                    ? () async {
                        FocusScope.of(context).unfocus();
                        final confirmed = await AppConfirmDialog.show(
                          context,
                          title: 'Simpan Perubahan',
                          message: 'Apakah Anda yakin ingin menyimpan perubahan pada profil Anda?',
                          confirmText: 'Simpan',
                          icon: LucideIcons.save,
                        );
                        if (confirmed == true && context.mounted) {
                          _handleSave();
                        }
                      }
                    : null,
                isLoading: _isLoading,
              ),
              const SizedBox(height: AppConstants.spacingXxl),
              const Divider(color: AppColors.border),
              const SizedBox(height: AppConstants.spacingLg),
              const AppText(
                'Keamanan Akun',
                variant: AppTextVariant.h4,
              ),
              const SizedBox(height: AppConstants.spacingMd),
              FilledButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const ChangePasswordSheet(),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.chipBackground,
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(AppConstants.buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  ),
                ),
                child: const AppText('Ubah Kata Sandi', variant: AppTextVariant.buttonLarge),
              ),
              const SizedBox(height: AppConstants.spacingXxl),
            ],
          ),
        ),
      ),
    );
  }
}

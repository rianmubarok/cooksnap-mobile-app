import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_routes.dart';
import '../../core/app_text_styles.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/auth/auth_footer_link.dart';
import '../../widgets/auth/auth_header.dart';
import '../../widgets/auth/auth_screen_layout.dart';
import '../../widgets/auth/terms_conditions_sheet.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/navigation/circular_header_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onFormChanged);
    _emailController.addListener(_onFormChanged);
    _passwordController.addListener(_onFormChanged);
    _confirmPasswordController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFormChanged);
    _emailController.removeListener(_onFormChanged);
    _passwordController.removeListener(_onFormChanged);
    _confirmPasswordController.removeListener(_onFormChanged);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onFormChanged() => setState(() {});

  bool get _isFormValid =>
      _nameController.text.trim().isNotEmpty &&
      _emailController.text.trim().isNotEmpty &&
      _passwordController.text.trim().isNotEmpty &&
      _confirmPasswordController.text.trim().isNotEmpty &&
      _agreedToTerms;

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      
      await context.read<UserProvider>().register(name, email, password);
      
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.verifyEmail,
        arguments: email,
      );
    } catch (e) {
      if (!mounted) return;
      
      String errorMessage = 'Gagal mendaftar. Silakan coba lagi.';
      if (e is ClientException) {
        if (e.statusCode == 0) {
          errorMessage = 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
        } else {
          final data = e.response['data'] as Map<String, dynamic>?;
          if (data != null && data['email'] != null) {
            errorMessage = 'Email ini sudah terdaftar. Silakan gunakan email lain atau Masuk.';
          } else {
            errorMessage = e.response['message']?.toString() ?? 'Pendaftaran gagal';
          }
        }
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenLayout(
      footer: AuthFooterLink(
        prompt: 'Sudah punya akun? ',
        actionLabel: 'Masuk',
        onTap: () => Navigator.pop(context),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: CircularHeaderButton(
                onPressed: () => Navigator.pop(context),
                icon: LucideIcons.chevronLeft,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            const AuthHeader(
              title: 'Buat Akun',
              subtitle: 'Gabung dengan CookSnap hari ini',
            ),
            const SizedBox(height: AppConstants.spacingXl),
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
            const SizedBox(height: AppConstants.spacingMd),
            CustomTextField(
              hintText: 'Alamat Email',
              prefixIcon: LucideIcons.mail,
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
              large: true,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Email wajib diisi';
                if (!value.contains('@')) return 'Email tidak valid';
                return null;
              },
            ),
            const SizedBox(height: AppConstants.spacingMd),
            CustomTextField(
              hintText: 'Kata Sandi',
              prefixIcon: LucideIcons.lock,
              isPassword: true,
              controller: _passwordController,
              large: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kata sandi wajib diisi';
                }
                if (value.length < 8) return 'Kata sandi minimal 8 karakter';
                return null;
              },
            ),
            const SizedBox(height: AppConstants.spacingMd),
            CustomTextField(
              hintText: 'Konfirmasi Kata Sandi',
              prefixIcon: LucideIcons.lock,
              isPassword: true,
              controller: _confirmPasswordController,
              textInputAction: TextInputAction.done,
              large: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Konfirmasi kata sandi wajib diisi';
                }
                if (value != _passwordController.text) {
                  return 'Kata sandi tidak cocok';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.spacingLg),
            PrimaryButton(
              text: 'Buat Akun',
              onPressed: _isFormValid && !_isLoading ? _handleRegister : null,
              isLoading: _isLoading,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            _buildTermsCheckbox(),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _agreedToTerms,
            onChanged: (value) {
              setState(() => _agreedToTerms = value ?? false);
            },
            activeColor: AppColors.brandOrange,
            checkColor: AppColors.white,
            side: const BorderSide(color: AppColors.brandOrange, width: 1.5),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.spacingSm),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
            child: Text.rich(
              TextSpan(
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey666),
                children: [
                  const TextSpan(text: 'Setuju dengan '),
                  TextSpan(
                    text: 'Syarat & Ketentuan',
                    style: AppTextStyles.link,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => showTermsConditionsSheet(context),
                  ),
                  const TextSpan(text: ' CookSnap'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

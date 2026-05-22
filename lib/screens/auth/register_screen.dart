import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../core/app_constants.dart';
import '../../core/app_decorations.dart';
import '../../core/app_text_styles.dart';
import '../../core/app_routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

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

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isLoading = false);
          context.read<UserProvider>().setUser(
                _nameController.text.trim(),
                _emailController.text.trim(),
              );
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.background,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.paddingScreen),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 20,
                            color: AppColors.textPrimary,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingMd),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Buat Akun',
                              style: AppTextStyles.headlineAuth,
                            ),
                            SizedBox(height: AppConstants.spacingSm),
                            Text(
                              'Gabung dengan CookSnap hari ini',
                              style: AppTextStyles.subtitleMuted,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingXl),
                      CustomTextField(
                        hintText: 'Nama Lengkap',
                        prefixIcon: Icons.person_outline,
                        controller: _nameController,
                        large: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.spacingMd),
                      CustomTextField(
                        hintText: 'Alamat Email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        large: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email wajib diisi';
                          }
                          if (!value.contains('@')) {
                            return 'Email tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.spacingMd),
                      CustomTextField(
                        hintText: 'Kata Sandi',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        controller: _passwordController,
                        large: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kata sandi wajib diisi';
                          }
                          if (value.length < 6) {
                            return 'Kata sandi minimal 6 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.spacingMd),
                      CustomTextField(
                        hintText: 'Konfirmasi Kata Sandi',
                        prefixIcon: Icons.lock_outline,
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
                        onPressed: _isFormValid && !_isLoading
                            ? _handleRegister
                            : null,
                        isLoading: _isLoading,
                        useGradient: true,
                      ),
                      const SizedBox(height: AppConstants.spacingMd),
                      _buildTermsCheckbox(),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingScreen,
                0,
                AppConstants.paddingScreen,
                AppConstants.spacingXl,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sudah punya akun? ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
            side: const BorderSide(
              color: AppColors.brandOrange,
              width: 1.5,
            ),
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
            onTap: () {
              setState(() => _agreedToTerms = !_agreedToTerms);
            },
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.grey666,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'Setuju dengan '),
                  TextSpan(
                    text: 'Syarat & Ketentuan',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fitur syarat & ketentuan segera hadir'),
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
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

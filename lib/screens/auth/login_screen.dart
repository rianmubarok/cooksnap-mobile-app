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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onFormChanged);
    _passwordController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onFormChanged);
    _passwordController.removeListener(_onFormChanged);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onFormChanged() => setState(() {});

  bool get _isFormValid =>
      _emailController.text.trim().isNotEmpty &&
      _passwordController.text.trim().isNotEmpty;

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isLoading = false);
          final email = _emailController.text.trim();
          final displayName = email.contains('@')
              ? email.split('@').first
              : email;
          context.read<UserProvider>().setUser(
                displayName.isEmpty ? 'User' : displayName,
                email,
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
        decoration: AppDecorations.pageBackground,
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
                        const SizedBox(height: AppConstants.spacingXl),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Selamat Datang Kembali',
                                style: AppTextStyles.headlineAuth,
                              ),
                              SizedBox(height: AppConstants.spacingSm),
                              Text(
                                'Masuk untuk lanjut memasak',
                                style: AppTextStyles.subtitleMuted,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingXl),
                        CustomTextField(
                          hintText: 'Alamat Email',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          large: true,
                        ),
                        const SizedBox(height: AppConstants.spacingMd),
                        CustomTextField(
                          hintText: 'Kata Sandi',
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          controller: _passwordController,
                          textInputAction: TextInputAction.done,
                          large: true,
                        ),
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'Lupa Kata Sandi?',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingLg),
                        PrimaryButton(
                          text: 'Masuk',
                          onPressed:
                              _isFormValid && !_isLoading ? _handleLogin : null,
                          isLoading: _isLoading,
                          useGradient: true,
                        ),
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
                      'Belum punya akun? ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.register);
                      },
                      child: const Text(
                        'Daftar',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
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
}

import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Login Screen
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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simulate login — replace with real auth later
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingScreen),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppConstants.spacingXl),

                // Header
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusLg),
                    ),
                    child: const Center(
                      child: Text(
                        '📸',
                        style: TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.spacingLg),

                const Center(
                  child: Text(
                    'Selamat Datang!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.spacingSm),

                const Center(
                  child: Text(
                    'Masuk ke akun CookSnap kamu',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.spacingXl),

                // Email Field
                CustomTextField(
                  labelText: 'Email',
                  hintText: 'nama@email.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
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

                // Password Field
                CustomTextField(
                  labelText: 'Password',
                  hintText: 'Masukkan password',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  controller: _passwordController,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password wajib diisi';
                    }
                    if (value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppConstants.spacingSm),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password
                    },
                    child: const Text(
                      'Lupa Password?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.spacingLg),

                // Login Button
                PrimaryButton(
                  text: 'Masuk',
                  onPressed: _handleLogin,
                  isLoading: _isLoading,
                  useGradient: true,
                ),

                const SizedBox(height: AppConstants.spacingMd),

                // Divider
                const Row(
                  children: [
                    Expanded(
                      child: Divider(color: AppColors.divider),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingMd,
                      ),
                      child: Text(
                        'atau',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textHint,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: AppColors.divider),
                    ),
                  ],
                ),

                const SizedBox(height: AppConstants.spacingMd),

                // Google Login
                SecondaryButton(
                  text: 'Masuk dengan Google',
                  icon: Icons.g_mobiledata,
                  onPressed: () {
                    // TODO: Implement Google login
                  },
                ),

                const SizedBox(height: AppConstants.spacingXl),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Belum punya akun? ',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.register);
                      },
                      child: const Text(
                        'Daftar',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppConstants.spacingLg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

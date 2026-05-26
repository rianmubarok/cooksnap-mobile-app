import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_constants.dart';
import '../../core/app_strings.dart';
import '../../core/app_routes.dart';
import '../../core/app_text_styles.dart';
import '../../providers/user_provider.dart';
import '../../utils/auth_mock.dart';
import '../../utils/placeholder_snackbar.dart';
import '../../widgets/auth/auth_footer_link.dart';
import '../../widgets/auth/auth_header.dart';
import '../../widgets/auth/auth_screen_layout.dart';
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

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await runMockAuth(context, onComplete: () {
      setState(() => _isLoading = false);
      final email = _emailController.text.trim();
      final displayName = email.contains('@') ? email.split('@').first : email;
      context.read<UserProvider>().setUser(
            displayName.isEmpty ? AppStrings.defaultUserName : displayName,
            email,
          );
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenLayout(
      footer: AuthFooterLink(
        prompt: 'Belum punya akun? ',
        actionLabel: 'Daftar',
        onTap: () => Navigator.pushNamed(context, AppRoutes.register),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: AppConstants.spacingXl),
            const AuthHeader(
              title: 'Selamat Datang Kembali',
              subtitle: 'Masuk untuk lanjut memasak',
            ),
            const SizedBox(height: AppConstants.spacingXl),
            CustomTextField(
              hintText: 'Alamat Email',
              prefixIcon: LucideIcons.mail,
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
              large: true,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            CustomTextField(
              hintText: 'Kata Sandi',
              prefixIcon: LucideIcons.lock,
              isPassword: true,
              controller: _passwordController,
              textInputAction: TextInputAction.done,
              large: true,
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => showPlaceholderSnackBar(
                  context,
                  'Fitur reset kata sandi segera hadir',
                ),
                child:
                    const Text('Lupa Kata Sandi?', style: AppTextStyles.link),
              ),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            PrimaryButton(
              text: 'Masuk',
              onPressed: _isFormValid && !_isLoading ? _handleLogin : null,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

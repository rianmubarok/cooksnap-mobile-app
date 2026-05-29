import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../core/app_constants.dart';
import '../../core/app_routes.dart';
import '../../core/app_text_styles.dart';
import '../../providers/user_provider.dart';
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

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onFormChanged);
    _passwordController.addListener(_onFormChanged);
    
    // Check for autofill email from recent registration
    _checkAutofillEmail();
    
    // Listen for incoming app links (e.g., from email verification)
    _initDeepLinks();
  }

  Future<void> _checkAutofillEmail() async {
    final email = await context.read<UserProvider>().getLastRegisteredEmail();
    if (email != null && email.isNotEmpty && mounted) {
      setState(() {
        _emailController.text = email;
      });
    }
  }

  void _initDeepLinks() {
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      if (uri.scheme == 'cooksnap' && uri.host == 'login') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verifikasi Berhasil! Silakan masukkan kata sandi Anda.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
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
    
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      
      await context.read<UserProvider>().login(email, password);
      
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      
      String errorMessage = 'Login gagal. Periksa kembali email dan kata sandi Anda.';
      if (e is ClientException && e.statusCode == 0) {
        errorMessage = 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      } else if (e.toString().contains('unverified_email')) {
        errorMessage = 'Email Anda belum diverifikasi. Silakan periksa kotak masuk email Anda terlebih dahulu.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
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
              validator: (value) {
                if (value == null || value.isEmpty) return 'Email wajib diisi';
                if (!value.contains('@')) return 'Format email tidak valid';
                return null;
              },
            ),
            const SizedBox(height: AppConstants.spacingMd),
            CustomTextField(
              hintText: 'Kata Sandi',
              prefixIcon: LucideIcons.lock,
              isPassword: true,
              controller: _passwordController,
              textInputAction: TextInputAction.done,
              large: true,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Kata sandi wajib diisi';
                return null;
              },
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
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

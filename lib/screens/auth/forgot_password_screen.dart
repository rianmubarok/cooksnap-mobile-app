import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/app_constants.dart';
import '../../core/pocketbase_client.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/auth/auth_footer_link.dart';
import '../../widgets/auth/auth_header.dart';
import '../../widgets/auth/auth_screen_layout.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onFormChanged);
    _emailController.dispose();
    super.dispose();
  }

  void _onFormChanged() => setState(() {});

  bool get _isFormValid => _emailController.text.trim().isNotEmpty;

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();
      await PocketBaseClient.instance.collection('users').requestPasswordReset(email);
      
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Tautan reset kata sandi telah dikirim ke email Anda',
        variant: AppSnackBarVariant.success,
      );
      Navigator.pop(context); // Kembali ke halaman login
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Gagal mengirim tautan reset: $e',
        variant: AppSnackBarVariant.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenLayout(
      footer: AuthFooterLink(
        prompt: 'Ingat kata sandi Anda? ',
        actionLabel: 'Masuk',
        onTap: () => Navigator.pop(context),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: AppConstants.spacingXl),
            const AuthHeader(
              title: 'Lupa Kata Sandi',
              subtitle: 'Masukkan email Anda untuk menerima tautan reset kata sandi',
            ),
            const SizedBox(height: AppConstants.spacingXl),
            CustomTextField(
              hintText: 'Alamat Email',
              prefixIcon: LucideIcons.mail,
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
              textInputAction: TextInputAction.done,
              large: true,
            ),
            const SizedBox(height: AppConstants.spacingXl),
            PrimaryButton(
              text: 'Kirim Tautan',
              onPressed: _isFormValid && !_isLoading ? _handleResetPassword : null,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

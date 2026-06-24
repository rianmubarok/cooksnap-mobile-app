import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/common/app_text.dart';
import '../../widgets/custom_button.dart';

class QrisPaymentScreen extends StatefulWidget {
  const QrisPaymentScreen({super.key});

  @override
  State<QrisPaymentScreen> createState() => _QrisPaymentScreenState();
}

class _QrisPaymentScreenState extends State<QrisPaymentScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  String? _qrisImageBase64;
  String? _orderId;
  int? _totalAmount;
  Timer? _pollingTimer;
  bool _isCheckingStatus = false;

  @override
  void initState() {
    super.initState();
    _createTransaction();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _createTransaction() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userProvider = context.read<UserProvider>();
      final result = await userProvider.createSubscription();
      
      setState(() {
        _orderId = result['order_id'];
        _totalAmount = result['total_amount'];
        
        final rawBase64 = result['qris_image'] as String;
        if (rawBase64.contains(',')) {
          _qrisImageBase64 = rawBase64.split(',')[1];
        } else {
          _qrisImageBase64 = rawBase64;
        }
        
        _isLoading = false;
      });

      _startPolling();
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal membuat transaksi. Pastikan internet Anda lancar dan coba lagi.';
        _isLoading = false;
      });
    }
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_orderId == null || _isCheckingStatus) return;
      _checkStatusInternal(isManual: false);
    });
  }

  Future<void> _checkStatusInternal({bool isManual = true}) async {
    if (_orderId == null || _isCheckingStatus) return;
    
    setState(() {
      _isCheckingStatus = true;
    });
    
    try {
      final userProvider = context.read<UserProvider>();
      final status = await userProvider.checkPaymentStatus(_orderId!);
      
      if (status == 'PAID' || status == 'SUCCESS') {
        _pollingTimer?.cancel();
        _showSuccessAndExit();
      } else if (status == 'EXPIRED') {
        _pollingTimer?.cancel();
        if (mounted) {
          setState(() {
            _errorMessage = 'Waktu pembayaran telah habis. Silakan buat transaksi baru.';
            _qrisImageBase64 = null;
          });
        }
      } else if (isManual && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pembayaran belum diterima, silakan tunggu sebentar lagi.')),
        );
      }
    } catch (e) {
      // Ignore errors for silent polling
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingStatus = false;
        });
      }
    }
  }

  void _showSuccessAndExit() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusLg)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 28),
            SizedBox(width: 8),
            Text('Berhasil!', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('Terima kasih! Pembayaran berhasil diterima dan akun CookSnap PRO Anda sudah aktif.'),
        actions: [
          TextButton(
            onPressed: () {
              // trigger provider update if necessary, usually authstore updates it
              Navigator.of(context).pop(); // pop dialog
              Navigator.of(context).pop(); // pop payment screen
            },
            child: const Text('Tutup', style: TextStyle(color: AppColors.primary)),
          )
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    // Simple manual format since intl is not in pubspec
    final str = amount.toString();
    String res = '';
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count == 3) {
        res = '.$res';
        count = 0;
      }
      res = '${str[i]}$res';
      count++;
    }
    return 'Rp $res';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pembayaran QRIS')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppText(
                'Selesaikan Pembayaran',
                variant: AppTextVariant.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingMd),
              const AppText(
                'Scan QR Code di bawah ini menggunakan aplikasi M-Banking atau E-Wallet pilihan Anda.',
                textAlign: TextAlign.center,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppConstants.spacingXl),
              
              Expanded(
                child: Center(
                  child: _buildMainContent(),
                ),
              ),
              
              if (_qrisImageBase64 != null) ...[
                const SizedBox(height: AppConstants.spacingXl),
                PrimaryButton(
                  text: _isCheckingStatus ? 'Mengecek...' : 'Cek Status Pembayaran',
                  onPressed: _isCheckingStatus ? null : () => _checkStatusInternal(isManual: true),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: AppConstants.spacingMd),
          AppText('Sedang membuat QR Code...', color: AppColors.textSecondary),
        ],
      );
    }

    if (_errorMessage != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: AppConstants.spacingMd),
          AppText(_errorMessage!, color: AppColors.error, textAlign: TextAlign.center),
          const SizedBox(height: AppConstants.spacingXl),
          PrimaryButton(
            text: 'Coba Lagi',
            onPressed: _createTransaction,
          )
        ],
      );
    }

    if (_qrisImageBase64 != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Image.memory(
              base64Decode(_qrisImageBase64!),
              width: 250,
              height: 250,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100),
            ),
          ),
          const SizedBox(height: AppConstants.spacingXl),
          const AppText('Total Tagihan', color: AppColors.textSecondary),
          AppText(
            _formatCurrency(_totalAmount ?? 0),
            variant: AppTextVariant.h3,
            color: const Color(0xFFD97706),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          const AppText(
            'Pastikan nominal sesuai hingga 3 digit terakhir.',
            variant: AppTextVariant.bodySmall,
            color: AppColors.error,
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

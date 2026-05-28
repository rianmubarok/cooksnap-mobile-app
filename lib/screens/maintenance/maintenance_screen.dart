import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/app_colors.dart';

/// Layar yang menahan user saat server dalam mode perbaikan.
/// Tidak ada tombol navigasi — user hanya bisa menunggu.
class MaintenanceScreen extends StatefulWidget {
  final String message;

  const MaintenanceScreen({
    super.key,
    required this.message,
  });

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Animated Logo
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/logos/cooksnap_logo.svg',
                        width: 60,
                        height: 60,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // Title
                const Text(
                  'Sedang Perbaikan',
                  style: TextStyle(
                    fontFamily: 'WorkSans',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 14),

                // Message
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    widget.message,
                    style: TextStyle(
                      fontFamily: 'WorkSans',
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 28),

                // Status indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Dot(delay: 0, controller: _pulseController),
                    const SizedBox(width: 6),
                    _Dot(delay: 0.3, controller: _pulseController),
                    const SizedBox(width: 6),
                    _Dot(delay: 0.6, controller: _pulseController),
                  ],
                ),

                const Spacer(flex: 3),

                // Footer
                Text(
                  'CookSnap akan kembali segera.',
                  style: TextStyle(
                    fontFamily: 'WorkSans',
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final double delay;
  final AnimationController controller;

  const _Dot({required this.delay, required this.controller});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> {
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: Interval(widget.delay, (widget.delay + 0.4).clamp(0.0, 1.0),
            curve: Curves.easeInOut),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) => Opacity(
        opacity: _anim.value,
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.secondary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

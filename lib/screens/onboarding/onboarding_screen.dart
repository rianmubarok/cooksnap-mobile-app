import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../core/app_routes.dart';
import '../../data/dummy/dummy_data.dart';
import '../../widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = DummyData.onboardingPages;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.animNormal,
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.onboardingGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              SizedBox(
                height: 240,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildIllustration(_pages[index]);
                  },
                ),
              ),
              const SizedBox(height: AppConstants.spacingXxl),
              _buildDotIndicators(),
              const SizedBox(height: AppConstants.spacingXxl),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingScreen * 2,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: Column(
                    children: [
                      Text(
                        page['title'] as String,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headlineDisplay,
                      ),
                      const SizedBox(height: AppConstants.spacingXl),
                      Text(
                        page['subtitle'] as String,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.subtitleMuted.copyWith(height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 3),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.paddingScreen,
                  0,
                  AppConstants.paddingScreen,
                  AppConstants.spacingXl,
                ),
                child: PrimaryButton(
                  text: _currentPage < _pages.length - 1 ? 'Lanjut' : 'Mulai',
                  onPressed: _onNext,
                  useGradient: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration(Map<String, dynamic> page) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SvgPicture.asset(
        page['image'] as String,
        width: 240,
        height: 240,
      ),
    );
  }

  Widget _buildDotIndicators() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _pages.length,
          (index) => AnimatedContainer(
            duration: AppConstants.animFast,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            width: _currentPage == index ? 28 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentPage == index
                  ? AppColors.brandOrange
                  : AppColors.brandOrange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppConstants.radiusRound),
            ),
          ),
        ),
      ),
    );
  }
}

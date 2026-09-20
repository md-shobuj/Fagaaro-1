import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/entities/onboarding_item.dart';
import '../widgets/onboarding_content_widget.dart';
import '../widgets/onboarding_page_indicator.dart';

/// Comprehensive 3-page Onboarding Screen adhering to Senior Flutter standards.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;

  static const List<OnboardingItem> _items = [
    OnboardingItem(
      titlePart1: 'Host with ',
      titlePart2: 'Ease',
      description: 'Create, manage, and monetize\nyour meetings in minutes',
      imagePath: 'assets/images/onboarding_first_image.png',
    ),
    OnboardingItem(
      titlePart1: 'Join What ',
      titlePart2: 'Matters',
      description:
          'Pay securely and join exclusive \nmeetings with experts, creators and \nprofessionals',
      imagePath: 'assets/images/onboarding_second_image.jpg',
    ),
    OnboardingItem(
      titlePart1: 'Connect Without ',
      titlePart2: 'Limits',
      description:
          'Meet, learn and grow with people\nfrom around the world',
      imagePath: 'assets/images/onboarding_third_image.jpg.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_currentIndex < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToSelectRole();
    }
  }

  void _onSkipPressed() {
    _navigateToSelectRole();
  }

  void _navigateToSelectRole() {
    context.go(AppRouter.selectRolePath);
  }

  void _navigateToLogin() {
    context.go(AppRouter.loginPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Top Header: Page Indicator & Skip Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  OnboardingPageIndicator(
                    count: _items.length,
                    currentIndex: _currentIndex,
                  ),
                  TextButton(
                    onPressed: _onSkipPressed,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Skip',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // PageView Slides
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _items.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return OnboardingContentWidget(
                      item: _items[index],
                      isLastPage: index == _items.length - 1,
                      onNextPressed: _onNextPressed,
                      onLoginPressed: _navigateToLogin,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

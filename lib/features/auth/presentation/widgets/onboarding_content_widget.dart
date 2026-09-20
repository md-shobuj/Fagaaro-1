import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/onboarding_item.dart';

/// Clean, responsive slide content widget for Onboarding.
class OnboardingContentWidget extends StatelessWidget {
  final OnboardingItem item;
  final VoidCallback onNextPressed;
  final VoidCallback onLoginPressed;
  final bool isLastPage;

  const OnboardingContentWidget({
    super.key,
    required this.item,
    required this.onNextPressed,
    required this.onLoginPressed,
    this.isLastPage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Illustration Image Section
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Image.asset(
              item.imagePath,
              fit: BoxFit.contain,
              alignment: Alignment.center,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Text Content & Action Controls Section
        Expanded(
          flex: 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title & Subtitle Group
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: item.titlePart1,
                          style: TextStyle(
                            color: item.colorPart1,
                            fontSize: 20,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            height: 1.20,
                            letterSpacing: -0.50,
                          ),
                        ),
                        TextSpan(
                          text: item.titlePart2,
                          style: TextStyle(
                            color: item.colorPart2,
                            fontSize: 20,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            height: 1.20,
                            letterSpacing: -0.50,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      item.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xB2475569),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                      ),
                    ),
                  ),
                ],
              ),

              // Button & Login Text Group
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Next / Get Started Primary Button
                  SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: ShapeDecoration(
                        color: const Color(0xFF084DFB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x19000000),
                            blurRadius: 15,
                            offset: Offset(0, 10),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Color(0x19000000),
                            blurRadius: 6,
                            offset: Offset(0, 4),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: onNextPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          isLastPage ? 'Get Started' : 'Next',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Already have an account? Log in text link
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Already have an account?',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.43,
                          ),
                        ),
                        TextSpan(
                          text: ' Log in',
                          style: const TextStyle(
                            color: Color(0xFF2E5DA8),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                            height: 1.43,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = onLoginPressed,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

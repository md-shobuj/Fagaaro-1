import 'package:flutter/material.dart';

/// Pure Dart domain entity representing a single Onboarding slide.
class OnboardingItem {
  final String titlePart1;
  final String titlePart2;
  final String description;
  final String imagePath;
  final Color colorPart1;
  final Color colorPart2;

  const OnboardingItem({
    required this.titlePart1,
    required this.titlePart2,
    required this.description,
    required this.imagePath,
    this.colorPart1 = const Color(0xFF084DFB),
    this.colorPart2 = const Color(0xFF8B34FA),
  });
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/screen_header.dart';

/// Placeholder copy shared by the Terms, Privacy and About pages.
const List<String> kLegalParagraphs = [
  'Lorem ipsum dolor sit amet consectetur. Imperdiet iaculis convallis '
      'bibendum massa id elementum consectetur neque mauris.',
  'Lorem ipsum dolor sit amet consectetur. Imperdiet iaculis convallis '
      'bibendum massa id elementum consectetur neque mauris.',
  'Lorem ipsum dolor sit amet consectetur. Imperdiet iaculis convallis '
      'bibendum massa id elementum consectetur neque mauris.',
  'Lorem ipsum dolor sit amet consectetur. Imperdiet iaculis convallis '
      'bibendum massa id elementum consectetur neque mauris.',
  'Lorem ipsum dolor sit amet consectetur. Imperdiet iaculis convallis '
      'bibendum massa id elementum consectetur neque mauris.',
];

/// Reader screen for the numbered legal / informational pages.
class LegalScreen extends StatelessWidget {
  final String title;
  final List<String> paragraphs;

  const LegalScreen({
    super.key,
    required this.title,
    this.paragraphs = kLegalParagraphs,
  });

  void _onBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRouter.homePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppScreenHeader(title: title, onBack: () => _onBack(context)),
                  const SizedBox(height: 20),
                  for (int i = 0; i < paragraphs.length; i++) ...[
                    if (i > 0) const SizedBox(height: 16),
                    Text(
                      '${i + 1}. ${paragraphs[i]}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

const Color _primaryBlue = Color(0xFF084DFB);
const Color _ink = Color(0xFF0F172A);

/// Back arrow plus blue screen title, shared by the settings and legal pages.
class AppScreenHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const AppScreenHeader({
    super.key,
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onBack,
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.arrow_back_rounded, size: 22, color: _ink),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: _primaryBlue,
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              height: 1.75,
            ),
          ),
        ),
      ],
    );
  }
}

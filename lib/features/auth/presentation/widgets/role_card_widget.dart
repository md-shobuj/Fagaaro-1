import 'package:flutter/material.dart';
import '../../domain/entities/user_role.dart';

/// Reusable card widget for role selection adhering to Senior Flutter standards.
class RoleCardWidget extends StatelessWidget {
  final UserRole role;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleCardWidget({
    super.key,
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF084DFB);
    const Color defaultBorderColor = Color(0xFFD0D4DC);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: ShapeDecoration(
            color: isSelected ? primaryColor.withValues(alpha: 0.04) : Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: isSelected ? 2 : 1,
                color: isSelected ? primaryColor : defaultBorderColor,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            shadows: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x14084DFB),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ]
                : const [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Role Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  role.icon,
                  size: 24,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 12),

              // Role Title
              Text(
                role.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 18,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  height: 1.56,
                ),
              ),
              const SizedBox(height: 6),

              // Role Description
              Text(
                role.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

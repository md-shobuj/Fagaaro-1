import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/entities/user_role.dart';
import '../widgets/role_card_widget.dart';

/// Screen allowing the user to select their role (Attendee or Organizer).
class SelectRoleScreen extends StatefulWidget {
  const SelectRoleScreen({super.key});

  @override
  State<SelectRoleScreen> createState() => _SelectRoleScreenState();
}

class _SelectRoleScreenState extends State<SelectRoleScreen> {
  UserRole? _selectedRole;

  void _onRoleSelected(UserRole role) {
    setState(() {
      _selectedRole = role;
    });
    _proceedToAuth(role);
  }

  void _proceedToAuth(UserRole role) {
    // Navigate to Login screen with selected role passed as extra parameter
    context.go(AppRouter.loginPath, extra: role);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button Row
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(AppRouter.onboardingPath);
                      }
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF111827),
                      size: 24,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Title & Subtitle Header
              Center(
                child: Column(
                  children: const [
                    Text(
                      'Select Your Role',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 24,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        height: 1.50,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Choose how you'll use Fagaaro",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF4B5563),
                        fontSize: 18,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.56,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Role Options List
              Expanded(
                child: ListView(
                  children: [
                    RoleCardWidget(
                      role: UserRole.attendee,
                      isSelected: _selectedRole == UserRole.attendee,
                      onTap: () => _onRoleSelected(UserRole.attendee),
                    ),
                    const SizedBox(height: 20),
                    RoleCardWidget(
                      role: UserRole.organizer,
                      isSelected: _selectedRole == UserRole.organizer,
                      onTap: () => _onRoleSelected(UserRole.organizer),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

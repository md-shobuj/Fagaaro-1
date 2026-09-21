import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/screen_header.dart';

const Color _danger = Color(0xFFEF4444);
const Color _chevron = Color(0xFF9AA1A9);

/// Account settings menu: password, legal pages and account deletion.
class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  void _onBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRouter.homePath);
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final bool confirmed = await showConfirmDialog(
      context,
      message: 'Confirm deleting your account?',
    );
    if (!confirmed || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account deletion requested.')),
    );
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
                  AppScreenHeader(
                    title: 'Account Settings',
                    onBack: () => _onBack(context),
                  ),
                  const SizedBox(height: 24),
                  _MenuRow(
                    label: 'Change Password',
                    onTap: () => context.push(AppRouter.changePasswordPath),
                  ),
                  const SizedBox(height: 20),
                  _MenuRow(
                    label: 'Terms of services',
                    onTap: () => context.push(AppRouter.termsPath),
                  ),
                  const SizedBox(height: 20),
                  _MenuRow(
                    label: 'Privacy Policy',
                    onTap: () => context.push(AppRouter.privacyPath),
                  ),
                  const SizedBox(height: 20),
                  _MenuRow(
                    label: 'About us',
                    onTap: () => context.push(AppRouter.aboutPath),
                  ),
                  const SizedBox(height: 24),
                  _MenuRow(
                    label: 'Delete Account',
                    destructive: true,
                    onTap: () => _deleteAccount(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final String label;
  final bool destructive;
  final VoidCallback onTap;

  const _MenuRow({
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: destructive ? _danger : Colors.black,
                fontSize: destructive ? 16 : 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 2,
              ),
            ),
            if (!destructive)
              const Icon(Icons.chevron_right_rounded, size: 22, color: _chevron),
          ],
        ),
      ),
    );
  }
}

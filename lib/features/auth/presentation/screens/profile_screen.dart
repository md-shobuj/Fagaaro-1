import 'package:flutter/material.dart';

const Color _primaryBlue = Color(0xFF084DFB);
const Color _ink = Color(0xFF0F172A);
const Color _danger = Color(0xFFEF4444);
const Color _tile = Color(0xFFFBF8F8);

/// Profile tab: identity header plus the account actions.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    this.userName = 'John smith',
    this.avatarAsset,
    this.onBack,
    this.onEditProfile,
    this.onAccountSettings,
    this.onLogout,
  });

  final String userName;

  /// Optional bundled avatar; falls back to a person glyph.
  final String? avatarAsset;
  final VoidCallback? onBack;
  final VoidCallback? onEditProfile;
  final VoidCallback? onAccountSettings;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(onBack: onBack),
            const SizedBox(height: 24),
            _Identity(name: userName, avatarAsset: avatarAsset),
            const SizedBox(height: 24),
            const Text(
              'Profile information',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            _MenuTile(
              icon: Icons.manage_accounts_outlined,
              label: 'Edit Profile',
              onTap: onEditProfile,
            ),
            const SizedBox(height: 14),
            _MenuTile(
              icon: Icons.settings_outlined,
              label: 'Account Settings',
              onTap: onAccountSettings,
            ),
            const SizedBox(height: 14),
            _MenuTile(
              icon: Icons.logout_rounded,
              label: 'Logout',
              destructive: true,
              onTap: onLogout,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback? onBack;

  const _Header({required this.onBack});

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
        const Text(
          'My Profile',
          style: TextStyle(
            color: _primaryBlue,
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Identity extends StatelessWidget {
  final String name;
  final String? avatarAsset;

  const _Identity({required this.name, required this.avatarAsset});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 96,
          height: 96,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: Color(0xFFEEF2F7),
            shape: BoxShape.circle,
          ),
          child: avatarAsset == null
              ? const Icon(Icons.person_rounded, size: 52, color: Color(0xFF94A3B8))
              : Image.asset(avatarAsset!, fit: BoxFit.cover, cacheWidth: 288),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool destructive;
  final VoidCallback? onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    this.destructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color foreground = destructive ? _danger : Colors.black;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _tile,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 22, color: foreground),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (!destructive)
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _primaryBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/presentation/utils/app_snackbar.dart';
import '../../../../core/presentation/widgets/app_bottom_nav_bar.dart';
import '../../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../../features/auth/domain/entities/user_profile.dart';
import '../../../../features/todos/domain/repositories/todos_repository.dart';
import '../../../../features/locations/domain/repositories/locations_repository.dart';
import '../../../../features/geofence/data/services/geofence_manager.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _profileDataFuture;

  @override
  void initState() {
    super.initState();
    _profileDataFuture = _loadProfileData();
  }

  Future<Map<String, dynamic>> _loadProfileData() async {
    final profile = await sl<AuthRepository>().getUserProfile();

    int completedTodos = 0;
    int totalTodos = 0;
    try {
      final todos = await sl<TodosRepository>().getTodos();
      totalTodos = todos.length;
      
      final now = DateTime.now();
      completedTodos = todos.where((t) {
        if (!t.isCompleted) return false;
        final localUpdated = t.updatedAt.toLocal();
        return localUpdated.year == now.year &&
               localUpdated.month == now.month &&
               localUpdated.day == now.day;
      }).length;
    } catch (_) {}

    int activeLocations = 0;
    try {
      final locations = await sl<LocationsRepository>().getLocations();
      activeLocations = locations.where((loc) => loc.isActive).length;
    } catch (_) {}

    return {
      'profile': profile,
      'completedTodos': completedTodos,
      'totalTodos': totalTodos,
      'activeLocations': activeLocations,
    };
  }

  String _formatRole(String role) {
    if (role.isEmpty) return 'User';
    return role.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  Future<void> _handleLogout() async {
    try {
      await sl<AuthRepository>().logout();
      sl<GeofenceManager>().stopMonitoring();
      if (mounted) {
        context.go(AppRouter.loginPath);
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Logout failed: ${e.toString()}');
      }
    }
  }

  Future<void> _showLogoutConfirmationDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF131A24);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF5C6675);
    final dialogBg = isDark ? const Color(0xFF131A24) : Colors.white;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: dialogBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Confirm Sign Out',
            style: TextStyle(
              color: titleColor,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 18.sp,
            ),
          ),
          content: Text(
            'Are you sure you want to sign out of your account?',
            style: TextStyle(
              color: subtitleColor,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 14.sp,
              height: 1.5,
            ),
          ),
          actionsPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: subtitleColor,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              ),
              child: Text(
                'Sign out',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _handleLogout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > AppDimensions.tabletBreakpoint;

    final cardBgColor = isDark ? const Color(0xFF131A24) : Colors.white;
    final borderColor = isDark ? const Color(0xFF222C3A) : const Color(0xFFE6EAEF);
    final titleColor = isDark ? Colors.white : const Color(0xFF131A24);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF5C6675);
    final accentBg = isDark ? const Color(0xFF0F3E3A) : const Color(0xFFD6F3EF);
    final accentText = isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0B6B62);

    final scaffoldBg = isDark ? const Color(0xFF0B0E14) : const Color(0xFFEBEDF1);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _profileDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
                ),
              );
            }

            final data = snapshot.data ?? {};
            final UserProfile? profile = data['profile'];
            final completed = data['completedTodos'] ?? 0;
            final total = data['totalTodos'] ?? 0;
            final activeLocs = data['activeLocations'] ?? 0;

            final String initials = (profile?.name.isNotEmpty ?? false)
                ? profile!.name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
                : 'JD';

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 480.0 : double.infinity,
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingXL,
                    vertical: AppDimensions.paddingXXL,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Screen Header Title
                      Text(
                        'Profile',
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 21.sp,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.42,
                        ),
                      ),
                      SizedBox(height: AppDimensions.spaceXXL),

                      // User Details Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingXXL,
                          vertical: AppDimensions.paddingXXL + 4,
                        ),
                        decoration: ShapeDecoration(
                          color: cardBgColor,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1,
                              color: borderColor,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          shadows: [
                            BoxShadow(
                              color: isDark ? Colors.black38 : const Color(0x0C141C28),
                              blurRadius: 16.r,
                              offset: const Offset(0, 6),
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: isDark ? Colors.black26 : const Color(0x0F141C28),
                              blurRadius: 2.r,
                              offset: const Offset(0, 1),
                              spreadRadius: 0,
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            // Initials Avatar
                            Container(
                              width: 76.w,
                              height: 76.w,
                              decoration: ShapeDecoration(
                                color: accentBg,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(38),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  initials,
                                  style: TextStyle(
                                    color: accentText,
                                    fontSize: 27.sp,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: AppDimensions.spaceM + 2),
                            // User Name
                            Text(
                              profile?.name ?? 'John Doe',
                              style: TextStyle(
                                color: titleColor,
                                fontSize: 19.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: AppDimensions.spaceXS),
                            // User Email
                            Text(
                              profile?.email ?? 'john.doe@example.com',
                              style: TextStyle(
                                color: subtitleColor,
                                fontSize: 13.5.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: AppDimensions.spaceM + 2),
                            // Role Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                              decoration: ShapeDecoration(
                                color: accentBg,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified_user_outlined,
                                    color: accentText,
                                    size: 13.sp,
                                  ),
                                  SizedBox(width: AppDimensions.spaceXS),
                                  Text(
                                    _formatRole(profile?.role ?? 'field_user'),
                                    style: TextStyle(
                                      color: accentText,
                                      fontSize: 12.sp,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppDimensions.spaceXXL),

                      // Stats Row
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingL,
                                vertical: AppDimensions.paddingL + 1,
                              ),
                              decoration: ShapeDecoration(
                                color: cardBgColor,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: borderColor,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                shadows: [
                                  BoxShadow(
                                    color: isDark ? Colors.black38 : const Color(0x0C141C28),
                                    blurRadius: 16.r,
                                    offset: const Offset(0, 6),
                                    spreadRadius: 0,
                                  ),
                                  BoxShadow(
                                    color: isDark ? Colors.black26 : const Color(0x0F141C28),
                                    blurRadius: 2.r,
                                    offset: const Offset(0, 1),
                                    spreadRadius: 0,
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$completed/$total',
                                    style: TextStyle(
                                      color: titleColor,
                                      fontSize: 23.sp,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.46,
                                    ),
                                  ),
                                  SizedBox(height: AppDimensions.spaceXS),
                                  Text(
                                    'Tasks done today',
                                    style: TextStyle(
                                      color: subtitleColor,
                                      fontSize: 12.sp,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: AppDimensions.spaceXL),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingL,
                                vertical: AppDimensions.paddingL + 1,
                              ),
                              decoration: ShapeDecoration(
                                color: cardBgColor,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: borderColor,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                shadows: [
                                  BoxShadow(
                                    color: isDark ? Colors.black38 : const Color(0x0C141C28),
                                    blurRadius: 16.r,
                                    offset: const Offset(0, 6),
                                    spreadRadius: 0,
                                  ),
                                  BoxShadow(
                                    color: isDark ? Colors.black26 : const Color(0x0F141C28),
                                    blurRadius: 2.r,
                                    offset: const Offset(0, 1),
                                    spreadRadius: 0,
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$activeLocs',
                                    style: TextStyle(
                                      color: titleColor,
                                      fontSize: 23.sp,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.46,
                                    ),
                                  ),
                                  SizedBox(height: AppDimensions.spaceXS),
                                  Text(
                                    'Active locations',
                                    style: TextStyle(
                                      color: subtitleColor,
                                      fontSize: 12.sp,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppDimensions.spaceXXL),

                      // Actions Card
                      Container(
                        width: double.infinity,
                        decoration: ShapeDecoration(
                          color: cardBgColor,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1,
                              color: borderColor,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          shadows: [
                            BoxShadow(
                              color: isDark ? Colors.black38 : const Color(0x0C141C28),
                              blurRadius: 16.r,
                              offset: const Offset(0, 6),
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: isDark ? Colors.black26 : const Color(0x0F141C28),
                              blurRadius: 2.r,
                              offset: const Offset(0, 1),
                              spreadRadius: 0,
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildActionItem(
                              context: context,
                              icon: Icons.person_outline,
                              title: 'Edit profile',
                              isDark: isDark,
                              titleColor: titleColor,
                              onTap: () {
                                AppSnackbar.showSuccess(context, 'Edit profile clicked');
                              },
                            ),
                            const Divider(height: 1, thickness: 1, color: Color(0xFFEFF2F5)),
                            _buildActionItem(
                              context: context,
                              icon: Icons.notifications_none_outlined,
                              title: 'Notifications',
                              isDark: isDark,
                              titleColor: titleColor,
                              onTap: () {
                                AppSnackbar.showSuccess(context, 'Notifications clicked');
                              },
                            ),
                            const Divider(height: 1, thickness: 1, color: Color(0xFFEFF2F5)),
                            _buildActionItem(
                              context: context,
                              icon: Icons.settings_outlined,
                              title: 'Settings',
                              isDark: isDark,
                              titleColor: titleColor,
                              onTap: () {
                                AppSnackbar.showSuccess(context, 'Settings clicked');
                              },
                            ),
                            const Divider(height: 1, thickness: 1, color: Color(0xFFEFF2F5)),
                            _buildActionItem(
                              context: context,
                              icon: Icons.help_outline,
                              title: 'Help & support',
                              isDark: isDark,
                              titleColor: titleColor,
                              onTap: () {
                                AppSnackbar.showSuccess(context, 'Help & support clicked');
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppDimensions.space4XL),

                      // Sign out Button
                      InkWell(
                        onTap: _showLogoutConfirmationDialog,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: double.infinity,
                          height: 52.h,
                          decoration: ShapeDecoration(
                            color: isDark ? const Color(0xFF2C1C1C) : const Color(0xFF2C1C1C),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 0.5,
                                color: isDark ? const Color(0xFF991B1B) : const Color(0xFFFDA29B),
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.logout_rounded,
                                color: isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626),
                                size: 20.sp,
                              ),
                              SizedBox(width: AppDimensions.spaceM),
                              Text(
                                'Sign out',
                                style: TextStyle(
                                  color: isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626),
                                  fontSize: 16.sp,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 3),
    );
  }

  Widget _buildActionItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isDark,
    required Color titleColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingXL,
          vertical: AppDimensions.paddingL + 1,
        ),
        child: Row(
          children: [
            // Icon wrapper
            Container(
              width: 34.w,
              height: 34.w,
              decoration: ShapeDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F4F7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Icon(
                icon,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF5C6675),
                size: 18.sp,
              ),
            ),
            SizedBox(width: AppDimensions.spaceXL),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 14.5.sp,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFF8A94A3),
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:fagaaro/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fagaaro/features/auth/presentation/bloc/auth_event.dart';
import 'package:fagaaro/features/auth/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../widgets/home_dashboard_tab.dart';
import '../widgets/my_events_tab.dart';

/// Root screen after onboarding: hosts the Home / Events / Profile tabs.
class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({super.key});

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  static const int _homeIndex = 0;
  static const int _eventsIndex = 1;

  int _currentIndex = _homeIndex;

  void _selectTab(int index) => setState(() => _currentIndex = index);

  Future<void> _logout() async {
    final bool confirmed = await showConfirmDialog(
      context,
      message: 'Do you want to Log out?',
    );
    if (!confirmed || !mounted) return;
    GetIt.instance<AuthBloc>().add(LogoutEvent());
    context.go(AppRouter.onboardingPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // IndexedStack keeps each tab's scroll position when switching.
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeDashboardTab(
            onManageSubscription: () => context.push(AppRouter.subscriptionPath),
            onCreateEvent: () => context.push(AppRouter.createEventPath),
            onSeeAllEvents: () => _selectTab(_eventsIndex),
          ),
          const MyEventsTab(totalCount: 24),
          ProfileScreen(
            onBack: () => _selectTab(_homeIndex),
            onEditProfile: () => context.push(AppRouter.editProfilePath),
            onAccountSettings: () => context.push(AppRouter.accountSettingsPath),
            onLogout: _logout,
          ),
        ],
      ),
      bottomNavigationBar: _HomeNavBar(
        currentIndex: _currentIndex,
        onSelected: _selectTab,
      ),
    );
  }
}

class _HomeNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelected;

  const _HomeNavBar({required this.currentIndex, required this.onSelected});

  static const Color _primaryBlue = Color(0xFF084DFB);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          height: 68,
          indicatorColor: const Color(0x1A084DFB),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final bool selected = states.contains(WidgetState.selected);
            return IconThemeData(
              size: 24,
              color: selected ? _primaryBlue : const Color(0xFF94A3B8),
            );
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final bool selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              color: selected ? _primaryBlue : const Color(0xFF94A3B8),
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onSelected,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.event_outlined),
              selectedIcon: Icon(Icons.event_rounded),
              label: 'Events',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

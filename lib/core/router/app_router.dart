import 'dart:async';
import 'package:fagaaro/features/auth/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/select_role_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/verify_otp_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/account_ready_screen.dart';
import '../../features/auth/presentation/screens/build_profile_screen.dart';
import '../../features/auth/presentation/screens/edit_profile_screen.dart';
import '../../features/auth/presentation/screens/account_settings_screen.dart';
import '../../features/auth/presentation/screens/change_password_screen.dart';
import '../../features/auth/presentation/screens/legal_screen.dart';
import '../../features/auth/presentation/screens/verification_submitted_screen.dart';
import '../../features/auth/presentation/screens/subscription_screen.dart';
import '../../features/auth/presentation/screens/subscription_checkout_screen.dart';
import '../../features/auth/presentation/screens/subscription_activated_screen.dart';
import '../../features/home/presentation/screens/home_shell_screen.dart';
import '../../features/events/presentation/screens/create_event_screen.dart';
import '../../features/events/presentation/screens/schedule_event_screen.dart';
import '../../features/events/presentation/screens/ticket_pricing_screen.dart';
import '../../features/events/presentation/screens/review_event_screen.dart';
import '../../features/events/presentation/screens/event_submitted_screen.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';

class AuthRouterListener extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;
  
  AuthRouterListener(AuthBloc authBloc) {
    _subscription = authBloc.stream.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

abstract class AppRouter {
  static const String splashPath = '/';
  static const String onboardingPath = '/onboarding';
  static const String selectRolePath = '/select-role';
  static const String buildProfilePath = '/build-profile';
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String forgotPasswordPath = '/forgot-password';
  static const String verifyOtpPath = '/verify-otp';
  static const String resetPasswordPath = '/reset-password';
  static const String accountReadyPath = '/account-ready';
  static const String verificationSubmittedPath = '/verification-submitted';
  static const String subscriptionPath = '/subscription';
  static const String subscriptionCheckoutPath = '/subscription-checkout';
  static const String subscriptionActivatedPath = '/subscription-activated';
  static const String homePath = '/home';
  static const String createEventPath = '/create-event';
  static const String scheduleEventPath = '/create-event/schedule';
  static const String ticketPricingPath = '/create-event/tickets';
  static const String reviewEventPath = '/create-event/review';
  static const String eventSubmittedPath = '/create-event/submitted';
  static const String dashboardPath = '/dashboard';
  static const String todosPath = '/todos';
  static const String addTodoPath = '/todos/add';
  static const String locationsPath = '/locations';
  static const String addLocationPath = '/locations/add';
  static const String editLocationPath = '/locations/edit';
  static const String syncPath = '/sync';
  static const String profilePath = '/profile';
  static const String editProfilePath = '/edit-profile';
  static const String accountSettingsPath = '/account-settings';
  static const String changePasswordPath = '/change-password';
  static const String termsPath = '/terms';
  static const String privacyPath = '/privacy';
  static const String aboutPath = '/about';

  static final GoRouter router = GoRouter(
    initialLocation: splashPath,
    refreshListenable: AuthRouterListener(GetIt.instance<AuthBloc>()),
    redirect: (context, state) {
      final authBloc = GetIt.instance<AuthBloc>();
      final authState = authBloc.state;
      
      final location = state.matchedLocation;
      final isAuthForm = location == loginPath ||
          location == registerPath ||
          location == forgotPasswordPath ||
          location == verifyOtpPath ||
          location == resetPasswordPath ||
          location == onboardingPath ||
          location == selectRolePath;
      final isProfileSetup = location == buildProfilePath ||
          location == accountReadyPath ||
          location == verificationSubmittedPath ||
          location == subscriptionPath ||
          location == subscriptionCheckoutPath ||
          location == subscriptionActivatedPath ||
          location == homePath ||
          location == createEventPath ||
          location == scheduleEventPath ||
          location == ticketPricingPath ||
          location == reviewEventPath ||
          location == eventSubmittedPath ||
          location == editProfilePath ||
          location == accountSettingsPath ||
          location == changePasswordPath ||
          location == termsPath ||
          location == privacyPath ||
          location == aboutPath;
      final isSplash = location == splashPath;

      // Handle redirect logic based on current authentication state
      return authState.maybeWhen(
        authenticated: (_) {
          // If logged in and on auth forms or splash, direct to build profile
          if (isAuthForm || isSplash) {
            return buildProfilePath;
          }
          return null; // Stay on current page (e.g. buildProfilePath, accountReadyPath, todosPath)
        },
        unauthenticated: () {
          // If logged out and trying to visit protected pages, redirect to onboarding
          final isAllowedUnauthenticated = isAuthForm || isProfileSetup || isSplash;
          if (!isAllowedUnauthenticated) {
            return onboardingPath;
          }
          return null;
        },
        orElse: () => null,
      );
    },
    routes: [
      GoRoute(
        path: splashPath,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: onboardingPath,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: selectRolePath,
        builder: (context, state) => const SelectRoleScreen(),
      ),
      GoRoute(
        path: buildProfilePath,
        builder: (context, state) => const BuildProfileScreen(),
      ),
      GoRoute(
        path: loginPath,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: registerPath,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: forgotPasswordPath,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: verifyOtpPath,
        builder: (context, state) => const VerifyOtpScreen(),
      ),
      GoRoute(
        path: resetPasswordPath,
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: accountReadyPath,
        builder: (context, state) => const AccountReadyScreen(),
      ),
      GoRoute(
        path: verificationSubmittedPath,
        builder: (context, state) => const VerificationSubmittedScreen(),
      ),
      GoRoute(
        path: subscriptionPath,
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: subscriptionCheckoutPath,
        builder: (context, state) {
          final extra = state.extra as Map<String, String>?;
          return SubscriptionCheckoutScreen(
            planTitle: extra?['title'] ?? 'Organizer Pro',
            planDuration: extra?['duration'] ?? '6 Months',
            planPrice: extra?['price'] ?? '\$143.95',
            discountTag: extra?['discountTag'] ?? 'Save 20%',
          );
        },
      ),
      GoRoute(
        path: subscriptionActivatedPath,
        builder: (context, state) {
          final extra = state.extra as Map<String, String>?;
          return SubscriptionActivatedScreen(
            planTitle: extra?['title'] ?? 'Organizer Pro',
            planDuration: extra?['duration'] ?? '6 Months',
          );
        },
      ),
      GoRoute(
        path: scheduleEventPath,
        builder: (context, state) => const ScheduleEventScreen(),
      ),
      GoRoute(
        path: ticketPricingPath,
        builder: (context, state) {
          final extra = state.extra as Map<String, Object>?;
          return TicketPricingScreen(
            date: extra?['date'] as DateTime?,
            startMinutes: extra?['startMinutes'] as int? ?? 9 * 60,
            endMinutes: extra?['endMinutes'] as int? ?? 17 * 60,
          );
        },
      ),
      GoRoute(
        path: reviewEventPath,
        builder: (context, state) {
          final extra = state.extra as Map<String, Object>?;
          return ReviewEventScreen(
            priceCents: extra?['priceCents'] as int? ?? 9900,
            capacity: extra?['capacity'] as int? ?? 500,
            date: extra?['date'] as DateTime?,
            startMinutes: extra?['startMinutes'] as int? ?? 9 * 60,
            endMinutes: extra?['endMinutes'] as int? ?? 17 * 60,
          );
        },
      ),
      GoRoute(
        path: eventSubmittedPath,
        builder: (context, state) {
          final extra = state.extra as Map<String, Object>?;
          return EventSubmittedScreen(
            eventName: extra?['eventName'] as String? ?? 'Global Tech Innovation Summit 2026',
            date: extra?['date'] as DateTime?,
            priceCents: extra?['priceCents'] as int? ?? 9900,
          );
        },
      ),
      GoRoute(
        path: createEventPath,
        builder: (context, state) => const CreateEventScreen(),
      ),
      GoRoute(
        path: homePath,
        builder: (context, state) => const HomeShellScreen(),
      ),
      GoRoute(
        path: dashboardPath,
        redirect: (context, state) => todosPath,
      ),
    
      GoRoute(
        path: profilePath,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: editProfilePath,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: accountSettingsPath,
        builder: (context, state) => const AccountSettingsScreen(),
      ),
      GoRoute(
        path: changePasswordPath,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: termsPath,
        builder: (context, state) => const LegalScreen(title: 'Terms of Conditions'),
      ),
      GoRoute(
        path: privacyPath,
        builder: (context, state) => const LegalScreen(title: 'Privacy Policy'),
      ),
      GoRoute(
        path: aboutPath,
        builder: (context, state) => const LegalScreen(title: 'About us'),
      ),
    ],
  );
}

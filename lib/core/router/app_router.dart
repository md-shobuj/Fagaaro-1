import 'dart:async';
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
import '../../features/auth/presentation/screens/verification_submitted_screen.dart';
import '../../features/auth/presentation/screens/subscription_screen.dart';
import '../../features/auth/presentation/screens/subscription_checkout_screen.dart';
import '../../features/todos/presentation/screens/todos_screen.dart';
import '../../features/todos/presentation/screens/add_todo_screen.dart';
import '../../features/locations/domain/entities/geofence_location.dart';
import '../../features/locations/presentation/screens/location_list_screen.dart';
import '../../features/locations/presentation/screens/add_location_screen.dart';
import '../../features/locations/presentation/screens/edit_location_screen.dart';
import '../../features/sync/presentation/screens/sync_screen.dart';
import '../../features/dashboard/presentation/screens/profile_screen.dart';
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
  static const String dashboardPath = '/dashboard';
  static const String todosPath = '/todos';
  static const String addTodoPath = '/todos/add';
  static const String locationsPath = '/locations';
  static const String addLocationPath = '/locations/add';
  static const String editLocationPath = '/locations/edit';
  static const String syncPath = '/sync';
  static const String profilePath = '/profile';

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
          location == subscriptionCheckoutPath;
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
        path: dashboardPath,
        redirect: (context, state) => todosPath,
      ),
      GoRoute(
        path: todosPath,
        builder: (context, state) => const TodosScreen(),
      ),
      GoRoute(
        path: addTodoPath,
        builder: (context, state) => const AddTodoScreen(),
      ),
      GoRoute(
        path: locationsPath,
        builder: (context, state) => const LocationListScreen(),
      ),
      GoRoute(
        path: addLocationPath,
        builder: (context, state) => const AddLocationScreen(),
      ),
      GoRoute(
        path: editLocationPath,
        builder: (context, state) {
          final location = state.extra as GeofenceLocation;
          return EditLocationScreen(location: location);
        },
      ),
      GoRoute(
        path: syncPath,
        builder: (context, state) => const SyncScreen(),
      ),
      GoRoute(
        path: profilePath,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}

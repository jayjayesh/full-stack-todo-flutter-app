import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:todoflutterapp/src/features/auth/presentation/providers/session_provider.dart';
import 'package:todoflutterapp/src/routing/global_navigator.dart';
import 'package:todoflutterapp/src/routing/app_routes.dart';

import 'package:todoflutterapp/src/features/auth/presentation/screens/login_screen.dart';
import 'package:todoflutterapp/src/features/auth/presentation/screens/signup_screen.dart';
import 'package:todoflutterapp/src/features/auth/presentation/screens/forgot_password_screen.dart';

import 'package:todoflutterapp/src/features/home/presentation/screens/home_page.dart';
import 'package:todoflutterapp/src/features/onboarding/presentation/screens/onboarding_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final sessionStatus = ref.watch(
    sessionProvider.select((state) => state.status),
  );

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.onboarding,
    redirect: (context, state) {
      return authGuardRedirect(
        status: sessionStatus,
        location: state.matchedLocation,
      );
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});

String? authGuardRedirect({
  required SessionStatus status,
  required String location,
}) {
  if (status == SessionStatus.unknown) {
    return null;
  }

  final isAuthRoute = _authRoutes.contains(location);
  final isProtectedRoute = _protectedRoutes.contains(location);

  if (status == SessionStatus.unauthenticated && isProtectedRoute) {
    return AppRoutes.onboarding;
  }

  if (status == SessionStatus.authenticated && isAuthRoute) {
    return AppRoutes.home;
  }

  return null;
}

const Set<String> _authRoutes = {
  AppRoutes.onboarding,
  AppRoutes.login,
  AppRoutes.signup,
  AppRoutes.forgotPassword,
};

const Set<String> _protectedRoutes = {
  AppRoutes.home,
};

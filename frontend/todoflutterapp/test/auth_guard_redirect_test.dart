import 'package:flutter_test/flutter_test.dart';

import 'package:todoflutterapp/src/features/auth/presentation/providers/session_provider.dart';
import 'package:todoflutterapp/src/routing/app_router.dart';
import 'package:todoflutterapp/src/routing/app_routes.dart';

void main() {
  group('authGuardRedirect', () {
    test('allows current route while session is unknown', () {
      final redirect = authGuardRedirect(
        status: SessionStatus.unknown,
        location: AppRoutes.home,
      );

      expect(redirect, isNull);
    });

    test('sends logged-out users away from protected routes', () {
      final redirect = authGuardRedirect(
        status: SessionStatus.unauthenticated,
        location: AppRoutes.home,
      );

      expect(redirect, AppRoutes.onboarding);
    });

    test('allows logged-out users to visit auth routes', () {
      final redirect = authGuardRedirect(
        status: SessionStatus.unauthenticated,
        location: AppRoutes.login,
      );

      expect(redirect, isNull);
    });

    test('sends logged-in users away from auth routes', () {
      final redirect = authGuardRedirect(
        status: SessionStatus.authenticated,
        location: AppRoutes.login,
      );

      expect(redirect, AppRoutes.home);
    });

    test('allows logged-in users to visit protected routes', () {
      final redirect = authGuardRedirect(
        status: SessionStatus.authenticated,
        location: AppRoutes.home,
      );

      expect(redirect, isNull);
    });
  });
}

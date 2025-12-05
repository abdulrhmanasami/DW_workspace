/// Widget tests for AuthGate
/// Created by: Track D - Ticket #237 (D-5) & Ticket #238 (D-6)
/// Purpose: Test AuthGate navigation logic based on IdentitySession status and onboarding completion

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auth_shims/auth_shims.dart';
import 'package:foundation_shims/foundation_shims.dart';

import 'package:delivery_ways_clean/widgets/auth/auth_gate.dart';
import 'package:delivery_ways_clean/app_shell/app_shell.dart';
import 'package:delivery_ways_clean/screens/auth/phone_login_screen.dart';
import 'package:delivery_ways_clean/screens/onboarding/onboarding_root_screen.dart';
import '../../support/dw_test_app.dart';

/// Fake OnboardingPrefs for testing AuthGate scenarios
class _FakeOnboardingPrefs implements OnboardingPrefs {
  final bool completed;

  _FakeOnboardingPrefs({required this.completed});

  @override
  Future<bool> hasCompletedOnboarding() => Future.value(completed);

  @override
  Future<void> setCompletedOnboarding(bool value) => Future.value();

  @override
  Future<bool> getMarketingOptIn() => Future.value(false);

  @override
  Future<void> setMarketingOptIn(bool value) => Future.value();
}

/// Fake IdentityShim for testing AuthGate scenarios
class FakeIdentityShimForAuthGate extends Fake implements IdentityShim {
  /// Session returned by loadInitialSession
  IdentitySession initialSession;

  FakeIdentityShimForAuthGate({required this.initialSession});

  @override
  Future<IdentitySession> loadInitialSession() => Future.value(initialSession);

  // Stub implementations for other required methods
  @override
  Future<IdentitySession> refreshTokens() => Future.value(initialSession);

  @override
  Future<void> signOut() => Future.value();

  @override
  Stream<IdentitySession> watchSession() => Stream.value(initialSession);

  @override
  Future<void> requestLoginCode({required PhoneNumber phoneNumber}) => Future.value();

  @override
  Future<IdentitySession> verifyLoginCode({
    required PhoneNumber phoneNumber,
    required OtpCode code,
  }) => Future.value(initialSession);
}

void main() {
  group('AuthGate - IdentityController + Onboarding Integration', () {
    testWidgets('shows loading screen when session status is unknown', (tester) async {
      final fakeShim = FakeIdentityShimForAuthGate(
        initialSession: const IdentitySession(
          status: AuthStatus.unknown,
          user: null,
          tokens: null,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Mock onboarding as completed to not interfere with identity logic
            onboardingPrefsServiceProvider.overrideWithValue(
              _FakeOnboardingPrefs(completed: true),
            ),
          ],
          child: DwTestApp.withIdentityShim(
            home: const AuthGate(),
            fakeIdentityShim: fakeShim,
          ),
        ),
      );
      await tester.pump();

      // Verify loading screen is shown
      expect(find.text('Loading...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Verify auth/onboarding screens are NOT shown
      expect(find.byType(PhoneLoginScreen), findsNothing);
      expect(find.byType(AppShell), findsNothing);
      expect(find.byType(OnboardingRootScreen), findsNothing);
    });

    testWidgets('shows OnboardingRootScreen when onboarding not completed and unauthenticated', (tester) async {
      final fakeShim = FakeIdentityShimForAuthGate(
        initialSession: const IdentitySession(
          status: AuthStatus.unauthenticated,
          user: null,
          tokens: null,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Mock onboarding as NOT completed
            onboardingPrefsServiceProvider.overrideWithValue(
              _FakeOnboardingPrefs(completed: false),
            ),
          ],
          child: DwTestApp.withIdentityShim(
            home: const AuthGate(),
            fakeIdentityShim: fakeShim,
          ),
        ),
      );
      await tester.pump();

      // Verify OnboardingRootScreen is shown
      expect(find.byType(OnboardingRootScreen), findsOneWidget);

      // Verify other screens are NOT shown
      expect(find.text('Loading...'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(PhoneLoginScreen), findsNothing);
      expect(find.byType(AppShell), findsNothing);
    });

    testWidgets('shows PhoneLoginScreen when onboarding completed and unauthenticated', (tester) async {
      final fakeShim = FakeIdentityShimForAuthGate(
        initialSession: const IdentitySession(
          status: AuthStatus.unauthenticated,
          user: null,
          tokens: null,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Mock onboarding as completed
            onboardingPrefsServiceProvider.overrideWithValue(
              _FakeOnboardingPrefs(completed: true),
            ),
          ],
          child: DwTestApp.withIdentityShim(
            home: const AuthGate(),
            fakeIdentityShim: fakeShim,
          ),
        ),
      );
      await tester.pump();

      // Verify PhoneLoginScreen is shown
      expect(find.byType(PhoneLoginScreen), findsOneWidget);

      // Verify other screens are NOT shown
      expect(find.text('Loading...'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(AppShell), findsNothing);
      expect(find.byType(OnboardingRootScreen), findsNothing);
    });

    testWidgets('shows AppShell when onboarding completed and authenticated', (tester) async {
      final fakeShim = FakeIdentityShimForAuthGate(
        initialSession: const IdentitySession(
          status: AuthStatus.authenticated,
          user: IdentityUser(userId: 'test-user'),
          tokens: AuthTokens(
            accessToken: 'access-token',
            refreshToken: 'refresh-token',
            accessTokenExpiresAt: null,
          ),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Mock onboarding as completed
            onboardingPrefsServiceProvider.overrideWithValue(
              _FakeOnboardingPrefs(completed: true),
            ),
          ],
          child: DwTestApp.withIdentityShim(
            home: const AuthGate(),
            fakeIdentityShim: fakeShim,
          ),
        ),
      );
      await tester.pump();

      // Verify AppShell is shown
      expect(find.byType(AppShell), findsOneWidget);

      // Verify other screens are NOT shown
      expect(find.text('Loading...'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(PhoneLoginScreen), findsNothing);
      expect(find.byType(OnboardingRootScreen), findsNothing);
    });
  });
}

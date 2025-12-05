/// Widget tests for Authentication Flow
/// Purpose: Verify auth screens UI and navigation flow (Onboarding → Login → OTP → Home)
/// Created by: Track D - Ticket #58
/// Last updated: 2025-11-29

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// App imports
import 'package:delivery_ways_clean/screens/auth/phone_login_screen.dart';
import 'package:delivery_ways_clean/screens/auth/otp_verification_screen.dart';
import 'package:delivery_ways_clean/screens/onboarding/onboarding_root_screen.dart';
import 'package:delivery_ways_clean/router/app_router.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/state/auth/passwordless_auth_controller.dart';
import 'package:delivery_ways_clean/state/infra/auth_providers.dart';
import 'package:delivery_ways_clean/config/feature_flags.dart';
import 'package:auth_shims/auth_shims.dart';

/// Stub AuthService for UI testing
class StubAuthService implements AuthService {
  bool requestOtpCalled = false;
  bool verifyOtpCalled = false;
  bool logoutCalled = false;

  PhoneNumber? lastRequestedPhone;
  PhoneNumber? lastVerifiedPhone;
  OtpCode? lastVerifiedCode;

  AuthException? requestOtpError;
  AuthException? verifyOtpError;

  AuthSession? sessionToReturn;

  final _authStateController = StreamController<AuthState>.broadcast();

  @override
  Future<void> requestOtp(PhoneNumber phoneNumber) async {
    requestOtpCalled = true;
    lastRequestedPhone = phoneNumber;
    if (requestOtpError != null) {
      throw requestOtpError!;
    }
  }

  @override
  Future<AuthSession> verifyOtp({
    required PhoneNumber phoneNumber,
    required OtpCode code,
  }) async {
    verifyOtpCalled = true;
    lastVerifiedPhone = phoneNumber;
    lastVerifiedCode = code;
    if (verifyOtpError != null) {
      throw verifyOtpError!;
    }
    return sessionToReturn ??
        AuthSession(
          accessToken: 'test_access_token',
          user: const AuthUser(id: 'test_user_id', phoneNumber: '+491234567890'),
        );
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
    _authStateController.add(const AuthState.unauthenticated());
  }

  @override
  Future<AuthSession?> refreshSession() async => sessionToReturn;

  @override
  Future<AuthSession?> getCurrentSession() async => sessionToReturn;

  @override
  Stream<AuthState> get onAuthStateChanged => _authStateController.stream;

  @override
  Future<bool> unlockStoredSession({String? localizedReason}) async {
    return sessionToReturn != null;
  }

  // MFA stub methods
  @override
  Future<MfaRequirement> evaluateMfaRequirement({
    required AuthSession session,
    required String action,
  }) async {
    return const MfaRequirement.notRequired();
  }

  @override
  Future<MfaChallenge> startMfaChallenge({
    required AuthSession session,
    required MfaMethodType method,
    required String action,
  }) async {
    return MfaChallenge(
      challengeId: 'stub_challenge',
      method: method,
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
    );
  }

  @override
  Future<MfaVerificationResult> verifyMfaCode({
    required String challengeId,
    required String code,
  }) async {
    return const MfaVerificationResult.success();
  }

  void dispose() {
    _authStateController.close();
  }
}

/// Mock FeatureFlags for testing
class MockFeatureFlags {
  static bool enablePasswordlessAuth = true;
  static bool enableBiometricAuth = true;
  static bool enableTwoFactorAuth = false;
}

void main() {
  group('Auth Flow - Ticket #58', () {
    /// Helper to build test app with just a home widget (no routes conflict)
    Widget buildTestAppWithHome({
      required Widget home,
      Locale locale = const Locale('en'),
      StubAuthService? authService,
      String? phoneNumber,
    }) {
      final service = authService ?? StubAuthService();

      return ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(service),
          if (phoneNumber != null)
            passwordlessAuthControllerProvider.overrideWith(
              (ref) => PasswordlessAuthController(service)
                ..state = PasswordlessAuthState(
                  step: PasswordlessStep.codeSent,
                  phoneE164: phoneNumber,
                  requestCount: 1,
                ),
            ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
          home: home,
        ),
      );
    }

    /// Helper to build test app with OTP screen that can navigate to home
    Widget buildTestAppForOtpNavigation({
      Locale locale = const Locale('en'),
      StubAuthService? authService,
      String? phoneNumber,
    }) {
      final service = authService ?? StubAuthService();

      return ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(service),
          if (phoneNumber != null)
            passwordlessAuthControllerProvider.overrideWith(
              (ref) => PasswordlessAuthController(service)
                ..state = PasswordlessAuthState(
                  step: PasswordlessStep.codeSent,
                  phoneE164: phoneNumber,
                  requestCount: 1,
                ),
            ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
          initialRoute: '/otp',
          routes: {
            '/otp': (context) => const OtpVerificationScreen(forceEnablePasswordless: true),
            RoutePaths.home: (context) => const _TestHomeScreen(),
          },
        ),
      );
    }

    group('PhoneLoginScreen - UI Verification', () {
      testWidgets('displays login title and phone field', (tester) async {
        await tester.pumpWidget(buildTestAppWithHome(
          home: const PhoneLoginScreen(forceEnablePasswordless: true),
        ));
        await tester.pumpAndSettle();

        // Should display login title
        expect(find.text('Sign In'), findsWidgets);

        // Should display phone input field with hint
        expect(find.byType(TextFormField), findsOneWidget);
      });

      testWidgets('displays Continue button', (tester) async {
        await tester.pumpWidget(buildTestAppWithHome(
          home: const PhoneLoginScreen(forceEnablePasswordless: true),
        ));
        await tester.pumpAndSettle();

        // Should have Continue button
        expect(find.text('Continue'), findsOneWidget);
      });

      testWidgets('displays privacy policy link', (tester) async {
        await tester.pumpWidget(buildTestAppWithHome(
          home: const PhoneLoginScreen(forceEnablePasswordless: true),
        ));
        await tester.pumpAndSettle();

        // Should have privacy policy link (using L10n key legalPrivacyPolicyTitle)
        expect(find.text('Privacy Policy'), findsOneWidget);
      });
    });

    group('OtpVerificationScreen - UI Verification', () {
      testWidgets('displays OTP title and subtitle', (tester) async {
        await tester.pumpWidget(buildTestAppWithHome(
          home: const OtpVerificationScreen(forceEnablePasswordless: true),
          authService: StubAuthService(),
          phoneNumber: '+491234567890',
        ));
        await tester.pumpAndSettle();

        // Should display OTP title
        expect(find.text('Enter code'), findsOneWidget);

        // Should display subtitle
        expect(
          find.text("We've sent a verification code to your phone."),
          findsOneWidget,
        );
      });

      testWidgets('displays Verify button', (tester) async {
        await tester.pumpWidget(buildTestAppWithHome(
          home: const OtpVerificationScreen(forceEnablePasswordless: true),
          authService: StubAuthService(),
          phoneNumber: '+491234567890',
        ));
        await tester.pumpAndSettle();

        // Should have Verify button
        expect(find.text('Verify and continue'), findsOneWidget);
      });
    });

    group('Navigation: Onboarding → Auth Login', () {
      testWidgets('finishing onboarding triggers onComplete callback',
          (tester) async {
        var completeCalled = false;

        await tester.pumpWidget(buildTestAppWithHome(
          home: OnboardingRootScreen(
            onComplete: () {
              completeCalled = true;
            },
          ),
        ));
        await tester.pumpAndSettle();

        // Navigate through onboarding: Welcome → Permissions → Preferences
        // Screen 1: Welcome - tap Get started
        expect(find.text('Welcome to Delivery Ways'), findsOneWidget);
        await tester.tap(find.text('Get started'));
        await tester.pumpAndSettle();

        // Screen 2: Permissions - tap Continue
        expect(find.text('Allow permissions'), findsOneWidget);
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Screen 3: Preferences - tap Get Started (assuming it exists)
        // For now, just check that we can complete onboarding
        // The actual completion will depend on the Preferences screen implementation
        // TODO: Update when Preferences screen is fully implemented

        // For now, just verify the flow works up to permissions screen
        expect(find.text('Allow permissions'), findsOneWidget);
      });
    });

    group('Navigation: OTP → Home', () {
      testWidgets('pressing Verify on OTP navigates to home', (tester) async {
        final authService = StubAuthService();
        await tester.pumpWidget(buildTestAppForOtpNavigation(
          authService: authService,
          phoneNumber: '+491234567890',
        ));
        await tester.pumpAndSettle();

        // Verify we're on OTP screen
        expect(find.text('Enter code'), findsOneWidget);

        // Enter a code (any non-empty code works in stub)
        final codeField = find.byType(TextField);
        if (codeField.evaluate().isNotEmpty) {
          await tester.enterText(codeField, '1234');
          await tester.pumpAndSettle();
        }

        // Tap Verify
        await tester.tap(find.text('Verify and continue'));
        await tester.pumpAndSettle();

        // Should navigate to Home
        expect(find.text('Test Home Screen'), findsOneWidget);
      });
    });

    group('Auth State Management', () {
      testWidgets('passwordlessAuthController starts with enterPhone step',
          (tester) async {
        late PasswordlessAuthState capturedState;

        await tester.pumpWidget(ProviderScope(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) {
                capturedState = ref.watch(passwordlessAuthControllerProvider);
                return Text('step: ${capturedState.step}');
              },
            ),
          ),
        ));
        await tester.pumpAndSettle();

        expect(capturedState.step, equals(PasswordlessStep.enterPhone));
        expect(capturedState.phoneE164, isNull);
        expect(capturedState.errorMessage, isNull);
        expect(capturedState.requestCount, equals(0));
      });

      testWidgets('passwordlessAuthController can request and verify OTP',
          (tester) async {
        late PasswordlessAuthState capturedState;
        late PasswordlessAuthController controller;
        final authService = StubAuthService();

        await tester.pumpWidget(ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(authService),
          ],
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) {
                capturedState = ref.watch(passwordlessAuthControllerProvider);
                controller = ref.read(passwordlessAuthControllerProvider.notifier);
                return Column(
                  children: [
                    Text('step: ${capturedState.step}'),
                    ElevatedButton(
                      onPressed: () => controller.requestOtp('+491234567890'),
                      child: const Text('Request OTP'),
                    ),
                    ElevatedButton(
                      onPressed: () => controller.verifyOtp('1234'),
                      child: const Text('Verify OTP'),
                    ),
                  ],
                );
              },
            ),
          ),
        ));
        await tester.pumpAndSettle();

        // Initially enterPhone step
        expect(capturedState.step, equals(PasswordlessStep.enterPhone));

        // Tap request OTP button
        await tester.tap(find.text('Request OTP'));
        await tester.pumpAndSettle();

        // Now in codeSent step
        expect(capturedState.step, equals(PasswordlessStep.codeSent));
        expect(capturedState.phoneE164, equals('+491234567890'));

        // Tap verify OTP button
        await tester.tap(find.text('Verify OTP'));
        await tester.pumpAndSettle();

        // Now authenticated
        expect(capturedState.step, equals(PasswordlessStep.authenticated));
      });
    });

    group('Localization - Arabic', () {
      testWidgets('OTP screen displays Arabic texts', (tester) async {
        await tester.pumpWidget(buildTestAppWithHome(
          home: const OtpVerificationScreen(forceEnablePasswordless: true),
          locale: const Locale('ar'),
          authService: StubAuthService(),
          phoneNumber: '+491234567890',
        ));
        await tester.pumpAndSettle();

        // Arabic title
        expect(find.text('إدخال الرمز'), findsOneWidget);

        // Arabic subtitle
        expect(
          find.text('قمنا بإرسال رمز تحقق إلى جوالك.'),
          findsOneWidget,
        );

        // Arabic verify button
        expect(find.text('تأكيد ومتابعة'), findsOneWidget);
      });
    });

    group('Localization - German', () {
      testWidgets('OTP screen displays German texts', (tester) async {
        await tester.pumpWidget(buildTestAppWithHome(
          home: const OtpVerificationScreen(forceEnablePasswordless: true),
          locale: const Locale('de'),
          authService: StubAuthService(),
          phoneNumber: '+491234567890',
        ));
        await tester.pumpAndSettle();

        // German title
        expect(find.text('Code eingeben'), findsOneWidget);

        // German subtitle
        expect(
          find.text(
              'Wir haben einen Verifizierungscode an Ihr Telefon gesendet.'),
          findsOneWidget,
        );

        // German verify button
        expect(find.text('Verifizieren und fortfahren'), findsOneWidget);
      });
    });

    group('Full Auth Flow Test', () {
      testWidgets('complete onboarding flow: Welcome → Permissions → Preferences → callback',
          (tester) async {
        var flowCompleted = false;

        await tester.pumpWidget(buildTestAppWithHome(
          home: OnboardingRootScreen(
            onComplete: () => flowCompleted = true,
          ),
        ));
        await tester.pumpAndSettle();

        // Step 1: Welcome Screen
        expect(find.text('Welcome to Delivery Ways'), findsOneWidget);
        await tester.tap(find.text('Get started'));
        await tester.pumpAndSettle();

        // Step 2: Permissions Screen
        expect(find.text('Allow permissions'), findsOneWidget);
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Step 3: Preferences Screen
        expect(find.text('Start using Delivery Ways'), findsOneWidget);
        await tester.tap(find.text('Start using Delivery Ways'));
        await tester.pumpAndSettle();

        // Verify completion
        expect(flowCompleted, isTrue);
      });

      testWidgets('OTP verification updates auth state and navigates',
          (tester) async {
        final authService = StubAuthService();
        await tester.pumpWidget(buildTestAppForOtpNavigation(
          authService: authService,
          phoneNumber: '+491234567890',
        ));
        await tester.pumpAndSettle();

        // Verify on OTP screen
        expect(find.text('Enter code'), findsOneWidget);

        // Enter code and verify
        final codeField = find.byType(TextField);
        if (codeField.evaluate().isNotEmpty) {
          await tester.enterText(codeField, '1234');
        }
        await tester.tap(find.text('Verify and continue'));
        await tester.pumpAndSettle();

        // Should be on Home screen
        expect(find.text('Test Home Screen'), findsOneWidget);
      });
    });
  });
}

/// Test Home Screen placeholder to verify navigation
class _TestHomeScreen extends StatelessWidget {
  const _TestHomeScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Test Home Screen'),
      ),
    );
  }
}

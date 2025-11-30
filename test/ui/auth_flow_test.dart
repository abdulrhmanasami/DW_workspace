/// Widget tests for Authentication Flow
/// Purpose: Verify auth screens UI and navigation flow (Onboarding → Login → OTP → Home)
/// Created by: Track D - Ticket #58
/// Last updated: 2025-11-29

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// App imports
import 'package:delivery_ways_clean/screens/auth/phone_login_screen.dart';
import 'package:delivery_ways_clean/screens/auth/otp_verification_screen.dart';
import 'package:delivery_ways_clean/screens/onboarding/onboarding_root_screen.dart';
import 'package:delivery_ways_clean/router/app_router.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/state/auth/auth_state.dart';

void main() {
  group('Auth Flow - Ticket #58', () {
    /// Helper to build test app with just a home widget (no routes conflict)
    Widget buildTestAppWithHome({
      required Widget home,
      Locale locale = const Locale('en'),
    }) {
      return ProviderScope(
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
    }) {
      return ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
          initialRoute: '/otp',
          routes: {
            '/otp': (context) => const OtpVerificationScreen(),
            RoutePaths.home: (context) => const _TestHomeScreen(),
          },
        ),
      );
    }

    group('PhoneLoginScreen - UI Verification', () {
      testWidgets('displays login title and phone field', (tester) async {
        await tester.pumpWidget(buildTestAppWithHome(
          home: const PhoneLoginScreen(),
        ));
        await tester.pumpAndSettle();

        // Should display login title
        expect(find.text('Sign In'), findsWidgets);

        // Should display phone input field with hint
        expect(find.byType(TextFormField), findsOneWidget);
      });

      testWidgets('displays Continue button', (tester) async {
        await tester.pumpWidget(buildTestAppWithHome(
          home: const PhoneLoginScreen(),
        ));
        await tester.pumpAndSettle();

        // Should have Continue button
        expect(find.text('Continue'), findsOneWidget);
      });

      testWidgets('displays privacy policy link', (tester) async {
        await tester.pumpWidget(buildTestAppWithHome(
          home: const PhoneLoginScreen(),
        ));
        await tester.pumpAndSettle();

        // Should have privacy policy link (using L10n key legalPrivacyPolicyTitle)
        expect(find.text('Privacy Policy'), findsOneWidget);
      });
    });

    group('OtpVerificationScreen - UI Verification', () {
      testWidgets('displays OTP title and subtitle', (tester) async {
        await tester.pumpWidget(buildTestAppWithHome(
          home: const OtpVerificationScreen(),
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
          home: const OtpVerificationScreen(),
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

        // Navigate through onboarding: Ride → Parcels → Food
        // Screen 1: Ride
        expect(find.text('Get a Ride, Instantly.'), findsOneWidget);
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Screen 2: Parcels
        expect(find.text('Deliver Anything, Effortlessly.'), findsOneWidget);
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Screen 3: Food - tap Get Started
        expect(find.text('Your Favorite Food, Delivered.'), findsOneWidget);
        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();

        // Verify onComplete was called
        expect(completeCalled, isTrue);
      });
    });

    group('Navigation: OTP → Home', () {
      testWidgets('pressing Verify on OTP navigates to home', (tester) async {
        await tester.pumpWidget(buildTestAppForOtpNavigation());
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
      testWidgets('simpleAuthStateProvider starts unauthenticated',
          (tester) async {
        late AuthState capturedState;

        await tester.pumpWidget(ProviderScope(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) {
                capturedState = ref.watch(simpleAuthStateProvider);
                return Text('isAuth: ${capturedState.isAuthenticated}');
              },
            ),
          ),
        ));
        await tester.pumpAndSettle();

        expect(capturedState.isAuthenticated, isFalse);
        expect(capturedState.isVerifying, isFalse);
        expect(capturedState.phoneNumber, isNull);
      });

      testWidgets('verifyOtpCode sets isAuthenticated to true', (tester) async {
        late AuthState capturedState;
        late AuthController controller;

        await tester.pumpWidget(ProviderScope(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) {
                capturedState = ref.watch(simpleAuthStateProvider);
                controller = ref.read(simpleAuthStateProvider.notifier);
                return Column(
                  children: [
                    Text('isAuth: ${capturedState.isAuthenticated}'),
                    ElevatedButton(
                      onPressed: () => controller.verifyOtpCode('1234'),
                      child: const Text('Verify'),
                    ),
                  ],
                );
              },
            ),
          ),
        ));
        await tester.pumpAndSettle();

        // Initially not authenticated
        expect(capturedState.isAuthenticated, isFalse);

        // Tap verify button
        await tester.tap(find.text('Verify'));
        await tester.pumpAndSettle();

        // Now authenticated
        expect(capturedState.isAuthenticated, isTrue);
      });
    });

    group('Localization - Arabic', () {
      testWidgets('OTP screen displays Arabic texts', (tester) async {
        await tester.pumpWidget(buildTestAppWithHome(
          home: const OtpVerificationScreen(),
          locale: const Locale('ar'),
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
          home: const OtpVerificationScreen(),
          locale: const Locale('de'),
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
      testWidgets('complete onboarding flow: Ride → Parcels → Food → callback',
          (tester) async {
        var flowCompleted = false;

        await tester.pumpWidget(buildTestAppWithHome(
          home: OnboardingRootScreen(
            onComplete: () => flowCompleted = true,
          ),
        ));
        await tester.pumpAndSettle();

        // Step 1: Ride Screen
        expect(find.text('Get a Ride, Instantly.'), findsOneWidget);
        expect(find.byIcon(Icons.directions_car_outlined), findsOneWidget);
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Step 2: Parcels Screen
        expect(find.text('Deliver Anything, Effortlessly.'), findsOneWidget);
        expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Step 3: Food Screen
        expect(find.text('Your Favorite Food, Delivered.'), findsOneWidget);
        expect(find.byIcon(Icons.restaurant_outlined), findsOneWidget);
        expect(find.text('Get Started'), findsOneWidget);
        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();

        // Verify completion
        expect(flowCompleted, isTrue);
      });

      testWidgets('OTP verification updates auth state and navigates',
          (tester) async {
        await tester.pumpWidget(buildTestAppForOtpNavigation());
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

/// Widget tests for Phone + OTP Auth Flow (Ticket #36 - Track D)
/// Purpose: Verify auth screens UI and navigation flow
/// Created by: Track D - Ticket #36
/// Last updated: 2025-11-28

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// App imports
import 'package:delivery_ways_clean/screens/auth/phone_sign_in_screen.dart';
import 'package:delivery_ways_clean/screens/auth/otp_verification_screen.dart';
import 'package:delivery_ways_clean/state/auth/auth_state.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';

void main() {
  group('Auth Flow - Ticket #36', () {
    /// Helper to build test widget with MaterialApp + ProviderScope wrapper
    Widget buildTestApp({
      required Widget home,
      List<Override>? overrides,
    }) {
      return ProviderScope(
        overrides: overrides ?? [],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: home,
        ),
      );
    }

    // --------------------------------------------------------------------------
    // PhoneSignInScreen Tests
    // --------------------------------------------------------------------------
    group('PhoneSignInScreen', () {
      testWidgets('builds with title and phone input field', (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const PhoneSignInScreen(),
        ));
        await tester.pumpAndSettle();

        // Verify title is displayed
        expect(find.text('Sign in'), findsOneWidget);

        // Verify subtitle is displayed
        expect(
          find.text('Enter your mobile number to sign in to Delivery Ways.'),
          findsOneWidget,
        );

        // Verify Continue button exists
        expect(find.text('Continue'), findsOneWidget);

        // Verify phone icon is displayed
        expect(find.byIcon(Icons.phone_iphone), findsOneWidget);
      });

      testWidgets('phone input field accepts text', (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const PhoneSignInScreen(),
        ));
        await tester.pumpAndSettle();

        // Find the TextField and enter text
        await tester.enterText(find.byType(TextField), '+966501234567');
        await tester.pumpAndSettle();

        // Verify text was entered
        expect(find.text('+966501234567'), findsOneWidget);
      });

      testWidgets('navigates to OtpVerificationScreen on Continue tap',
          (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const PhoneSignInScreen(),
        ));
        await tester.pumpAndSettle();

        // Enter phone number
        await tester.enterText(find.byType(TextField), '+966501234567');
        await tester.pumpAndSettle();

        // Tap Continue button
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Verify navigation to OtpVerificationScreen
        expect(find.byType(OtpVerificationScreen), findsOneWidget);
        expect(find.text('Enter code'), findsOneWidget);
      });

      testWidgets('does not navigate if phone field is empty', (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const PhoneSignInScreen(),
        ));
        await tester.pumpAndSettle();

        // Tap Continue button without entering phone
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Should stay on PhoneSignInScreen
        expect(find.byType(PhoneSignInScreen), findsOneWidget);
        expect(find.byType(OtpVerificationScreen), findsNothing);
      });

      testWidgets('back button pops the screen', (tester) async {
        await tester.pumpWidget(MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: ProviderScope(
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const PhoneSignInScreen(),
                        ),
                      );
                    },
                    child: const Text('Open Sign In'),
                  ),
                );
              },
            ),
          ),
        ));
        await tester.pumpAndSettle();

        // Navigate to PhoneSignInScreen
        await tester.tap(find.text('Open Sign In'));
        await tester.pumpAndSettle();
        expect(find.byType(PhoneSignInScreen), findsOneWidget);

        // Tap back button
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        // Should be back to initial screen
        expect(find.byType(PhoneSignInScreen), findsNothing);
        expect(find.text('Open Sign In'), findsOneWidget);
      });
    });

    // --------------------------------------------------------------------------
    // OtpVerificationScreen Tests
    // --------------------------------------------------------------------------
    group('OtpVerificationScreen', () {
      testWidgets('builds with title and code input field', (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const OtpVerificationScreen(),
        ));
        await tester.pumpAndSettle();

        // Verify title is displayed
        expect(find.text('Enter code'), findsOneWidget);

        // Verify subtitle is displayed
        expect(
          find.text("We've sent a verification code to your phone."),
          findsOneWidget,
        );

        // Verify Verify button exists
        expect(find.text('Verify and continue'), findsOneWidget);
      });

      testWidgets('code input field accepts text', (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const OtpVerificationScreen(),
        ));
        await tester.pumpAndSettle();

        // Find the TextField and enter code
        await tester.enterText(find.byType(TextField), '123456');
        await tester.pumpAndSettle();

        // Verify code was entered
        expect(find.text('123456'), findsOneWidget);
      });

      testWidgets('does not verify if code field is empty', (tester) async {
        await tester.pumpWidget(buildTestApp(
          home: const OtpVerificationScreen(),
        ));
        await tester.pumpAndSettle();

        // Tap Verify button without entering code
        await tester.tap(find.text('Verify and continue'));
        await tester.pumpAndSettle();

        // Should stay on OtpVerificationScreen
        expect(find.byType(OtpVerificationScreen), findsOneWidget);
      });
    });

    // --------------------------------------------------------------------------
    // Full Auth Flow Tests
    // --------------------------------------------------------------------------
    group('Full Auth Flow', () {
      testWidgets('Phone → OTP → Home navigation flow', (tester) async {
        await tester.pumpWidget(ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: Builder(
              builder: (context) {
                return Scaffold(
                  appBar: AppBar(title: const Text('Home')),
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const PhoneSignInScreen(),
                          ),
                        );
                      },
                      child: const Text('Sign In'),
                    ),
                  ),
                );
              },
            ),
          ),
        ));
        await tester.pumpAndSettle();

        // Start at Home
        expect(find.text('Home'), findsOneWidget);

        // Navigate to PhoneSignInScreen
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();
        expect(find.byType(PhoneSignInScreen), findsOneWidget);

        // Enter phone number
        await tester.enterText(find.byType(TextField), '+966501234567');
        await tester.pumpAndSettle();

        // Tap Continue → go to OTP screen
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        expect(find.byType(OtpVerificationScreen), findsOneWidget);

        // Enter OTP code
        await tester.enterText(find.byType(TextField), '123456');
        await tester.pumpAndSettle();

        // Tap Verify → go back to Home
        await tester.tap(find.text('Verify and continue'));
        await tester.pumpAndSettle();

        // Verify we're back at Home
        expect(find.byType(PhoneSignInScreen), findsNothing);
        expect(find.byType(OtpVerificationScreen), findsNothing);
        expect(find.text('Home'), findsOneWidget);
      });

      testWidgets('AuthState updates after OTP verification', (tester) async {
        // Create a container to read state after the test
        late ProviderContainer container;

        await tester.pumpWidget(
          ProviderScope(
            child: Builder(
              builder: (context) {
                // Get reference to container
                container = ProviderScope.containerOf(context);
                return MaterialApp(
                  localizationsDelegates: AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  locale: const Locale('en'),
                  home: Builder(
                    builder: (innerContext) {
                      return Scaffold(
                        body: ElevatedButton(
                          onPressed: () {
                            Navigator.of(innerContext).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const PhoneSignInScreen(),
                              ),
                            );
                          },
                          child: const Text('Sign In'),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Initial state should be unauthenticated
        expect(
          container.read(simpleAuthStateProvider).isAuthenticated,
          isFalse,
        );

        // Navigate to PhoneSignInScreen
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        // Enter phone number and continue
        await tester.enterText(find.byType(TextField), '+966501234567');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // State should now have phone number and be verifying
        expect(
          container.read(simpleAuthStateProvider).phoneNumber,
          equals('+966501234567'),
        );
        expect(
          container.read(simpleAuthStateProvider).isVerifying,
          isTrue,
        );

        // Enter OTP and verify
        await tester.enterText(find.byType(TextField), '123456');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Verify and continue'));
        await tester.pumpAndSettle();

        // State should now be authenticated
        expect(
          container.read(simpleAuthStateProvider).isAuthenticated,
          isTrue,
        );
        expect(
          container.read(simpleAuthStateProvider).isVerifying,
          isFalse,
        );
      });
    });

    // --------------------------------------------------------------------------
    // Arabic Localization Tests
    // --------------------------------------------------------------------------
    group('Arabic Localization', () {
      testWidgets('PhoneSignInScreen displays Arabic text', (tester) async {
        await tester.pumpWidget(ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('ar'),
            home: const PhoneSignInScreen(),
          ),
        ));
        await tester.pumpAndSettle();

        // Verify Arabic title is displayed
        expect(find.text('تسجيل الدخول'), findsOneWidget);

        // Verify Arabic continue button
        expect(find.text('متابعة'), findsOneWidget);
      });

      testWidgets('OtpVerificationScreen displays Arabic text', (tester) async {
        await tester.pumpWidget(ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('ar'),
            home: const OtpVerificationScreen(),
          ),
        ));
        await tester.pumpAndSettle();

        // Verify Arabic title is displayed
        expect(find.text('إدخال الرمز'), findsOneWidget);

        // Verify Arabic verify button
        expect(find.text('تأكيد ومتابعة'), findsOneWidget);
      });
    });
  });
}


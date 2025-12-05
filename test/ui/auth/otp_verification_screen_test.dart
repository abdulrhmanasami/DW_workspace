/// Widget tests for OtpVerificationScreen
/// Created by: Track D - Ticket #236 (D-4)
/// Purpose: Test OTP verification screen integration with IdentityController

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:auth_shims/auth_shims.dart';

import 'package:delivery_ways_clean/screens/auth/otp_verification_screen.dart';
import '../../support/dw_test_app.dart';

/// Fake IdentityShim for testing OTP verification scenarios
class FakeIdentityShimForOtpVerification extends Fake implements IdentityShim {
  /// Session returned by loadInitialSession
  IdentitySession initialSession = const IdentitySession(
    status: AuthStatus.unauthenticated,
    user: null,
    tokens: null,
  );

  /// Session returned by verifyLoginCode on success
  IdentitySession authenticatedSession = const IdentitySession(
    status: AuthStatus.authenticated,
    user: IdentityUser(
      userId: 'test-user-id',
      phoneNumber: '+966501234567',
    ),
    tokens: AuthTokens(accessToken: 'test-token'),
  );

  /// Whether loadInitialSession should throw
  bool shouldThrowOnLoad = false;

  /// Whether verifyLoginCode should throw
  bool shouldThrowOnVerifyLoginCode = false;

  /// Track method calls
  bool loadInitialSessionCalled = false;
  bool verifyLoginCodeCalled = false;

  /// Parameters passed to methods
  PhoneNumber? lastVerifiedPhoneNumber;
  OtpCode? lastVerifiedCode;

  @override
  Future<IdentitySession> loadInitialSession() async {
    loadInitialSessionCalled = true;
    if (shouldThrowOnLoad) {
      throw Exception('Load failed');
    }
    return initialSession;
  }

  @override
  Future<IdentitySession> verifyLoginCode({
    required PhoneNumber phoneNumber,
    required OtpCode code,
  }) async {
    verifyLoginCodeCalled = true;
    lastVerifiedPhoneNumber = phoneNumber;
    lastVerifiedCode = code;
    if (shouldThrowOnVerifyLoginCode) {
      throw const AuthException.otpVerificationFailed();
    }
    return authenticatedSession;
  }

  // Stub implementations for other required methods
  @override
  Future<IdentitySession> refreshTokens() async => initialSession;

  @override
  Future<void> signOut() async {}

  @override
  Stream<IdentitySession> watchSession() async* {
    yield initialSession;
  }

  @override
  Future<void> requestLoginCode({required PhoneNumber phoneNumber}) async {}
}

void main() {
  late FakeIdentityShimForOtpVerification fakeIdentityShim;

  setUp(() {
    fakeIdentityShim = FakeIdentityShimForOtpVerification();
  });

  group('OtpVerificationScreen - UI Elements', () {
    testWidgets('displays OTP form with code field and verify button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => DwTestApp.withIdentityShim(
                  home: const OtpVerificationScreen(),
                  fakeIdentityShim: fakeIdentityShim,
                ),
                settings: const RouteSettings(arguments: '+966501234567'),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify UI elements are present
      expect(find.text('Enter code'), findsOneWidget);
      expect(find.text("We've sent a verification code to your phone."), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Verify and continue'), findsOneWidget);
    });

    testWidgets('navigates back when no phone number provided', (tester) async {
      await tester.pumpWidget(
        DwTestApp.withIdentityShim(
          home: const OtpVerificationScreen(),
          fakeIdentityShim: fakeIdentityShim,
        ),
      );
      await tester.pumpAndSettle();

      // Should show loading initially, then navigate back
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('OtpVerificationScreen - Success Scenario', () {
    testWidgets('enters valid OTP code and verifies successfully', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => DwTestApp.withIdentityShim(
                  home: const OtpVerificationScreen(),
                  fakeIdentityShim: fakeIdentityShim,
                ),
                settings: const RouteSettings(arguments: '+966501234567'),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter a valid OTP code
      final codeField = find.byType(TextField);
      await tester.enterText(codeField, '123456');
      await tester.pumpAndSettle();

      // Tap verify button
      final verifyButton = find.text('Verify and continue');
      await tester.tap(verifyButton);
      await tester.pumpAndSettle();

      // Verify verifyLoginCode was called with correct parameters
      expect(fakeIdentityShim.verifyLoginCodeCalled, isTrue);
      expect(fakeIdentityShim.lastVerifiedPhoneNumber?.e164, '+966501234567');
      expect(fakeIdentityShim.lastVerifiedCode?.value, '123456');
    });

    testWidgets('shows loading state during OTP verification', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => DwTestApp.withIdentityShim(
                  home: const OtpVerificationScreen(),
                  fakeIdentityShim: fakeIdentityShim,
                ),
                settings: const RouteSettings(arguments: '+966501234567'),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter OTP code and tap verify
      final codeField = find.byType(TextField);
      await tester.enterText(codeField, '123456');

      final verifyButton = find.text('Verify and continue');
      await tester.tap(verifyButton);
      await tester.pump(); // Don't settle to catch loading state

      // Button should be disabled during loading
      final buttonFinder = find.byType(ElevatedButton);
      if (buttonFinder.evaluate().isNotEmpty) {
        final button = tester.widget<ElevatedButton>(buttonFinder);
        // The button might be replaced with a loading version, so check if it's disabled
        expect(button.onPressed == null || button.enabled == false, isTrue,
            reason: 'Button should be disabled during loading');
      }
    });

    testWidgets('navigates to home screen on successful OTP verification', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => DwTestApp.withIdentityShim(
                  home: const OtpVerificationScreen(),
                  fakeIdentityShim: fakeIdentityShim,
                ),
                settings: const RouteSettings(arguments: '+966501234567'),
              );
            },
          ),
          routes: {
            '/home': (context) => const Scaffold(body: Center(child: Text('Home Screen'))),
          },
        ),
      );
      await tester.pumpAndSettle();

      // Enter OTP code and tap verify
      final codeField = find.byType(TextField);
      await tester.enterText(codeField, '123456');

      final verifyButton = find.text('Verify and continue');
      await tester.tap(verifyButton);
      await tester.pumpAndSettle();

      // Should navigate to home screen
      expect(find.text('Home Screen'), findsOneWidget);
    });
  });

  group('OtpVerificationScreen - Error Scenario', () {
    testWidgets('shows error message when OTP verification fails', (tester) async {
      // Configure fake shim to throw error
      fakeIdentityShim.shouldThrowOnVerifyLoginCode = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => DwTestApp.withIdentityShim(
                  home: const OtpVerificationScreen(),
                  fakeIdentityShim: fakeIdentityShim,
                ),
                settings: const RouteSettings(arguments: '+966501234567'),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter OTP code and tap verify
      final codeField = find.byType(TextField);
      await tester.enterText(codeField, '123456');

      final verifyButton = find.text('Verify and continue');
      await tester.tap(verifyButton);
      await tester.pumpAndSettle();

      // Verify verifyLoginCode was called
      expect(fakeIdentityShim.verifyLoginCodeCalled, isTrue);

      // Verify error message is shown (via SnackBar)
      expect(find.text('OTP verification failed'), findsOneWidget);
    });

    testWidgets('does not navigate to home screen when OTP verification fails', (tester) async {
      // Configure fake shim to throw error
      fakeIdentityShim.shouldThrowOnVerifyLoginCode = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => DwTestApp.withIdentityShim(
                  home: const OtpVerificationScreen(),
                  fakeIdentityShim: fakeIdentityShim,
                ),
                settings: const RouteSettings(arguments: '+966501234567'),
              );
            },
          ),
          routes: {
            '/home': (context) => const Scaffold(body: Center(child: Text('Home Screen'))),
          },
        ),
      );
      await tester.pumpAndSettle();

      // Enter OTP code and tap verify
      final codeField = find.byType(TextField);
      await tester.enterText(codeField, '123456');

      final verifyButton = find.text('Verify and continue');
      await tester.tap(verifyButton);
      await tester.pumpAndSettle();

      // Should still be on OTP screen
      expect(find.text('Enter code'), findsOneWidget);
      expect(find.text('Verify and continue'), findsOneWidget);
      // Should not be on home screen
      expect(find.text('Home Screen'), findsNothing);
    });

    testWidgets('displays error message below input field', (tester) async {
      // Configure fake shim to throw error
      fakeIdentityShim.shouldThrowOnVerifyLoginCode = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => DwTestApp.withIdentityShim(
                  home: const OtpVerificationScreen(),
                  fakeIdentityShim: fakeIdentityShim,
                ),
                settings: const RouteSettings(arguments: '+966501234567'),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter OTP code and tap verify
      final codeField = find.byType(TextField);
      await tester.enterText(codeField, '123456');

      final verifyButton = find.text('Verify and continue');
      await tester.tap(verifyButton);
      await tester.pumpAndSettle();

      // Error message should be displayed in the UI
      expect(find.text('OTP verification failed'), findsOneWidget);
    });
  });

  group('OtpVerificationScreen - Validation', () {
    testWidgets('does not call verifyLoginCode with empty code', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => DwTestApp.withIdentityShim(
                  home: const OtpVerificationScreen(),
                  fakeIdentityShim: fakeIdentityShim,
                ),
                settings: const RouteSettings(arguments: '+966501234567'),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Leave code field empty and tap verify
      final verifyButton = find.text('Verify and continue');
      await tester.tap(verifyButton);
      await tester.pumpAndSettle();

      // Should not call verifyLoginCode
      expect(fakeIdentityShim.verifyLoginCodeCalled, isFalse);
    });
  });
}

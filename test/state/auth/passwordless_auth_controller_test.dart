// Component: Passwordless Auth Controller Tests
// Created by: CENT-006 QA Implementation
// Purpose: Unit tests for passwordless OTP auth flow controller
// Last updated: 2025-11-25

import 'dart:async';

import 'package:auth_shims/auth_shims.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:delivery_ways_clean/state/auth/passwordless_auth_controller.dart';

// ============================================================================
// Test Doubles (Stubs/Fakes)
// ============================================================================

/// Stub AuthService for testing controller behavior without backend
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

  // MFA stub methods (CENT-004)
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

// ============================================================================
// Test Helpers
// ============================================================================

/// Creates a clock function that returns a fixed DateTime
PasswordlessClock fixedClock(DateTime value) => () => value;

PasswordlessAuthController createController({
  required StubAuthService service,
  PasswordlessClock? clock,
}) {
  return PasswordlessAuthController(service, clock: clock);
}

// ============================================================================
// Tests
// ============================================================================

void main() {
  group('PasswordlessAuthController', () {
    late StubAuthService stubService;
    PasswordlessAuthController? controller;

    setUp(() {
      stubService = StubAuthService();
      controller = null;
    });

    tearDown(() {
      stubService.dispose();
      controller?.dispose();
    });

    // --------------------------------------------------------------------------
    // Initial State
    // --------------------------------------------------------------------------
    group('Initial State', () {
      test('starts with enterPhone step', () {
        controller = createController(service: stubService);

        expect(controller!.state.step, equals(PasswordlessStep.enterPhone));
        expect(controller!.state.phoneE164, isNull);
        expect(controller!.state.errorMessage, isNull);
        expect(controller!.state.requestCount, equals(0));
      });

      test('can request OTP initially', () {
        controller = createController(service: stubService);
        final now = DateTime.now().toUtc();

        expect(controller!.state.canRequestOtp(now), isTrue);
      });
    });

    // --------------------------------------------------------------------------
    // requestOtp - Success Scenarios
    // --------------------------------------------------------------------------
    group('requestOtp - Success', () {
      test('successful OTP request transitions to codeSent', () async {
        controller = createController(service: stubService);
        const validPhone = '+491234567890';

        await controller!.requestOtp(validPhone);

        expect(controller!.state.step, equals(PasswordlessStep.codeSent));
        expect(controller!.state.phoneE164, equals(validPhone));
        expect(controller!.state.errorMessage, isNull);
        expect(stubService.requestOtpCalled, isTrue);
        expect(stubService.lastRequestedPhone?.e164, equals(validPhone));
      });

      test('increments request count on successful OTP request', () async {
        controller = createController(service: stubService);

        expect(controller!.state.requestCount, equals(0));

        await controller!.requestOtp('+491234567890');

        expect(controller!.state.requestCount, equals(1));
      });

      test('sets cooldown timer after successful request', () async {
        final now = DateTime.utc(2025, 11, 25, 12, 0, 0);
        controller = createController(
          service: stubService,
          clock: fixedClock(now),
        );

        await controller!.requestOtp('+491234567890');

        expect(controller!.state.nextRequestAllowedAt, isNotNull);
        expect(
          controller!.state.nextRequestAllowedAt!.isAfter(now),
          isTrue,
        );
      });

      test('trims phone number whitespace', () async {
        controller = createController(service: stubService);

        await controller!.requestOtp('  +491234567890  ');

        expect(controller!.state.phoneE164, equals('+491234567890'));
      });
    });

    // --------------------------------------------------------------------------
    // requestOtp - Failure Scenarios
    // --------------------------------------------------------------------------
    group('requestOtp - Failures', () {
      test('invalid phone format transitions to error state', () async {
        controller = createController(service: stubService);

        await controller!.requestOtp('invalid-phone');

        expect(controller!.state.step, equals(PasswordlessStep.error));
        expect(controller!.state.errorMessage, isNotNull);
        expect(
          controller!.state.errorMessage,
          contains('Invalid phone number'),
        );
      });

      test('backend error transitions to error state', () async {
        stubService.requestOtpError = const AuthException.networkError(
          'Network unavailable',
        );
        controller = createController(service: stubService);

        await controller!.requestOtp('+491234567890');

        expect(controller!.state.step, equals(PasswordlessStep.error));
        expect(controller!.state.errorMessage, contains('Network'));
      });

      test('rate limit error sets cooldown and shows message', () async {
        stubService.requestOtpError = const AuthException(
          'rate_limited',
          'Too many requests',
        );
        controller = createController(service: stubService);

        await controller!.requestOtp('+491234567890');

        expect(controller!.state.step, equals(PasswordlessStep.error));
        expect(controller!.state.nextRequestAllowedAt, isNotNull);
      });

      test('blocks request during cooldown period', () async {
        final now = DateTime.utc(2025, 11, 25, 12, 0, 0);
        controller = createController(
          service: stubService,
          clock: fixedClock(now),
        );

        // First request succeeds
        await controller!.requestOtp('+491234567890');
        stubService.requestOtpCalled = false;

        // Second request during cooldown fails
        await controller!.requestOtp('+491234567890');

        expect(controller!.state.step, equals(PasswordlessStep.error));
        expect(
          controller!.state.errorMessage,
          contains('wait'),
        );
        // Service should NOT be called during cooldown
        expect(stubService.requestOtpCalled, isFalse);
      });

      test('blocks request after max requests reached', () async {
        // Use a clock that advances past cooldown for each request
        var clockTime = DateTime.utc(2025, 11, 25, 12, 0, 0);
        controller = PasswordlessAuthController(
          stubService,
          clock: () {
            // Advance clock by 1 minute each time it's called
            clockTime = clockTime.add(const Duration(minutes: 1));
            return clockTime;
          },
        );

        // Make 5 requests to exhaust the limit
        for (int i = 0; i < 5; i++) {
          await controller!.requestOtp('+4912345678$i$i');
        }

        // 6th request should fail with max requests message
        await controller!.requestOtp('+491234567890');

        expect(controller!.state.step, equals(PasswordlessStep.error));
        expect(
          controller!.state.errorMessage,
          contains('Maximum OTP requests'),
        );
      });
    });

    // --------------------------------------------------------------------------
    // verifyOtp - Success Scenarios
    // --------------------------------------------------------------------------
    group('verifyOtp - Success', () {
      test('successful OTP verification transitions to authenticated', () async {
        controller = createController(service: stubService);

        // First request OTP
        await controller!.requestOtp('+491234567890');
        expect(controller!.state.step, equals(PasswordlessStep.codeSent));

        // Then verify
        await controller!.verifyOtp('123456');

        expect(controller!.state.step, equals(PasswordlessStep.authenticated));
        expect(controller!.state.errorMessage, isNull);
        expect(stubService.verifyOtpCalled, isTrue);
        expect(stubService.lastVerifiedCode?.value, equals('123456'));
      });

      test('clears cooldown after successful verification', () async {
        controller = createController(service: stubService);

        await controller!.requestOtp('+491234567890');
        expect(controller!.state.nextRequestAllowedAt, isNotNull);

        await controller!.verifyOtp('123456');

        expect(controller!.state.nextRequestAllowedAt, isNull);
      });
    });

    // --------------------------------------------------------------------------
    // verifyOtp - Failure Scenarios
    // --------------------------------------------------------------------------
    group('verifyOtp - Failures', () {
      test('missing phone number shows error', () async {
        controller = createController(service: stubService);

        // Try to verify without requesting OTP first
        await controller!.verifyOtp('123456');

        expect(controller!.state.step, equals(PasswordlessStep.error));
        expect(controller!.state.errorMessage, contains('Phone number missing'));
      });

      test('invalid OTP format shows error', () async {
        controller = createController(service: stubService);

        await controller!.requestOtp('+491234567890');
        await controller!.verifyOtp('abc'); // Invalid: not digits

        expect(controller!.state.step, equals(PasswordlessStep.error));
        expect(controller!.state.errorMessage, contains('Invalid OTP'));
      });

      test('backend verification failure shows error', () async {
        stubService.verifyOtpError = const AuthException.otpVerificationFailed();
        controller = createController(service: stubService);

        await controller!.requestOtp('+491234567890');
        await controller!.verifyOtp('123456');

        expect(controller!.state.step, equals(PasswordlessStep.error));
        expect(
          controller!.state.errorMessage,
          contains('verification failed'),
        );
      });

      test('expired OTP shows error', () async {
        stubService.verifyOtpError = const AuthException.otpExpired();
        controller = createController(service: stubService);

        await controller!.requestOtp('+491234567890');
        await controller!.verifyOtp('123456');

        expect(controller!.state.step, equals(PasswordlessStep.error));
        expect(controller!.state.errorMessage, contains('expired'));
      });
    });

    // --------------------------------------------------------------------------
    // logout
    // --------------------------------------------------------------------------
    group('logout', () {
      test('logout resets state to initial', () async {
        controller = createController(service: stubService);

        // Authenticate first
        await controller!.requestOtp('+491234567890');
        await controller!.verifyOtp('123456');
        expect(controller!.state.step, equals(PasswordlessStep.authenticated));

        // Logout
        await controller!.logout();

        expect(controller!.state.step, equals(PasswordlessStep.enterPhone));
        expect(controller!.state.phoneE164, isNull);
        expect(controller!.state.requestCount, equals(0));
        expect(stubService.logoutCalled, isTrue);
      });
    });

    // --------------------------------------------------------------------------
    // State Helper Methods
    // --------------------------------------------------------------------------
    group('State Helper Methods', () {
      test('canRequestOtp returns true when no cooldown', () {
        controller = createController(service: stubService);
        final now = DateTime.now().toUtc();

        expect(controller!.state.canRequestOtp(now), isTrue);
      });

      test('canRequestOtp returns false during cooldown', () async {
        final now = DateTime.utc(2025, 11, 25, 12, 0, 0);
        controller = createController(
          service: stubService,
          clock: fixedClock(now),
        );

        await controller!.requestOtp('+491234567890');

        // Still in cooldown
        expect(controller!.state.canRequestOtp(now), isFalse);
      });

      test('canRequestOtp returns false when max requests reached', () async {
        // This tests the helper method logic directly on PasswordlessAuthState
        // No need to create a controller for this test
        const state = PasswordlessAuthState(
          step: PasswordlessStep.codeSent,
          requestCount: 5,
          maxRequestsPerSession: 5,
        );

        expect(state.canRequestOtp(DateTime.now()), isFalse);
      });

      test('cooldownRemaining calculates correct duration', () {
        // This tests the helper method logic directly on PasswordlessAuthState
        // No need to create a controller for this test
        final now = DateTime.utc(2025, 11, 25, 12, 0, 0);
        final nextAllowed = now.add(const Duration(seconds: 30));

        final state = PasswordlessAuthState(
          step: PasswordlessStep.codeSent,
          nextRequestAllowedAt: nextAllowed,
        );

        final remaining = state.cooldownRemaining(now);

        expect(remaining, isNotNull);
        expect(remaining!.inSeconds, equals(30));
      });

      test('cooldownRemaining returns zero when past cooldown', () {
        // This tests the helper method logic directly on PasswordlessAuthState
        final now = DateTime.utc(2025, 11, 25, 12, 0, 0);
        final nextAllowed = now.subtract(const Duration(seconds: 10));

        final state = PasswordlessAuthState(
          step: PasswordlessStep.codeSent,
          nextRequestAllowedAt: nextAllowed,
        );

        final remaining = state.cooldownRemaining(now);

        expect(remaining, equals(Duration.zero));
      });

      test('remainingRequests calculates correctly', () {
        // This tests the helper method logic directly on PasswordlessAuthState
        const state = PasswordlessAuthState(
          step: PasswordlessStep.codeSent,
          requestCount: 3,
          maxRequestsPerSession: 5,
        );

        expect(state.remainingRequests, equals(2));
      });
    });
  });
}


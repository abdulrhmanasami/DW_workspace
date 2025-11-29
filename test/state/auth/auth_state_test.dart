/// Unit Tests for AuthState + AuthController (Stub)
/// Created by: Track D - Ticket #36
/// Purpose: Tests for simple Phone + OTP Auth flow
/// Last updated: 2025-11-28

import 'package:flutter_test/flutter_test.dart';

import 'package:delivery_ways_clean/state/auth/auth_state.dart';

void main() {
  group('AuthState', () {
    // --------------------------------------------------------------------------
    // Initial/Default State
    // --------------------------------------------------------------------------
    group('Initial State', () {
      test('default state has isAuthenticated == false', () {
        const state = AuthState();

        expect(state.isAuthenticated, isFalse);
      });

      test('default state has isVerifying == false', () {
        const state = AuthState();

        expect(state.isVerifying, isFalse);
      });

      test('default state has phoneNumber == null', () {
        const state = AuthState();

        expect(state.phoneNumber, isNull);
      });
    });

    // --------------------------------------------------------------------------
    // copyWith
    // --------------------------------------------------------------------------
    group('copyWith', () {
      test('copyWith updates isAuthenticated correctly', () {
        const state = AuthState();

        final updated = state.copyWith(isAuthenticated: true);

        expect(updated.isAuthenticated, isTrue);
        expect(updated.isVerifying, isFalse);
        expect(updated.phoneNumber, isNull);
      });

      test('copyWith updates isVerifying correctly', () {
        const state = AuthState();

        final updated = state.copyWith(isVerifying: true);

        expect(updated.isAuthenticated, isFalse);
        expect(updated.isVerifying, isTrue);
        expect(updated.phoneNumber, isNull);
      });

      test('copyWith updates phoneNumber correctly', () {
        const state = AuthState();

        final updated = state.copyWith(phoneNumber: '+966501234567');

        expect(updated.isAuthenticated, isFalse);
        expect(updated.isVerifying, isFalse);
        expect(updated.phoneNumber, equals('+966501234567'));
      });

      test('copyWith preserves existing values when not overridden', () {
        const state = AuthState(
          isAuthenticated: true,
          isVerifying: false,
          phoneNumber: '+966501234567',
        );

        final updated = state.copyWith(isVerifying: true);

        expect(updated.isAuthenticated, isTrue);
        expect(updated.isVerifying, isTrue);
        expect(updated.phoneNumber, equals('+966501234567'));
      });

      test('copyWith can update all values at once', () {
        const state = AuthState();

        final updated = state.copyWith(
          isAuthenticated: true,
          isVerifying: false,
          phoneNumber: '+966509876543',
        );

        expect(updated.isAuthenticated, isTrue);
        expect(updated.isVerifying, isFalse);
        expect(updated.phoneNumber, equals('+966509876543'));
      });
    });

    // --------------------------------------------------------------------------
    // Equality
    // --------------------------------------------------------------------------
    group('Equality', () {
      test('two default states are equal', () {
        const state1 = AuthState();
        const state2 = AuthState();

        expect(state1 == state2, isTrue);
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('two states with same values are equal', () {
        const state1 = AuthState(
          isAuthenticated: true,
          isVerifying: false,
          phoneNumber: '+966501234567',
        );
        const state2 = AuthState(
          isAuthenticated: true,
          isVerifying: false,
          phoneNumber: '+966501234567',
        );

        expect(state1 == state2, isTrue);
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('two states with different isAuthenticated are not equal', () {
        const state1 = AuthState(isAuthenticated: true);
        const state2 = AuthState(isAuthenticated: false);

        expect(state1 == state2, isFalse);
      });

      test('two states with different phoneNumber are not equal', () {
        const state1 = AuthState(phoneNumber: '+966501234567');
        const state2 = AuthState(phoneNumber: '+966509876543');

        expect(state1 == state2, isFalse);
      });
    });

    // --------------------------------------------------------------------------
    // toString
    // --------------------------------------------------------------------------
    group('toString', () {
      test('toString returns readable representation', () {
        const state = AuthState(
          isAuthenticated: true,
          phoneNumber: '+966501234567',
        );

        final str = state.toString();

        expect(str, contains('AuthState'));
        expect(str, contains('isAuthenticated: true'));
        expect(str, contains('+966501234567'));
      });
    });
  });

  group('AuthController', () {
    late AuthController controller;

    setUp(() {
      controller = AuthController();
    });

    tearDown(() {
      controller.dispose();
    });

    // --------------------------------------------------------------------------
    // Initial State
    // --------------------------------------------------------------------------
    group('Initial State', () {
      test('starts with default AuthState', () {
        expect(controller.state.isAuthenticated, isFalse);
        expect(controller.state.isVerifying, isFalse);
        expect(controller.state.phoneNumber, isNull);
      });
    });

    // --------------------------------------------------------------------------
    // startPhoneSignIn
    // --------------------------------------------------------------------------
    group('startPhoneSignIn', () {
      test('saves phone number to state', () {
        controller.startPhoneSignIn('+966501234567');

        expect(controller.state.phoneNumber, equals('+966501234567'));
      });

      test('sets isVerifying to true', () {
        controller.startPhoneSignIn('+966501234567');

        expect(controller.state.isVerifying, isTrue);
      });

      test('keeps isAuthenticated as false', () {
        controller.startPhoneSignIn('+966501234567');

        expect(controller.state.isAuthenticated, isFalse);
      });

      test('trims whitespace from phone number', () {
        controller.startPhoneSignIn('  +966501234567  ');

        expect(controller.state.phoneNumber, equals('+966501234567'));
      });

      test('does nothing for empty phone number', () {
        controller.startPhoneSignIn('');

        expect(controller.state.phoneNumber, isNull);
        expect(controller.state.isVerifying, isFalse);
      });

      test('does nothing for whitespace-only phone number', () {
        controller.startPhoneSignIn('   ');

        expect(controller.state.phoneNumber, isNull);
        expect(controller.state.isVerifying, isFalse);
      });
    });

    // --------------------------------------------------------------------------
    // verifyOtpCode
    // --------------------------------------------------------------------------
    group('verifyOtpCode', () {
      test('sets isAuthenticated to true for non-empty code', () {
        controller.startPhoneSignIn('+966501234567');
        controller.verifyOtpCode('1234');

        expect(controller.state.isAuthenticated, isTrue);
      });

      test('sets isVerifying to false after verification', () {
        controller.startPhoneSignIn('+966501234567');
        controller.verifyOtpCode('1234');

        expect(controller.state.isVerifying, isFalse);
      });

      test('preserves phoneNumber after verification', () {
        controller.startPhoneSignIn('+966501234567');
        controller.verifyOtpCode('1234');

        expect(controller.state.phoneNumber, equals('+966501234567'));
      });

      test('accepts any non-empty code (stub behavior)', () {
        controller.startPhoneSignIn('+966501234567');

        // Any code should work in stub mode
        controller.verifyOtpCode('0000');
        expect(controller.state.isAuthenticated, isTrue);
      });

      test('does nothing for empty code', () {
        controller.startPhoneSignIn('+966501234567');
        controller.verifyOtpCode('');

        // Should still be in verifying state
        expect(controller.state.isAuthenticated, isFalse);
        expect(controller.state.isVerifying, isTrue);
      });

      test('does nothing for whitespace-only code', () {
        controller.startPhoneSignIn('+966501234567');
        controller.verifyOtpCode('   ');

        // Should still be in verifying state
        expect(controller.state.isAuthenticated, isFalse);
        expect(controller.state.isVerifying, isTrue);
      });

      test('trims whitespace from code', () {
        controller.startPhoneSignIn('+966501234567');
        controller.verifyOtpCode('  1234  ');

        // Should authenticate with trimmed code
        expect(controller.state.isAuthenticated, isTrue);
      });
    });

    // --------------------------------------------------------------------------
    // signOut
    // --------------------------------------------------------------------------
    group('signOut', () {
      test('resets state to default', () {
        // First, authenticate
        controller.startPhoneSignIn('+966501234567');
        controller.verifyOtpCode('1234');
        expect(controller.state.isAuthenticated, isTrue);

        // Then sign out
        controller.signOut();

        expect(controller.state.isAuthenticated, isFalse);
        expect(controller.state.isVerifying, isFalse);
        expect(controller.state.phoneNumber, isNull);
      });

      test('can sign out even when not authenticated', () {
        controller.signOut();

        expect(controller.state.isAuthenticated, isFalse);
        expect(controller.state.phoneNumber, isNull);
      });
    });

    // --------------------------------------------------------------------------
    // cancelVerification
    // --------------------------------------------------------------------------
    group('cancelVerification', () {
      test('clears verifying state', () {
        controller.startPhoneSignIn('+966501234567');
        expect(controller.state.isVerifying, isTrue);

        controller.cancelVerification();

        expect(controller.state.isVerifying, isFalse);
      });

      test('clears phone number', () {
        controller.startPhoneSignIn('+966501234567');

        controller.cancelVerification();

        expect(controller.state.phoneNumber, isNull);
      });

      test('keeps isAuthenticated as false', () {
        controller.startPhoneSignIn('+966501234567');

        controller.cancelVerification();

        expect(controller.state.isAuthenticated, isFalse);
      });
    });

    // --------------------------------------------------------------------------
    // Full Flow
    // --------------------------------------------------------------------------
    group('Full Auth Flow', () {
      test('complete sign-in flow: phone -> otp -> authenticated', () {
        // Initial state
        expect(controller.state.isAuthenticated, isFalse);
        expect(controller.state.phoneNumber, isNull);

        // Step 1: Enter phone
        controller.startPhoneSignIn('+966501234567');
        expect(controller.state.isAuthenticated, isFalse);
        expect(controller.state.isVerifying, isTrue);
        expect(controller.state.phoneNumber, equals('+966501234567'));

        // Step 2: Verify OTP
        controller.verifyOtpCode('123456');
        expect(controller.state.isAuthenticated, isTrue);
        expect(controller.state.isVerifying, isFalse);
        expect(controller.state.phoneNumber, equals('+966501234567'));
      });

      test('sign-in, sign-out, re-sign-in flow', () {
        // Sign in
        controller.startPhoneSignIn('+966501234567');
        controller.verifyOtpCode('1234');
        expect(controller.state.isAuthenticated, isTrue);

        // Sign out
        controller.signOut();
        expect(controller.state.isAuthenticated, isFalse);
        expect(controller.state.phoneNumber, isNull);

        // Sign in again with different phone
        controller.startPhoneSignIn('+966509876543');
        controller.verifyOtpCode('5678');
        expect(controller.state.isAuthenticated, isTrue);
        expect(controller.state.phoneNumber, equals('+966509876543'));
      });
    });
  });
}


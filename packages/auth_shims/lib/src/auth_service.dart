// Auth Service Interfaces
// Created by: CEN-AUTH001 Implementation
// Purpose: Abstract interfaces for authentication services
// Last updated: 2025-11-25 (CENT-004: 2FA/MFA support)

import 'dart:async';

import 'auth_models.dart';
import 'mfa_models.dart';

/// Service for phone/OTP authentication operations
abstract class AuthService {
  /// Request OTP code to be sent to phone number
  /// Backend should send SMS with OTP to the provided phone number
  Future<void> requestOtp(PhoneNumber phoneNumber);

  /// Verify OTP code and create authentication session
  /// Returns AuthSession containing access token and user information
  Future<AuthSession> verifyOtp({
    required PhoneNumber phoneNumber,
    required OtpCode code,
  });

  /// Sign out current user and invalidate session
  Future<void> logout();

  /// Refresh current session if possible
  Future<AuthSession?> refreshSession();

  /// Get current authentication session (null if not authenticated)
  Future<AuthSession?> getCurrentSession();

  /// Stream of authentication state changes
  Stream<AuthState> get onAuthStateChanged;

  /// Attempt to unlock a previously stored session (biometric-gated flows).
  Future<bool> unlockStoredSession({String? localizedReason});

  // ---------------------------------------------------------------------------
  // MFA / 2FA Methods (CENT-004)
  // ---------------------------------------------------------------------------

  /// Evaluate whether MFA is required for the current session/action.
  ///
  /// Called after primary authentication (OTP verification) to determine
  /// if a second factor is needed based on backend risk assessment.
  ///
  /// [session] - The current (possibly partial) auth session after OTP.
  /// [action] - The action context, e.g., "login", "change_phone", "high_value_payment".
  ///
  /// Returns [MfaRequirement] indicating if MFA is required and available methods.
  Future<MfaRequirement> evaluateMfaRequirement({
    required AuthSession session,
    required String action,
  });

  /// Start an MFA challenge using the specified method.
  ///
  /// This triggers the backend to send an OTP (for sms/email) or prepare
  /// verification (for totp/push).
  ///
  /// [session] - The current auth session.
  /// [method] - The MFA method to use (must be in [MfaRequirement.allowedMethods]).
  /// [action] - The action context that triggered MFA.
  ///
  /// Returns [MfaChallenge] containing the challenge ID and expiry info.
  /// Throws [MfaException] if the method is not available or backend fails.
  Future<MfaChallenge> startMfaChallenge({
    required AuthSession session,
    required MfaMethodType method,
    required String action,
  });

  /// Verify an MFA code for the given challenge.
  ///
  /// [challengeId] - The challenge ID from [startMfaChallenge].
  /// [code] - The user-entered verification code.
  ///
  /// Returns [MfaVerificationResult] indicating success, failure, or lockout.
  Future<MfaVerificationResult> verifyMfaCode({
    required String challengeId,
    required String code,
  });
}

/// Repository for managing authentication session persistence
abstract class AuthSessionRepository {
  /// Load current authentication state from persistent storage
  Future<AuthState> loadAuthState();

  /// Save authentication session to persistent storage
  Future<void> saveSession(AuthSession session);

  /// Clear authentication session from persistent storage
  Future<void> clearSession();

  /// Check if there's a valid session stored
  Future<bool> hasValidSession();
}

/// Supported biometric types exposed to the app layer.
enum BiometricType {
  face,
  fingerprint,
  iris,
  unknown,
}

/// Describes whether biometric authentication can be used on the device.
class BiometricSupportStatus {
  const BiometricSupportStatus({
    required this.canAuthenticate,
    required this.isDeviceSupported,
    this.availableTypes = const <BiometricType>[],
  });

  const BiometricSupportStatus.unavailable()
      : canAuthenticate = false,
        isDeviceSupported = false,
        availableTypes = const <BiometricType>[];

  final bool canAuthenticate;
  final bool isDeviceSupported;
  final List<BiometricType> availableTypes;
}

/// Possible biometric authentication outcomes.
enum BiometricAuthOutcome {
  success,
  failed,
  canceled,
  error,
  unavailable,
}

/// Result returned after attempting biometric authentication.
class BiometricAuthResult {
  const BiometricAuthResult(this.outcome, {this.message});

  const BiometricAuthResult.success()
      : outcome = BiometricAuthOutcome.success,
        message = null;

  const BiometricAuthResult.canceled()
      : outcome = BiometricAuthOutcome.canceled,
        message = null;

  const BiometricAuthResult.failed()
      : outcome = BiometricAuthOutcome.failed,
        message = null;

  final BiometricAuthOutcome outcome;
  final String? message;

  bool get isSuccess => outcome == BiometricAuthOutcome.success;
  bool get isCanceled => outcome == BiometricAuthOutcome.canceled;
}

/// Contract for biometric authentication implementations.
abstract class BiometricAuthenticator {
  Future<BiometricSupportStatus> getSupportStatus();

  Future<BiometricAuthResult> authenticate({
    String? localizedReason,
    bool biometricsOnly = true,
  });
}

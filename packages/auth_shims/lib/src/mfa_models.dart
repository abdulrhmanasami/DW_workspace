// Component: MFA Domain Models
// Created by: CENT-004 Implementation
// Purpose: Multi-Factor Authentication contracts and models for risk-based MFA
// Last updated: 2025-11-25

/// Supported MFA method types.
///
/// These represent the available second-factor authentication methods
/// that the backend may offer based on user configuration and risk assessment.
enum MfaMethodType {
  /// SMS-based OTP code
  sms,

  /// Time-based One-Time Password (TOTP) via authenticator app
  totp,

  /// Email-based OTP code
  email,

  /// Push notification to registered device
  push,
}

/// Risk context that triggered MFA requirement.
///
/// The backend may require MFA based on various risk signals.
/// This enum captures the reason code for auditing and UX messaging.
enum MfaRiskContext {
  /// Standard login from known device
  standardLogin,

  /// Login from a new or unrecognized device
  newDevice,

  /// Sensitive operation like payment method change
  sensitiveOperation,

  /// High-value transaction threshold exceeded
  highValueTransaction,

  /// Phone number or email change request
  accountRecoveryChange,

  /// Elevated risk detected by backend (e.g., unusual location)
  elevatedRisk,

  /// DSR (Data Subject Rights) operations like account deletion
  dsrOperation,
}

/// Describes whether MFA is required and what methods are available.
///
/// Returned by [AuthService.evaluateMfaRequirement] after primary
/// authentication (OTP) to determine if a second factor is needed.
class MfaRequirement {
  const MfaRequirement({
    required this.required,
    this.allowedMethods = const <MfaMethodType>[],
    this.reasonCode,
    this.riskContext,
  });

  /// Factory for when no MFA is required.
  const MfaRequirement.notRequired()
      : required = false,
        allowedMethods = const <MfaMethodType>[],
        reasonCode = null,
        riskContext = null;

  /// Whether MFA is required to complete authentication.
  final bool required;

  /// List of allowed MFA methods the user can choose from.
  /// Empty if [required] is false.
  final List<MfaMethodType> allowedMethods;

  /// Backend reason code for requiring MFA (e.g., "new_device", "high_risk").
  /// Useful for analytics and debugging.
  final String? reasonCode;

  /// Parsed risk context if available.
  final MfaRiskContext? riskContext;

  /// Check if a specific method is available.
  bool hasMethod(MfaMethodType method) => allowedMethods.contains(method);

  /// Get the primary/preferred method (first in list).
  MfaMethodType? get preferredMethod =>
      allowedMethods.isNotEmpty ? allowedMethods.first : null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MfaRequirement &&
          runtimeType == other.runtimeType &&
          required == other.required &&
          _listEquals(allowedMethods, other.allowedMethods) &&
          reasonCode == other.reasonCode;

  @override
  int get hashCode =>
      required.hashCode ^ allowedMethods.hashCode ^ reasonCode.hashCode;

  @override
  String toString() {
    return 'MfaRequirement(required: $required, methods: $allowedMethods, reason: $reasonCode)';
  }
}

/// Represents an active MFA challenge from the backend.
///
/// Created when [AuthService.startMfaChallenge] is called.
/// Contains the challenge ID needed to verify the code.
class MfaChallenge {
  const MfaChallenge({
    required this.challengeId,
    required this.method,
    required this.expiresAt,
    this.retryLimit,
    this.attemptsRemaining,
    this.maskedDestination,
  });

  /// Unique identifier for this challenge session.
  /// Must be passed to [AuthService.verifyMfaCode].
  final String challengeId;

  /// The MFA method being used for this challenge.
  final MfaMethodType method;

  /// When this challenge expires.
  final DateTime expiresAt;

  /// Maximum number of verification attempts allowed.
  final int? retryLimit;

  /// Number of attempts remaining (if tracked by backend).
  final int? attemptsRemaining;

  /// Masked destination for display purposes.
  /// E.g., "***@example.com" or "+49***890"
  final String? maskedDestination;

  /// Check if the challenge has expired.
  bool get isExpired => DateTime.now().toUtc().isAfter(expiresAt);

  /// Calculate remaining time until expiry.
  Duration get timeRemaining {
    final now = DateTime.now().toUtc();
    if (now.isAfter(expiresAt)) return Duration.zero;
    return expiresAt.difference(now);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MfaChallenge &&
          runtimeType == other.runtimeType &&
          challengeId == other.challengeId;

  @override
  int get hashCode => challengeId.hashCode;

  @override
  String toString() {
    return 'MfaChallenge(id: $challengeId, method: $method, expires: $expiresAt)';
  }
}

/// Result of an MFA code verification attempt.
class MfaVerificationResult {
  const MfaVerificationResult({
    required this.success,
    this.locked = false,
    this.errorCode,
    this.message,
    this.attemptsRemaining,
    this.lockoutEndTime,
  });

  /// Factory for successful verification.
  const MfaVerificationResult.success()
      : success = true,
        locked = false,
        errorCode = null,
        message = null,
        attemptsRemaining = null,
        lockoutEndTime = null;

  /// Factory for failed verification (wrong code).
  const MfaVerificationResult.failed({
    String? errorCode,
    String? message,
    this.attemptsRemaining,
  })  : success = false,
        locked = false,
        errorCode = errorCode ?? 'invalid_code',
        message = message ?? 'Invalid verification code',
        lockoutEndTime = null;

  /// Factory for lockout state (too many attempts).
  const MfaVerificationResult.locked({
    String? message,
    this.lockoutEndTime,
  })  : success = false,
        locked = true,
        errorCode = 'mfa_locked',
        message = message ?? 'Too many failed attempts. Account temporarily locked.',
        attemptsRemaining = 0;

  /// Whether the verification was successful.
  final bool success;

  /// Whether the account is now locked due to too many failed attempts.
  final bool locked;

  /// Error code from backend if verification failed.
  final String? errorCode;

  /// Human-readable error message.
  final String? message;

  /// Number of attempts remaining before lockout.
  final int? attemptsRemaining;

  /// When the lockout period ends (if locked).
  final DateTime? lockoutEndTime;

  /// Check if the user has attempts remaining.
  bool get hasAttemptsRemaining =>
      attemptsRemaining == null || attemptsRemaining! > 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MfaVerificationResult &&
          runtimeType == other.runtimeType &&
          success == other.success &&
          locked == other.locked &&
          errorCode == other.errorCode;

  @override
  int get hashCode => success.hashCode ^ locked.hashCode ^ errorCode.hashCode;

  @override
  String toString() {
    return 'MfaVerificationResult(success: $success, locked: $locked, error: $errorCode)';
  }
}

/// MFA-specific exceptions.
class MfaException implements Exception {
  const MfaException(this.code, this.message, [this.originalError]);

  /// Challenge expired
  const MfaException.challengeExpired()
      : this('mfa_challenge_expired', 'MFA challenge has expired. Please start a new challenge.');

  /// Invalid challenge ID
  const MfaException.invalidChallenge()
      : this('mfa_invalid_challenge', 'Invalid or unknown MFA challenge.');

  /// Method not available
  const MfaException.methodNotAvailable()
      : this('mfa_method_not_available', 'Selected MFA method is not available.');

  /// Account locked
  const MfaException.accountLocked([String? details])
      : this('mfa_account_locked', details ?? 'Account is temporarily locked due to too many failed attempts.');

  /// Backend error
  const MfaException.backendError([String? details])
      : this('mfa_backend_error', details ?? 'MFA service error');

  final String code;
  final String message;
  final dynamic originalError;

  @override
  String toString() => 'MfaException($code): $message';
}

// Private helper for list equality
bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}


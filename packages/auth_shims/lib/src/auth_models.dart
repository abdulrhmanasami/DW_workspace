// Auth Domain Models
// Created by: CEN-AUTH001 Implementation
// Purpose: Core domain models for phone/OTP authentication
// Last updated: 2025-11-19

/// Phone number in E.164 format (+country code)
class PhoneNumber {
  final String e164;

  const PhoneNumber(this.e164);

  /// Validate E.164 format (+ followed by digits)
  bool get isValid {
    final regex = RegExp(r'^\+[1-9]\d{1,14}$');
    return regex.hasMatch(e164);
  }

  /// Extract country code
  String get countryCode {
    if (!isValid) return '';
    final match = RegExp(r'^\+(\d+)').firstMatch(e164);
    return match?.group(1) ?? '';
  }

  /// Extract national number (without country code)
  String get nationalNumber {
    if (!isValid) return e164;
    return e164.substring(countryCode.length + 1);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhoneNumber && runtimeType == other.runtimeType && e164 == other.e164;

  @override
  int get hashCode => e164.hashCode;

  @override
  String toString() => 'PhoneNumber($e164)';
}

/// OTP code (4-6 digits typically)
class OtpCode {
  final String value;

  const OtpCode(this.value);

  /// Validate OTP format (digits only, reasonable length)
  bool get isValid {
    final regex = RegExp(r'^\d{4,8}$');
    return regex.hasMatch(value);
  }

  /// Get length of the OTP
  int get length => value.length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OtpCode && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'OtpCode(${value.replaceAll(RegExp(r'.'), '*')})';
}

/// Authenticated user information
class AuthUser {
  final String id;
  final String? phoneNumber;
  final String? displayName;
  final String? avatarUrl;
  final Map<String, dynamic> metadata;

  const AuthUser({
    required this.id,
    this.phoneNumber,
    this.displayName,
    this.avatarUrl,
    this.metadata = const {},
  });

  /// Create a copy with updated fields
  AuthUser copyWith({
    String? id,
    String? phoneNumber,
    String? displayName,
    String? avatarUrl,
    Map<String, dynamic>? metadata,
  }) {
    return AuthUser(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AuthUser(id: $id, phone: $phoneNumber, name: $displayName)';
  }
}

/// Authentication session containing tokens and user info
class AuthSession {
  final String accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;
  final AuthUser user;

  const AuthSession({
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
    required this.user,
  });

  /// Check if session is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if session is close to expiry (within 5 minutes)
  bool get isExpiringSoon {
    if (expiresAt == null) return false;
    final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));
    return fiveMinutesFromNow.isAfter(expiresAt!);
  }

  /// Create a copy with updated access token (for refresh)
  AuthSession copyWithNewAccessToken(String newAccessToken, DateTime? newExpiresAt) {
    return AuthSession(
      accessToken: newAccessToken,
      refreshToken: refreshToken,
      expiresAt: newExpiresAt,
      user: user,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthSession &&
          runtimeType == other.runtimeType &&
          accessToken == other.accessToken &&
          user == other.user;

  @override
  int get hashCode => accessToken.hashCode ^ user.hashCode;

  @override
  String toString() {
    return 'AuthSession(userId: ${user.id}, expired: $isExpired)';
  }
}

/// Authentication status
enum AuthStatus {
  unknown,
  unauthenticated,
  authenticated,
}

/// Authentication state
class AuthState {
  final AuthStatus status;
  final AuthSession? session;
  final String? errorMessage;

  const AuthState._({
    required this.status,
    this.session,
    this.errorMessage,
  });

  /// Unknown authentication state (initial state)
  const AuthState.unknown()
      : this._(status: AuthStatus.unknown);

  /// User is not authenticated
  const AuthState.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);

  /// User is authenticated with valid session
  const AuthState.authenticated(AuthSession session)
      : this._(status: AuthStatus.authenticated, session: session);

  /// Authentication failed with error
  const AuthState.error(String message)
      : this._(status: AuthStatus.unauthenticated, errorMessage: message);

  /// Check if user is authenticated
  bool get isAuthenticated => status == AuthStatus.authenticated && session != null;

  /// Check if user is unauthenticated
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;

  /// Check if authentication state is loading/unknown
  bool get isLoading => status == AuthStatus.unknown;

  /// Check if there's an error
  bool get hasError => errorMessage != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          session == other.session &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => status.hashCode ^ (session?.hashCode ?? 0) ^ (errorMessage?.hashCode ?? 0);

  @override
  String toString() {
    return 'AuthState(status: $status, userId: ${session?.user.id}, error: $errorMessage)';
  }
}

/// Authentication exceptions
class AuthException implements Exception {
  final String code;
  final String message;
  final dynamic originalError;

  const AuthException(this.code, this.message, [this.originalError]);

  /// Invalid phone number
  const AuthException.invalidPhone()
      : this('invalid_phone', 'Invalid phone number format');

  /// Invalid OTP code
  const AuthException.invalidOtp()
      : this('invalid_otp', 'Invalid OTP code');

  /// OTP expired
  const AuthException.otpExpired()
      : this('otp_expired', 'OTP code has expired');

  /// OTP verification failed
  const AuthException.otpVerificationFailed()
      : this('otp_verification_failed', 'OTP verification failed');

  /// Session expired
  const AuthException.sessionExpired()
      : this('session_expired', 'Authentication session has expired');

  /// Network error
  const AuthException.networkError([String? details])
      : this('network_error', details ?? 'Network communication failed');

  /// Server error
  const AuthException.serverError([String? details])
      : this('server_error', details ?? 'Server error occurred');

  /// Unknown error
  const AuthException.unknown([dynamic error])
      : this('unknown_error', 'An unknown error occurred', error);

  @override
  String toString() => 'AuthException($code): $message';
}

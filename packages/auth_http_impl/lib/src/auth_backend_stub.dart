/// Component: StubAuthBackendClient
/// Created by: CENT-003 Implementation
/// Purpose: Deterministic OTP backend stub for passwordless auth hardening
/// Last updated: 2025-11-25 (CENT-004: MFA stub support)

import 'dart:math';

import 'package:auth_shims/auth_shims.dart';

import 'auth_backend_client.dart';

/// Function that returns the current time for testability
typedef Clock = DateTime Function();
/// Function that generates OTP codes for testability
typedef OtpGenerator = String Function();

/// Configuration for the passwordless auth stub backend.
class StubAuthBackendConfig {
  StubAuthBackendConfig({
    Duration? otpTtl,
    Duration? resendCooldown,
    Duration? throttleWindow,
    int maxRequestsPerWindow = 5,
    int maxVerifyAttempts = 5,
    Duration? sessionTtl,
    Clock? now,
    OtpGenerator? otpGenerator,
  })  : otpTtl = otpTtl ?? const Duration(minutes: 2),
        resendCooldown = resendCooldown ?? const Duration(seconds: 45),
        throttleWindow = throttleWindow ?? const Duration(minutes: 5),
        sessionTtl = sessionTtl ?? const Duration(hours: 2),
        now = now ?? _defaultClock,
        otpGenerator = otpGenerator ?? _defaultOtpGenerator,
        maxRequestsPerWindow = maxRequestsPerWindow < 1 ? 1 : maxRequestsPerWindow,
        maxVerifyAttempts = maxVerifyAttempts < 1 ? 1 : maxVerifyAttempts;

  final Duration otpTtl;
  final Duration resendCooldown;
  final Duration throttleWindow;
  final int maxRequestsPerWindow;
  final int maxVerifyAttempts;
  final Duration sessionTtl;
  final Clock now;
  final OtpGenerator otpGenerator;

  static DateTime _defaultClock() => DateTime.now().toUtc();

  static String _defaultOtpGenerator() {
    final random = Random.secure();
    final code = random.nextInt(900000) + 100000;
    return code.toString();
  }
}

/// In-memory OTP backend used while the real API is unavailable.
class StubAuthBackendClient implements AuthBackendClient {
  StubAuthBackendClient({StubAuthBackendConfig? config})
      : _config = config ?? StubAuthBackendConfig(),
        _random = Random.secure();

  final StubAuthBackendConfig _config;
  final Random _random;

  final Map<String, _PendingOtp> _pendingOtps = {};
  final Map<String, _SessionRecord> _sessions = {};
  final Map<String, List<DateTime>> _requestHistory = {};

  @override
  Future<void> requestOtp(PhoneNumber phoneNumber) async {
    final now = _config.now();
    _enforceRateLimits(phoneNumber.e164, now);

    final otpCode = _config.otpGenerator();
    _pendingOtps[phoneNumber.e164] = _PendingOtp(
      code: otpCode,
      expiresAt: now.add(_config.otpTtl),
    );

    final history = _requestHistory.putIfAbsent(phoneNumber.e164, () => []);
    history.add(now);
  }

  @override
  Future<AuthSession> verifyOtp({
    required PhoneNumber phoneNumber,
    required OtpCode code,
  }) async {
    final pending = _pendingOtps[phoneNumber.e164];
    if (pending == null) {
      throw const AuthException.otpVerificationFailed();
    }

    final now = _config.now();
    if (now.isAfter(pending.expiresAt)) {
      _pendingOtps.remove(phoneNumber.e164);
      throw const AuthException.otpExpired();
    }

    if (pending.failedAttempts >= _config.maxVerifyAttempts) {
      _pendingOtps.remove(phoneNumber.e164);
      throw const AuthException(
        'too_many_attempts',
        'Too many incorrect codes. Request a new OTP.',
      );
    }

    if (pending.code != code.value) {
      pending.failedAttempts += 1;
      throw const AuthException.otpVerificationFailed();
    }

    _pendingOtps.remove(phoneNumber.e164);
    final session = _createSession(phoneNumber.e164, now);
    if (session.refreshToken != null) {
      _sessions[session.refreshToken!] = _SessionRecord(
        session: session,
        issuedAt: now,
      );
    }
    return session;
  }

  @override
  Future<void> logout(AuthSession session) async {
    final refresh = session.refreshToken;
    if (refresh != null) {
      _sessions.remove(refresh);
    }
  }

  @override
  Future<AuthSession> refreshSession(String refreshToken) async {
    final record = _sessions[refreshToken];
    if (record == null) {
      throw const AuthException.sessionExpired();
    }

    final now = _config.now();
    final updatedSession = AuthSession(
      accessToken: _generateToken(prefix: 'access'),
      refreshToken: refreshToken,
      expiresAt: now.add(_config.sessionTtl),
      user: record.session.user,
    );
    _sessions[refreshToken] = _SessionRecord(
      session: updatedSession,
      issuedAt: now,
    );
    return updatedSession;
  }

  /// Testing helper to inspect the last OTP generated for a phone number.
  String? debugPeekLatestOtp(String phoneE164) {
    return _pendingOtps[phoneE164]?.code;
  }

  // ---------------------------------------------------------------------------
  // MFA/2FA Stub Implementation (CENT-004)
  // ---------------------------------------------------------------------------

  final Map<String, _MfaChallengeRecord> _mfaChallenges = {};

  /// Stub: Whether to require MFA (configurable for testing).
  bool stubMfaRequired = false;

  /// Stub: Available MFA methods when required.
  List<MfaMethodType> stubAllowedMethods = [MfaMethodType.sms, MfaMethodType.totp];

  @override
  Future<MfaRequirement> getMfaRequirement({
    required String accessToken,
    required String action,
  }) async {
    // Stub returns MFA requirement based on config
    if (!stubMfaRequired) {
      return const MfaRequirement.notRequired();
    }

    return MfaRequirement(
      required: true,
      allowedMethods: stubAllowedMethods,
      reasonCode: 'stub_test',
      riskContext: MfaRiskContext.standardLogin,
    );
  }

  @override
  Future<MfaChallenge> startMfaChallenge({
    required String accessToken,
    required MfaMethodType method,
    required String action,
  }) async {
    final now = _config.now();
    final challengeId = 'mfa_challenge_${_random.nextInt(1 << 32)}_${now.millisecondsSinceEpoch}';
    final code = _config.otpGenerator();

    final challenge = _MfaChallengeRecord(
      challengeId: challengeId,
      code: code,
      method: method,
      expiresAt: now.add(const Duration(minutes: 5)),
    );

    _mfaChallenges[challengeId] = challenge;

    return MfaChallenge(
      challengeId: challengeId,
      method: method,
      expiresAt: challenge.expiresAt,
      retryLimit: _MfaChallengeRecord.maxAttempts,
      attemptsRemaining: _MfaChallengeRecord.maxAttempts - challenge.failedAttempts,
      maskedDestination: method == MfaMethodType.sms ? '+49***890' : '***@test.com',
    );
  }

  @override
  Future<MfaVerificationResult> verifyMfaCode({
    required String challengeId,
    required String code,
  }) async {
    final challenge = _mfaChallenges[challengeId];
    if (challenge == null) {
      return const MfaVerificationResult.failed(
        errorCode: 'invalid_challenge',
        message: 'Invalid or expired challenge',
      );
    }

    final now = _config.now();
    if (now.isAfter(challenge.expiresAt)) {
      _mfaChallenges.remove(challengeId);
      return const MfaVerificationResult.failed(
        errorCode: 'challenge_expired',
        message: 'Challenge has expired',
      );
    }

    if (challenge.isLocked) {
      return MfaVerificationResult.locked(
        message: 'Too many failed attempts',
        lockoutEndTime: now.add(const Duration(minutes: 15)),
      );
    }

    if (challenge.code != code) {
      challenge.failedAttempts += 1;
      if (challenge.isLocked) {
        return MfaVerificationResult.locked(
          message: 'Too many failed attempts. Account temporarily locked.',
          lockoutEndTime: now.add(const Duration(minutes: 15)),
        );
      }
      return MfaVerificationResult.failed(
        errorCode: 'invalid_code',
        message: 'Invalid verification code',
        attemptsRemaining: _MfaChallengeRecord.maxAttempts - challenge.failedAttempts,
      );
    }

    // Success - remove challenge
    _mfaChallenges.remove(challengeId);
    return const MfaVerificationResult.success();
  }

  /// Testing helper to inspect the last MFA code generated for a challenge.
  String? debugPeekMfaCode(String challengeId) {
    return _mfaChallenges[challengeId]?.code;
  }

  /// Testing helper to set MFA requirement state.
  void debugSetMfaRequired(bool required, {List<MfaMethodType>? methods}) {
    stubMfaRequired = required;
    if (methods != null) {
      stubAllowedMethods = methods;
    }
  }

  void _enforceRateLimits(String phoneE164, DateTime now) {
    final history = _requestHistory.putIfAbsent(phoneE164, () => []);
    history.removeWhere(
      (timestamp) => now.difference(timestamp) > _config.throttleWindow,
    );

    if (history.isNotEmpty) {
      final lastRequest = history.last;
      final timeSinceLast = now.difference(lastRequest);
      if (timeSinceLast < _config.resendCooldown) {
        final remaining = _config.resendCooldown - timeSinceLast;
        throw AuthException(
          'rate_limited',
          'Please wait ${remaining.inSeconds}s before requesting another code.',
        );
      }
    }

    if (history.length >= _config.maxRequestsPerWindow) {
      throw const AuthException(
        'rate_limited',
        'Too many OTP requests. Try again later.',
      );
    }
  }

  AuthSession _createSession(String phoneE164, DateTime issuedAt) {
    final refreshToken = _generateToken(prefix: 'refresh');
    return AuthSession(
      accessToken: _generateToken(prefix: 'access'),
      refreshToken: refreshToken,
      expiresAt: issuedAt.add(_config.sessionTtl),
      user: AuthUser(
        id: 'stub_${phoneE164}_$issuedAt',
        phoneNumber: phoneE164,
        displayName: 'Test User',
        metadata: const {'source': 'stub'},
      ),
    );
  }

  String _generateToken({required String prefix}) {
    return '${prefix}_${_random.nextInt(1 << 32)}_${_config.now().millisecondsSinceEpoch}';
  }
}

class _PendingOtp {
  _PendingOtp({
    required this.code,
    required this.expiresAt,
  });

  final String code;
  final DateTime expiresAt;
  int failedAttempts = 0;
}

class _SessionRecord {
  _SessionRecord({
    required this.session,
    required this.issuedAt,
  });

  final AuthSession session;
  final DateTime issuedAt;
}

class _MfaChallengeRecord {
  _MfaChallengeRecord({
    required this.challengeId,
    required this.code,
    required this.method,
    required this.expiresAt,
  });

  final String challengeId;
  final String code;
  final MfaMethodType method;
  final DateTime expiresAt;
  static const int maxAttempts = 3;
  int failedAttempts = 0;

  bool get isLocked => failedAttempts >= maxAttempts;
}


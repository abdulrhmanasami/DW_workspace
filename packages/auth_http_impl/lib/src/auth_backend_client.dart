// Auth Backend Client Implementation
// Created by: CEN-AUTH001 Implementation
// Purpose: HTTP client for authentication backend communication
// Last updated: 2025-11-25 (CENT-004: 2FA/MFA support)

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:auth_shims/auth_shims.dart';
import 'package:foundation_shims/foundation_shims.dart';

/// HTTP-based implementation of authentication backend client
abstract class AuthBackendClient {
  Future<void> requestOtp(PhoneNumber phoneNumber);
  Future<AuthSession> verifyOtp({
    required PhoneNumber phoneNumber,
    required OtpCode code,
  });
  Future<void> logout(AuthSession session);
  Future<AuthSession> refreshSession(String refreshToken);

  // MFA/2FA methods (CENT-004)
  Future<MfaRequirement> getMfaRequirement({
    required String accessToken,
    required String action,
  });
  Future<MfaChallenge> startMfaChallenge({
    required String accessToken,
    required MfaMethodType method,
    required String action,
  });
  Future<MfaVerificationResult> verifyMfaCode({
    required String challengeId,
    required String code,
  });
}

/// HTTP implementation using existing network infrastructure
class HttpAuthBackendClient implements AuthBackendClient {
  HttpAuthBackendClient({required ConfigManager configManager})
      : _configManager = configManager;

  final ConfigManager _configManager;

  /// Resolve the base API URL from the injected configuration.
  String get _baseUrl {
    // Try auth-specific URL first, fallback to general API base URL
    final authUrl = _configManager.getString('auth.baseUrl') ?? '';
    final preferred = authUrl.isNotEmpty ? authUrl : _configManager.apiBaseUrl;
    final baseUrl =
        preferred.isNotEmpty ? preferred : 'https://api.deliveryways.com';
    return baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
  }

  /// Get authorization headers for authenticated requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  @override
  Future<void> requestOtp(PhoneNumber phoneNumber) async {
    final uri = Uri.parse('$_baseUrl/api/v1/auth/otp/request');

    try {
      final response = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode({
          'phone': phoneNumber.e164,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw _handleErrorResponse(response);
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException.networkError('Failed to request OTP: $e');
    }
  }

  @override
  Future<AuthSession> verifyOtp({
    required PhoneNumber phoneNumber,
    required OtpCode code,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/v1/auth/otp/verify');

    try {
      final response = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode({
          'phone': phoneNumber.e164,
          'code': code.value,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return _parseAuthSession(data);
      } else {
        throw _handleErrorResponse(response);
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException.networkError('Failed to verify OTP: $e');
    }
  }

  @override
  Future<void> logout(AuthSession session) async {
    final uri = Uri.parse('$_baseUrl/api/v1/auth/logout');

    try {
      final response = await http.post(
        uri,
        headers: {
          ..._headers,
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );

      // Logout is best-effort, don't throw on failure
      if (response.statusCode != 200 && response.statusCode != 204) {
        // Best-effort: swallow failures to avoid impacting the UX.
      }
    } catch (e) {
      // Don't throw - logout should not fail the user experience
    }
  }

  @override
  Future<AuthSession> refreshSession(String refreshToken) async {
    final uri = Uri.parse('$_baseUrl/api/v1/auth/refresh');

    try {
      final response = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode({
          'refresh_token': refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return _parseAuthSession(data);
      } else {
        throw _handleErrorResponse(response);
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException.networkError('Failed to refresh session: $e');
    }
  }

  /// Parse authentication session from API response
  AuthSession _parseAuthSession(Map<String, dynamic> data) {
    final userData = data['user'] as Map<String, dynamic>;
    final tokens = data['tokens'] as Map<String, dynamic>;

    final user = AuthUser(
      id: userData['id'] as String,
      phoneNumber: userData['phone_number'] as String?,
      displayName: userData['display_name'] as String?,
      avatarUrl: userData['avatar_url'] as String?,
      metadata: userData['metadata'] as Map<String, dynamic>? ?? {},
    );

    final expiresAt = tokens['expires_at'] != null
        ? DateTime.parse(tokens['expires_at'] as String)
        : null;

    return AuthSession(
      accessToken: tokens['access_token'] as String,
      refreshToken: tokens['refresh_token'] as String?,
      expiresAt: expiresAt,
      user: user,
    );
  }

  /// Handle API error responses
  AuthException _handleErrorResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final errorCode = data['error'] as String? ?? 'unknown_error';
      final errorMessage = data['message'] as String? ?? 'Unknown error';

      switch (errorCode) {
        case 'invalid_phone':
          return const AuthException.invalidPhone();
        case 'invalid_otp':
          return const AuthException.invalidOtp();
        case 'otp_expired':
          return const AuthException.otpExpired();
        case 'otp_verification_failed':
          return const AuthException.otpVerificationFailed();
        case 'session_expired':
          return const AuthException.sessionExpired();
        default:
          return AuthException(errorCode, errorMessage);
      }
    } catch (e) {
      // If response body is not valid JSON
      return AuthException.serverError('Server error: ${response.statusCode}');
    }
  }

  // ---------------------------------------------------------------------------
  // MFA/2FA Implementation (CENT-004)
  // ---------------------------------------------------------------------------

  @override
  Future<MfaRequirement> getMfaRequirement({
    required String accessToken,
    required String action,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/v1/auth/mfa/requirement');

    try {
      final response = await http.post(
        uri,
        headers: {
          ..._headers,
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'action': action,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return _parseMfaRequirement(data);
      } else {
        throw _handleErrorResponse(response);
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException.networkError('Failed to evaluate MFA requirement: $e');
    }
  }

  @override
  Future<MfaChallenge> startMfaChallenge({
    required String accessToken,
    required MfaMethodType method,
    required String action,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/v1/auth/mfa/challenge');

    try {
      final response = await http.post(
        uri,
        headers: {
          ..._headers,
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'method': method.name,
          'action': action,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return _parseMfaChallenge(data);
      } else {
        throw _handleErrorResponse(response);
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException.networkError('Failed to start MFA challenge: $e');
    }
  }

  @override
  Future<MfaVerificationResult> verifyMfaCode({
    required String challengeId,
    required String code,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/v1/auth/mfa/verify');

    try {
      final response = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode({
          'challenge_id': challengeId,
          'code': code,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return _parseMfaVerificationResult(data);
      } else {
        // Parse error response but still return a result object
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return _parseMfaVerificationResult(data);
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException.networkError('Failed to verify MFA code: $e');
    }
  }

  /// Parse MFA requirement from API response
  MfaRequirement _parseMfaRequirement(Map<String, dynamic> data) {
    final required = data['required'] as bool? ?? false;
    final methodsRaw = data['allowed_methods'] as List<dynamic>?;
    final reasonCode = data['reason_code'] as String?;

    final methods = <MfaMethodType>[];
    if (methodsRaw != null) {
      for (final m in methodsRaw) {
        final method = _parseMethodType(m as String);
        if (method != null) {
          methods.add(method);
        }
      }
    }

    return MfaRequirement(
      required: required,
      allowedMethods: methods,
      reasonCode: reasonCode,
      riskContext: _parseRiskContext(reasonCode),
    );
  }

  /// Parse MFA challenge from API response
  MfaChallenge _parseMfaChallenge(Map<String, dynamic> data) {
    final challengeId = data['challenge_id'] as String;
    final methodRaw = data['method'] as String;
    final expiresAtRaw = data['expires_at'] as String;

    return MfaChallenge(
      challengeId: challengeId,
      method: _parseMethodType(methodRaw) ?? MfaMethodType.sms,
      expiresAt: DateTime.parse(expiresAtRaw),
      retryLimit: data['retry_limit'] as int?,
      attemptsRemaining: data['attempts_remaining'] as int?,
      maskedDestination: data['masked_destination'] as String?,
    );
  }

  /// Parse MFA verification result from API response
  MfaVerificationResult _parseMfaVerificationResult(Map<String, dynamic> data) {
    final success = data['success'] as bool? ?? false;
    final locked = data['locked'] as bool? ?? false;

    if (success) {
      return const MfaVerificationResult.success();
    }

    if (locked) {
      final lockoutEndTimeRaw = data['lockout_end_time'] as String?;
      return MfaVerificationResult.locked(
        message: data['message'] as String?,
        lockoutEndTime: lockoutEndTimeRaw != null
            ? DateTime.parse(lockoutEndTimeRaw)
            : null,
      );
    }

    return MfaVerificationResult.failed(
      errorCode: data['error_code'] as String?,
      message: data['message'] as String?,
      attemptsRemaining: data['attempts_remaining'] as int?,
    );
  }

  /// Parse MFA method type from string
  MfaMethodType? _parseMethodType(String value) {
    switch (value.toLowerCase()) {
      case 'sms':
        return MfaMethodType.sms;
      case 'totp':
        return MfaMethodType.totp;
      case 'email':
        return MfaMethodType.email;
      case 'push':
        return MfaMethodType.push;
      default:
        return null;
    }
  }

  /// Parse risk context from reason code
  MfaRiskContext? _parseRiskContext(String? reasonCode) {
    if (reasonCode == null) return null;
    switch (reasonCode.toLowerCase()) {
      case 'new_device':
        return MfaRiskContext.newDevice;
      case 'sensitive_operation':
        return MfaRiskContext.sensitiveOperation;
      case 'high_value_transaction':
        return MfaRiskContext.highValueTransaction;
      case 'account_recovery_change':
        return MfaRiskContext.accountRecoveryChange;
      case 'elevated_risk':
        return MfaRiskContext.elevatedRisk;
      case 'dsr_operation':
        return MfaRiskContext.dsrOperation;
      default:
        return MfaRiskContext.standardLogin;
    }
  }
}

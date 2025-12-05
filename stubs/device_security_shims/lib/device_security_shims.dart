/// Device security shims providing biometric authentication helpers.
/// Created by: CENT-003 Implementation
/// Purpose: Biometric authenticator backed by local_auth (outside app/lib)
/// Last updated: 2025-11-25
library device_security_shims;

import 'dart:async';

import 'dart:convert';

import 'package:auth_shims/auth_shims.dart';
import 'package:flutter/services.dart';
// Note: error_codes removed in local_auth 2.x+; error codes are strings
import 'package:local_auth/local_auth.dart' as local_auth;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stub implementation of device security checks (kept for compatibility).
class DeviceSecurityService {
  static final DeviceSecurityService _instance =
      DeviceSecurityService._internal();
  factory DeviceSecurityService() => _instance;
  DeviceSecurityService._internal();

  /// Check if device is rooted/jailbroken.
  Future<bool> isDeviceSecure() async {
    return true;
  }

  /// Check if app is running in emulator.
  Future<bool> isRunningOnEmulator() async {
    return false;
  }

  /// Get device security score (0-100).
  Future<int> getSecurityScore() async {
    return 85;
  }
}

/// Platform-specific security implementations (stubs).
class AndroidSecurity {
  static Future<bool> isDeviceRooted() async {
    return false;
  }
}

class IOSSecurity {
  static Future<bool> isDeviceJailbroken() async {
    return false;
  }
}

/// Biometric authenticator backed by `local_auth`.
class DeviceBiometricAuthenticator implements BiometricAuthenticator {
  DeviceBiometricAuthenticator({
    local_auth.LocalAuthentication? localAuthentication,
  }) : _localAuth = localAuthentication ?? local_auth.LocalAuthentication();

  final local_auth.LocalAuthentication _localAuth;
  static const String _defaultReason = 'Authenticate to continue';

  @override
  Future<BiometricSupportStatus> getSupportStatus() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final supported = await _localAuth.isDeviceSupported();
      final nativeTypes = supported
          ? await _localAuth.getAvailableBiometrics()
          : <local_auth.BiometricType>[];
      final mapped = nativeTypes.map(_mapBiometricType).toList();
      final canAuthenticate = canCheck && supported && mapped.isNotEmpty;

      return BiometricSupportStatus(
        canAuthenticate: canAuthenticate,
        isDeviceSupported: supported,
        availableTypes: mapped,
      );
    } on PlatformException {
      return const BiometricSupportStatus.unavailable();
    }
  }

  @override
  Future<BiometricAuthResult> authenticate({
    String? localizedReason,
    bool biometricsOnly = true,
  }) async {
    final status = await getSupportStatus();
    if (!status.canAuthenticate) {
      return const BiometricAuthResult(BiometricAuthOutcome.unavailable);
    }

    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason ?? _defaultReason,
        options: local_auth.AuthenticationOptions(
          biometricOnly: biometricsOnly,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      return didAuthenticate
          ? const BiometricAuthResult.success()
          : const BiometricAuthResult.failed();
    } on PlatformException catch (error) {
      // Error codes from local_auth plugin
      const userCanceled = 'UserCanceled';
      const userFallback = 'UserFallback';
      const systemCancel = 'SystemCancel';
      const notAvailable = 'NotAvailable';
      const notEnrolled = 'NotEnrolled';

      if (error.code == userCanceled ||
          error.code == userFallback ||
          error.code == systemCancel) {
        return const BiometricAuthResult.canceled();
      }

      if (error.code == notAvailable ||
          error.code == notEnrolled) {
        return BiometricAuthResult(
          BiometricAuthOutcome.unavailable,
          message: error.message,
        );
      }

      return BiometricAuthResult(
        BiometricAuthOutcome.error,
        message: error.message,
      );
    }
  }

  BiometricType _mapBiometricType(local_auth.BiometricType type) {
    switch (type) {
      case local_auth.BiometricType.face:
      case local_auth.BiometricType.strong:
        return BiometricType.face;
      case local_auth.BiometricType.fingerprint:
      case local_auth.BiometricType.weak:
        return BiometricType.fingerprint;
      case local_auth.BiometricType.iris:
        return BiometricType.iris;
    }
  }
}

/// Abstract interface for secure session storage operations.
/// Used to persist and retrieve identity sessions securely.
abstract class SessionStorageShim {
  /// Save an identity session to secure storage.
  Future<void> saveSession(IdentitySession session);

  /// Load an identity session from secure storage.
  /// Returns null if no session is stored.
  Future<IdentitySession?> loadSession();

  /// Clear the stored session from secure storage.
  Future<void> clearSession();
}

/// Flutter Secure Storage implementation of SessionStorageShim.
/// Stores identity sessions as JSON in encrypted storage.
class FlutterSecureSessionStorage implements SessionStorageShim {
  FlutterSecureSessionStorage({
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  /// Storage key for the identity session
  static const String _sessionKey = 'dw.identity.session';

  static const _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  static const _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  @override
  Future<void> saveSession(IdentitySession session) async {
    try {
      final sessionJson = jsonEncode(_sessionToJson(session));
      await _secureStorage.write(
        key: _sessionKey,
        value: sessionJson,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
    } catch (e) {
      // Handle storage errors gracefully
      rethrow;
    }
  }

  @override
  Future<IdentitySession?> loadSession() async {
    try {
      final sessionJson = await _secureStorage.read(
        key: _sessionKey,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );

      if (sessionJson == null || sessionJson.isEmpty) {
        return null;
      }

      final sessionData = jsonDecode(sessionJson) as Map<String, dynamic>;
      return _sessionFromJson(sessionData);
    } catch (e) {
      // Handle storage errors gracefully - return null on failure
      return null;
    }
  }

  @override
  Future<void> clearSession() async {
    try {
      await _secureStorage.delete(
        key: _sessionKey,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
    } catch (e) {
      // Handle storage errors gracefully
    }
  }

  /// Convert IdentitySession to JSON
  Map<String, dynamic> _sessionToJson(IdentitySession session) {
    return {
      'status': session.status.name,
      'user': session.user != null ? _userToJson(session.user!) : null,
      'tokens': session.tokens != null ? _tokensToJson(session.tokens!) : null,
      'isRefreshing': session.isRefreshing,
    };
  }

  /// Convert JSON to IdentitySession
  IdentitySession _sessionFromJson(Map<String, dynamic> json) {
    final status = AuthStatus.values.firstWhere(
      (s) => s.name == json['status'] as String,
      orElse: () => AuthStatus.unknown,
    );

    return IdentitySession(
      status: status,
      user: json['user'] != null ? _userFromJson(json['user'] as Map<String, dynamic>) : null,
      tokens: json['tokens'] != null ? _tokensFromJson(json['tokens'] as Map<String, dynamic>) : null,
      isRefreshing: json['isRefreshing'] as bool? ?? false,
    );
  }

  /// Convert IdentityUser to JSON
  Map<String, dynamic> _userToJson(IdentityUser user) {
    return {
      'userId': user.userId,
      'phoneNumber': user.phoneNumber,
      'displayName': user.displayName,
      'countryCode': user.countryCode,
    };
  }

  /// Convert JSON to IdentityUser
  IdentityUser _userFromJson(Map<String, dynamic> json) {
    return IdentityUser(
      userId: json['userId'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      displayName: json['displayName'] as String?,
      countryCode: json['countryCode'] as String?,
    );
  }

  /// Convert AuthTokens to JSON
  Map<String, dynamic> _tokensToJson(AuthTokens tokens) {
    return {
      'accessToken': tokens.accessToken,
      'refreshToken': tokens.refreshToken,
      'accessTokenExpiresAt': tokens.accessTokenExpiresAt?.toIso8601String(),
    };
  }

  /// Convert JSON to AuthTokens
  AuthTokens _tokensFromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      accessTokenExpiresAt: json['accessTokenExpiresAt'] != null
          ? DateTime.parse(json['accessTokenExpiresAt'] as String)
          : null,
    );
  }
}

/// Creates default session storage instance
SessionStorageShim createSessionStorageShim() {
  return FlutterSecureSessionStorage();
}

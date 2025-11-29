/// Device security shims providing biometric authentication helpers.
/// Created by: CENT-003 Implementation
/// Purpose: Biometric authenticator backed by local_auth (outside app/lib)
/// Last updated: 2025-11-25
library device_security_shims;

import 'dart:async';

import 'package:auth_shims/auth_shims.dart';
import 'package:flutter/services.dart';
// Note: error_codes removed in local_auth 2.x+; error codes are strings
import 'package:local_auth/local_auth.dart' as local_auth;

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
      default:
        return BiometricType.unknown;
    }
  }
}

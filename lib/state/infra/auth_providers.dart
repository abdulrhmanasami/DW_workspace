// Component: Auth Providers
// Created by: CENT-003 Implementation
// Purpose: Wire HttpAuthService + storage via Riverpod for passwordless OTP auth
// Last updated: 2025-11-25

import 'dart:async';

import 'package:auth_http_impl/auth_http_impl.dart';
import 'package:auth_shims/auth_shims.dart';
import 'package:device_security_shims/device_security_shims.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/config_manager.dart';
import '../../config/feature_flags.dart';

enum PasswordlessBackendFlavor { stub, http }

/// Secure storage-backed repository for persisting auth sessions.
final authSessionRepositoryProvider = Provider<AuthSessionRepository>(
  (ref) => SecureStorageAuthSessionRepository(createAuthSecureStorage()),
);

final biometricAuthenticatorProvider = Provider<BiometricAuthenticator?>((ref) {
  if (!FeatureFlags.enablePasswordlessAuth ||
      !FeatureFlags.enableBiometricAuth) {
    return null;
  }
  return DeviceBiometricAuthenticator();
});

final biometricSupportProvider =
    FutureProvider<BiometricSupportStatus>((ref) async {
  final authenticator = ref.watch(biometricAuthenticatorProvider);
  if (authenticator == null) {
    return const BiometricSupportStatus.unavailable();
  }
  return authenticator.getSupportStatus();
});

/// Select which backend implementation should be used for passwordless auth.
final passwordlessBackendFlavorProvider =
    Provider<PasswordlessBackendFlavor>((ref) {
  if (!FeatureFlags.requiresBackend) {
    return PasswordlessBackendFlavor.stub;
  }
  return PasswordlessBackendFlavor.http;
});

/// Backend client configured via ConfigManager api.baseUrl or stub fallback.
final authBackendClientProvider = Provider<AuthBackendClient>((ref) {
  final flavor = ref.watch(passwordlessBackendFlavorProvider);
  switch (flavor) {
    case PasswordlessBackendFlavor.stub:
      return StubAuthBackendClient();
    case PasswordlessBackendFlavor.http:
      return HttpAuthBackendClient(configManager: ConfigManager.instance);
  }
});

/// Live passwordless AuthService wiring (guarded by feature flag).
final authServiceProvider = Provider<AuthService>((ref) {
  if (!FeatureFlags.enablePasswordlessAuth) {
    throw StateError(
      'Passwordless auth disabled. Flip FeatureFlags.enablePasswordlessAuth to opt-in.',
    );
  }

  final backendClient = ref.watch(authBackendClientProvider);
  final sessionRepository = ref.watch(authSessionRepositoryProvider);
  final biometricAuthenticator = ref.watch(biometricAuthenticatorProvider);
  final requireBiometricUnlock =
      FeatureFlags.enableBiometricAuth && biometricAuthenticator != null;

  final service = HttpAuthService(
    backendClient,
    sessionRepository,
    biometricAuthenticator: biometricAuthenticator,
    requireBiometricUnlock: requireBiometricUnlock,
  );
  unawaited(service.initialize());
  return service;
});

/// Stream provider exposing AuthState broadcasts from HttpAuthService.
final authStateProvider = StreamProvider<AuthState>((ref) {
  if (!FeatureFlags.enablePasswordlessAuth) {
    return Stream<AuthState>.value(const AuthState.unauthenticated());
  }

  final service = ref.watch(authServiceProvider);
  return service.onAuthStateChanged;
});

/// Session storage shim for identity/session persistence.
final sessionStorageShimProvider = Provider<SessionStorageShim>((ref) {
  return createSessionStorageShim();
});


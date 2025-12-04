// HTTP Identity Shim Implementation
// Created by: Track D - Ticket #233 (D-1)
// Purpose: HTTP implementation of IdentityShim interface with token lifecycle
// Last updated: 2025-12-04

import 'dart:async';
import 'package:auth_shims/auth_shims.dart';
import 'package:device_security_shims/device_security_shims.dart';
import 'src/auth_backend_client.dart';

/// HTTP implementation of IdentityShim with real token lifecycle management.
///
/// Track D - Ticket #234 (D-2): Complete implementation with token storage,
/// refresh, and logout functionality using HTTP backend client.
class HttpIdentityShim implements IdentityShim {
  /// Create HTTP identity shim with required dependencies.
  HttpIdentityShim({
    required AuthBackendClient authApiClient,
    required SessionStorageShim storage,
  })  : _client = authApiClient,
        _storage = storage;

  final AuthBackendClient _client;
  final SessionStorageShim _storage;

  final _sessionController = StreamController<IdentitySession>.broadcast();

  IdentitySession _currentSession = const IdentitySession(
    status: AuthStatus.unknown,
    user: null,
    tokens: null,
    isRefreshing: false,
  );

  @override
  Stream<IdentitySession> watchSession() => _sessionController.stream;

  @override
  Future<IdentitySession> loadInitialSession() async {
    try {
      final stored = await _storage.loadSession();
      _currentSession = stored ?? const IdentitySession(
        status: AuthStatus.unauthenticated,
        user: null,
        tokens: null,
        isRefreshing: false,
      );
      _sessionController.add(_currentSession);
      return _currentSession;
    } catch (e) {
      // On storage failure, default to unauthenticated
      _currentSession = const IdentitySession(
        status: AuthStatus.unauthenticated,
        user: null,
        tokens: null,
        isRefreshing: false,
      );
      _sessionController.add(_currentSession);
      return _currentSession;
    }
  }

  @override
  Future<IdentitySession> refreshTokens() async {
    // Check if we have tokens to refresh
    final currentTokens = _currentSession.tokens;
    if (currentTokens == null || !currentTokens.canRefresh) {
      // No refresh token available, return unauthenticated
      _currentSession = const IdentitySession(
        status: AuthStatus.unauthenticated,
        user: null,
        tokens: null,
        isRefreshing: false,
      );
      await _storage.clearSession();
      _sessionController.add(_currentSession);
      return _currentSession;
    }

    try {
      // Set refreshing state
      _currentSession = _currentSession.copyWith(isRefreshing: true);
      _sessionController.add(_currentSession);

      // Call backend refresh endpoint
      final refreshedSession = await _client.refreshSession(currentTokens.refreshToken!);

      // Convert AuthSession to IdentitySession
      final newTokens = AuthTokens(
        accessToken: refreshedSession.accessToken,
        refreshToken: refreshedSession.refreshToken,
        accessTokenExpiresAt: refreshedSession.expiresAt,
      );

      final newUser = IdentityUser(
        userId: refreshedSession.user.id,
        phoneNumber: refreshedSession.user.phoneNumber,
        displayName: refreshedSession.user.displayName,
        countryCode: _extractCountryCode(refreshedSession.user.phoneNumber),
      );

      // Update current session
      _currentSession = IdentitySession(
        status: AuthStatus.authenticated,
        user: newUser,
        tokens: newTokens,
        isRefreshing: false,
      );

      // Save to storage
      await _storage.saveSession(_currentSession);

      // Emit updated session
      _sessionController.add(_currentSession);
      return _currentSession;

    } catch (e) {
      // On refresh failure (401/invalid token), clear session
      _currentSession = const IdentitySession(
        status: AuthStatus.unauthenticated,
        user: null,
        tokens: null,
        isRefreshing: false,
      );
      await _storage.clearSession();
      _sessionController.add(_currentSession);
      return _currentSession;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Call backend logout if we have valid tokens (best effort)
      final currentTokens = _currentSession.tokens;
      if (currentTokens != null && _currentSession.isAuthenticated) {
        final authSession = AuthSession(
          accessToken: currentTokens.accessToken,
          refreshToken: currentTokens.refreshToken,
          expiresAt: currentTokens.accessTokenExpiresAt,
          user: AuthUser(
            id: _currentSession.user!.userId,
            phoneNumber: _currentSession.user!.phoneNumber,
            displayName: _currentSession.user!.displayName,
          ),
        );
        await _client.logout(authSession);
      }
    } catch (e) {
      // Logout is best-effort, don't fail if backend call fails
    }

    // Clear local state and storage
    _currentSession = const IdentitySession(
      status: AuthStatus.unauthenticated,
      user: null,
      tokens: null,
      isRefreshing: false,
    );

    await _storage.clearSession();
    _sessionController.add(_currentSession);
  }

  /// Extract country code from phone number (simple implementation)
  String? _extractCountryCode(String? phoneNumber) {
    if (phoneNumber == null || !phoneNumber.startsWith('+')) {
      return null;
    }

    // Simple extraction: assume country code is 1-3 digits after +
    final match = RegExp(r'^\+(\d{1,3})').firstMatch(phoneNumber);
    return match?.group(1);
  }
}

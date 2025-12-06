// Auth HTTP Implementation
// Created by: CEN-AUTH001 Implementation
// Purpose: HTTP implementation of authentication services
// Last updated: 2025-12-04 (Track D - Ticket #233: HTTP Identity Shim)

import 'dart:async';
import 'dart:convert';

import 'package:auth_shims/auth_shims.dart';
import 'package:foundation_shims/foundation_shims.dart' show ConfigManager;

import 'src/auth_backend_client.dart';
import 'src/auth_storage.dart';

export 'src/auth_backend_client.dart'
    show AuthBackendClient, HttpAuthBackendClient;
export 'src/auth_storage.dart' show AuthSecureStorage, createAuthSecureStorage;

// Identity shim implementation (Track D - Ticket #233)
export 'http_identity_shim.dart' show HttpIdentityShim;

/// HTTP implementation of AuthService
class HttpAuthService implements AuthService {
  HttpAuthService(
    this._backendClient,
    this._sessionRepository, {
    BiometricAuthenticator? biometricAuthenticator,
    bool requireBiometricUnlock = false,
  })  : _biometricAuthenticator = biometricAuthenticator,
        _requireBiometricUnlock = requireBiometricUnlock;

  final AuthBackendClient _backendClient;
  final AuthSessionRepository _sessionRepository;
  final BiometricAuthenticator? _biometricAuthenticator;
  final bool _requireBiometricUnlock;

  final _authStateController = StreamController<AuthState>.broadcast();
  AuthState _currentState = const AuthState.unknown();

  @override
  Future<void> requestOtp(PhoneNumber phoneNumber) async {
    await _backendClient.requestOtp(phoneNumber);
  }

  @override
  Future<AuthSession> verifyOtp({
    required PhoneNumber phoneNumber,
    required OtpCode code,
  }) async {
    final session = await _backendClient.verifyOtp(
      phoneNumber: phoneNumber,
      code: code,
    );

    await _sessionRepository.saveSession(session);
    _updateAuthState(AuthState.authenticated(session));

    return session;
  }

  @override
  Future<void> logout() async {
    try {
      final session = _currentState.session;
      if (session != null) {
        await _backendClient.logout(session);
      } else if (!_requireBiometricUnlock) {
        final storedState = await _sessionRepository.loadAuthState();
        final storedSession = storedState.session;
        if (storedSession != null) {
          await _backendClient.logout(storedSession);
        }
      }
    } finally {
      // Always clear local session, even if backend logout fails
      await _sessionRepository.clearSession();
      _updateAuthState(const AuthState.unauthenticated());
    }
  }

  @override
  Future<AuthSession?> refreshSession() async {
    try {
      final session = _currentState.session;
      if (session == null || session.refreshToken == null) {
        return null;
      }

      final newSession =
          await _backendClient.refreshSession(session.refreshToken!);
      await _sessionRepository.saveSession(newSession);
      _updateAuthState(AuthState.authenticated(newSession));

      return newSession;
    } catch (e) {
      // If refresh fails, clear session
      await _sessionRepository.clearSession();
      _updateAuthState(const AuthState.unauthenticated());
      return null;
    }
  }

  @override
  Future<AuthSession?> getCurrentSession() async {
    if (_currentState.session != null) {
      return _currentState.session;
    }

    if (_requireBiometricUnlock) {
      return null;
    }

    final state = await _sessionRepository.loadAuthState();
    if (state.isAuthenticated) {
      _updateAuthState(state);
    }
    return state.session;
  }

  @override
  Stream<AuthState> get onAuthStateChanged {
    // Emit current state immediately when someone listens
    Future(() => _authStateController.add(_currentState));
    return _authStateController.stream;
  }

  void _updateAuthState(AuthState newState) {
    _currentState = newState;
    _authStateController.add(newState);
  }

  /// Initialize service by loading current auth state.
  Future<void> initialize() async {
    if (_requireBiometricUnlock) {
      _updateAuthState(const AuthState.unauthenticated());
      return;
    }
    try {
      final state = await _sessionRepository.loadAuthState();
      _updateAuthState(state);
    } catch (e) {
      _updateAuthState(const AuthState.error('Failed to load auth state'));
    }
  }

  @override
  Future<bool> unlockStoredSession({String? localizedReason}) async {
    if (!_requireBiometricUnlock) {
      final state = await _sessionRepository.loadAuthState();
      if (state.isAuthenticated) {
        _updateAuthState(state);
        return true;
      }
      return false;
    }

    final authenticator = _biometricAuthenticator;
    if (authenticator == null) {
      return false;
    }

    final support = await authenticator.getSupportStatus();
    if (!support.canAuthenticate) {
      return false;
    }

    final result = await authenticator.authenticate(
      localizedReason: localizedReason ?? 'Confirm your identity',
      biometricsOnly: true,
    );

    if (!result.isSuccess) {
      return false;
    }

    final state = await _sessionRepository.loadAuthState();
    if (!state.isAuthenticated) {
      return false;
    }

    _updateAuthState(state);
    return true;
  }

  // ---------------------------------------------------------------------------
  // MFA / 2FA Implementation (CENT-004)
  // ---------------------------------------------------------------------------

  @override
  Future<MfaRequirement> evaluateMfaRequirement({
    required AuthSession session,
    required String action,
  }) async {
    return _backendClient.getMfaRequirement(
      accessToken: session.accessToken,
      action: action,
    );
  }

  @override
  Future<MfaChallenge> startMfaChallenge({
    required AuthSession session,
    required MfaMethodType method,
    required String action,
  }) async {
    return _backendClient.startMfaChallenge(
      accessToken: session.accessToken,
      method: method,
      action: action,
    );
  }

  @override
  Future<MfaVerificationResult> verifyMfaCode({
    required String challengeId,
    required String code,
  }) async {
    return _backendClient.verifyMfaCode(
      challengeId: challengeId,
      code: code,
    );
  }
}

/// Secure storage implementation of AuthSessionRepository
class SecureStorageAuthSessionRepository implements AuthSessionRepository {
  SecureStorageAuthSessionRepository(this._storage);

  final AuthSecureStorage _storage;

  static const String _sessionKey = 'auth_session_v1';

  @override
  Future<AuthState> loadAuthState() async {
    try {
      final raw = await _storage.read(_sessionKey);
      if (raw == null) {
        return const AuthState.unauthenticated();
      }

      final session = _decodeSession(raw);
      if (session.isExpired) {
        // Session expired, clear it
        await clearSession();
        return const AuthState.unauthenticated();
      }

      return AuthState.authenticated(session);
    } catch (e) {
      // If there's any error reading/decoding, treat as unauthenticated
      await clearSession();
      return const AuthState.unauthenticated();
    }
  }

  @override
  Future<void> saveSession(AuthSession session) async {
    final raw = _encodeSession(session);
    await _storage.write(_sessionKey, raw);
  }

  @override
  Future<void> clearSession() async {
    await _storage.delete(_sessionKey);
  }

  @override
  Future<bool> hasValidSession() async {
    final state = await loadAuthState();
    return state.isAuthenticated;
  }

  /// Encode AuthSession to JSON string
  String _encodeSession(AuthSession session) {
    return jsonEncode({
      'accessToken': session.accessToken,
      'refreshToken': session.refreshToken,
      'expiresAt': session.expiresAt?.toUtc().toIso8601String(),
      'user': {
        'id': session.user.id,
        'phoneNumber': session.user.phoneNumber,
        'displayName': session.user.displayName,
        'avatarUrl': session.user.avatarUrl,
        'metadata': session.user.metadata,
      },
    });
  }

  /// Decode JSON string to AuthSession
  AuthSession _decodeSession(String raw) {
    final data = jsonDecode(raw) as Map<String, dynamic>;

    final userData = data['user'] as Map<String, dynamic>;
    final user = AuthUser(
      id: userData['id'] as String,
      phoneNumber: userData['phoneNumber'] as String?,
      displayName: userData['displayName'] as String?,
      avatarUrl: userData['avatarUrl'] as String?,
      metadata: userData['metadata'] as Map<String, dynamic>? ?? {},
    );

    final expiresAt = data['expiresAt'] != null
        ? DateTime.parse(data['expiresAt'] as String)
        : null;

    return AuthSession(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String?,
      expiresAt: expiresAt,
      user: user,
    );
  }
}

/// Factory function to create auth service with dependencies
HttpAuthService createHttpAuthService({
  required ConfigManager configManager,
  BiometricAuthenticator? biometricAuthenticator,
  bool requireBiometricUnlock = false,
}) {
  final backendClient = HttpAuthBackendClient(configManager: configManager);
  final secureStorage = createAuthSecureStorage();
  final sessionRepository = SecureStorageAuthSessionRepository(secureStorage);

  return HttpAuthService(
    backendClient,
    sessionRepository,
    biometricAuthenticator: biometricAuthenticator,
    requireBiometricUnlock: requireBiometricUnlock,
  );
}

/// Factory function to create session repository
AuthSessionRepository createAuthSessionRepository() {
  final secureStorage = createAuthSecureStorage();
  return SecureStorageAuthSessionRepository(secureStorage);
}

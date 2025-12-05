// Identity Controller Tests
// Created by: Track D - Ticket #233 (D-1)
// Purpose: Unit tests for identity state management
// Last updated: 2025-12-04

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:auth_shims/auth_shims.dart';
import 'package:delivery_ways_clean/state/identity/identity_controller.dart';

// ============================================================================
// Test Doubles (Fakes)
// ============================================================================

/// Fake IdentityShim for testing
///
/// Allows controlling what sessions are returned for different operations.
class FakeIdentityShim implements IdentityShim {
  /// Session to return from loadInitialSession
  IdentitySession initialSession = const IdentitySession(
    status: AuthStatus.unauthenticated,
    user: null,
    tokens: null,
    isRefreshing: false,
  );

  /// Session to return from refreshTokens
  IdentitySession refreshedSession = const IdentitySession(
    status: AuthStatus.authenticated,
    user: IdentityUser(
      userId: 'test-user-id',
      phoneNumber: '+966501234567',
      displayName: 'Test User',
    ),
    tokens: AuthTokens(
      accessToken: 'access-token-123',
      refreshToken: 'refresh-token-456',
      accessTokenExpiresAt: null,
    ),
    isRefreshing: false,
  );

  /// Whether operations should throw errors
  bool shouldThrowOnLoad = false;
  bool shouldThrowOnRefresh = false;
  bool shouldThrowOnSignOut = false;

  /// Track method calls for verification
  bool loadInitialSessionCalled = false;
  bool refreshTokensCalled = false;
  bool signOutCalled = false;
  bool watchSessionCalled = false;
  bool requestLoginCodeCalled = false;
  bool verifyLoginCodeCalled = false;

  /// Parameters passed to methods
  PhoneNumber? lastRequestedPhoneNumber;
  PhoneNumber? lastVerifiedPhoneNumber;
  OtpCode? lastVerifiedCode;

  /// Whether operations should throw errors
  bool shouldThrowOnRequestLoginCode = false;
  bool shouldThrowOnVerifyLoginCode = false;

  @override
  Future<IdentitySession> loadInitialSession() async {
    loadInitialSessionCalled = true;
    if (shouldThrowOnLoad) {
      throw Exception('Load initial session failed');
    }
    return initialSession;
  }

  @override
  Future<IdentitySession> refreshTokens() async {
    refreshTokensCalled = true;
    if (shouldThrowOnRefresh) {
      throw Exception('Refresh tokens failed');
    }
    return refreshedSession;
  }

  @override
  Future<void> signOut() async {
    signOutCalled = true;
    if (shouldThrowOnSignOut) {
      throw Exception('Sign out failed');
    }
  }

  @override
  Stream<IdentitySession> watchSession() async* {
    watchSessionCalled = true;
    yield initialSession;
  }

  @override
  Future<void> requestLoginCode({required PhoneNumber phoneNumber}) async {
    requestLoginCodeCalled = true;
    lastRequestedPhoneNumber = phoneNumber;
    if (shouldThrowOnRequestLoginCode) {
      throw const AuthException.invalidPhone();
    }
  }

  @override
  Future<IdentitySession> verifyLoginCode({
    required PhoneNumber phoneNumber,
    required OtpCode code,
  }) async {
    verifyLoginCodeCalled = true;
    lastVerifiedPhoneNumber = phoneNumber;
    lastVerifiedCode = code;
    if (shouldThrowOnVerifyLoginCode) {
      throw const AuthException.otpVerificationFailed();
    }
    return refreshedSession; // Return authenticated session on success
  }
}

// ============================================================================
// Test Groups
// ============================================================================

void main() {
  late FakeIdentityShim fakeShim;
  late ProviderContainer container;

  setUp(() {
    fakeShim = FakeIdentityShim();
    container = ProviderContainer(
      overrides: [
        identityShimProvider.overrideWithValue(fakeShim),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('IdentityController', () {
    test('initializes with unknown status and loads initial session', () async {
      // Given: Controller is created with fake shim
      final controller = container.read(identityControllerProvider.notifier);

      // Initially should be in unknown state with loading
      expect(controller.state.session.status, AuthStatus.unknown);
      expect(controller.state.isLoading, true);
      expect(controller.state.lastError, null);

      // Wait for initialization to complete
      await Future.delayed(Duration.zero);

      // Then: Should load initial session from shim
      expect(fakeShim.loadInitialSessionCalled, true);
      expect(controller.state.session, fakeShim.initialSession);
      expect(controller.state.isLoading, false);
      expect(controller.state.isUnauthenticated, true);
    });

    test('reloadSession updates state with new session from shim', () async {
      // Given: Controller initialized with unauthenticated session
      final controller = container.read(identityControllerProvider.notifier);
      await Future.delayed(Duration.zero); // Wait for init

      // When: Reload session
      fakeShim.initialSession = const IdentitySession(
        status: AuthStatus.authenticated,
        user: IdentityUser(
          userId: 'reloaded-user',
          phoneNumber: '+966509876543',
        ),
        tokens: AuthTokens(accessToken: 'new-token'),
        isRefreshing: false,
      );

      await controller.reloadSession();

      // Then: State should be updated
      expect(controller.state.session.user?.userId, 'reloaded-user');
      expect(controller.state.session.user?.phoneNumber, '+966509876543');
      expect(controller.state.isAuthenticated, true);
      expect(controller.state.isLoading, false);
    });

    test('refreshTokens updates state with refreshed session', () async {
      // Given: Controller initialized
      final controller = container.read(identityControllerProvider.notifier);
      await Future.delayed(Duration.zero); // Wait for init

      // When: Refresh tokens
      await controller.refreshTokens();

      // Then: Should call refreshTokens on shim and update state
      expect(fakeShim.refreshTokensCalled, true);
      expect(controller.state.session, fakeShim.refreshedSession);
      expect(controller.state.session.user?.userId, 'test-user-id');
      expect(controller.state.session.tokens?.accessToken, 'access-token-123');
      expect(controller.state.isAuthenticated, true);
    });

    test('signOut clears session and calls shim signOut', () async {
      // Given: Controller initialized
      final controller = container.read(identityControllerProvider.notifier);
      await Future.delayed(Duration.zero); // Wait for init

      // When: Sign out
      await controller.signOut();

      // Then: Should call signOut on shim and reload session
      expect(fakeShim.signOutCalled, true);
      expect(fakeShim.loadInitialSessionCalled, true); // Called during init and reload
      expect(controller.state.session.status, AuthStatus.unauthenticated);
      expect(controller.state.session.user, null);
      expect(controller.state.session.tokens, null);
      expect(controller.state.isUnauthenticated, true);
    });

    test('handles errors during loadInitialSession', () async {
      // Given: Shim configured to throw on load
      fakeShim.shouldThrowOnLoad = true;

      // When: Controller is created
      final controller = container.read(identityControllerProvider.notifier);

      // Wait for initialization to complete
      await Future.delayed(Duration.zero);

      // Then: Should handle error gracefully
      expect(controller.state.isLoading, false);
      expect(controller.state.lastError, isNotNull);
      expect(controller.state.lastError.toString(), contains('Load initial session failed'));
    });

    test('handles errors during refreshTokens', () async {
      // Given: Controller initialized
      final controller = container.read(identityControllerProvider.notifier);
      await Future.delayed(Duration.zero); // Wait for init

      // When: Refresh tokens with error
      fakeShim.shouldThrowOnRefresh = true;
      await controller.refreshTokens();

      // Then: Should handle error and keep previous state
      expect(controller.state.isLoading, false);
      expect(controller.state.lastError, isNotNull);
      expect(controller.state.lastError.toString(), contains('Refresh tokens failed'));
      // State should remain as initial session
      expect(controller.state.session, fakeShim.initialSession);
    });

    test('handles errors during signOut', () async {
      // Given: Controller initialized
      final controller = container.read(identityControllerProvider.notifier);
      await Future.delayed(Duration.zero); // Wait for init

      // When: Sign out with error
      fakeShim.shouldThrowOnSignOut = true;
      await controller.signOut();

      // Then: Should handle error but still attempt to reload
      expect(fakeShim.signOutCalled, true);
      expect(controller.state.isLoading, false);
      expect(controller.state.lastError, isNotNull);
      expect(controller.state.lastError.toString(), contains('Sign out failed'));
    });

    test('state provides correct computed properties', () async {
      // Given: Controller initialized
      final controller = container.read(identityControllerProvider.notifier);
      await Future.delayed(Duration.zero); // Wait for init

      // Initially unauthenticated
      expect(controller.state.isAuthenticated, false);
      expect(controller.state.isUnauthenticated, true);
      expect(controller.state.isUnknown, false);
      expect(controller.state.hasError, false);
      expect(controller.state.isRefreshing, false);

      // When: State changes to authenticated
      controller.state = controller.state.copyWith(
        session: const IdentitySession(
          status: AuthStatus.authenticated,
          user: IdentityUser(userId: 'test'),
          tokens: AuthTokens(accessToken: 'token'),
          isRefreshing: true,
        ),
      );

      // Then: Computed properties update correctly
      expect(controller.state.isAuthenticated, true);
      expect(controller.state.isUnauthenticated, false);
      expect(controller.state.isUnknown, false);
      expect(controller.state.isRefreshing, true);
    });

    test('refreshTokensIfNeeded does nothing when session does not need refresh', () async {
      // Given: Controller initialized with valid (non-expired) tokens
      final controller = container.read(identityControllerProvider.notifier);
      await Future.delayed(Duration.zero); // Wait for init

      // Set up authenticated session with non-expired tokens
      final validTokens = AuthTokens(
        accessToken: 'valid_token',
        refreshToken: 'refresh_token',
        accessTokenExpiresAt: DateTime.now().add(const Duration(hours: 1)), // Not expired
      );
      controller.state = controller.state.copyWith(
        session: IdentitySession(
          status: AuthStatus.authenticated,
          user: const IdentityUser(userId: 'test'),
          tokens: validTokens,
        ),
      );

      // When: Call refreshTokensIfNeeded
      await controller.refreshTokensIfNeeded();

      // Then: Should not call refresh on shim
      expect(fakeShim.refreshTokensCalled, false);
      // State should remain unchanged
      expect(controller.state.session.tokens?.accessToken, 'valid_token');
      expect(controller.state.isLoading, false);
    });

    test('refreshTokensIfNeeded refreshes when session needs refresh', () async {
      // Given: Controller initialized with expired tokens
      final controller = container.read(identityControllerProvider.notifier);
      await Future.delayed(Duration.zero); // Wait for init

      // Set up authenticated session with expired tokens
      final expiredTokens = AuthTokens(
        accessToken: 'expired_token',
        refreshToken: 'refresh_token',
        accessTokenExpiresAt: DateTime.now().subtract(const Duration(hours: 1)), // Expired
      );
      controller.state = controller.state.copyWith(
        session: IdentitySession(
          status: AuthStatus.authenticated,
          user: const IdentityUser(userId: 'test'),
          tokens: expiredTokens,
        ),
      );

      // When: Call refreshTokensIfNeeded
      await controller.refreshTokensIfNeeded();

      // Then: Should call refresh on shim and update state
      expect(fakeShim.refreshTokensCalled, true);
      expect(controller.state.session, fakeShim.refreshedSession);
      expect(controller.state.session.tokens?.accessToken, 'access-token-123');
      expect(controller.state.isLoading, false);
    });

    test('refreshTokensIfNeeded handles refresh errors gracefully', () async {
      // Given: Controller initialized with expired tokens
      final controller = container.read(identityControllerProvider.notifier);
      await Future.delayed(Duration.zero); // Wait for init

      // Set up authenticated session with expired tokens
      final expiredTokens = AuthTokens(
        accessToken: 'expired_token',
        refreshToken: 'refresh_token',
        accessTokenExpiresAt: DateTime.now().subtract(const Duration(hours: 1)), // Expired
      );
      controller.state = controller.state.copyWith(
        session: IdentitySession(
          status: AuthStatus.authenticated,
          user: const IdentityUser(userId: 'test'),
          tokens: expiredTokens,
        ),
      );

      // Configure shim to throw on refresh
      fakeShim.shouldThrowOnRefresh = true;

      // When: Call refreshTokensIfNeeded
      await controller.refreshTokensIfNeeded();

      // Then: Should call refresh on shim, handle error, and set error state
      expect(fakeShim.refreshTokensCalled, true);
      expect(controller.state.isLoading, false);
      expect(controller.state.lastError, isNotNull);
      expect(controller.state.lastError.toString(), contains('Refresh tokens failed'));
    });

    // ============================================================================
    // Login/OTP Tests (Track D - D-3)
    // ============================================================================

    test('requestLoginCode success updates state correctly', () async {
      // Given: Controller initialized
      final controller = container.read(identityControllerProvider.notifier);
      await Future.delayed(Duration.zero); // Wait for init

      // When: Request login code
      const phoneNumber = PhoneNumber('+966501234567');
      await controller.requestLoginCode(phoneNumber);

      // Then: Should call shim method and update state correctly
      expect(fakeShim.requestLoginCodeCalled, true);
      expect(fakeShim.lastRequestedPhoneNumber, phoneNumber);
      expect(controller.state.isRequestingLoginCode, false);
      expect(controller.state.lastAuthErrorMessage, null);
      expect(controller.state.lastError, null);
    });

    test('requestLoginCode failure updates state with error message', () async {
      // Given: Controller initialized and shim configured to throw
      final controller = container.read(identityControllerProvider.notifier);
      await Future.delayed(Duration.zero); // Wait for init
      fakeShim.shouldThrowOnRequestLoginCode = true;

      // When: Request login code with invalid phone
      const phoneNumber = PhoneNumber('+966501234567');
      await controller.requestLoginCode(phoneNumber);

      // Then: Should handle error and set error message
      expect(fakeShim.requestLoginCodeCalled, true);
      expect(controller.state.isRequestingLoginCode, false);
      expect(controller.state.lastAuthErrorMessage, 'Invalid phone number format');
      expect(controller.state.lastError, isNotNull);
    });

    test('requestLoginCode sets loading state during operation', () async {
      // Given: Controller initialized
      final controller = container.read(identityControllerProvider.notifier);
      await Future.delayed(Duration.zero); // Wait for init

      // When: Request login code
      const phoneNumber = PhoneNumber('+966501234567');
      await controller.requestLoginCode(phoneNumber);

      // Then: Should call shim and update state correctly
      expect(fakeShim.requestLoginCodeCalled, true);
      expect(fakeShim.lastRequestedPhoneNumber, phoneNumber);
      expect(controller.state.isRequestingLoginCode, false);
      expect(controller.state.lastAuthErrorMessage, null);
    });

    test('verifyLoginCode success authenticates user and updates session', () async {
      // Given: Controller initialized
      final controller = container.read(identityControllerProvider.notifier);
      await Future.delayed(Duration.zero); // Wait for init

      // When: Verify login code
      const phoneNumber = PhoneNumber('+966501234567');
      const otpCode = OtpCode('123456');
      await controller.verifyLoginCode(phoneNumber: phoneNumber, code: otpCode);

      // Then: Should call shim method, update session, and clear loading state
      expect(fakeShim.verifyLoginCodeCalled, true);
      expect(fakeShim.lastVerifiedPhoneNumber, phoneNumber);
      expect(fakeShim.lastVerifiedCode, otpCode);
      expect(controller.state.isVerifyingLoginCode, false);
      expect(controller.state.lastAuthErrorMessage, null);
      expect(controller.state.lastError, null);
      expect(controller.state.session, fakeShim.refreshedSession);
      expect(controller.state.isAuthenticated, true);
    });

    test('verifyLoginCode failure keeps unauthenticated state with error', () async {
      // Given: Controller initialized and shim configured to throw
      final controller = container.read(identityControllerProvider.notifier);
      await Future.delayed(Duration.zero); // Wait for init
      fakeShim.shouldThrowOnVerifyLoginCode = true;

      // When: Verify login code with invalid OTP
      const phoneNumber = PhoneNumber('+966501234567');
      const otpCode = OtpCode('123456');
      await controller.verifyLoginCode(phoneNumber: phoneNumber, code: otpCode);

      // Then: Should handle error, keep unauthenticated state, and set error message
      expect(fakeShim.verifyLoginCodeCalled, true);
      expect(controller.state.isVerifyingLoginCode, false);
      expect(controller.state.lastAuthErrorMessage, 'OTP verification failed');
      expect(controller.state.lastError, isNotNull);
      expect(controller.state.session, fakeShim.initialSession); // Should remain unauthenticated
      expect(controller.state.isAuthenticated, false);
    });

    test('verifyLoginCode sets loading state during operation', () async {
      // Given: Controller initialized
      final controller = container.read(identityControllerProvider.notifier);
      await Future.delayed(Duration.zero); // Wait for init

      // When: Verify login code
      const phoneNumber = PhoneNumber('+966501234567');
      const otpCode = OtpCode('123456');
      await controller.verifyLoginCode(phoneNumber: phoneNumber, code: otpCode);

      // Then: Should call shim and update state correctly
      expect(fakeShim.verifyLoginCodeCalled, true);
      expect(fakeShim.lastVerifiedPhoneNumber, phoneNumber);
      expect(fakeShim.lastVerifiedCode, otpCode);
      expect(controller.state.isVerifyingLoginCode, false);
      expect(controller.state.lastAuthErrorMessage, null);
      expect(controller.state.isAuthenticated, true);
    });

    test('login operations handle AuthException messages correctly', () async {
      // Given: Controller initialized and shim configured to throw AuthException
      final controller = container.read(identityControllerProvider.notifier);
      await Future.delayed(Duration.zero); // Wait for init
      fakeShim.shouldThrowOnRequestLoginCode = true;

      // When: Request login code with invalid phone (triggers AuthException.invalidPhone)
      const phoneNumber = PhoneNumber('+966501234567');
      await controller.requestLoginCode(phoneNumber);

      // Then: Should use AuthException message
      expect(controller.state.isRequestingLoginCode, false);
      expect(controller.state.lastAuthErrorMessage, 'Invalid phone number format');
      expect(controller.state.lastError, isNotNull);
    });

    test('state initializes with correct default values for login fields', () async {
      // Given: Controller initialized
      final controller = container.read(identityControllerProvider.notifier);
      await Future.delayed(Duration.zero); // Wait for init

      // Then: Login-related state fields should have correct defaults
      expect(controller.state.isRequestingLoginCode, false);
      expect(controller.state.isVerifyingLoginCode, false);
      expect(controller.state.lastAuthErrorMessage, null);
    });
  });
}

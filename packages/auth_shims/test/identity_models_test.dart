// Identity Models Tests
// Created by: Track D - Ticket #234 (D-2)
// Purpose: Unit tests for AuthTokens and IdentitySession models
// Tests: isExpired, canRefresh, needsRefresh getters

import 'package:test/test.dart';
import 'package:auth_shims/auth_shims.dart';

void main() {
  group('AuthTokens', () {
    test('isExpired returns false when expiresAt is null', () {
      final tokens = AuthTokens(accessToken: 'token');
      expect(tokens.isExpired, false);
    });

    test('isExpired returns false when expiresAt is in the future', () {
      final futureTime = DateTime.now().add(const Duration(hours: 1));
      final tokens = AuthTokens(
        accessToken: 'token',
        accessTokenExpiresAt: futureTime,
      );
      expect(tokens.isExpired, false);
    });

    test('isExpired returns true when expiresAt is in the past', () {
      final pastTime = DateTime.now().subtract(const Duration(hours: 1));
      final tokens = AuthTokens(
        accessToken: 'token',
        accessTokenExpiresAt: pastTime,
      );
      expect(tokens.isExpired, true);
    });

    test('canRefresh returns false when refreshToken is null', () {
      final tokens = AuthTokens(accessToken: 'token');
      expect(tokens.canRefresh, false);
    });

    test('canRefresh returns false when refreshToken is empty', () {
      final tokens = AuthTokens(
        accessToken: 'token',
        refreshToken: '',
      );
      expect(tokens.canRefresh, false);
    });

    test('canRefresh returns true when refreshToken is valid', () {
      final tokens = AuthTokens(
        accessToken: 'token',
        refreshToken: 'refresh_token',
      );
      expect(tokens.canRefresh, true);
    });
  });

  group('IdentitySession', () {
    test('needsRefresh returns false when not authenticated', () {
      final session = IdentitySession(status: AuthStatus.unauthenticated);
      expect(session.needsRefresh, false);
    });

    test('needsRefresh returns false when authenticated but tokens are null', () {
      final session = IdentitySession(
        status: AuthStatus.authenticated,
        user: IdentityUser(userId: '123'),
        tokens: null,
      );
      expect(session.needsRefresh, false);
    });

    test('needsRefresh returns false when tokens are not expired', () {
      final futureTime = DateTime.now().add(const Duration(hours: 1));
      final tokens = AuthTokens(
        accessToken: 'token',
        accessTokenExpiresAt: futureTime,
      );
      final session = IdentitySession(
        status: AuthStatus.authenticated,
        user: IdentityUser(userId: '123'),
        tokens: tokens,
      );
      expect(session.needsRefresh, false);
    });

    test('needsRefresh returns true when tokens are expired', () {
      final pastTime = DateTime.now().subtract(const Duration(hours: 1));
      final tokens = AuthTokens(
        accessToken: 'token',
        accessTokenExpiresAt: pastTime,
      );
      final session = IdentitySession(
        status: AuthStatus.authenticated,
        user: IdentityUser(userId: '123'),
        tokens: tokens,
      );
      expect(session.needsRefresh, true);
    });

    test('needsRefresh returns false when tokens have no expiry', () {
      final tokens = AuthTokens(accessToken: 'token');
      final session = IdentitySession(
        status: AuthStatus.authenticated,
        user: IdentityUser(userId: '123'),
        tokens: tokens,
      );
      expect(session.needsRefresh, false);
    });

    test('isAuthenticated getter works correctly', () {
      expect(
        IdentitySession(status: AuthStatus.authenticated, user: IdentityUser(userId: '123')).isAuthenticated,
        true,
      );
      expect(
        IdentitySession(status: AuthStatus.unauthenticated).isAuthenticated,
        false,
      );
      expect(
        IdentitySession(status: AuthStatus.unknown).isAuthenticated,
        false,
      );
    });

    test('isUnauthenticated getter works correctly', () {
      expect(
        IdentitySession(status: AuthStatus.unauthenticated).isUnauthenticated,
        true,
      );
      expect(
        IdentitySession(status: AuthStatus.authenticated, user: IdentityUser(userId: '123')).isUnauthenticated,
        false,
      );
    });

    test('isUnknown getter works correctly', () {
      expect(
        IdentitySession(status: AuthStatus.unknown).isUnknown,
        true,
      );
      expect(
        IdentitySession(status: AuthStatus.authenticated, user: IdentityUser(userId: '123')).isUnknown,
        false,
      );
    });
  });
}

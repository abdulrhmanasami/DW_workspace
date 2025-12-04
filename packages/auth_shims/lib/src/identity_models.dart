// Identity Domain Models
// Created by: Track D - Ticket #233 (D-1)
// Purpose: Core domain models for identity/auth state management
// Last updated: 2025-12-04

import 'package:meta/meta.dart';
import 'auth_models.dart';

/// Authentication tokens container
@immutable
class AuthTokens {
  /// Access token for API calls
  final String accessToken;

  /// Optional refresh token for token renewal
  final String? refreshToken;

  /// Optional expiration time for access token
  final DateTime? accessTokenExpiresAt;

  const AuthTokens({
    required this.accessToken,
    this.refreshToken,
    this.accessTokenExpiresAt,
  });

  /// Create a copy with updated fields
  AuthTokens copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? accessTokenExpiresAt,
  }) {
    return AuthTokens(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      accessTokenExpiresAt: accessTokenExpiresAt ?? this.accessTokenExpiresAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthTokens &&
          runtimeType == other.runtimeType &&
          accessToken == other.accessToken &&
          refreshToken == other.refreshToken &&
          accessTokenExpiresAt == other.accessTokenExpiresAt;

  @override
  int get hashCode =>
      accessToken.hashCode ^ refreshToken.hashCode ^ accessTokenExpiresAt.hashCode;

  /// Check if the access token is expired
  bool get isExpired {
    if (accessTokenExpiresAt == null) return false;
    return DateTime.now().isAfter(accessTokenExpiresAt!);
  }

  /// Check if tokens can be refreshed (has valid refresh token)
  bool get canRefresh => refreshToken != null && refreshToken!.isNotEmpty;

  @override
  String toString() {
    return 'AuthTokens(accessToken: ${accessToken.substring(0, 10)}..., '
        'hasRefreshToken: ${refreshToken != null}, '
        'expiresAt: $accessTokenExpiresAt, '
        'isExpired: $isExpired, '
        'canRefresh: $canRefresh)';
  }
}

/// Identity user information
///
/// Note: Currently using simple fields. In future iterations,
/// this may be extended or integrated with existing AuthUser model.
@immutable
class IdentityUser {
  /// Unique user identifier
  final String userId;

  /// User's phone number (optional)
  final String? phoneNumber;

  /// User's display name (optional)
  final String? displayName;

  /// Additional country code if available (optional)
  final String? countryCode;

  const IdentityUser({
    required this.userId,
    this.phoneNumber,
    this.displayName,
    this.countryCode,
  });

  /// Create a copy with updated fields
  IdentityUser copyWith({
    String? userId,
    String? phoneNumber,
    String? displayName,
    String? countryCode,
  }) {
    return IdentityUser(
      userId: userId ?? this.userId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      countryCode: countryCode ?? this.countryCode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdentityUser &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() {
    return 'IdentityUser(userId: $userId, phone: $phoneNumber, name: $displayName)';
  }
}

/// Identity session containing authentication state
@immutable
class IdentitySession {
  /// Current authentication status
  final AuthStatus status;

  /// User information (null when unauthenticated)
  final IdentityUser? user;

  /// Authentication tokens (null when unauthenticated)
  final AuthTokens? tokens;

  /// Whether tokens are currently being refreshed
  final bool isRefreshing;

  const IdentitySession({
    required this.status,
    this.user,
    this.tokens,
    this.isRefreshing = false,
  });

  /// Create a copy with updated fields
  IdentitySession copyWith({
    AuthStatus? status,
    IdentityUser? user,
    AuthTokens? tokens,
    bool? isRefreshing,
  }) {
    return IdentitySession(
      status: status ?? this.status,
      user: user ?? this.user,
      tokens: tokens ?? this.tokens,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  /// Whether the session is authenticated
  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;

  /// Whether the session is unauthenticated
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;

  /// Whether the session state is unknown/loading
  bool get isUnknown => status == AuthStatus.unknown;

  /// Whether the session needs token refresh
  bool get needsRefresh => isAuthenticated && (tokens?.isExpired ?? false);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdentitySession &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          user == other.user &&
          tokens == other.tokens &&
          isRefreshing == other.isRefreshing;

  @override
  int get hashCode =>
      status.hashCode ^ (user?.hashCode ?? 0) ^ (tokens?.hashCode ?? 0) ^ isRefreshing.hashCode;

  @override
  String toString() {
    return 'IdentitySession(status: $status, userId: ${user?.userId}, isRefreshing: $isRefreshing)';
  }
}

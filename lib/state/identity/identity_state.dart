/// Identity State Management
/// Created by: Track D - Ticket #233 (D-1)
/// Purpose: State classes for identity/session management
/// Last updated: 2025-12-04

import 'package:flutter/foundation.dart';
import 'package:auth_shims/auth_shims.dart';

/// State for the IdentityController.
///
/// Contains the current identity session and loading/error states.
/// Follows the same pattern as other state classes in the project.
@immutable
class IdentityControllerState {
  /// Current identity session
  final IdentitySession session;

  /// Whether an operation is currently loading
  final bool isLoading;

  /// Last error that occurred (if any)
  final Object? lastError;

  const IdentityControllerState({
    required this.session,
    this.isLoading = false,
    this.lastError,
  });

  /// Create initial state with unknown session
  factory IdentityControllerState.initial() => const IdentityControllerState(
        session: IdentitySession(
          status: AuthStatus.unknown,
          user: null,
          tokens: null,
          isRefreshing: false,
        ),
        isLoading: false,
        lastError: null,
      );

  /// Create a copy with updated fields
  IdentityControllerState copyWith({
    IdentitySession? session,
    bool? isLoading,
    Object? lastError,
    bool clearError = false,
  }) => IdentityControllerState(
        session: session ?? this.session,
        isLoading: isLoading ?? this.isLoading,
        lastError: clearError ? null : (lastError ?? this.lastError),
      );

  /// Whether the user is authenticated
  bool get isAuthenticated => session.isAuthenticated;

  /// Whether the user is unauthenticated
  bool get isUnauthenticated => session.isUnauthenticated;

  /// Whether the session state is unknown/loading
  bool get isUnknown => session.isUnknown;

  /// Whether there is currently an error
  bool get hasError => lastError != null;

  /// Whether tokens are currently being refreshed
  bool get isRefreshing => session.isRefreshing;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdentityControllerState &&
          runtimeType == other.runtimeType &&
          session == other.session &&
          isLoading == other.isLoading &&
          lastError == other.lastError;

  @override
  int get hashCode =>
      session.hashCode ^ isLoading.hashCode ^ lastError.hashCode;

  @override
  String toString() {
    return 'IdentityControllerState('
        'session: $session, '
        'isLoading: $isLoading, '
        'hasError: $hasError)';
  }
}

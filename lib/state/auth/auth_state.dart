/// Simple Auth State + Controller (Stub)
/// Created by: Track D - Ticket #36
/// Purpose: Session-only Auth state for Phone + OTP flow (no Backend integration)
/// Last updated: 2025-11-28
///
/// NOTE: This is a Stub implementation for UI development.
/// In a later ticket, this will be wired to accounts_shims or real backend.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simple authentication state for Phone + OTP flow.
///
/// This is a session-only stub - no persistent storage.
/// In future tickets, this will integrate with accounts_shims.
@immutable
class AuthState {
  const AuthState({
    this.isAuthenticated = false,
    this.isVerifying = false,
    this.phoneNumber,
  });

  /// Whether the user is currently authenticated.
  final bool isAuthenticated;

  /// Whether verification is in progress (OTP sent, waiting for code).
  final bool isVerifying;

  /// The phone number used for authentication.
  final String? phoneNumber;

  /// Create a copy with updated values.
  AuthState copyWith({
    bool? isAuthenticated,
    bool? isVerifying,
    String? phoneNumber,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isVerifying: isVerifying ?? this.isVerifying,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.isAuthenticated == isAuthenticated &&
        other.isVerifying == isVerifying &&
        other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode => Object.hash(isAuthenticated, isVerifying, phoneNumber);

  @override
  String toString() {
    return 'AuthState(isAuthenticated: $isAuthenticated, '
        'isVerifying: $isVerifying, phoneNumber: $phoneNumber)';
  }
}

/// Controller for managing authentication state.
///
/// This is a Stub implementation - no real backend integration.
/// All verification is simulated (any non-empty code is accepted).
class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(const AuthState());

  /// Start phone sign-in flow.
  ///
  /// Saves the phone number and marks as verifying.
  void startPhoneSignIn(String phoneNumber) {
    final trimmed = phoneNumber.trim();
    if (trimmed.isEmpty) return;

    state = state.copyWith(
      phoneNumber: trimmed,
      isVerifying: true,
      isAuthenticated: false,
    );
  }

  /// Verify OTP code.
  ///
  /// Stub implementation: any non-empty code is accepted.
  /// In a real implementation, this would call the backend.
  void verifyOtpCode(String code) {
    if (code.trim().isEmpty) {
      // In future: add error state for empty code
      return;
    }

    // Stub: accept any code
    state = state.copyWith(
      isAuthenticated: true,
      isVerifying: false,
    );
  }

  /// Sign out and reset state.
  void signOut() {
    state = const AuthState();
  }

  /// Cancel verification and go back to initial state.
  void cancelVerification() {
    state = const AuthState(
      isAuthenticated: false,
      isVerifying: false,
      phoneNumber: null,
    );
  }
}

/// Provider for the simple Auth state.
///
/// Usage:
/// ```dart
/// final authState = ref.watch(simpleAuthStateProvider);
/// if (authState.isAuthenticated) {
///   // User is logged in
/// }
///
/// // To trigger actions:
/// ref.read(simpleAuthStateProvider.notifier).startPhoneSignIn('+966501234567');
/// ref.read(simpleAuthStateProvider.notifier).verifyOtpCode('1234');
/// ```
final simpleAuthStateProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController();
});


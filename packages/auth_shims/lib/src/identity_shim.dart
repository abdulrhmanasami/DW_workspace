// Identity Shim Interface
// Created by: Track D - Ticket #233 (D-1)
// Purpose: Abstract interface for identity/session management
// Last updated: 2025-12-04

import 'dart:async';
import 'auth_models.dart';
import 'identity_models.dart';

/// Abstract interface for identity and session management.
///
/// This shim provides a clean separation between the application layer
/// and the underlying authentication implementation (HTTP, Supabase, etc.).
///
/// Track D - Ticket #233: Identity Shim as central node for auth state.
abstract class IdentityShim {
  /// Load the initial identity session from persistent storage or memory.
  ///
  /// This method is called when the app starts to restore any existing
  /// authentication state. In D-1 skeleton, this returns an unauthenticated session.
  ///
  /// Returns: [IdentitySession] with current authentication state
  Future<IdentitySession> loadInitialSession();

  /// Refresh authentication tokens.
  ///
  /// This method attempts to refresh expired or expiring tokens.
  /// In D-1 skeleton, this is a no-op returning the current unauthenticated state.
  ///
  /// Returns: [IdentitySession] with updated tokens (or same state if refresh fails)
  Future<IdentitySession> refreshTokens();

  /// Sign out the current user and clear all authentication state.
  ///
  /// This method should clear tokens, user data, and reset to unauthenticated state.
  /// In D-1 skeleton, this is a no-op since no persistent storage exists.
  ///
  /// Returns: void (completion indicates successful sign out)
  Future<void> signOut();

  /// Stream of identity session changes.
  ///
  /// Applications can listen to this stream to react to authentication state changes.
  /// In D-1 skeleton, this emits a single unauthenticated session.
  ///
  /// Returns: [Stream<IdentitySession>] emitting session updates
  Stream<IdentitySession> watchSession();

  /// Request login code for phone number.
  ///
  /// Sends an OTP code to the specified phone number for login verification.
  /// Track D - Ticket #235 (D-3): Phone login & OTP support.
  ///
  /// Parameters:
  ///   - phoneNumber: The phone number to send OTP to
  ///
  /// Returns: Future<void> (completes when OTP request is sent)
  Future<void> requestLoginCode({
    required PhoneNumber phoneNumber,
  });

  /// Verify login code and create authenticated session.
  ///
  /// Verifies the OTP code and, if valid, creates an authenticated session
  /// with tokens and user information.
  /// Track D - Ticket #235 (D-3): Phone login & OTP support.
  ///
  /// Parameters:
  ///   - phoneNumber: The phone number the OTP was sent to
  ///   - code: The OTP code to verify
  ///
  /// Returns: [IdentitySession] authenticated session with tokens and user data
  Future<IdentitySession> verifyLoginCode({
    required PhoneNumber phoneNumber,
    required OtpCode code,
  });
}

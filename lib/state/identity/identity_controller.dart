/// Identity Controller
/// Created by: Track D - Ticket #233 (D-1)
/// Purpose: Controller for managing identity/session state using Riverpod
/// Last updated: 2025-12-04

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auth_shims/auth_shims.dart';
import 'package:auth_http_impl/auth_http_impl.dart';
import '../infra/auth_providers.dart';
import 'identity_state.dart';

/// Controller for managing identity and authentication state.
///
/// This controller acts as the bridge between the UI layer and the IdentityShim.
/// It manages the identity session state and provides methods for authentication operations.
///
/// Track D - Ticket #233: State Machine for Identity/Auth as central node.
class IdentityController extends StateNotifier<IdentityControllerState> {
  /// Create identity controller with the given shim
  IdentityController(this._shim) : super(IdentityControllerState.initial()) {
    _init();
  }

  final IdentityShim _shim;

  /// Initialize the controller by loading the initial session
  Future<void> _init() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      final session = await _shim.loadInitialSession();
      state = state.copyWith(
        session: session,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        lastError: e,
      );
    }
  }

  /// Reload the current session from the shim
  ///
  /// Useful for refreshing the session state after external changes.
  Future<void> reloadSession() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      final session = await _shim.loadInitialSession();
      state = state.copyWith(
        session: session,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        lastError: e,
      );
    }
  }

  /// Refresh authentication tokens
  ///
  /// Attempts to refresh expired or expiring tokens.
  Future<void> refreshTokens() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      final session = await _shim.refreshTokens();
      state = state.copyWith(
        session: session,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        lastError: e,
      );
    }
  }

  /// Refresh authentication tokens only if needed
  ///
  /// Checks if the current session needs refresh and performs refresh if necessary.
  /// Does nothing if tokens are still valid.
  Future<void> refreshTokensIfNeeded() async {
    // Check if refresh is needed
    if (!state.session.needsRefresh) {
      return; // No refresh needed
    }

    try {
      state = state.copyWith(isLoading: true, clearError: true);
      final session = await _shim.refreshTokens();
      state = state.copyWith(
        session: session,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        lastError: e,
      );
    }
  }

  /// Sign out the current user
  ///
  /// Clears authentication state and signs out.
  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      await _shim.signOut();
      // After sign out, reload session to get the new unauthenticated state
      final session = await _shim.loadInitialSession();
      state = state.copyWith(
        session: session,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        lastError: e,
      );
    }
  }
}

/// Provider for the IdentityShim implementation
///
/// Track D - Ticket #234: Provides HttpIdentityShim with real dependencies.
/// In future tickets, this can be overridden for testing or different implementations.
final identityShimProvider = Provider<IdentityShim>((ref) {
  final authBackendClient = ref.watch(authBackendClientProvider);
  final sessionStorage = ref.watch(sessionStorageShimProvider);
  return HttpIdentityShim(
    authApiClient: authBackendClient,
    storage: sessionStorage,
  );
});

/// Provider for the IdentityController
///
/// This creates and provides the identity controller instance.
/// The controller automatically loads the initial session on creation.
final identityControllerProvider =
    StateNotifierProvider<IdentityController, IdentityControllerState>((ref) {
  final shim = ref.watch(identityShimProvider);
  return IdentityController(shim);
});

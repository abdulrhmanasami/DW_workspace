/// Component: Supabase Auth Repository
/// Created by: Cursor (auto-generated)
/// Purpose: Supabase implementation of AuthRepository interface
/// Last updated: 2025-11-02

import 'dart:async';

import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Supabase implementation of AuthRepository
class AuthRepositorySupabase implements AuthRepository {
  final String url;
  final String anonKey;
  late final supabase.SupabaseClient _supabase;

  AuthRepositorySupabase({
    required this.url,
    required this.anonKey,
  }) {
    _initializeSupabase();
  }

  void _initializeSupabase() {
    supabase.Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
    _supabase = supabase.Supabase.instance.client;
  }

  @override
  Future<UserSession> signInWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AuthException('sign_in_failed', 'Sign in failed');
      }

      return _userToSession(response.user!);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('sign_in_error', e.toString());
    }
  }

  @override
  Future<UserSession> signUpWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AuthException('sign_up_failed', 'Sign up failed');
      }

      return _userToSession(response.user!);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('sign_up_error', e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw AuthException('sign_out_error', e.toString());
    }
  }

  @override
  Future<UserSession?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      return _userToSession(user);
    } catch (e) {
      throw AuthException('get_current_user_error', e.toString());
    }
  }

  @override
  Stream<UserSession?> get onAuthStateChanged {
    return _supabase.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      return user != null ? _userToSession(user) : null;
    });
  }

  @override
  Future<UserSession?> refreshSession() async {
    try {
      final response = await _supabase.auth.refreshSession();
      final user = response.user;
      if (user == null) return null;

      return _userToSession(user);
    } catch (e) {
      throw AuthException('refresh_session_error', e.toString());
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw AuthException('reset_password_error', e.toString());
    }
  }

  UserSession _userToSession(supabase.User user) {
    return UserSession(
      userId: user.id,
      email: user.email,
      displayName: user.userMetadata?['display_name'] as String?,
      expiresAt: user.aud == 'authenticated'
          ? DateTime.now().add(const Duration(hours: 1)) // Simplified
          : null,
      metadata: user.userMetadata ?? {},
    );
  }
}

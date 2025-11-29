/// Component: Auth Repository Interface
/// Created by: Cursor (auto-generated)
/// Purpose: Authentication repository contract for user management
/// Last updated: 2025-11-02

/// User session data
class UserSession {
  final String userId;
  final String? email;
  final String? displayName;
  final DateTime? expiresAt;
  final Map<String, dynamic> metadata;

  const UserSession({
    required this.userId,
    this.email,
    this.displayName,
    this.expiresAt,
    this.metadata = const {},
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
}

/// Authentication repository interface
abstract class AuthRepository {
  /// Sign in with email and password
  Future<UserSession> signInWithEmail(String email, String password);

  /// Sign up with email and password
  Future<UserSession> signUpWithEmail(String email, String password);

  /// Sign out current user
  Future<void> signOut();

  /// Get current user session (null if not authenticated)
  Future<UserSession?> getCurrentUser();

  /// Stream of authentication state changes
  Stream<UserSession?> get onAuthStateChanged;

  /// Refresh current session
  Future<UserSession?> refreshSession();

  /// Reset password for email
  Future<void> resetPassword(String email);
}

/// Authentication exceptions
class AuthException implements Exception {
  final String code;
  final String message;

  const AuthException(this.code, this.message);

  @override
  String toString() => 'AuthException($code): $message';
}

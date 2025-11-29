/// Component: RBAC Client Interface
/// Created by: Cursor (auto-generated)
/// Purpose: RBAC authorization client contract
/// Last updated: 2025-11-02

import '../../../rbac/rbac_models.dart';

/// RBAC authorization client interface
abstract class RBACClient {
  /// Authorize an action on a resource for a subject
  /// Returns RBACDecision with allow/deny result and optional reason
  Future<RBACDecision> authorize({
    required String action,
    required String resource,
    required String subjectId,
    Map<String, dynamic>? context,
  });

  /// Check if subject has permission for specific action on resource
  Future<bool> hasPermission({
    required String action,
    required String resource,
    required String subjectId,
  });

  /// Get all permissions for a subject
  Future<List<RBACPermission>> getSubjectPermissions(String subjectId);

  /// Get user role for a subject
  Future<UserRole?> getSubjectRole(String subjectId);
}

/// Authorization context for additional metadata
class AuthorizationContext {
  final String? userId;
  final String? sessionId;
  final String? ipAddress;
  final Map<String, dynamic> customData;

  const AuthorizationContext({
    this.userId,
    this.sessionId,
    this.ipAddress,
    this.customData = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'userId': userId,
      if (sessionId != null) 'sessionId': sessionId,
      if (ipAddress != null) 'ipAddress': ipAddress,
      ...customData,
    };
  }
}

/// Component: RBAC Models
/// Created by: Cursor (auto-generated)
/// Purpose: Role-Based Access Control models for clean version
/// Last updated: 2025-01-27
library;

/// User roles in the system
enum UserRole { customer, driver, operator, admin, superAdmin }

/// RBAC resources that can be protected
enum RBACResource {
  adminUsers,
  adminSystem,
  opsAnalytics,
  opsMonitoring,
  payments,
  userData,
}

/// RBAC actions that can be performed
enum RBACAction { read, write, delete, execute }

/// RBAC permission combining resource and action
class RBACPermission {
  final RBACResource resource;
  final RBACAction action;

  const RBACPermission({required this.resource, required this.action});

  @override
  String toString() => '${resource.name}.${action.name}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RBACPermission &&
        other.resource == resource &&
        other.action == action;
  }

  @override
  int get hashCode => Object.hash(resource, action);
}

/// RBAC decision result
class RBACDecision {
  final bool allowed;
  final String? reason;

  const RBACDecision({required this.allowed, this.reason});
}

/// Extension to get display names for user roles
extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.driver:
        return 'Driver';
      case UserRole.operator:
        return 'Operator';
      case UserRole.admin:
        return 'Administrator';
      case UserRole.superAdmin:
        return 'Super Administrator';
    }
  }

  String get name {
    switch (this) {
      case UserRole.customer:
        return 'customer';
      case UserRole.driver:
        return 'driver';
      case UserRole.operator:
        return 'operator';
      case UserRole.admin:
        return 'admin';
      case UserRole.superAdmin:
        return 'super_admin';
    }
  }
}

/// Extension to get display names for RBAC resources
extension RBACResourceExtension on RBACResource {
  String get displayName {
    switch (this) {
      case RBACResource.adminUsers:
        return 'User Management';
      case RBACResource.adminSystem:
        return 'System Administration';
      case RBACResource.opsAnalytics:
        return 'Operations Analytics';
      case RBACResource.opsMonitoring:
        return 'Operations Monitoring';
      case RBACResource.payments:
        return 'Payment Processing';
      case RBACResource.userData:
        return 'User Data';
    }
  }
}

/// Extension to get display names for RBAC actions
extension RBACActionExtension on RBACAction {
  String get displayName {
    switch (this) {
      case RBACAction.read:
        return 'Read';
      case RBACAction.write:
        return 'Write';
      case RBACAction.delete:
        return 'Delete';
      case RBACAction.execute:
        return 'Execute';
    }
  }
}

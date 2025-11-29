import 'package:flutter/material.dart';

import 'package:core/rbac/rbac_models.dart';

/// Component: RBAC Guard Widget
/// Created by: Cursor (auto-generated)
/// Purpose: عنصر واجهة لحراسة الشاشات بناءً على صلاحيات RBAC
/// Last updated: 2025-11-02

/// عنصر واجهة لحراسة المحتوى بناءً على صلاحيات المستخدم والمورد المطلوب
class RbacGuard extends StatelessWidget {
  final String? userId;
  final UserRole? userRole;
  final RBACPermission? requiredPermission;
  final Widget? fallback;
  final Widget child;
  final String? screenId; // For backward compatibility

  const RbacGuard({
    super.key,
    this.userId,
    this.userRole,
    this.requiredPermission,
    this.fallback,
    required this.child,
    this.screenId, // For backward compatibility
  });

  @override
  Widget build(BuildContext context) {
    // Handle backward compatibility for screenId-based access
    if (screenId != null) {
      // For backward compatibility, allow all screens for now
      return child;
    }

    // New API: permission-based access control
    if (userRole != null && requiredPermission != null && fallback != null) {
      final hasPermission = _checkPermission(userRole!, requiredPermission!);
      return hasPermission ? child : fallback!;
    }

    // Default: allow access
    return child;
  }

  bool _checkPermission(UserRole userRole, RBACPermission permission) {
    // Simple permission check based on role hierarchy
    switch (userRole) {
      case UserRole.admin:
      case UserRole.superAdmin:
        return true; // Admin has all permissions
      case UserRole.operator:
      case UserRole.driver:
        // Drivers/operators can access orders, profile, payments
        return permission.resource == RBACResource.userData ||
            permission.resource == RBACResource.payments;
      case UserRole.customer:
        // Customers can access orders, profile, payments
        return permission.resource == RBACResource.userData ||
            permission.resource == RBACResource.payments;
    }
  }
}

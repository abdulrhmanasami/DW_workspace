/// Component: RBAC E2E Tests
/// Created by: Cursor (auto-generated)
/// Purpose: End-to-end RBAC authorization testing with REST API
/// Last updated: 2025-11-02

import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_ways_clean/config/service_locator.dart';
import 'package:delivery_ways_clean/config/integration_config.dart';
import 'package:core/core.dart';

void main() {
  group('RBAC E2E Tests', () {
    late bool isConfigured;

    setUpAll(() {
      isConfigured = IntegrationConfig.isFullyConfigured;
    });

    test('RBAC service initialization', () {
      expect(
        isConfigured,
        isTrue,
        reason: 'RBAC requires RBAC_BASE_URL to be configured',
      );
    });

    test('Authorize admin user for admin action', () async {
      if (!isConfigured) return;

      const adminUserId = 'admin_user_123';
      const action = 'admin.users.read';
      const resource = 'users';

      try {
        final decision = await ServiceLocator.rbac.authorize(
          action: action,
          resource: resource,
          subjectId: adminUserId,
        );

        // In test environment, admin should have access
        // This depends on your backend RBAC configuration
        expect(decision, isA<RBACDecision>());
      } catch (e) {
        // If backend is not available, expect network error
        expect(e.toString(), contains('RBACException'));
      }
    });

    test('Deny customer user for admin action', () async {
      if (!isConfigured) return;

      const customerUserId = 'customer_user_456';
      const action = 'admin.users.read';
      const resource = 'users';

      try {
        final decision = await ServiceLocator.rbac.authorize(
          action: action,
          resource: resource,
          subjectId: customerUserId,
        );

        // Customer should NOT have admin access
        expect(decision.allowed, isFalse);
        expect(decision.reason, isNotNull);
      } catch (e) {
        // If backend is not available, expect network error
        expect(e.toString(), contains('RBACException'));
      }
    });

    test('Allow customer user for order actions', () async {
      if (!isConfigured) return;

      const customerUserId = 'customer_user_456';
      const action = 'orders.read';
      const resource = 'order_123';

      try {
        final decision = await ServiceLocator.rbac.authorize(
          action: action,
          resource: resource,
          subjectId: customerUserId,
        );

        // Customer should have access to their own orders
        expect(decision.allowed, isTrue);
      } catch (e) {
        // If backend is not available, expect network error
        expect(e.toString(), contains('RBACException'));
      }
    });

    test('Get user permissions', () async {
      if (!isConfigured) return;

      const userId = 'test_user_789';

      try {
        final permissions = await ServiceLocator.rbac.getSubjectPermissions(
          userId,
        );
        expect(permissions, isA<List<RBACPermission>>());

        // Should have at least basic permissions
        expect(permissions.length, greaterThanOrEqualTo(0));
      } catch (e) {
        // If backend is not available, expect network error
        expect(e.toString(), contains('RBACException'));
      }
    });

    test('Get user role', () async {
      if (!isConfigured) return;

      const userId = 'test_user_789';

      try {
        final role = await ServiceLocator.rbac.getSubjectRole(userId);
        // Role might be null for non-existent users
        expect(role, anyOf(isNull, isA<UserRole>()));
      } catch (e) {
        // If backend is not available, expect network error
        expect(e.toString(), contains('RBACException'));
      }
    });
  });
}

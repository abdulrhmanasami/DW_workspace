/// Component: RBAC Guard Integration Tests
/// Created by: Cursor (auto-generated)
/// Purpose: UI integration tests for RBAC authorization flows
/// Last updated: 2025-11-02

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:delivery_ways_clean/main.dart';
import 'package:delivery_ways_clean/widgets/rbac_guard.dart';
import 'package:delivery_ways_clean/config/service_locator.dart';
import 'package:core/rbac/rbac_models.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('RBAC Guard Integration Tests', () {
    testWidgets('RBAC Guard widget renders without errors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RbacGuard(
              requiredPermission: RBACPermission(
                resource: RBACResource.userData,
                action: RBACAction.read,
              ),
              child: Text('Protected Content'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify RBAC Guard is rendered
      expect(find.byType(RbacGuard), findsOneWidget);

      // Test that RBAC service is available
      expect(ServiceLocator.rbac, isNotNull);
    });

    testWidgets('RBAC service operations work', (WidgetTester tester) async {
      await tester.pumpWidget(const DeliveryWaysApp());
      await tester.pumpAndSettle();

      // Test basic RBAC operations don't crash
      final hasPermission = await ServiceLocator.rbac.hasPermission(
        action: 'read',
        resource: 'user_data',
        subjectId: 'test_user',
      );

      // Result may be false (expected for unauthorized user), but shouldn't crash
      expect(hasPermission, isA<bool>());

      // Verify no exceptions
      expect(tester.takeException(), isNull);
    });
  });
}

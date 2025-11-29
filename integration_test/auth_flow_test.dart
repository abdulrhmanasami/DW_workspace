/// Component: Auth Flow Integration Tests
/// Created by: Cursor (auto-generated)
/// Purpose: UI integration tests for authentication flows
/// Last updated: 2025-11-02

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:delivery_ways_clean/main.dart';
import 'package:delivery_ways_clean/config/service_locator.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Flow Integration Tests', () {
    testWidgets('App launches and shows auth-related UI', (
      WidgetTester tester,
    ) async {
      // Build our app
      await tester.pumpWidget(const DeliveryWaysApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify app launched successfully
      expect(find.byType(MaterialApp), findsOneWidget);

      // Test that auth service is available
      expect(ServiceLocator.auth, isNotNull);

      // Verify no immediate crashes
      expect(tester.takeException(), isNull);
    });

    testWidgets('Telemetry service initializes without errors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const DeliveryWaysApp());
      await tester.pumpAndSettle();

      // Verify telemetry service is available
      expect(ServiceLocator.telemetry, isNotNull);

      // Test basic telemetry operations don't crash
      ServiceLocator.telemetry.logEvent('test_app_launch');
      ServiceLocator.telemetry.logScreen('test_screen');

      // Wait for any async operations
      await tester.pumpAndSettle();

      // Verify no exceptions
      expect(tester.takeException(), isNull);
    });
  });
}

/// Component: Telemetry Events Integration Tests
/// Created by: Cursor (auto-generated)
/// Purpose: UI integration tests for telemetry and analytics events
/// Last updated: 2025-11-02

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:delivery_ways_clean/main.dart';
import 'package:delivery_ways_clean/config/service_locator.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Telemetry Events Integration Tests', () {
    testWidgets('Telemetry service operations work in UI context', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const DeliveryWaysApp());
      await tester.pumpAndSettle();

      final telemetry = ServiceLocator.telemetry;

      // Test various telemetry operations
      telemetry.logEvent('app_launch', params: {'version': '1.0.0'});
      telemetry.logScreen('home_screen', params: {'user_type': 'guest'});

      telemetry.trackAuthEvent('login_attempt', params: {'method': 'email'});
      telemetry.trackScreenView('dashboard', params: {'tab': 'orders'});

      telemetry.trackApiCall(
        '/api/user/profile',
        statusCode: 200,
        durationMs: 150,
      );

      // Track a successful payment
      telemetry.trackPaymentSucceeded(
        paymentId: 'pay_123456',
        amount: 25.99,
        currency: 'EUR',
      );

      // Track an error
      telemetry.trackError(
        'Network timeout',
        stack: StackTrace.current,
        context: {'screen': 'checkout', 'action': 'submit_payment'},
      );

      // Wait for any async operations to complete
      await tester.pumpAndSettle();

      // Verify no exceptions occurred
      expect(tester.takeException(), isNull);
    });

    testWidgets('Custom event tracking works', (WidgetTester tester) async {
      await tester.pumpWidget(const DeliveryWaysApp());
      await tester.pumpAndSettle();

      final telemetry = ServiceLocator.telemetry;

      // Test custom event with various parameters
      telemetry.trackCustomEvent(
        'user_interaction',
        params: {
          'element': 'checkout_button',
          'action': 'tap',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      await tester.pumpAndSettle();

      // Verify no exceptions
      expect(tester.takeException(), isNull);
    });
  });
}

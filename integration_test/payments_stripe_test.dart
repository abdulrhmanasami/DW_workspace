/// Component: Payments Integration Tests
/// Created by: Cursor (auto-generated)
/// Purpose: UI integration tests for payment flows using Stripe
/// Last updated: 2025-11-02

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:delivery_ways_clean/main.dart';
import 'package:delivery_ways_clean/screens/payment_screen.dart';
import 'package:delivery_ways_clean/config/service_locator.dart';
import 'package:payments/payments.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Payments Integration Tests', () {
    setUpAll(() async {
      await ServiceLocator.ensurePaymentsReady();
    });

    testWidgets('Payment screen renders without errors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PaymentScreen(
              amount: 1000, // 10.00 in minor units
              currency: 'GBP',
              serviceType: PaymentServiceType.defaultService,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify PaymentScreen is rendered
      expect(find.byType(PaymentScreen), findsOneWidget);

      // Test that payments service is available
      expect(ServiceLocator.payments, isNotNull);
    });

    testWidgets('Payment service initializes correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const DeliveryWaysApp());
      await tester.pumpAndSettle();

      // Verify payment service is available and configured
      expect(ServiceLocator.payments, isNotNull);

      // Test telemetry integration for payments
      ServiceLocator.telemetry.trackPaymentSucceeded(
        paymentId: 'test_payment_123',
        amount: 10.0,
        currency: 'EUR',
      );

      await tester.pumpAndSettle();

      // Verify no exceptions
      expect(tester.takeException(), isNull);
    });
  });
}

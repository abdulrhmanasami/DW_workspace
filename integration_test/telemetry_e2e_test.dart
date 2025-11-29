/// Component: Telemetry E2E Tests
/// Created by: Cursor (auto-generated)
/// Purpose: End-to-end telemetry and observability testing
/// Last updated: 2025-11-02

import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_ways_clean/config/service_locator.dart';
import 'package:core/core.dart';
import 'package:payments/payments.dart' as payments;

void main() {
  group('Telemetry E2E Tests', () {
    late TelemetryService telemetry;

    setUpAll(() {
      telemetry = ServiceLocator.telemetry;
      // No need to initialize - ServiceLocator handles this
    });

    test('Telemetry service initialization', () {
      expect(telemetry, isNotNull);
    });

    test('Payment success event tracking', () {
      const metadata = payments.PaymentMetadata(
        orderId: 'telemetry_test_order_123',
        amount: 15.99,
        currency: 'EUR',
      );

      // Track payment success - in real app this would be called automatically
      telemetry.trackPaymentSucceeded(
        paymentId: 'test_txn_123',
        amount: metadata.amount.toDouble(),
        currency: metadata.currency,
      );

      // Verify telemetry doesn't crash
      expect(true, isTrue);
    });

    test('Payment failure event tracking', () {
      const metadata = payments.PaymentMetadata(
        orderId: 'telemetry_test_failed_order_456',
        amount: 25.50,
        currency: 'EUR',
      );

      const failure = payments.PaymentFailure(
        code: 'card_declined',
        message: 'Your card was declined',
      );

      // Track payment failure
      telemetry.trackPaymentFailed(
        paymentId: metadata.orderId,
        reason: '${failure.code}: ${failure.message}',
        amount: metadata.amount,
      );

      // Verify telemetry doesn't crash
      expect(true, isTrue);
    });

    test('Auth event tracking', () {
      // Track auth success
      telemetry.trackAuthEvent(
        'login_success',
        params: {'userId': 'test_user_123'},
      );

      // Track auth failure
      telemetry.trackAuthEvent(
        'login_failure',
        params: {'errorMessage': 'Invalid credentials'},
      );

      // Verify telemetry doesn't crash
      expect(true, isTrue);
    });

    test('Screen view tracking', () {
      telemetry.trackScreenView(
        'payment_screen',
        params: {'screenClass': 'PaymentScreen'},
      );

      telemetry.trackScreenView(
        'order_tracking_screen',
        params: {'screenClass': 'OrderTrackingScreen'},
      );

      // Verify telemetry doesn't crash
      expect(true, isTrue);
    });

    test('Performance metrics tracking', () {
      // Track API call performance
      telemetry.trackApiCall('/api/orders', statusCode: 200, durationMs: 250);

      // Track slow API call
      telemetry.trackApiCall(
        '/api/payments',
        statusCode: 200,
        durationMs: 5000,
      );

      // Verify telemetry doesn't crash
      expect(true, isTrue);
    });

    test('Error tracking', () {
      telemetry.trackError(
        'Test error',
        stack: StackTrace.current,
        context: {'screen': 'test_screen', 'action': 'test_action'},
      );

      // Verify telemetry doesn't crash
      expect(true, isTrue);
    });

    test('Custom event tracking', () {
      telemetry.trackCustomEvent(
        'app_launch',
        params: {'first_launch': true, 'platform': 'test', 'version': '1.0.0'},
      );

      // Verify telemetry doesn't crash
      expect(true, isTrue);
    });
  });
}

// Component: Payment Gateway Tests
// Created by: CENT-006 QA Implementation
// Purpose: Unit tests for PaymentGateway contracts and stub implementations
// Last updated: 2025-11-25

import 'package:flutter_test/flutter_test.dart';
import 'package:payments/payments.dart';
import 'package:payments_stub_impl/payments_stub_impl.dart';

void main() {
  group('NoOpPaymentsGateway', () {
    late NoOpPaymentsGateway gateway;

    setUp(() {
      gateway = NoOpPaymentsGateway();
    });

    tearDown(() {
      gateway.dispose();
    });

    // --------------------------------------------------------------------------
    // createIntent
    // --------------------------------------------------------------------------
    group('createIntent', () {
      test('returns valid PaymentIntent', () async {
        final amount = const Amount(1000, 'EUR');
        final currency = const Currency('EUR');

        final intent = await gateway.createIntent(amount, currency);

        expect(intent.id, startsWith('pi_stub_'));
        expect(intent.amount, equals(1000));
        expect(intent.currency, equals('EUR'));
        expect(intent.clientSecret, startsWith('cs_stub_'));
      });

      test('generates unique IDs for each call', () async {
        final amount = const Amount(500, 'USD');
        final currency = const Currency('USD');

        final intent1 = await gateway.createIntent(amount, currency);
        await Future.delayed(const Duration(milliseconds: 5));
        final intent2 = await gateway.createIntent(amount, currency);

        expect(intent1.id, isNot(equals(intent2.id)));
        expect(intent1.clientSecret, isNot(equals(intent2.clientSecret)));
      });
    });

    // --------------------------------------------------------------------------
    // confirmIntent
    // --------------------------------------------------------------------------
    group('confirmIntent', () {
      test('returns succeeded status', () async {
        final result = await gateway.confirmIntent('cs_test_123');

        expect(result.status, equals(PaymentStatus.succeeded));
      });

      test('accepts optional payment method', () async {
        final result = await gateway.confirmIntent(
          'cs_test_123',
          method: const StubPaymentMethod(id: 'pm_test', type: PaymentMethodType.card, displayName: 'Test'),
        );

        expect(result.status, equals(PaymentStatus.succeeded));
      });
    });

    // --------------------------------------------------------------------------
    // setupPaymentMethod
    // --------------------------------------------------------------------------
    group('setupPaymentMethod', () {
      test('returns succeeded setup result', () async {
        final request = const SetupRequest(
          customerId: 'cus_test',
          useGooglePayIfAvailable: false,
        );

        final result = await gateway.setupPaymentMethod(request: request);

        expect(result.paymentMethodId, startsWith('pm_stub_'));
        expect(result.status, equals(SetupIntentStatus.succeeded));
        expect(result.message, equals('Stub setup completed'));
      });

      test('handles Google Pay flag', () async {
        final request = const SetupRequest(
          customerId: 'cus_test',
          useGooglePayIfAvailable: true,
        );

        final result = await gateway.setupPaymentMethod(request: request);

        expect(result.status, equals(SetupIntentStatus.succeeded));
      });
    });

    // --------------------------------------------------------------------------
    // listMethods
    // --------------------------------------------------------------------------
    group('listMethods', () {
      test('returns empty list', () async {
        final methods = await gateway.listMethods(customerId: 'cus_test');

        expect(methods, isEmpty);
      });
    });

    // --------------------------------------------------------------------------
    // detachPaymentMethod
    // --------------------------------------------------------------------------
    group('detachPaymentMethod', () {
      test('completes without error', () async {
        await expectLater(
          gateway.detachPaymentMethod(
            customerId: 'cus_test',
            paymentMethodId: 'pm_test',
          ),
          completes,
        );
      });
    });
  });

  // --------------------------------------------------------------------------
  // NoOpPaymentsSheet Tests
  // --------------------------------------------------------------------------
  group('NoOpPaymentsSheet', () {
    late NoOpPaymentsSheet sheet;

    setUp(() {
      sheet = NoOpPaymentsSheet();
    });

    test('present returns succeeded status', () async {
      final result = await sheet.present(clientSecret: 'cs_test_123');

      expect(result.status, equals(PaymentStatus.succeeded));
    });
  });

  // --------------------------------------------------------------------------
  // Payment Models Tests
  // --------------------------------------------------------------------------
  group('Payment Models', () {
    group('Amount', () {
      test('toString returns formatted string', () {
        const amount = Amount(1000, 'EUR');

        expect(amount.toString(), equals('1000 EUR'));
      });
    });

    group('Currency', () {
      test('toString returns currency code', () {
        const currency = Currency('USD');

        expect(currency.toString(), equals('USD'));
      });
    });

    group('PaymentIntent', () {
      test('stores all properties correctly', () {
        const intent = PaymentIntent(
          id: 'pi_test',
          amount: 2000,
          currency: 'GBP',
          clientSecret: 'cs_test',
        );

        expect(intent.id, equals('pi_test'));
        expect(intent.amount, equals(2000));
        expect(intent.currency, equals('GBP'));
        expect(intent.clientSecret, equals('cs_test'));
      });
    });

    group('PaymentResult', () {
      test('stores status and message', () {
        const result = PaymentResult(
          status: PaymentStatus.failed,
          message: 'Card declined',
        );

        expect(result.status, equals(PaymentStatus.failed));
        expect(result.message, equals('Card declined'));
      });

      test('message is optional', () {
        const result = PaymentResult(status: PaymentStatus.succeeded);

        expect(result.message, isNull);
      });
    });

    group('SetupRequest', () {
      test('default values are correct', () {
        const request = SetupRequest(customerId: 'cus_test');

        expect(request.customerId, equals('cus_test'));
        expect(request.useGooglePayIfAvailable, isFalse);
      });

      test('accepts custom Google Pay flag', () {
        const request = SetupRequest(
          customerId: 'cus_test',
          useGooglePayIfAvailable: true,
        );

        expect(request.useGooglePayIfAvailable, isTrue);
      });
    });

    group('SetupResult', () {
      test('stores all properties', () {
        const result = SetupResult(
          paymentMethodId: 'pm_test',
          status: SetupIntentStatus.succeeded,
          message: 'Success',
        );

        expect(result.paymentMethodId, equals('pm_test'));
        expect(result.status, equals(SetupIntentStatus.succeeded));
        expect(result.message, equals('Success'));
      });
    });

    group('SavedPaymentMethod', () {
      test('implements PaymentMethod interface', () {
        const method = SavedPaymentMethod(
          id: 'pm_test',
          brand: 'Visa',
          last4: '4242',
          expMonth: 12,
          expYear: 2025,
          type: PaymentMethodType.card,
        );

        expect(method.id, equals('pm_test'));
        expect(method.type, equals(PaymentMethodType.card));
        expect(method.displayName, equals('Visa **** 4242'));
        expect(method.isAvailable, isTrue);
        expect(method.isDefault, isFalse);
        expect(method.iconUrl, isNull);
      });
    });

    group('SetupIntentStatus', () {
      test('has all expected values', () {
        expect(SetupIntentStatus.values, containsAll([
          SetupIntentStatus.requiresAction,
          SetupIntentStatus.succeeded,
          SetupIntentStatus.failed,
          SetupIntentStatus.canceled,
        ]));
      });
    });

    group('PaymentStatus', () {
      test('has all expected values', () {
        expect(PaymentStatus.values, containsAll([
          PaymentStatus.requiresAction,
          PaymentStatus.processing,
          PaymentStatus.succeeded,
          PaymentStatus.canceled,
          PaymentStatus.failed,
        ]));
      });
    });
  });
}

// Helper stub for testing
class StubPaymentMethod implements PaymentMethod {
  @override
  final String id;
  @override
  final PaymentMethodType type;
  @override
  final String displayName;
  @override
  final String? iconUrl;
  @override
  final bool isDefault;

  const StubPaymentMethod({
    required this.id,
    required this.type,
    required this.displayName,
    this.iconUrl,
    this.isDefault = false,
  });

  @override
  bool get isAvailable => true;
}


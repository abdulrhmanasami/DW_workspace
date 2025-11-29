/// Service: PaymentService
/// Created by: Cursor (auto-generated)
/// Purpose: Abstract interface for payment operations in Delivery Ways platform
/// Last updated: 2025-11-02

import 'payment_models.dart';

abstract class PaymentService {
  Future<PaymentResult> pay(PaymentMetadata metadata);
  Future<PaymentResult> refund(String orderId, {double? amount});
}

// Legacy interface for backward compatibility
abstract class LegacyPaymentService {
  Future<void> initialize();
  Future<PaymentIntent> createIntent(PaymentRequest req);
  Future<LegacyPaymentResult> confirm(String intentId, {String? methodId});
  Future<LegacyPaymentResult> cancel(String intentId, {String? reason});
  Future<LegacyPaymentResult> refund(String transactionId, {int? amountMinor});
  Future<LegacyPaymentStatus> status(String intentId);
}

class DefaultPaymentService implements PaymentService {
  @override
  Future<PaymentResult> pay(PaymentMetadata metadata) async {
    throw StateError('Payment gateway not configured');
  }

  @override
  Future<PaymentResult> refund(String orderId, {double? amount}) async {
    throw StateError('Payment gateway not configured');
  }
}

class LegacyDefaultPaymentService implements LegacyPaymentService {
  @override
  Future<void> initialize() async {}

  @override
  Future<PaymentIntent> createIntent(PaymentRequest req) async {
    throw StateError('Payment gateway not configured');
  }

  @override
  Future<LegacyPaymentResult> confirm(
    String intentId, {
    String? methodId,
  }) async {
    throw StateError('Payment gateway not configured');
  }

  @override
  Future<LegacyPaymentResult> cancel(String intentId, {String? reason}) async {
    throw StateError('Payment gateway not configured');
  }

  @override
  Future<LegacyPaymentResult> refund(
    String transactionId, {
    int? amountMinor,
  }) async {
    throw StateError('Payment gateway not configured');
  }

  @override
  Future<LegacyPaymentStatus> status(String intentId) async {
    return LegacyPaymentStatus.unknown;
  }
}

PaymentService paymentServiceFactory(PaymentServiceType type) =>
    DefaultPaymentService();

/// Component: Payments Stub Implementation
/// Created by: Cursor (auto-generated)
/// Purpose: NoOp implementations for PaymentsGateway and PaymentsSheet (not for production)
/// Last updated: 2025-11-17 PAY-CLEANUP-012

library payments_stub_impl;

import 'dart:async';

import 'package:payments/payments.dart';

/// NoOp implementation of PaymentsGateway
class NoOpPaymentsGateway implements PaymentsGateway {
  @override
  Future<PaymentIntent> createIntent(Amount amount, Currency currency) async {
    return PaymentIntent(
      id: 'pi_stub_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount.value,
      currency: currency.code,
      clientSecret: 'cs_stub_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<PaymentResult> confirmIntent(
    String clientSecret, {
    PaymentMethod? method,
  }) async {
    return const PaymentResult(status: PaymentStatus.succeeded);
  }

  @override
  Future<SetupResult> setupPaymentMethod({required SetupRequest request}) async {
    return SetupResult(
      paymentMethodId: 'pm_stub_${DateTime.now().millisecondsSinceEpoch}',
      status: SetupIntentStatus.succeeded,
      message: 'Stub setup completed',
    );
  }

  @override
  Future<List<SavedPaymentMethod>> listMethods({
    required String customerId,
  }) async {
    return [];
  }

  @override
  Future<void> detachPaymentMethod({
    required String customerId,
    required String paymentMethodId,
  }) async {
    // No stored methods to detach in stub
  }

  @override
  void dispose() {
    // NoOp - nothing to dispose
  }
}

/// NoOp implementation of PaymentsSheet
class NoOpPaymentsSheet implements PaymentsSheet {
  @override
  Future<PaymentResult> present({required String clientSecret}) async {
    return const PaymentResult(status: PaymentStatus.succeeded);
  }
}

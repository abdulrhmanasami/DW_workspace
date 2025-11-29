/// Repository: PaymentsRepository
/// Created by: Cursor (auto-generated)
/// Purpose: Repository layer for payment operations using PaymentsGateway
/// Last updated: 2025-11-17 PAY-CLEANUP-012

import 'package:payments/payments.dart';

class PaymentsRepository {
  final PaymentsGateway gateway;
  PaymentsRepository(this.gateway);

  Future<PaymentIntent> createIntent(Amount amount, Currency currency) =>
      gateway.createIntent(amount, currency);

  Future<PaymentResult> confirmIntent(
    String clientSecret, {
    PaymentMethod? method,
  }) => gateway.confirmIntent(clientSecret, method: method);

  Future<List<SavedPaymentMethod>> listMethods(String customerId) =>
      gateway.listMethods(customerId: customerId);
}

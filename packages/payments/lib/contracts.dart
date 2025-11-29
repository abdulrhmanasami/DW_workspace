/// Component: Payment Contracts
/// Created by: Cursor (auto-generated)
/// Purpose: Unified payment gateway contracts for Delivery Ways
/// Last updated: 2025-11-17 PAY-CLEANUP-012

import 'models.dart';
import 'src/payment_method.dart';

/// Payment gateway interface for processing payments
abstract class PaymentGateway {
  Future<PaymentIntent> createIntent(Amount amount, Currency currency);
  Future<PaymentResult> confirmIntent(
    String clientSecret, {
    PaymentMethod? method,
  });
  Future<SetupResult> setupPaymentMethod({required SetupRequest request});
  Future<List<SavedPaymentMethod>> listMethods({required String customerId});
  Future<void> detachPaymentMethod({
    required String customerId,
    required String paymentMethodId,
  });
  void dispose();
}

abstract class PaymentsGateway extends PaymentGateway {
  // Inherits all methods from PaymentGateway
  // Additional methods can be added here if needed
}

abstract class PaymentsSheet {
  Future<PaymentResult> present({required String clientSecret});
}

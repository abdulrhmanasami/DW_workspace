/// Component: Payment Method Contracts
/// Created by: Cursor (auto-generated)
/// Purpose: Payment method abstractions
/// Last updated: 2025-11-03

/// Payment method types
enum PaymentMethodType { card, cash, applePay, googlePay, digitalWallet, bankTransfer, cashOnDelivery }

/// Abstract payment method contract
abstract class PaymentMethod {
  PaymentMethodType get type;
  String get id;
  String get displayName;
  String? get iconUrl;
  bool get isDefault;
  bool get isAvailable;
}

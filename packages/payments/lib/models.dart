/// Component: Payment Models
/// Created by: Cursor (auto-generated)
/// Purpose: Unified payment data models for Delivery Ways
/// Last updated: 2025-11-18 COM-INTEG-036

import 'src/payment_method.dart';

enum SetupIntentStatus { requiresAction, succeeded, failed, canceled }

enum PaymentStatus { requiresAction, processing, succeeded, canceled, failed }

class Amount {
  final int value; // in minor units (e.g., cents)
  final String currency;

  const Amount(this.value, this.currency);

  @override
  String toString() => '$value $currency';
}

class Currency {
  final String code; // e.g., 'USD', 'EUR'

  const Currency(this.code);

  @override
  String toString() => code;
}

class CardDetails {
  final String number;
  final String expiryMonth;
  final String expiryYear;
  final String cvc;
  final String? cardholderName;

  const CardDetails({
    required this.number,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvc,
    this.cardholderName,
  });
}

class PaymentMethodParams {
  final PaymentMethodType type;
  // يمكن توسيعها لاحقاً (billing, token, platform params...)
  const PaymentMethodParams(this.type);
}

class PaymentIntent {
  final String id;
  final int amount; // بالـ minor units (مثلاً سنت)
  final String currency; // "USD", "EUR", ...
  final String clientSecret;

  const PaymentIntent({
    required this.id,
    required this.amount,
    required this.currency,
    required this.clientSecret,
  });

}

class PaymentResult {
  final PaymentStatus status;
  final String? message;

  const PaymentResult({required this.status, this.message});

}

class SetupRequest {
  final String customerId;
  final bool useGooglePayIfAvailable;

  const SetupRequest({
    required this.customerId,
    this.useGooglePayIfAvailable = false,
  });

}

class SetupResult {
  final String paymentMethodId;
  final SetupIntentStatus status;
  final String? message;

  const SetupResult({
    required this.paymentMethodId,
    required this.status,
    this.message,
  });

}

class SavedPaymentMethod implements PaymentMethod {
  @override
  final String id;
  final String brand;
  final String last4;
  final int? expMonth;
  final int? expYear;
  final PaymentMethodType _type;

  const SavedPaymentMethod({
    required this.id,
    required this.brand,
    required this.last4,
    this.expMonth,
    this.expYear,
    required PaymentMethodType type,
  }) : _type = type;

  @override
  PaymentMethodType get type => _type;

  @override
  String get displayName => '$brand **** $last4';

  @override
  String? get iconUrl => null; // TODO: Add icon URLs for payment methods

  @override
  bool get isDefault => false; // TODO: Determine from backend

  @override
  bool get isAvailable => true;
}

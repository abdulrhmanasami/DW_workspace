/// Component|Model: PaymentModels
/// Created by: Cursor (auto-generated)
/// Purpose: Core payment data models with JSON serialization for Delivery Ways payment processing
/// Last updated: 2025-11-02

library payments_models;

import 'package:json_annotation/json_annotation.dart';
import 'payment_method.dart';
part 'payment_models.g.dart';

enum PaymentServiceType { defaultService, ride, parcel, food }

enum PaymentStatus { success, pending, failure }

@JsonSerializable()
class PaymentMetadata {
  final String orderId;
  final double amount;
  final String currency;
  final Map<String, dynamic>? extra;
  const PaymentMetadata({
    required this.orderId,
    required this.amount,
    required this.currency,
    this.extra,
  });
  factory PaymentMetadata.fromJson(Map<String, dynamic> json) =>
      _$PaymentMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentMetadataToJson(this);
}

@JsonSerializable()
class PaymentFailure {
  final String code;
  final String message;
  final Map<String, dynamic>? details;
  const PaymentFailure({
    required this.code,
    required this.message,
    this.details,
  });
  factory PaymentFailure.fromJson(Map<String, dynamic> json) =>
      _$PaymentFailureFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentFailureToJson(this);
}

@JsonSerializable()
class PaymentResult {
  final PaymentStatus status;
  final PaymentMetadata? metadata;
  final PaymentFailure? failure;
  const PaymentResult({required this.status, this.metadata, this.failure});
  factory PaymentResult.fromJson(Map<String, dynamic> json) =>
      _$PaymentResultFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentResultToJson(this);
}

// Legacy models for backward compatibility
enum LegacyPaymentStatus {
  requiresPaymentMethod,
  requiresConfirmation,
  processing,
  succeeded,
  canceled,
  refunded,
  failed,
  unknown,
}

class PaymentRequest {
  final int amountMinor;
  final String currency;
  final String? description;
  PaymentRequest({
    required this.amountMinor,
    required this.currency,
    this.description,
  });
}

class PaymentIntent {
  final String id;
  final int amountMinor;
  final String currency;
  final String? clientSecret;
  PaymentIntent({
    required this.id,
    required this.amountMinor,
    required this.currency,
    this.clientSecret,
  });
}

class LegacyPaymentResult {
  final LegacyPaymentStatus status;
  final String? transactionId;
  final String? error;
  LegacyPaymentResult({required this.status, this.transactionId, this.error});
}

/// مستخدم بعد الدفع في الطبقات العليا
class PostCheckoutResult {
  final bool success;
  final String? message;
  final LegacyPaymentResult? payment;
  PostCheckoutResult({required this.success, this.message, this.payment});
}

/// Checkout session status
enum CheckoutStatus { success, failure, pending, canceled }

/// Checkout request model
@JsonSerializable()
class CheckoutRequest {
  final String orderId;
  final double amount;
  final String currency;
  final Map<String, dynamic>? metadata;

  const CheckoutRequest({
    required this.orderId,
    required this.amount,
    required this.currency,
    this.metadata,
  });

  factory CheckoutRequest.fromJson(Map<String, dynamic> json) =>
      _$CheckoutRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CheckoutRequestToJson(this);
}

/// Checkout result model
@JsonSerializable()
class CheckoutResult {
  final CheckoutStatus status;
  final String? transactionId;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;

  const CheckoutResult({
    required this.status,
    this.transactionId,
    this.errorMessage,
    this.metadata,
  });

  factory CheckoutResult.fromJson(Map<String, dynamic> json) =>
      _$CheckoutResultFromJson(json);
  Map<String, dynamic> toJson() => _$CheckoutResultToJson(this);
}

/// Abstract payment method vault contract
abstract class PaymentMethodVault {
  Future<void> add(PaymentMethod method);
  Future<List<PaymentMethod>> list();
  Future<void> remove(String methodId);
}

/// Abstract checkout session contract
abstract class CheckoutSession {
  Future<String> create(CheckoutRequest request);
  Future<CheckoutResult> confirm(String sessionId);
  Future<void> cancel(String sessionId);
}

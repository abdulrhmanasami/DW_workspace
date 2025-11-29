/// Component: Stripe Intents Service
/// Created by: Cursor (auto-generated)
/// Purpose: Service for managing Stripe payment intents (create/confirm/cancel/status)
/// Last updated: 2025-11-11

import 'package:payments_shims/payments.dart';
import 'stripe_backend_client.dart';
import 'stripe_endpoints.dart';
import 'stripe_mappers.dart';

class CreateIntentResponse {
  final String clientSecret;
  final String? customerId;
  final String? intentId;

  const CreateIntentResponse({
    required this.clientSecret,
    this.customerId,
    this.intentId,
  });
}

class StripeIntentsService {
  final StripeBackendClient _client;
  final StripeEndpoints _endpoints;

  StripeIntentsService(this._client, this._endpoints);

  /// Create payment intent
  Future<CreateIntentResponse> createIntent(PaymentMethodParams params) async {
    try {
      final body = <String, dynamic>{
        'amount': 1000, // Amount in cents (example)
        'currency': 'usd',
        'payment_method_type': params.type.name,
        // Add more fields as needed
      };

      final response = await _client.postJson(
        _endpoints.createIntent,
        body,
      );

      final clientSecret = response['client_secret'] as String?;
      final customerId = response['customer_id'] as String?;
      final intentId = response['intent_id'] as String?;

      if (clientSecret == null) {
        throw PaymentFailure(
          code: 'MISSING_CLIENT_SECRET',
          message: 'Backend did not return client secret',
        );
      }

      return CreateIntentResponse(
        clientSecret: clientSecret,
        customerId: customerId,
        intentId: intentId,
      );
    } catch (e) {
      if (e is PaymentFailure) rethrow;
      throw PaymentFailure(
        code: 'INTENT_CREATION_FAILED',
        message: 'Failed to create payment intent: ${e.toString()}',
      );
    }
  }

  /// Fetch payment intent status
  Future<PaymentStatus> fetchStatus(String paymentId) async {
    try {
      final response = await _client.getJson(
        _endpoints.intentStatusUrl(paymentId),
      );

      final status = response['status'] as String?;
      return mapStripeStatus(status);
    } catch (e) {
      if (e is PaymentFailure) rethrow;
      throw PaymentFailure(
        code: 'STATUS_FETCH_FAILED',
        message: 'Failed to fetch payment status: ${e.toString()}',
      );
    }
  }

  /// Confirm payment intent (if needed)
  Future<PaymentResult> confirmIntent(String intentId) async {
    try {
      final response = await _client.postJson(
        _endpoints.confirmIntent,
        {'intent_id': intentId},
      );

      final status = response['status'] as String?;
      return PaymentResult(
        status: mapStripeStatus(status),
        message: response['message'] as String?,
      );
    } catch (e) {
      if (e is PaymentFailure) rethrow;
      throw PaymentFailure(
        code: 'INTENT_CONFIRMATION_FAILED',
        message: 'Failed to confirm payment intent: ${e.toString()}',
      );
    }
  }

  /// Cancel payment intent
  Future<void> cancelIntent(String intentId) async {
    try {
      await _client.postJson(
        _endpoints.cancelIntent,
        {'intent_id': intentId},
      );
    } catch (e) {
      if (e is PaymentFailure) rethrow;
      throw PaymentFailure(
        code: 'INTENT_CANCELLATION_FAILED',
        message: 'Failed to cancel payment intent: ${e.toString()}',
      );
    }
  }
}

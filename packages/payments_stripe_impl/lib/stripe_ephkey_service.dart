/// Component: Stripe Ephemeral Key Service
/// Created by: Cursor (auto-generated)
/// Purpose: Service for creating and managing Stripe ephemeral keys
/// Last updated: 2025-11-11

import 'package:payments/src/payment_models.dart' as legacy;

import 'stripe_backend_client.dart';
import 'stripe_endpoints.dart';

class StripeEphemeralKeyService {
  final StripeBackendClient _client;
  final StripeEndpoints _endpoints;

  StripeEphemeralKeyService(this._client, this._endpoints);

  /// Create ephemeral key for customer
  Future<String> createEphemeralKey({
    required String customerId,
    String? intentId,
  }) async {
    try {
      final body = <String, dynamic>{
        'customer_id': customerId,
        if (intentId != null) 'intent_id': intentId,
      };

      final response = await _client.postJson(
        _endpoints.createEphemeralKey,
        body,
      );

      final ephemeralKey = response['ephemeral_key'] as String?;
      if (ephemeralKey == null) {
        throw const legacy.PaymentFailure(
          code: 'MISSING_EPHEMERAL_KEY',
          message: 'Backend did not return ephemeral key',
        );
      }

      return ephemeralKey;
    } catch (e) {
      if (e is legacy.PaymentFailure) rethrow;
      throw legacy.PaymentFailure(
        code: 'EPHEMERAL_KEY_CREATION_FAILED',
        message: 'Failed to create ephemeral key: ${e.toString()}',
      );
    }
  }

  /// Validate ephemeral key format (basic check)
  bool isValidEphemeralKey(String key) {
    // Stripe ephemeral keys start with 'ephkey_'
    return key.startsWith('ephkey_') && key.length > 20;
  }
}

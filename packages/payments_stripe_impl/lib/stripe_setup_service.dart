/// Component: Stripe Setup Service
/// Created by: Cursor (auto-generated)
/// Purpose: Handles SetupIntent creation and payment method management
/// Last updated: 2025-11-11

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe_sdk;
import 'package:payments_shims/payments.dart';

import 'stripe_backend_client.dart';
import 'stripe_config.dart';
import 'stripe_ephkey_service.dart';
import 'stripe_mappers.dart';

class StripeSetupService {
  final StripeBackendClient _backendClient;
  final StripeEphemeralKeyService _ephkeyService;
  final StripeConfig _config;

  StripeSetupService(this._backendClient, this._ephkeyService, this._config);

  /// Create a setup intent for saving payment methods
  Future<String> createSetupIntent({
    required String customerId,
  }) async {
    try {
      final response = await _backendClient.post(
        '/payments/create-setup-intent',
        body: {
          'customer_id': customerId,
        },
      );

      final clientSecret = response['client_secret'] as String?;
      if (clientSecret == null || clientSecret.isEmpty) {
        throw Exception('Invalid setup intent response: missing client_secret');
      }

      return clientSecret;
    } catch (e) {
      throw Exception('Failed to create setup intent: ${e.toString()}');
    }
  }

  /// Present setup payment sheet for saving payment methods
  Future<SetupResult> presentSetupSheet({
    required String setupIntentClientSecret,
    required String customerId,
    bool useGooglePayIfAvailable = false,
  }) async {
    try {
      // Create ephemeral key for the customer
      final ephemeralKey = await _ephkeyService.createEphemeralKey(
        customerId: customerId,
      );

      // Check Google Pay support if requested
      bool googlePaySupported = false;
      if (useGooglePayIfAvailable && _config.googlePayEnabled) {
        try {
          // Try new API first, fallback to old API if not available
          googlePaySupported =
              await stripe_sdk.Stripe.instance.isGooglePaySupported(
            const stripe_sdk.IsGooglePaySupportedParams(),
          );
        } catch (e) {
          googlePaySupported = false;
        }
      }

      // Initialize payment sheet for setup intent
      await stripe_sdk.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe_sdk.SetupPaymentSheetParameters(
          merchantDisplayName: _config.merchantDisplayName ?? 'Delivery Ways',
          setupIntentClientSecret: setupIntentClientSecret,
          customerId: customerId,
          customerEphemeralKeySecret: ephemeralKey,
          style: ThemeMode.system,
          googlePay: googlePaySupported
              ? stripe_sdk.PaymentSheetGooglePay(
                  merchantCountryCode: _config.merchantCountryCode,
                  currencyCode: 'USD',
                  testEnv: true,
                )
              : null,
        ),
      );

      // Present the setup sheet
      await stripe_sdk.Stripe.instance.presentPaymentSheet();

      // Retrieve the setup intent to get payment method ID
      final setupIntent = await stripe_sdk.Stripe.instance
          .retrieveSetupIntent(setupIntentClientSecret);

      if (setupIntent.paymentMethodId == null) {
        throw Exception(
            'Setup intent completed but no payment method ID returned');
      }

      return SetupResult(
        paymentMethodId: setupIntent.paymentMethodId!,
        status: SetupIntentStatus.succeeded,
      );
    } on stripe_sdk.StripeException catch (e) {
      final failure = mapStripeException(e);
      return SetupResult(
        paymentMethodId: '',
        status: SetupIntentStatus.failed,
        message: failure.message,
      );
    } catch (e) {
      return SetupResult(
        paymentMethodId: '',
        status: SetupIntentStatus.failed,
        message: 'Setup failed: ${e.toString()}',
      );
    }
  }

  /// List saved payment methods for a customer
  Future<List<SavedPaymentMethod>> listPaymentMethods({
    required String customerId,
  }) async {
    try {
      final response = await _backendClient.get(
        '/payments/list-payment-methods',
        queryParameters: {'customer_id': customerId},
      );

      final paymentMethods =
          response['payment_methods'] as List<dynamic>? ?? [];

      return paymentMethods.map((pm) {
        return SavedPaymentMethod(
          id: pm['id'] as String,
          brand: pm['card']['brand'] as String? ?? 'Unknown',
          last4: pm['card']['last4'] as String? ?? '****',
          expMonth: pm['card']['exp_month'] as int?,
          expYear: pm['card']['exp_year'] as int?,
          type: PaymentMethodType.card, // Assuming card for now
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to list payment methods: ${e.toString()}');
    }
  }

  /// Detach a payment method from a customer
  Future<void> detachPaymentMethod({
    required String customerId,
    required String paymentMethodId,
  }) async {
    try {
      await _backendClient.post(
        '/payments/detach-payment-method',
        body: {
          'customer_id': customerId,
          'payment_method_id': paymentMethodId,
        },
      );
    } catch (e) {
      throw Exception('Failed to detach payment method: ${e.toString()}');
    }
  }
}

/// Component: Stripe Payment Sheet Flow
/// Created by: Cursor (auto-generated)
/// Purpose: Handles PaymentSheet presentation and 3DS flow
/// Last updated: 2025-11-11

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe_sdk;
import 'package:payments_shims/payments.dart';

import 'stripe_config.dart';
import 'stripe_ephkey_service.dart';
import 'stripe_mappers.dart';

class StripePaymentSheetFlow {
  final StripeEphemeralKeyService _ephkeyService;
  final StripeConfig _config;

  StripePaymentSheetFlow(this._ephkeyService, this._config);

  /// Present payment sheet with full flow including 3DS and Google Pay support
  Future<PaymentResult> presentPaymentSheet({
    required String clientSecret,
    String? customerId,
    String? merchantDisplayName,
  }) async {
    try {
      // Create ephemeral key if customer ID is provided
      String? ephemeralKey;
      if (customerId != null) {
        ephemeralKey = await _ephkeyService.createEphemeralKey(
          customerId: customerId,
        );
      }

      // Check Google Pay support and configure
      bool googlePaySupported = false;
      if (_config.googlePayEnabled) {
        try {
          // Try new API first, fallback to old API if not available
          googlePaySupported =
              await stripe_sdk.Stripe.instance.isGooglePaySupported(
            const stripe_sdk.IsGooglePaySupportedParams(),
          );
        } catch (e) {
          // Google Pay not supported or error occurred, continue without it
          googlePaySupported = false;
        }
      }

      // Initialize payment sheet with Google Pay support if available
      await stripe_sdk.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe_sdk.SetupPaymentSheetParameters(
          merchantDisplayName: merchantDisplayName ??
              _config.merchantDisplayName ??
              'Delivery Ways',
          paymentIntentClientSecret: clientSecret,
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

      // Present payment sheet (handles 3DS automatically)
      await stripe_sdk.Stripe.instance.presentPaymentSheet();

      // If we reach here, payment was successful
      return const PaymentResult(status: PaymentStatus.succeeded);
    } on stripe_sdk.StripeException catch (e) {
      final paymentFailure = mapStripeException(e);
      return PaymentResult(
        status: PaymentStatus.failed,
        message: paymentFailure.message,
      );
    } catch (e) {
      return PaymentResult(
        status: PaymentStatus.failed,
        message: 'Payment sheet failed: ${e.toString()}',
      );
    }
  }

  /// Reset payment sheet (useful for cleanup)
  Future<void> resetPaymentSheet() async {
    // Reset payment sheet customer ID
    // Note: Stripe SDK may not have this method, using alternative approach
    // await stripe_sdk.Stripe.instance.resetPaymentSheetCustomerId();
  }
}

/// Component: Stripe Gateway Implementation
/// Created by: Cursor (auto-generated)
/// Purpose: Stripe implementation of PaymentGateway with PaymentSheet and 3DS
/// Last updated: 2025-11-11

import 'dart:async';

import 'package:flutter_stripe/flutter_stripe.dart' as stripe_sdk;
import 'package:payments/payments.dart';
import 'package:payments_shims/payments.dart';

import 'stripe_config.dart';
import 'stripe_intents_service.dart';
import 'stripe_payment_sheet_flow.dart';
import 'stripe_setup_service.dart';
import 'stripe_mappers.dart';

class StripeGateway implements PaymentsGateway {
  final StripeConfig _config;
  final StripeIntentsService _intentsService;
  final StripePaymentSheetFlow _paymentSheetFlow;
  final StripeSetupService _setupService;
  final Map<String, StreamController<PaymentStatus>> _statusControllers = {};

  StripeGateway({
    required StripeConfig config,
    required StripeIntentsService intentsService,
    required StripePaymentSheetFlow paymentSheetFlow,
    required StripeSetupService setupService,
  })  : _config = config,
        _intentsService = intentsService,
        _paymentSheetFlow = paymentSheetFlow,
        _setupService = setupService;

  Future<void> init({required String publishableKey}) async {
    // Initialize Stripe SDK
    stripe_sdk.Stripe.publishableKey = _config.publishableKey;

    // Configure appearance if needed
    await stripe_sdk.Stripe.instance.applySettings();
  }

  @override
  Future<PaymentIntent> createIntent(Amount amount, Currency currency) async {
    try {
      // Create payment method params from metadata or defaults
      const paymentMethodType = PaymentMethodType.card; // Default to card
      const params = PaymentMethodParams(paymentMethodType);

      // Create intent via backend
      final response = await _intentsService.createIntent(params);

      return PaymentIntent(
        id: response.intentId ?? 'pi_${DateTime.now().millisecondsSinceEpoch}',
        amount: amount.value,
        currency: currency.code,
        clientSecret: response.clientSecret,
      );
    } catch (e) {
      throw mapStripeException(e);
    }
  }

  @override
  Future<PaymentResult> confirmIntent(
    String clientSecret, {
    PaymentMethod? method,
  }) async {
    try {
      // Use payment sheet flow for confirmation (handles 3DS automatically)
      final result = await _paymentSheetFlow.presentPaymentSheet(
        clientSecret: clientSecret,
        merchantDisplayName: _config.merchantDisplayName,
      );

      return result;
    } catch (e) {
      final failure = mapPaymentSheetError(e);
      return PaymentResult(
        status: PaymentStatus.failed,
        message: failure.message,
      );
    }
  }

  Future<void> cancel({required String intentId}) async {
    try {
      // Cancel payment intent via backend
      await _intentsService.cancelIntent(intentId);

      // Update status
      _statusControllers[intentId]?.add(PaymentStatus.canceled);
    } catch (e) {
      // Even if backend call fails, mark as canceled locally
      _statusControllers[intentId]?.add(PaymentStatus.canceled);
      rethrow;
    }
  }

  Stream<PaymentStatus> statusStream(String intentId) {
    final controller = _statusControllers.putIfAbsent(
      intentId,
      () => StreamController<PaymentStatus>.broadcast(),
    );

    // Start polling for status updates
    _startStatusPolling(intentId, controller);

    return controller.stream;
  }

  void _startStatusPolling(
      String intentId, StreamController<PaymentStatus> controller) {
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        final status = await _intentsService.fetchStatus(intentId);
        controller.add(status);

        // Stop polling if payment is in a final state
        if (status == PaymentStatus.succeeded ||
            status == PaymentStatus.failed ||
            status == PaymentStatus.canceled) {
          timer.cancel();
        }
      } catch (e) {
        // On error, assume failed and stop polling
        controller.add(PaymentStatus.failed);
        timer.cancel();
      }
    });
  }

  @override
  Future<SetupResult> setupPaymentMethod({
    required SetupRequest request,
  }) async {
    try {
      // Create setup intent via backend
      final setupIntentClientSecret = await _setupService.createSetupIntent(
        customerId: request.customerId,
      );

      // Present setup sheet
      final result = await _setupService.presentSetupSheet(
        setupIntentClientSecret: setupIntentClientSecret,
        customerId: request.customerId,
        useGooglePayIfAvailable: request.useGooglePayIfAvailable,
      );

      return result;
    } catch (e) {
      return SetupResult(
        paymentMethodId: '',
        status: SetupIntentStatus.failed,
        message: 'Setup failed: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<SavedPaymentMethod>> listMethods({
    required String customerId,
  }) async {
    if (customerId.isEmpty) {
      return [];
    }
    try {
      return await _setupService.listPaymentMethods(customerId: customerId);
    } catch (e) {
      // Return empty list on error
      return [];
    }
  }

  @override
  Future<void> detachPaymentMethod({
    required String customerId,
    required String paymentMethodId,
  }) async {
    try {
      await _setupService.detachPaymentMethod(
        customerId: customerId,
        paymentMethodId: paymentMethodId,
      );
    } catch (e) {
      throw Exception('Failed to detach payment method: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    for (final controller in _statusControllers.values) {
      controller.close();
    }
    _statusControllers.clear();
  }
}

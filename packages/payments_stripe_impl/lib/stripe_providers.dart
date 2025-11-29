/// Component: Stripe Providers
/// Created by: Cursor (auto-generated)
/// Purpose: Builders for Stripe payment gateway and payment service
/// Last updated: 2025-11-15

import 'package:foundation_shims/payments_config.dart';
import 'package:payments_shims/payments.dart' as gateway;
import 'package:payments/src/payment_models.dart' as legacy;
import 'package:payments/src/payment_service.dart' show PaymentService;

import 'stripe_backend_client.dart';
import 'stripe_config.dart';
import 'stripe_endpoints.dart';
import 'stripe_ephkey_service.dart';
import 'stripe_gateway.dart';
import 'stripe_intents_service.dart';
import 'stripe_payment_sheet_flow.dart';
import 'stripe_setup_service.dart';

Future<gateway.PaymentGateway> buildStripeGateway(PaymentsConfig cfg) async {
  final Uri baseUrl = cfg.backendBaseUrl ??
      (throw StateError('payments_backend_base_url is required for Stripe.'));

  final stripeConfig = StripeConfig(
    publishableKey: cfg.publishableKey,
    backendBaseUrl: baseUrl,
    merchantDisplayName:
        cfg.merchantDisplayName.isEmpty ? null : cfg.merchantDisplayName,
    googlePayEnabled: cfg.googlePayEnabled,
    merchantCountryCode: cfg.merchantCountryCode,
    merchantCategoryCode: cfg.merchantCategoryCode,
    usePaymentSheet: cfg.usePaymentSheet,
  );

  final backendClient = StripeBackendClient(baseUrl: baseUrl);
  final endpoints = StripeEndpoints.fromBaseUrl(baseUrl);
  final ephKeyService = StripeEphemeralKeyService(backendClient, endpoints);
  final intentsService = StripeIntentsService(backendClient, endpoints);
  final paymentSheetFlow = StripePaymentSheetFlow(ephKeyService, stripeConfig);
  final setupService =
      StripeSetupService(backendClient, ephKeyService, stripeConfig);

  final gatewayInstance = StripeGateway(
    config: stripeConfig,
    intentsService: intentsService,
    paymentSheetFlow: paymentSheetFlow,
    setupService: setupService,
  );

  await gatewayInstance.init(publishableKey: cfg.publishableKey);
  return gatewayInstance;
}

Future<PaymentService> buildStripePaymentService(PaymentsConfig cfg) async {
  final gatewayInstance = await buildStripeGateway(cfg);
  return StripePaymentService(
    gateway: gatewayInstance as StripeGateway,
    cfg: cfg,
  );
}

class StripePaymentService implements PaymentService {
  StripePaymentService({
    required StripeGateway gateway,
    required PaymentsConfig cfg,
  })  : _gateway = gateway,
        _cfg = cfg;

  final StripeGateway _gateway;
  final PaymentsConfig _cfg;
  final Map<String, gateway.PaymentIntent> _intentByOrder = {};

  // PaymentService implementation
  @override
  Future<legacy.PaymentResult> pay(legacy.PaymentMetadata metadata) async {
    try {
      final intent = await _gateway.createIntent(
        gateway.Amount(_toMinorUnits(metadata.amount), metadata.currency),
        gateway.Currency(metadata.currency),
      );
      _intentByOrder[metadata.orderId] = intent;

      if (!_cfg.usePaymentSheet) {
        return legacy.PaymentResult(
          status: legacy.PaymentStatus.pending,
          metadata: metadata,
        );
      }

      final result = await _gateway.confirmIntent(intent.clientSecret);
      return _mapGatewayResult(result, metadata);
    } catch (error) {
      return legacy.PaymentResult(
        status: legacy.PaymentStatus.failure,
        metadata: metadata,
        failure: legacy.PaymentFailure(
          code: 'PAYMENT_ERROR',
          message: error.toString(),
        ),
      );
    }
  }

  @override
  Future<legacy.PaymentResult> refund(String orderId, {double? amount}) async {
    try {
      final intent = _intentByOrder[orderId];
      if (intent == null) {
        return const legacy.PaymentResult(
          status: legacy.PaymentStatus.failure,
          failure: legacy.PaymentFailure(
            code: 'INTENT_NOT_FOUND',
            message: 'No payment intent cached for this order',
          ),
        );
      }

      await _gateway.cancel(intentId: intent.id);
      return legacy.PaymentResult(
        status: legacy.PaymentStatus.success,
        metadata: legacy.PaymentMetadata(
          orderId: orderId,
          amount: amount ?? intent.amount / 100,
          currency: intent.currency,
        ),
      );
    } catch (error) {
      return legacy.PaymentResult(
        status: legacy.PaymentStatus.failure,
        failure: legacy.PaymentFailure(
          code: 'REFUND_ERROR',
          message: error.toString(),
        ),
      );
    }
  }

  void dispose() {
    _intentByOrder.clear();
    _gateway.dispose();
  }

  legacy.PaymentResult _mapGatewayResult(
    gateway.PaymentResult result,
    legacy.PaymentMetadata metadata,
  ) {
    final status = _mapStatus(result.status);
    return legacy.PaymentResult(
      status: status,
      metadata: metadata,
      failure: status == legacy.PaymentStatus.failure
          ? legacy.PaymentFailure(
              code: 'PAYMENT_FAILED',
              message: result.message ?? 'Payment failed',
            )
          : null,
    );
  }

  legacy.PaymentStatus _mapStatus(gateway.PaymentStatus status) {
    switch (status) {
      case gateway.PaymentStatus.succeeded:
        return legacy.PaymentStatus.success;
      case gateway.PaymentStatus.processing:
      case gateway.PaymentStatus.requiresAction:
        return legacy.PaymentStatus.pending;
      case gateway.PaymentStatus.canceled:
      case gateway.PaymentStatus.failed:
        return legacy.PaymentStatus.failure;
    }
  }

  int _toMinorUnits(double amount) => (amount * 100).round();
}

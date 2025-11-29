/// Component: Payment Providers
/// Created by: Cursor (auto-generated)
/// Purpose: Neutral payment factory with Stripe wiring hidden from app/lib
/// Last updated: 2025-11-15

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_shims/payments_config.dart';
import 'package:payments_adapter_stripe/stripe_gateway.dart' as stripe_adapter;
import 'package:payments_stub_impl/payments_stub_impl.dart' as stub_impl;

import 'contracts.dart';
import 'models.dart';
import 'src/impl/stubs.dart';
import 'src/payment_service.dart';

PaymentService? _activeService;
PaymentGateway? _activeGateway;
PaymentsConfig? _activeConfig;
PaymentsSheet? _activeSheet;

/// Lazily build the payment service using the supplied configuration.
Future<PaymentService> getPaymentService({required PaymentsConfig cfg}) async {
  _assertConfigReady(cfg);
  if (_activeService != null && _activeConfig == cfg) {
    return _activeService!;
  }

  final PaymentService service = await _buildStripeService(cfg);

  final PaymentGateway gateway = service is PaymentGateway
      ? service as PaymentGateway
      : await _buildStripeGateway(cfg);

  _setActiveBinding(service: service, gateway: gateway, cfg: cfg);
  return service;
}

/// Returns the cached payment service or throws if it was not initialized.
PaymentService ensurePaymentService() {
  final service = _activeService;
  if (service == null) {
    throw StateError(
      'PaymentService not initialized. Call getPaymentService(...) first.',
    );
  }
  return service;
}

/// Returns the cached payment gateway or throws if it was not initialized.
PaymentGateway ensurePaymentGateway() {
  final gateway = _activeGateway;
  if (gateway == null) {
    throw StateError(
      'PaymentGateway not initialized. Call getPaymentService(...) first.',
    );
  }
  return gateway;
}

/// Ensures a gateway is ready for the provided configuration.
Future<PaymentGateway> ensurePaymentGatewayReady({
  required PaymentsConfig cfg,
}) async {
  _assertConfigReady(cfg);
  if (_activeGateway != null && _activeConfig == cfg) {
    return _activeGateway!;
  }
  await getPaymentService(cfg: cfg);
  return ensurePaymentGateway();
}

PaymentsSheet ensurePaymentSheet() {
  final sheet = _activeSheet;
  if (sheet == null) {
    throw StateError(
      'PaymentsSheet not initialized. Call getPaymentService(...) first.',
    );
  }
  return sheet;
}

/// Builds a stub gateway (compile-only fallback). Use only behind kill-switches
/// or in tests; not intended for production flows.
PaymentGateway buildStubPaymentGateway() => stub_impl.NoOpPaymentsGateway();

/// Builds a stub-backed [PaymentService] without touching global caches.
PaymentService buildStubPaymentService({PaymentsConfig? cfg}) {
  return _buildStubService();
}

final paymentGatewayProvider = Provider<PaymentGateway>((_) {
  return ensurePaymentGateway();
});

final paymentsSheetProvider = Provider<PaymentsSheet>((_) {
  return ensurePaymentSheet();
});

Future<PaymentService> _buildStripeService(PaymentsConfig cfg) {
  return stripe_adapter.buildStripePaymentService(cfg);
}

Future<PaymentGateway> _buildStripeGateway(PaymentsConfig cfg) {
  _assertConfigReady(cfg);
  return stripe_adapter.buildStripeGateway(cfg);
}

PaymentService _buildStubService() => StubPaymentService();

void _setActiveBinding({
  required PaymentService service,
  required PaymentGateway gateway,
  required PaymentsConfig cfg,
}) {
  _activeService = service;
  _activeGateway?.dispose();
  _activeGateway = gateway;
  _activeSheet = _GatewayBackedPaymentsSheet(gateway);
  _activeConfig = cfg;
}

void _assertConfigReady(PaymentsConfig cfg) {
  if (cfg.isStripeReady) {
    return;
  }
  throw StateError(
    'PaymentsConfig is incomplete (publishable key, backend base URL, and '
    'environment are required). Use buildStubPaymentGateway() via the '
    'payments kill-switch when a stub is desired.',
  );
}

class _GatewayBackedPaymentsSheet implements PaymentsSheet {
  _GatewayBackedPaymentsSheet(this._gateway);

  final PaymentGateway _gateway;

  @override
  Future<PaymentResult> present({required String clientSecret}) {
    return _gateway.confirmIntent(clientSecret);
  }
}

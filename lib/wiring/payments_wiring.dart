/// Component: Payments Wiring
/// Created by: Cursor (auto-generated)
/// Purpose: Payment services wiring using Riverpod providers
/// Last updated: 2025-11-25 DW-COMMERCE-PHASE4-COM-002

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payments/payments.dart' as pay;

import '../state/infra/payments_providers.dart';

/// Provides the real PaymentsGateway wired through the payments package.
final paymentsGatewayProvider =
    FutureProvider<pay.PaymentsGateway>((ref) async {
  final runtimeConfig = ref.watch(paymentsRuntimeConfigProvider);
  final cfg = runtimeConfig.config;
  if (cfg == null) {
    throw StateError(
      'Payments runtime config incomplete; gateway unavailable',
    );
  }
  await pay.getPaymentService(cfg: cfg);
  return ref.read(pay.paymentGatewayProvider) as pay.PaymentsGateway;
});

/// Provides the PaymentSheet facade backed by the active PaymentsGateway.
final paymentsSheetProvider = FutureProvider<pay.PaymentsSheet>((ref) async {
  final runtimeConfig = ref.watch(paymentsRuntimeConfigProvider);
  final cfg = runtimeConfig.config;
  if (cfg == null) {
    throw StateError(
      'Payments runtime config incomplete; sheet unavailable',
    );
  }
  await pay.getPaymentService(cfg: cfg);
  return ref.read(pay.paymentsSheetProvider);
});

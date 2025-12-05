/// Component: Stripe Providers
/// Created by: Cursor (auto-generated)
/// Purpose: Riverpod providers for Stripe gateway
/// Last updated: 2025-11-11

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payments/payments.dart';
import 'stripe_gateway.dart';

final stripeGatewayProvider = FutureProvider<PaymentGateway>((ref) async {
  // Get config and build gateway
  final cfg = loadPaymentsConfig();
  return buildStripeGateway(cfg);
});

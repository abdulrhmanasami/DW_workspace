import 'package:foundation_shims/payments_config.dart';
import 'package:payments_shims/payments.dart';
import 'package:payments_stripe_impl/stripe_providers.dart' as impl;

Future<PaymentService> buildStripePaymentService(PaymentsConfig cfg) {
  return impl.buildStripePaymentService(cfg);
}

Future<PaymentGateway> buildStripeGateway(PaymentsConfig cfg) {
  return impl.buildStripeGateway(cfg);
}

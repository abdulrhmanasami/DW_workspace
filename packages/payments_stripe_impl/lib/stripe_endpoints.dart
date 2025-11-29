/// Component: Stripe Endpoints Configuration
/// Created by: Cursor (auto-generated)
/// Purpose: Centralized endpoint definitions for Stripe backend integration
/// Last updated: 2025-11-11

class StripeEndpoints {
  final Uri createIntent; // /payments/create-intent
  final Uri confirmIntent; // /payments/confirm-intent
  final Uri cancelIntent; // /payments/cancel-intent
  final Uri intentStatus; // /payments/intent-status/{id}
  final Uri createEphemeralKey; // /stripe/ephemeral-keys

  const StripeEndpoints({
    required this.createIntent,
    required this.confirmIntent,
    required this.cancelIntent,
    required this.createEphemeralKey,
    required this.intentStatus,
  });

  factory StripeEndpoints.fromBaseUrl(Uri baseUrl) {
    return StripeEndpoints(
      createIntent: baseUrl.resolve('payments/create-intent'),
      confirmIntent: baseUrl.resolve('payments/confirm-intent'),
      cancelIntent: baseUrl.resolve('payments/cancel-intent'),
      intentStatus: baseUrl.resolve('payments/intent-status/'),
      createEphemeralKey: baseUrl.resolve('stripe/ephemeral-keys'),
    );
  }

  /// Build intent status URL with payment ID
  Uri intentStatusUrl(String paymentId) {
    return intentStatus.resolve('$paymentId');
  }
}

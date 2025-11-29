/// Component: WebhookEvent
/// Created by: Cursor (auto-generated)
/// Purpose: Webhook event domain model extracted from app/lib
/// Last updated: 2025-01-27

/// Webhook event types
enum WebhookEventType {
  paymentIntentSucceeded,
  paymentIntentPaymentFailed,
  paymentIntentCanceled,
  paymentMethodAttached,
  customerCreated,
  unknown,
}

/// Webhook event data
class WebhookEvent {
  final String id;
  final WebhookEventType type;
  final String intentId;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final int latencyMs;

  const WebhookEvent({
    required this.id,
    required this.type,
    required this.intentId,
    required this.data,
    required this.timestamp,
    required this.latencyMs,
  });

  factory WebhookEvent.fromJson(Map<String, dynamic> json) {
    final WebhookEventType eventType = _parseEventType(json['type'] as String?);
    final String intentId = _extractIntentId(
      json['data'] as Map<String, dynamic>?,
    );

    return WebhookEvent(
      id: json['id'] as String? ?? '',
      type: eventType,
      intentId: intentId,
      data: json['data'] as Map<String, dynamic>? ?? <String, dynamic>{},
      timestamp: DateTime.now(),
      latencyMs: 0, // Will be calculated by monitor
    );
  }

  static WebhookEventType _parseEventType(String? type) {
    switch (type) {
      case 'payment_intent.succeeded':
        return WebhookEventType.paymentIntentSucceeded;
      case 'payment_intent.payment_failed':
        return WebhookEventType.paymentIntentPaymentFailed;
      case 'payment_intent.canceled':
        return WebhookEventType.paymentIntentCanceled;
      case 'payment_method.attached':
        return WebhookEventType.paymentMethodAttached;
      case 'customer.created':
        return WebhookEventType.customerCreated;
      default:
        return WebhookEventType.unknown;
    }
  }

  static String _extractIntentId(Map<String, dynamic>? data) {
    final Map<String, dynamic>? object =
        data?['object'] as Map<String, dynamic>?;
    if (object == null) return '';
    return object['id'] as String? ?? '';
  }
}

/// Component: Payment Status Contracts
/// Created by: Cursor (auto-generated)
/// Purpose: Payment processing status contracts
/// Last updated: 2025-11-03

/// Payment processing status
enum PaymentProcessingStatus {
  initializing,
  processing,
  requiresAction,
  succeeded,
  failed,
  canceled,
  refunded,
}

/// Payment intent status from payment processor
enum PaymentIntentStatus {
  requiresPaymentMethod,
  requiresConfirmation,
  requiresAction,
  processing,
  succeeded,
  canceled,
}

/// Abstract payment status contract
abstract class PaymentStatus {
  PaymentProcessingStatus get processingStatus;
  PaymentIntentStatus? get intentStatus;
  String? get transactionId;
  DateTime? get processedAt;
  String? get errorMessage;
}

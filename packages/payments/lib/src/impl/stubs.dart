/// Component: Payment Stubs
/// Created by: Cursor (auto-generated)
/// Purpose: Safe stub implementations for payment contracts - compile-ready without SDK logic
/// Last updated: 2025-11-10

import 'package:payments/src/payment_method.dart';
import 'package:payments/src/payment_models.dart';
import 'package:payments/src/payment_service.dart';

/// Stub implementation of PaymentMethodVault
class StubPaymentMethodVault implements PaymentMethodVault {
  final List<StubPaymentMethod> _methods = [];

  @override
  Future<void> add(PaymentMethod method) async {
    // Stub: Add method to in-memory list (no persistence)
    _methods.add(
      StubPaymentMethod(
        id: method.id,
        type: method.type,
        displayName: method.displayName,
        iconUrl: method.iconUrl,
        isDefault: method.isDefault,
      ),
    );
  }

  @override
  Future<List<PaymentMethod>> list() async {
    // Stub: Return in-memory list
    return _methods;
  }

  @override
  Future<void> remove(String methodId) async {
    // Stub: Remove from in-memory list
    _methods.removeWhere((method) => method.id == methodId);
  }
}

/// Stub implementation of PaymentMethod
class StubPaymentMethod implements PaymentMethod {
  @override
  final String id;
  @override
  final PaymentMethodType type;
  @override
  final String displayName;
  @override
  final String? iconUrl;
  @override
  final bool isDefault;

  const StubPaymentMethod({
    required this.id,
    required this.type,
    required this.displayName,
    this.iconUrl,
    this.isDefault = false,
  });

  @override
  bool get isAvailable => true;
}

/// Stub implementation of CheckoutSession
class StubCheckoutSession implements CheckoutSession {
  final Map<String, CheckoutRequest> _sessions = {};

  @override
  Future<String> create(CheckoutRequest request) async {
    // Stub: Generate session ID and store request
    final sessionId =
        'checkout_session_${DateTime.now().millisecondsSinceEpoch}';
    _sessions[sessionId] = request;
    return sessionId;
  }

  @override
  Future<CheckoutResult> confirm(String sessionId) async {
    // Stub: Return success result (no actual payment processing)
    final request = _sessions[sessionId];
    if (request == null) {
      return const CheckoutResult(
        status: CheckoutStatus.failure,
        errorMessage: 'Session not found',
      );
    }

    return CheckoutResult(
      status: CheckoutStatus.success,
      transactionId: 'txn_${DateTime.now().millisecondsSinceEpoch}',
      metadata: {'orderId': request.orderId},
    );
  }

  @override
  Future<void> cancel(String sessionId) async {
    // Stub: Remove session
    _sessions.remove(sessionId);
  }
}

/// Stub implementation of PaymentService with additional contracts
class StubPaymentService
    implements PaymentService, PaymentMethodVault, CheckoutSession {
  final StubPaymentMethodVault _vault = StubPaymentMethodVault();
  final StubCheckoutSession _session = StubCheckoutSession();

  // PaymentService implementation
  @override
  Future<PaymentResult> pay(PaymentMetadata metadata) async {
    // Stub: Return success result with UnsupportedError for SDK requirement
    throw UnsupportedError(
      'Payment gateway not wired - use payments_stripe_impl',
    );
  }

  @override
  Future<PaymentResult> refund(String orderId, {double? amount}) async {
    // Stub: Return success result with UnsupportedError for SDK requirement
    throw UnsupportedError(
      'Payment gateway not wired - use payments_stripe_impl',
    );
  }

  // PaymentMethodVault implementation
  @override
  Future<void> add(PaymentMethod method) => _vault.add(method);

  @override
  Future<List<PaymentMethod>> list() => _vault.list();

  @override
  Future<void> remove(String methodId) => _vault.remove(methodId);

  // CheckoutSession implementation
  @override
  Future<String> create(CheckoutRequest request) => _session.create(request);

  @override
  Future<CheckoutResult> confirm(String sessionId) =>
      _session.confirm(sessionId);

  @override
  Future<void> cancel(String sessionId) => _session.cancel(sessionId);
}

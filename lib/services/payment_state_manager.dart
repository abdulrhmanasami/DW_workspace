/// Service: PaymentStateManager
/// Created by: Cursor (auto-generated)
/// Purpose: Payment state management with Riverpod for payment operations in Delivery Ways
/// Last updated: 2025-11-11

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payments/payments.dart';

// Payment state management now uses unified PaymentGateway contract

/// Payment state for UI management
class PaymentState {
  final bool processing;
  final PaymentResult? result;
  final String? error;

  const PaymentState({this.processing = false, this.result, this.error});

  PaymentState copyWith({
    bool? processing,
    PaymentResult? result,
    String? error,
  }) => PaymentState(
    processing: processing ?? this.processing,
    result: result ?? this.result,
    error: error ?? this.error,
  );
}

/// Payment controller using unified PaymentGateway
class PaymentController extends StateNotifier<PaymentState> {
  final PaymentGateway gateway;

  PaymentController(this.gateway) : super(const PaymentState());

  Future<void> processPayment({
    required int amount,
    required String currency,
    Map<String, Object?> metadata = const {},
  }) async {
    state = state.copyWith(processing: true, error: null, result: null);
    try {
      final intent = await gateway.createIntent(
        Amount(amount, currency),
        Currency(currency),
      );

      final result = await gateway.confirmIntent(
        intent.clientSecret,
      );

      state = state.copyWith(processing: false, result: result);
    } catch (e) {
      state = state.copyWith(
        processing: false,
        error: e.toString(),
        result: PaymentResult(
          status: PaymentStatus.failed,
          message: e.toString(),
        ),
      );
    }
  }
}

/// Provider for payment controller
final paymentControllerProvider =
    StateNotifierProvider<PaymentController, PaymentState>((ref) {
      final gateway = ref.watch(paymentGatewayProvider);
      return PaymentController(gateway);
    });

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payments/payments.dart';
import 'package:delivery_ways_clean/state/infra/payments_providers.dart';

class PaymentMethodsState {
  final AsyncValue<List<SavedPaymentMethod>> methods;
  final bool isAdding;
  final String? error;

  const PaymentMethodsState({
    required this.methods,
    this.isAdding = false,
    this.error,
  });

  PaymentMethodsState copyWith({
    AsyncValue<List<SavedPaymentMethod>>? methods,
    bool? isAdding,
    String? error,
    bool clearError = false,
  }) => PaymentMethodsState(
    methods: methods ?? this.methods,
    isAdding: isAdding ?? this.isAdding,
    error: clearError ? null : (error ?? this.error),
  );

  static PaymentMethodsState initial() =>
      const PaymentMethodsState(methods: AsyncValue.loading());
}

class PaymentMethodsController extends StateNotifier<PaymentMethodsState> {
  final PaymentGateway _gateway;
  final Future<String?> _customerIdFuture;

  PaymentMethodsController(this._gateway, this._customerIdFuture)
    : super(PaymentMethodsState.initial()) {
    _init();
  }

  Future<void> _init() async {
    try {
      await refresh();
    } catch (e) {
      state = state.copyWith(methods: AsyncValue.error(e, StackTrace.current));
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(methods: const AsyncValue.loading(), clearError: true);
    try {
      final customerId = await _customerIdFuture;
      if (customerId == null || customerId.isEmpty) {
        state = state.copyWith(
          methods: const AsyncValue.data(<SavedPaymentMethod>[]),
        );
        return;
      }
      final list = await _gateway.listMethods(customerId: customerId);
      state = state.copyWith(methods: AsyncValue.data(list));
    } catch (e) {
      state = state.copyWith(
        methods: AsyncValue.error(e, StackTrace.current),
        error: e.toString(),
      );
    }
  }

  Future<void> addMethod({required bool useGPayIfAvailable}) async {
    state = state.copyWith(isAdding: true, clearError: true);
    try {
      final customerId = _requireCustomerId(await _customerIdFuture);
      await _gateway.setupPaymentMethod(
        request: SetupRequest(
          customerId: customerId,
          useGooglePayIfAvailable: useGPayIfAvailable,
        ),
      );
      // If successful, refresh the list
      await refresh();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isAdding: false);
    }
  }

  Future<void> removeMethod(String paymentMethodId) async {
    try {
      final customerId = _requireCustomerId(await _customerIdFuture);
      await _gateway.detachPaymentMethod(
        customerId: customerId,
        paymentMethodId: paymentMethodId,
      );
      await refresh();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  String _requireCustomerId(String? customerId) {
    if (customerId == null || customerId.isEmpty) {
      throw StateError('Missing payment customer id');
    }
    return customerId;
  }
}

final paymentMethodsControllerProvider =
    StateNotifierProvider<PaymentMethodsController, PaymentMethodsState>((ref) {
      final gw = ref.watch(paymentGatewayProvider);
      final cidFuture = ref.watch(customerIdFutureProvider.future);
      return PaymentMethodsController(gw, cidFuture);
    });

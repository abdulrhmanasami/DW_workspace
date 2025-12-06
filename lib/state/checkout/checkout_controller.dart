import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'checkout_state.dart';

class CheckoutController extends StateNotifier<CheckoutState> {
  CheckoutController() : super(const CheckoutState());

  Future<void> submit() async {
    state = state.copyWith(status: CheckoutStatus.processing);
    // TODO: استدعِ حِزم الدفع/الشبكة عبر الشيمات (payments/network_shims) — لا SDKs مباشرة.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    state = state.copyWith(status: CheckoutStatus.success, orderId: 'order_#');
  }
}

final checkoutProvider =
    StateNotifierProvider<CheckoutController, CheckoutState>(
      (ref) => CheckoutController(),
    );

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cart_state.dart';

class CartController extends StateNotifier<CartState> {
  CartController() : super(const CartState());

  void setItemCount(int count) => state = state.copyWith(itemCount: count);
  void setTotal(double total, {String? currency}) => state = state.copyWith(
    total: total,
    currency: currency ?? state.currency,
  );
}

final cartProvider = StateNotifierProvider<CartController, CartState>(
  (ref) => CartController(),
);

import '../cart/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: Column(
        children: [
          Text('Items: ${cart.itemCount}'),
          Text('Total: ${cart.total.toStringAsFixed(2)} ${cart.currency}'),
          ElevatedButton(
            onPressed: () => ref
                .read(cartProvider.notifier)
                .setItemCount(cart.itemCount + 1),
            child: const Text('Add One'),
          ),
        ],
      ),
    );
  }
}

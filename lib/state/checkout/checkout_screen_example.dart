import '../checkout/checkout_controller.dart';
import '../checkout/checkout_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(checkoutProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Center(
        child: switch (st.status) {
          CheckoutStatus.idle => ElevatedButton(
            onPressed: () => ref.read(checkoutProvider.notifier).submit(),
            child: const Text('Pay'),
          ),
          CheckoutStatus.processing => const CircularProgressIndicator(),
          CheckoutStatus.success => Text('Success! order: ${st.orderId ?? ''}'),
          CheckoutStatus.failure => const Text('Failed'),
        },
      ),
    );
  }
}

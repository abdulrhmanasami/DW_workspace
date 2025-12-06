import 'package:delivery_ways_clean/state/orders/orders_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(ordersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: Column(
        children: [
          Text('Order: ${st.orderId ?? '-'}'),
          Text('Status: ${st.status.name}'),
          ElevatedButton(
            onPressed: () => ref
                .read(ordersProvider.notifier)
                .subscribe('orders', orderId: st.orderId ?? 'temp'),
            child: const Text('Subscribe'),
          ),
        ],
      ),
    );
  }
}

import 'package:delivery_ways_clean/state/orders/providers.dart';
import '../config/config_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);

    // Fail-closed: Check backend availability
    if (!AppConfig.canUseBackendFeature()) {
      return Scaffold(
        appBar: AppBar(title: const Text('Orders')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              AppConfig.backendPolicyMessage,
              textAlign: TextAlign.center,
              style: theme.typography.body1,
            ),
          ),
        ),
      );
    }

    final st = ref.watch(ordersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order: ${st.orderId ?? '-'}', style: theme.typography.body1),
            const SizedBox(height: 8),
            Text(
              'Status: ${st.status.name}',
              style: theme.typography.body1.copyWith(
                color: theme.colors.primary,
              ),
            ),
            const SizedBox(height: 16),
            AppButton.primary(
              label: 'Subscribe',
              onPressed: () => ref
                  .read(ordersProvider.notifier)
                  .subscribe('orders', orderId: st.orderId ?? 'temp'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:delivery_ways_clean/state/cart/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final theme = ref.watch(appThemeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Items: ${cart.itemCount}', style: theme.typography.body1),
            const SizedBox(height: 8),
            Text(
              'Total: ${cart.total.toStringAsFixed(2)} ${cart.currency}',
              style: theme.typography.body1.copyWith(
                color: theme.colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            AppButton.primary(
              label: 'Add One',
              onPressed: () => ref
                  .read(cartProvider.notifier)
                  .setItemCount(cart.itemCount + 1),
            ),
          ],
        ),
      ),
    );
  }
}

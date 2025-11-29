import 'package:delivery_ways_clean/state/checkout/checkout_state.dart';
import 'package:delivery_ways_clean/state/checkout/providers.dart';
import '../config/config_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);

    // Fail-closed: Check backend availability
    if (!AppConfig.canUseBackendFeature()) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
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

    // Fail-closed: Check payments availability
    if (!AppConfig.canUsePaymentFeature()) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              AppConfig.paymentsPolicyMessage,
              textAlign: TextAlign.center,
              style: theme.typography.body1,
            ),
          ),
        ),
      );
    }

    final st = ref.watch(checkoutProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Center(
        child: switch (st.status) {
          CheckoutStatus.idle => AppButton.primary(
            label: 'Pay',
            onPressed: () => ref.read(checkoutProvider.notifier).submit(),
          ),
          CheckoutStatus.processing => const CircularProgressIndicator(),
          CheckoutStatus.success => Text(
            'Success! order: ${st.orderId ?? ''}',
            style: theme.typography.body1.copyWith(
              color: theme.colors.primary,
            ),
          ),
          CheckoutStatus.failure => Text(
            'Failed',
            style: theme.typography.body1.copyWith(
              color: theme.colors.error,
            ),
          ),
        },
      ),
    );
  }
}

/// Component: Payments Debug Screen
/// Created by: Cursor (auto-generated)
/// Purpose: Minimal diagnostics for payments wiring without SDK imports
/// Last updated: 2025-11-25 DW-COMMERCE-PHASE4-COM-002

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payments/payments.dart';

import '../state/infra/feature_flags.dart' show paymentsEnabledProvider;
import '../state/infra/payments_providers.dart';
import '../wiring/payments_wiring.dart' as wiring;

class PaymentsDebugScreen extends ConsumerWidget {
  const PaymentsDebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runtimeCfg = ref.watch(paymentsRuntimeConfigProvider);
    final paymentsEnabled = ref.watch(paymentsEnabledProvider);
    final gatewayAsync = ref.watch(wiring.paymentsGatewayProvider);
    final sheetAsync = ref.watch(wiring.paymentsSheetProvider);
    final PaymentGateway? gateway = gatewayAsync.asData?.value;
    final PaymentsSheet? sheet = sheetAsync.asData?.value;

    final missingKeysLabel = runtimeCfg.missingKeys.isEmpty
        ? 'none'
        : runtimeCfg.missingKeys.join(', ');

    return Scaffold(
      appBar: AppBar(title: const Text('Payments Debug')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payments enabled: $paymentsEnabled'),
            if (!paymentsEnabled) ...[
              const SizedBox(height: 8),
              Text('Missing config keys: $missingKeysLabel'),
            ],
            const SizedBox(height: 16),
            Text('Gateway status: ${_statusLabel(gatewayAsync)}'),
            const SizedBox(height: 12),
            Text('Gateway: ${gateway?.runtimeType ?? 'pending'}'),
            const SizedBox(height: 12),
            Text('Sheet status: ${_statusLabel(sheetAsync)}'),
            const SizedBox(height: 12),
            Text('Sheet: ${sheet?.runtimeType ?? 'pending'}'),
            const SizedBox(height: 24),
            const Text(
              'This screen is intended for smoke verification only. '
              'Full payment flows should be tested via integration tests.',
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(AsyncValue<dynamic> asyncValue) {
    return asyncValue.when(
      data: (_) => 'READY',
      loading: () => 'INITIALIZING',
      error: (err, _) => 'ERROR: $err',
    );
  }
}

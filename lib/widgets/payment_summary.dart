import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payments/payments.dart';

/// Component: PaymentSummary
/// Created by: Cursor (auto-generated)
/// Purpose: Widget to display payment summary information
/// Last updated: 2025-11-12

/// Widget to display payment summary
class PaymentSummary extends ConsumerWidget {
  final int amount;
  final String currency;
  final PaymentServiceType serviceType;
  final String? orderId;

  const PaymentSummary({
    super.key,
    required this.amount,
    required this.currency,
    required this.serviceType,
    this.orderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Payment Summary',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16.0),
            _buildSummaryRow(ref, 'Service', _getServiceName(serviceType)),
            if (orderId != null) ...<Widget>[
              const SizedBox(height: 8.0),
              _buildSummaryRow(ref, 'Order ID', orderId!),
            ],
            const SizedBox(height: 8),
            _buildSummaryRow(
              ref,
              'Amount',
              _formatAmount(amount, currency),
              isAmount: true,
            ),
            const SizedBox(height: 16.0),
            const Divider(),
            const SizedBox(height: 8),
            _buildSummaryRow(
              ref,
              'Total',
              _formatAmount(amount, currency),
              isAmount: true,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    WidgetRef ref,
    String label,
    String value, {
    bool isAmount = false,
    bool isTotal = false,
  }) {
    return Builder(
      builder: (context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isTotal
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isTotal
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
              fontFamily: isAmount ? 'monospace' : null,
            ),
          ),
        ],
      ),
    );
  }

  String _getServiceName(PaymentServiceType serviceType) {
    switch (serviceType) {
      case PaymentServiceType.defaultService:
        return 'Default Service';
      case PaymentServiceType.ride:
        return 'Ride Service';
      case PaymentServiceType.parcel:
        return 'Parcel Delivery';
      case PaymentServiceType.food:
        return 'Food Delivery';
    }
  }

  String _formatAmount(int amount, String currency) {
    final String formattedAmount = (amount / 100).toStringAsFixed(2);
    return '$formattedAmount ${currency.toUpperCase()}';
  }
}

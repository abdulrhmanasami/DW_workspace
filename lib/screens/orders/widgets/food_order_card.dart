/// Food Order Card Widget
/// Created by: Track C - Ticket #54
/// Purpose: Reusable card widget for displaying food orders in My Orders screen.

import 'package:design_system_shims/design_system_shims.dart';
import 'package:flutter/material.dart';
import 'package:food_shims/food_shims.dart';

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';

/// Reusable food order card showing order summary.
/// Displays: Restaurant name, Status, Price, and Created Date.
class FoodOrderCard extends StatelessWidget {
  const FoodOrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  final FoodOrder order;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final statusLabel = _statusLabel(order.status, l10n);

    return Padding(
      padding: const EdgeInsets.only(bottom: DWSpacing.sm),
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DWRadius.md),
          child: Padding(
            padding: const EdgeInsets.all(DWSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: Icon + Restaurant name + Price
                Row(
                  children: [
                    Icon(
                      Icons.fastfood_outlined,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: DWSpacing.xs),
                    Expanded(
                      child: Text(
                        order.restaurantName,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: DWSpacing.sm),
                    Text(
                      '${order.totalAmount.toStringAsFixed(2)} ${order.currencyCode}',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DWSpacing.xs),

                // Status row: Status chip + Items count
                Row(
                  children: [
                    _StatusChip(label: statusLabel),
                    const SizedBox(width: DWSpacing.sm),
                    Text(
                      '${order.totalItems} ${order.totalItems == 1 ? 'item' : 'items'}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DWSpacing.xs),

                // Created at timestamp
                Text(
                  l10n?.ordersFoodCreatedAtLabel(
                        _formatCreatedAt(order.createdAt),
                      ) ??
                      'Ordered on ${_formatCreatedAt(order.createdAt)}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Format createdAt date for display.
  String _formatCreatedAt(DateTime createdAt) {
    final year = createdAt.year.toString();
    final month = createdAt.month.toString().padLeft(2, '0');
    final day = createdAt.day.toString().padLeft(2, '0');
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
  }

  /// Get localized status label for a FoodOrderStatus.
  String _statusLabel(FoodOrderStatus status, AppLocalizations? l10n) {
    switch (status) {
      case FoodOrderStatus.pending:
        return l10n?.ordersFoodStatusPending ?? 'Pending';
      case FoodOrderStatus.inPreparation:
        return l10n?.ordersFoodStatusInPreparation ?? 'In preparation';
      case FoodOrderStatus.onTheWay:
        return l10n?.ordersFoodStatusOnTheWay ?? 'On the way';
      case FoodOrderStatus.delivered:
        return l10n?.ordersFoodStatusDelivered ?? 'Delivered';
      case FoodOrderStatus.cancelled:
        return l10n?.ordersFoodStatusCancelled ?? 'Cancelled';
    }
  }
}

/// Status chip widget for displaying order status.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DWSpacing.sm,
        vertical: DWSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(DWRadius.lg),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall,
      ),
    );
  }
}


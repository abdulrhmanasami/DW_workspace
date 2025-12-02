/// Parcel Order Card Widget
/// Created by: Track C - Ticket #51
/// Updated by: Track B - Ticket #126 (Added OrderStatusChip)
/// Updated by: Track B - Ticket #127 (Semantics for accessibility)
/// Purpose: Reusable card widget for displaying parcel shipments
/// Used in: ParcelsEntryScreen, OrdersHistoryScreen

import 'package:design_system_shims/design_system_shims.dart';
import 'package:flutter/material.dart';
import 'package:parcels_shims/parcels_shims.dart';

import '../../../l10n/generated/app_localizations.dart';
// Track C - Ticket #78: Unified parcel status helpers
import '../../../state/parcels/parcel_status_utils.dart';
// Track B - Ticket #126: Unified OrderStatusChip
import '../../orders/widgets/order_status_chip.dart';

/// Reusable parcel order card showing shipment summary.
/// Displays: ID, Status, Route, Price, and Created Date.
class ParcelOrderCard extends StatelessWidget {
  const ParcelOrderCard({
    super.key,
    required this.parcel,
    required this.onTap,
  });

  final Parcel parcel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Generate shortened ID (last 6 characters)
    final shortId = parcel.id.length > 6
        ? parcel.id.substring(parcel.id.length - 6)
        : parcel.id;

    // Extract price for display
    final price = parcel.price;

    // Track B - Ticket #127: Wrap card in Semantics for accessibility
    return Semantics(
      label: l10n?.ordersServiceParcelSemanticLabel ?? 'Parcel shipment',
      child: Padding(
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
                  // Title row: ID + Status Chip + Price
                  // Track B - Ticket #126: Use OrderStatusChip instead of inline text
                  Row(
                    children: [
                      Text(
                        '#$shortId',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(width: DWSpacing.xs),
                    // Track B - Ticket #126: OrderStatusChip for parcel status
                    OrderStatusChip(
                      status: _mapParcelStatusToUiModel(parcel.status, l10n),
                    ),
                    const Spacer(),
                    // Display final price
                    if (price != null)
                      Text(
                        _formatPrice(price),
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: DWSpacing.xs),

                // Route: pickup → dropoff
                Text(
                  '${parcel.pickupAddress.label} → ${parcel.dropoffAddress.label}',
                  style: textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: DWSpacing.xs),

                // Created at timestamp
                Text(
                  _formatCreatedAt(parcel.createdAt),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  /// Format price for UI display.
  String _formatPrice(ParcelPrice price) {
    return '${price.totalAmount.toStringAsFixed(2)} ${price.currencyCode}';
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

  /// Maps a parcel status to the unified OrderStatusUiModel.
  ///
  /// Track B - Ticket #126: Centralized mapping for consistent status display.
  /// Uses localized labels from parcel_status_utils.dart.
  OrderStatusUiModel _mapParcelStatusToUiModel(
    ParcelStatus status,
    AppLocalizations? l10n,
  ) {
    final label = localizedParcelStatusShort(l10n, status);

    // Determine tone based on status
    final OrderStatusTone tone;
    if (status == ParcelStatus.delivered) {
      tone = OrderStatusTone.success;
    } else if (status == ParcelStatus.cancelled || status == ParcelStatus.failed) {
      tone = OrderStatusTone.error;
    } else if (status == ParcelStatus.inTransit ||
        status == ParcelStatus.pickedUp ||
        status == ParcelStatus.pickupPending) {
      tone = OrderStatusTone.info;
    } else {
      // draft, quoting, scheduled - early/pending states
      tone = OrderStatusTone.warning;
    }

    return OrderStatusUiModel(label: label, tone: tone);
  }
}


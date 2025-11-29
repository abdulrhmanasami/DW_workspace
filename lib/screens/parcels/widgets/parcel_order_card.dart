/// Parcel Order Card Widget
/// Created by: Track C - Ticket #51
/// Purpose: Reusable card widget for displaying parcel shipments
/// Used in: ParcelsEntryScreen, OrdersHistoryScreen

import 'package:design_system_shims/design_system_shims.dart';
import 'package:flutter/material.dart';
import 'package:parcels_shims/parcels_shims.dart';

import '../../../l10n/generated/app_localizations.dart';

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
                // Title row: ID + Status + Price
                Row(
                  children: [
                    Text(
                      '#$shortId',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: DWSpacing.xs),
                    Text(
                      '• ${_statusLabel(parcel.status, l10n)}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
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

  /// Get localized status label for a ParcelStatus.
  String _statusLabel(ParcelStatus status, AppLocalizations? l10n) {
    switch (status) {
      case ParcelStatus.draft:
        return l10n?.parcelsStatusScheduled ?? 'Draft';
      case ParcelStatus.quoting:
        return l10n?.parcelsStatusScheduled ?? 'Quoting';
      case ParcelStatus.scheduled:
        return l10n?.parcelsStatusScheduled ?? 'Scheduled';
      case ParcelStatus.pickupPending:
        return l10n?.parcelsStatusPickupPending ?? 'Pickup pending';
      case ParcelStatus.pickedUp:
        return l10n?.parcelsStatusPickedUp ?? 'Picked up';
      case ParcelStatus.inTransit:
        return l10n?.parcelsStatusInTransit ?? 'In transit';
      case ParcelStatus.delivered:
        return l10n?.parcelsStatusDelivered ?? 'Delivered';
      case ParcelStatus.cancelled:
        return l10n?.parcelsStatusCancelled ?? 'Cancelled';
      case ParcelStatus.failed:
        return l10n?.parcelsStatusFailed ?? 'Failed';
    }
  }
}


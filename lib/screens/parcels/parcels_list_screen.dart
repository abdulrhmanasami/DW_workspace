/// Parcels List Screen - My Shipments (Screen 12)
/// Created by: Track C - Ticket #72
/// Updated by: Track C - Ticket #73 (Design Alignment + New Shipment CTA)
/// Purpose: Display list of all parcels (active + completed) with navigation to details
/// Last updated: 2025-11-29
///
/// This screen shows:
/// - AppBar with "My Shipments" title + New Shipment action
/// - List of all parcels from ParcelOrdersState using Card/Order layout
/// - Status Chip, destination, createdAt date for each item
/// - Empty state with CTA to create first shipment
///
/// Design System Alignment:
/// - Uses DWSpacing/DWRadius tokens
/// - Card/Order style for parcel items with Status Chip
/// - Typography: titleMedium, bodyMedium, bodySmall

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart'
    show DWSpacing, DWRadius;
import 'package:parcels_shims/parcels_shims.dart' show Parcel;

import '../../l10n/generated/app_localizations.dart';
import '../../router/app_router.dart';
import '../../state/parcels/parcel_orders_state.dart';
// Track C - Ticket #78: Unified parcel status helpers
import '../../state/parcels/parcel_status_utils.dart';
import '../../widgets/app_button_unified.dart';
import '../../widgets/app_shell.dart';
import 'parcel_shipment_details_screen.dart';

/// Screen that displays list of all parcels.
/// Track C - Ticket #72: Main entry point for viewing all shipments.
class ParcelsListScreen extends ConsumerWidget {
  const ParcelsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    // Watch parcel orders state - same provider used in app_shell
    final parcelsState = ref.watch(parcelOrdersProvider);
    final parcels = parcelsState.parcels;
    final hasParcels = parcels.isNotEmpty;

    return AppShell(
      title: l10n.parcelsListTitle,
      body: Padding(
        padding: EdgeInsets.all(DWSpacing.md),
        child: hasParcels
            ? _ParcelsListView(parcels: parcels)
            : const _ParcelsEmptyState(),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.parcelsListNewShipmentTooltip,
        onPressed: () {
          Navigator.of(context).pushNamed(RoutePaths.parcelsDestination);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Track C - Ticket #78: _mapParcelStatusToLabel moved to parcel_status_utils.dart
// Use localizedParcelStatusLong(l10n, status) instead.

/// Widget that displays the list of parcels.
/// Track C - Ticket #73: Updated to Card/Order layout with Status Chip + createdAt
class _ParcelsListView extends StatelessWidget {
  const _ParcelsListView({required this.parcels});

  final List<Parcel> parcels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return ListView.separated(
      itemCount: parcels.length,
      separatorBuilder: (_, __) => SizedBox(height: DWSpacing.sm),
      itemBuilder: (context, index) {
        final parcel = parcels[index];
        final statusLabel = localizedParcelStatusLong(l10n, parcel.status);
        final destinationLabel = parcel.dropoffAddress.label;
        final createdAt = parcel.createdAt;
        final shipmentId = parcel.id;

        return Card(
          // Card/Order style from Design System
          child: InkWell(
            borderRadius: BorderRadius.circular(DWRadius.md),
            onTap: () {
              // Navigate to Parcel Detail Screen
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ParcelShipmentDetailsScreen(parcel: parcel),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(DWSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Service icon (Parcel)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(DWRadius.sm),
                    ),
                    child: Icon(
                      Icons.local_shipping_outlined,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: DWSpacing.md),
                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title: Destination or fallback
                        Text(
                          destinationLabel.isNotEmpty
                              ? destinationLabel
                              : l10n.parcelsListUnknownDestinationLabel,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: DWSpacing.xxs),
                        // Subtitle: Date/time
                        Text(
                          _formatParcelCreatedAt(l10n, createdAt),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (shipmentId.isNotEmpty) ...[
                          SizedBox(height: DWSpacing.xxs),
                          // Shipment ID
                          Text(
                            l10n.parcelsActiveShipmentIdLabel(shipmentId),
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: DWSpacing.sm),
                  // Status chip
                  _ParcelStatusChip(label: statusLabel),
                  SizedBox(width: DWSpacing.xs),
                  // Chevron indicator
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Status chip widget for parcel status display.
/// Track C - Ticket #73: Utility/Chip style for status display.
class _ParcelStatusChip extends StatelessWidget {
  const _ParcelStatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DWSpacing.sm,
        vertical: DWSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(DWRadius.sm),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Helper function to format parcel creation date.
/// Track C - Ticket #73
String _formatParcelCreatedAt(AppLocalizations l10n, DateTime createdAt) {
  final dateStr =
      '${createdAt.year.toString().padLeft(4, '0')}-'
      '${createdAt.month.toString().padLeft(2, '0')}-'
      '${createdAt.day.toString().padLeft(2, '0')}';
  return l10n.parcelsListCreatedAtLabel(dateStr);
}

/// Empty state widget when no parcels exist.
/// Track C - Ticket #73: Added CTA to create first shipment.
class _ParcelsEmptyState extends StatelessWidget {
  const _ParcelsEmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: DWSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: DWSpacing.md),
            Text(
              l10n.parcelsListEmptyTitle,
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DWSpacing.xs),
            Text(
              l10n.parcelsListEmptySubtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DWSpacing.lg),
            // Track C - Ticket #73: CTA to create first shipment
            AppButtonUnified.primary(
              label: l10n.parcelsListEmptyCta,
              onPressed: () {
                Navigator.of(context).pushNamed(RoutePaths.parcelsDestination);
              },
            ),
          ],
        ),
      ),
    );
  }
}


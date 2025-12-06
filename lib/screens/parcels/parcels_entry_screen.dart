import 'package:design_system_shims/design_system_shims.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parcels_shims/parcels_shims.dart';

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/widgets/dw_app_shell.dart';
import 'package:delivery_ways_clean/state/parcels/parcel_orders_state.dart';
import 'package:delivery_ways_clean/screens/orders/widgets/order_list_skeleton.dart';
import 'parcel_create_shipment_screen.dart';
import 'parcel_shipment_details_screen.dart';
import 'widgets/parcel_order_card.dart';

/// Parcels Entry Screen
/// Created by: Track C - Ticket #40
/// Updated by: Track C - Ticket #45 (My Shipments list + filtering)
/// Updated by: Track C - Ticket #46 (Create Shipment navigation)
/// Updated by: Track C - Ticket #47 (Navigate to Shipment Details)
/// Updated by: Track C - Ticket #50 (Parcels Pricing Integration - price display)
/// Updated by: Track B - Ticket #127 (Skeleton Loader support)
/// Purpose: Initial entry point for Parcels vertical from Home Hub.
/// This screen now includes My Shipments section with filtering and price display.
class ParcelsEntryScreen extends ConsumerWidget {
  const ParcelsEntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Watch parcel orders state for My Shipments section
    final ordersState = ref.watch(parcelOrdersProvider);
    final parcels = ordersState.parcels;
    // Track B - Ticket #127: Get loading state for skeleton
    final isLoading = ordersState.isLoading;

    return DWAppShell(
      appBar: AppBar(
        title: Text(l10n?.parcelsEntryTitle ?? 'Parcels'),
      ),
      applyPadding: false, // We'll handle padding in the body
      useSafeArea: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DWSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
              const SizedBox(height: DWSpacing.lg),
              Icon(
                Icons.local_shipping_outlined,
                size: 72,
                color: colors.primary,
              ),
              const SizedBox(height: DWSpacing.lg),
              Text(
                l10n?.parcelsEntryTitle ?? 'Parcels',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DWSpacing.sm),
              Text(
                l10n?.parcelsEntrySubtitle ??
                    'Ship and track your parcels in one place.',
                style: textTheme.bodyLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DWSpacing.xl),

              // Primary CTA - Track C Ticket #46: Navigate to ParcelCreateShipmentScreen
              DWButton.primary(
                label:
                    l10n?.parcelsEntryCreateShipmentCta ?? 'Create shipment',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ParcelCreateShipmentScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: DWSpacing.xl),

              // Track C - Ticket #45: My Shipments Section
              // Track B - Ticket #127: Pass loading state for skeleton
              _ParcelsListSection(parcels: parcels, isLoading: isLoading),

              const SizedBox(height: DWSpacing.xl),
              Text(
                l10n?.parcelsEntryFooterNote ??
                    'Parcels MVP is under active development.',
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DWSpacing.sm),
            ],
          ),
        ),
      );
  }
}

/// Private enum for filtering parcels by status.
enum _ParcelsFilter {
  all,
  inProgress,
  delivered,
  cancelled,
}

/// Helper to check if a parcel matches the given filter.
bool _matchesFilter(Parcel parcel, _ParcelsFilter filter) {
  switch (filter) {
    case _ParcelsFilter.all:
      return true;
    case _ParcelsFilter.inProgress:
      return parcel.status == ParcelStatus.scheduled ||
          parcel.status == ParcelStatus.pickupPending ||
          parcel.status == ParcelStatus.pickedUp ||
          parcel.status == ParcelStatus.inTransit;
    case _ParcelsFilter.delivered:
      return parcel.status == ParcelStatus.delivered;
    case _ParcelsFilter.cancelled:
      return parcel.status == ParcelStatus.cancelled ||
          parcel.status == ParcelStatus.failed;
  }
}

/// My Shipments Section Widget
/// Shows either empty state or list of parcels with filtering.
/// Track B - Ticket #127: Added isLoading support for skeleton.
class _ParcelsListSection extends StatefulWidget {
  const _ParcelsListSection({
    required this.parcels,
    this.isLoading = false,
  });

  final List<Parcel> parcels;

  /// Track B - Ticket #127: Loading state for skeleton display.
  final bool isLoading;

  @override
  State<_ParcelsListSection> createState() => _ParcelsListSectionState();
}

class _ParcelsListSectionState extends State<_ParcelsListSection> {
  _ParcelsFilter _selectedFilter = _ParcelsFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Track B - Ticket #127: Show skeleton while loading
    if (widget.isLoading) {
      return const SizedBox(
        height: 300, // Constrained height for skeleton in this context
        child: OrderListSkeleton(itemCount: 3),
      );
    }

    // Empty state
    if (widget.parcels.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: DWSpacing.lg),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 40,
                color: colorScheme.outline,
              ),
              const SizedBox(height: DWSpacing.sm),
              Text(
                l10n?.parcelsListEmptyTitle ?? 'No shipments yet',
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: DWSpacing.xs),
              Text(
                l10n?.parcelsListEmptySubtitle ??
                    'When you create a shipment, it will appear here.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Non-empty state: show title, filter bar, and list
    final filteredParcels = widget.parcels
        .where((p) => _matchesFilter(p, _selectedFilter))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(
          l10n?.parcelsListSectionTitle ?? 'My shipments',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: DWSpacing.md),

        // Filter bar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                label: l10n?.parcelsFilterAllLabel ?? 'All',
                isSelected: _selectedFilter == _ParcelsFilter.all,
                onSelected: () => setState(() {
                  _selectedFilter = _ParcelsFilter.all;
                }),
              ),
              const SizedBox(width: DWSpacing.xs),
              _FilterChip(
                label: l10n?.parcelsFilterInProgressLabel ?? 'In progress',
                isSelected: _selectedFilter == _ParcelsFilter.inProgress,
                onSelected: () => setState(() {
                  _selectedFilter = _ParcelsFilter.inProgress;
                }),
              ),
              const SizedBox(width: DWSpacing.xs),
              _FilterChip(
                label: l10n?.parcelsFilterDeliveredLabel ?? 'Delivered',
                isSelected: _selectedFilter == _ParcelsFilter.delivered,
                onSelected: () => setState(() {
                  _selectedFilter = _ParcelsFilter.delivered;
                }),
              ),
              const SizedBox(width: DWSpacing.xs),
              _FilterChip(
                label: l10n?.parcelsFilterCancelledLabel ?? 'Cancelled',
                isSelected: _selectedFilter == _ParcelsFilter.cancelled,
                onSelected: () => setState(() {
                  _selectedFilter = _ParcelsFilter.cancelled;
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: DWSpacing.md),

        // Parcel list
        if (filteredParcels.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: DWSpacing.lg),
            child: Center(
              child: Text(
                l10n?.parcelsListEmptyTitle ?? 'No shipments yet',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ...filteredParcels.map(
            (parcel) => _ParcelCard(parcel: parcel),
          ),
      ],
    );
  }
}

/// Filter chip widget for parcels filtering.
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.onPrimaryContainer,
      backgroundColor: colorScheme.surfaceContainerHighest,
    );
  }
}

/// Parcel card widget showing shipment summary.
/// Track C - Ticket #50: Now displays final price.
/// Track C - Ticket #51: Refactored to use shared ParcelOrderCard widget.
class _ParcelCard extends StatelessWidget {
  const _ParcelCard({required this.parcel});

  final Parcel parcel;

  @override
  Widget build(BuildContext context) {
    return ParcelOrderCard(
      parcel: parcel,
      onTap: () {
        // Track C - Ticket #47: Navigate to Shipment Details Screen
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ParcelShipmentDetailsScreen(parcel: parcel),
          ),
        );
      },
    );
  }
}

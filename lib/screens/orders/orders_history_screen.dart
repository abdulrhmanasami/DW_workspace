/// Orders History Screen (Parcels-Only MVP)
/// Created by: Track C - Ticket #51
/// Purpose: Unified orders history screen displaying Parcels shipments
/// Future: Will be extended to include Rides/Food without breaking structure

import 'package:design_system_shims/design_system_shims.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parcels_shims/parcels_shims.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../state/parcels/parcel_orders_state.dart';
import '../parcels/parcel_shipment_details_screen.dart';
import '../parcels/widgets/parcel_order_card.dart';

/// Filter enum for orders list.
/// MVP: All and Parcels only (both show parcels).
/// Future: Will add Rides, Food options.
enum _OrdersFilter { all, parcels }

/// Orders History Screen - Parcels Only MVP
///
/// Displays a list of parcel shipments with filtering capability.
/// Follows the existing design patterns from ParcelsEntryScreen.
class OrdersHistoryScreen extends ConsumerStatefulWidget {
  const OrdersHistoryScreen({super.key});

  @override
  ConsumerState<OrdersHistoryScreen> createState() =>
      _OrdersHistoryScreenState();
}

class _OrdersHistoryScreenState extends ConsumerState<OrdersHistoryScreen> {
  _OrdersFilter _selectedFilter = _OrdersFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Watch parcel orders state
    final ordersState = ref.watch(parcelOrdersProvider);
    final parcels = ordersState.parcels;

    // MVP: Both filters show parcels (future: separate by service type)
    final List<Parcel> visibleParcels;
    switch (_selectedFilter) {
      case _OrdersFilter.all:
        visibleParcels = parcels;
      case _OrdersFilter.parcels:
        visibleParcels = parcels;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.ordersHistoryTitle ?? 'My Orders'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Filter bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DWSpacing.md,
                vertical: DWSpacing.sm,
              ),
              child: Row(
                children: [
                  ChoiceChip(
                    label: Text(l10n?.ordersFilterAll ?? 'All'),
                    selected: _selectedFilter == _OrdersFilter.all,
                    onSelected: (_) => setState(() {
                      _selectedFilter = _OrdersFilter.all;
                    }),
                  ),
                  const SizedBox(width: DWSpacing.xs),
                  ChoiceChip(
                    label: Text(l10n?.ordersFilterParcels ?? 'Parcels'),
                    selected: _selectedFilter == _OrdersFilter.parcels,
                    onSelected: (_) => setState(() {
                      _selectedFilter = _OrdersFilter.parcels;
                    }),
                  ),
                ],
              ),
            ),

            // Content area
            Expanded(
              child: visibleParcels.isEmpty
                  ? _buildEmptyState(context, l10n, colorScheme, textTheme)
                  : _buildParcelsList(context, visibleParcels),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state widget
  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations? l10n,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DWSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: colorScheme.outline,
            ),
            const SizedBox(height: DWSpacing.md),
            Text(
              l10n?.ordersHistoryEmptyTitle ?? 'No orders yet',
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DWSpacing.xs),
            Text(
              l10n?.ordersHistoryEmptySubtitle ??
                  'You don\'t have any orders yet. Start by creating a new shipment.',
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

  /// Build parcels list
  Widget _buildParcelsList(BuildContext context, List<Parcel> parcels) {
    return ListView.builder(
      padding: const EdgeInsets.all(DWSpacing.md),
      itemCount: parcels.length,
      itemBuilder: (context, index) {
        final parcel = parcels[index];
        return ParcelOrderCard(
          parcel: parcel,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ParcelShipmentDetailsScreen(parcel: parcel),
              ),
            );
          },
        );
      },
    );
  }
}


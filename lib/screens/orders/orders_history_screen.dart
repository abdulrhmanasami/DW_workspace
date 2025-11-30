/// Orders History Screen
/// Created by: Track C - Ticket #51, updated Ticket #54, #55
/// Updated by: Track B - Ticket #96 (Added Rides integration)
/// Updated by: Track B - Ticket #98 (Added navigation to Trip Summary)
/// Purpose: Unified orders history screen displaying Rides, Parcels, and Food orders
/// Track C - Ticket #54: Added Food Orders integration
/// Track C - Ticket #55: Feature Flag integration for Food
/// Track B - Ticket #96: Added Rides Orders integration
/// Track B - Ticket #98: Added deep link to Trip Summary for Rides

import 'package:design_system_shims/design_system_shims.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_shims/food_shims.dart';
import 'package:parcels_shims/parcels_shims.dart';

import '../../config/feature_flags.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../router/app_router.dart';
import '../../screens/mobility/ride_trip_summary_screen.dart';
import '../../state/food/food_orders_state.dart';
import '../../state/mobility/ride_trip_session.dart';
import '../../state/parcels/parcel_orders_state.dart';
import '../parcels/parcel_shipment_details_screen.dart';
import '../parcels/widgets/parcel_order_card.dart';
import 'widgets/food_order_card.dart';
import 'widgets/ride_order_card.dart';

/// Filter enum for orders list.
/// Track C - Ticket #54: Added food filter.
/// Track B - Ticket #96: Added rides filter.
enum _OrdersFilter { all, rides, parcels, food }

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

    // Track C - Ticket #55: Check if Food feature is enabled
    final isFoodEnabled = FeatureFlags.enableFoodMvp;

    // Track B - Ticket #96: Watch ride trip session for history
    final rideSessionState = ref.watch(rideTripSessionProvider);
    final rideHistory = rideSessionState.historyTrips;

    // Watch parcel orders state
    final parcelsState = ref.watch(parcelOrdersProvider);
    final parcels = parcelsState.parcels;

    // Watch food orders state - Track C - Ticket #54
    // Track C - Ticket #55: Only load food orders if feature is enabled
    final List<FoodOrder> foodOrders;
    if (isFoodEnabled) {
      final foodOrdersState = ref.watch(foodOrdersControllerProvider);
      foodOrders = foodOrdersState.orders;
    } else {
      foodOrders = const [];
    }

    // Filter visible items based on selected filter
    final List<RideHistoryEntry> visibleRides;
    final List<Parcel> visibleParcels;
    final List<FoodOrder> visibleFoodOrders;

    switch (_selectedFilter) {
      case _OrdersFilter.all:
        visibleRides = rideHistory;
        visibleParcels = parcels;
        visibleFoodOrders = isFoodEnabled ? foodOrders : const [];
      case _OrdersFilter.rides:
        visibleRides = rideHistory;
        visibleParcels = const [];
        visibleFoodOrders = const [];
      case _OrdersFilter.parcels:
        visibleRides = const [];
        visibleParcels = parcels;
        visibleFoodOrders = const [];
      case _OrdersFilter.food:
        visibleRides = const [];
        visibleParcels = const [];
        visibleFoodOrders = isFoodEnabled ? foodOrders : const [];
    }

    final isEmpty = visibleRides.isEmpty && visibleParcels.isEmpty && visibleFoodOrders.isEmpty;

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
            // Track C - Ticket #55: Food filter only shown when feature is enabled
            // Track B - Ticket #96: Added Rides filter
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DWSpacing.md,
                vertical: DWSpacing.sm,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
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
                    // Track B - Ticket #96: Rides filter
                    ChoiceChip(
                      label: Text(l10n?.ordersFilterRides ?? 'Rides'),
                      selected: _selectedFilter == _OrdersFilter.rides,
                      onSelected: (_) => setState(() {
                        _selectedFilter = _OrdersFilter.rides;
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
                    // Track C - Ticket #55: Only show Food filter when feature is enabled
                    if (isFoodEnabled) ...[
                      const SizedBox(width: DWSpacing.xs),
                      ChoiceChip(
                        label: Text(l10n?.ordersFilterFood ?? 'Food'),
                        selected: _selectedFilter == _OrdersFilter.food,
                        onSelected: (_) => setState(() {
                          _selectedFilter = _OrdersFilter.food;
                        }),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Content area
            Expanded(
              child: isEmpty
                  ? _buildEmptyState(context, l10n, colorScheme, textTheme)
                  : _buildOrdersList(
                      context,
                      visibleRides,
                      visibleParcels,
                      visibleFoodOrders,
                      l10n,
                      textTheme,
                    ),
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

  /// Build orders list with sections for Rides, Parcels and Food.
  /// Track C - Ticket #54
  /// Track B - Ticket #96: Added Rides section
  Widget _buildOrdersList(
    BuildContext context,
    List<RideHistoryEntry> rides,
    List<Parcel> parcels,
    List<FoodOrder> foodOrders,
    AppLocalizations? l10n,
    TextTheme textTheme,
  ) {
    return ListView(
      padding: const EdgeInsets.all(DWSpacing.md),
      children: [
        // Track B - Ticket #96: Rides section
        // Track B - Ticket #98: Added navigation to Trip Summary
        if (rides.isNotEmpty) ...[
          Text(
            l10n?.ordersSectionRidesTitle ?? 'Rides',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DWSpacing.sm),
          for (final entry in rides)
            RideOrderCard(
              entry: entry,
              l10n: l10n,
              // Track B - Ticket #98: Navigate to Trip Summary on tap
              onTap: () {
                Navigator.of(context).pushNamed(
                  RoutePaths.rideTripSummary,
                  arguments: RideTripSummaryArgs(historyEntry: entry),
                );
              },
            ),
          if (parcels.isNotEmpty || foodOrders.isNotEmpty)
            const SizedBox(height: DWSpacing.lg),
        ],

        // Parcels section
        if (parcels.isNotEmpty) ...[
          Text(
            l10n?.ordersSectionParcelsTitle ?? 'Parcels',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DWSpacing.sm),
          for (final parcel in parcels)
            ParcelOrderCard(
              parcel: parcel,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ParcelShipmentDetailsScreen(parcel: parcel),
                  ),
                );
              },
            ),
          if (foodOrders.isNotEmpty) const SizedBox(height: DWSpacing.lg),
        ],

        // Food orders section
        if (foodOrders.isNotEmpty) ...[
          Text(
            l10n?.ordersSectionFoodTitle ?? 'Food',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DWSpacing.sm),
          for (final order in foodOrders) FoodOrderCard(order: order),
        ],
      ],
    );
  }
}


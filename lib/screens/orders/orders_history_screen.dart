/// Orders History Screen
/// Created by: Track C - Ticket #51, updated Ticket #54, #55
/// Updated by: Track B - Ticket #96 (Added Rides integration)
/// Updated by: Track B - Ticket #98 (Added navigation to Trip Summary)
/// Updated by: Track B - Ticket #125 (Segmented Control filter + Empty States per Mockups)
/// Updated by: Track B - Ticket #127 (Skeleton Loader + Accessibility)
/// Purpose: Unified orders history screen displaying Rides, Parcels, and Food orders
/// Track C - Ticket #54: Added Food Orders integration
/// Track C - Ticket #55: Feature Flag integration for Food
/// Track B - Ticket #96: Added Rides Orders integration
/// Track B - Ticket #98: Added deep link to Trip Summary for Rides
/// Track B - Ticket #125: Segmented Control + Empty State per filter
/// Track B - Ticket #127: Skeleton Loader while data is loading

// Design System imports (Ticket #221 - Track A Design System Integration)
import 'package:design_system_foundation/design_system_foundation.dart';
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
import 'widgets/order_list_skeleton.dart';
import 'widgets/orders_history_filter_bar.dart';
import 'widgets/ride_order_card.dart';

/// Orders History Screen - Unified Orders MVP
///
/// Displays a list of orders (Rides, Parcels, Food) with filtering capability.
/// Follows Design System patterns with Segmented Control per Mockups Screen 15.
///
/// Track B - Ticket #125: Updated to use Segmented Control filter bar
class OrdersHistoryScreen extends ConsumerStatefulWidget {
  const OrdersHistoryScreen({super.key});

  @override
  ConsumerState<OrdersHistoryScreen> createState() =>
      _OrdersHistoryScreenState();
}

class _OrdersHistoryScreenState extends ConsumerState<OrdersHistoryScreen> {
  // Track B - Ticket #125: Use exported enum from filter bar widget
  OrdersHistoryFilter _selectedFilter = OrdersHistoryFilter.all;

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

    // Track B - Ticket #127: Check if any data source is loading
    final isLoading = rideSessionState.isLoading || parcelsState.isLoading;

    // Watch food orders state - Track C - Ticket #54
    // Track C - Ticket #55: Only load food orders if feature is enabled
    final List<FoodOrder> foodOrders;
    if (isFoodEnabled) {
      final foodOrdersState = ref.watch(foodOrdersControllerProvider);
      foodOrders = foodOrdersState.orders;
    } else {
      foodOrders = const [];
    }

    // Track B - Ticket #125: Filter visible items based on selected filter
    final List<RideHistoryEntry> visibleRides;
    final List<Parcel> visibleParcels;
    final List<FoodOrder> visibleFoodOrders;

    switch (_selectedFilter) {
      case OrdersHistoryFilter.all:
        visibleRides = rideHistory;
        visibleParcels = parcels;
        visibleFoodOrders = isFoodEnabled ? foodOrders : const [];
      case OrdersHistoryFilter.rides:
        visibleRides = rideHistory;
        visibleParcels = const [];
        visibleFoodOrders = const [];
      case OrdersHistoryFilter.parcels:
        visibleRides = const [];
        visibleParcels = parcels;
        visibleFoodOrders = const [];
      case OrdersHistoryFilter.food:
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
            // Track B - Ticket #125: Segmented Control filter bar
            // Track C - Ticket #55: Food filter only shown when feature is enabled
            OrdersHistoryFilterBar(
              currentFilter: _selectedFilter,
              onFilterChanged: (filter) {
                if (_selectedFilter != filter) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                }
              },
              labels: OrdersHistoryFilterLabels(
                all: l10n?.ordersFilterAll ?? 'All',
                rides: l10n?.ordersFilterRides ?? 'Rides',
                parcels: l10n?.ordersFilterParcels ?? 'Parcels',
                food: l10n?.ordersFilterFood ?? 'Food',
              ),
              showFoodFilter: isFoodEnabled,
            ),

            // Content area
            // Track B - Ticket #125: Empty state per filter
            // Track B - Ticket #127: Skeleton loader while loading
            Expanded(
              child: isLoading
                  ? const OrderListSkeleton(itemCount: 4)
                  : isEmpty
                      ? _buildEmptyState(
                          context,
                          _selectedFilter,
                          l10n,
                          colorScheme,
                          textTheme,
                        )
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

  /// Build empty state widget per filter
  /// Track B - Ticket #125: Empty state per filter with specific messages
  Widget _buildEmptyState(
    BuildContext context,
    OrdersHistoryFilter filter,
    AppLocalizations? l10n,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    // Get title and description based on current filter
    final (String title, String description, IconData icon) = switch (filter) {
      OrdersHistoryFilter.all => (
          l10n?.ordersHistoryEmptyAllTitle ?? 'No orders yet',
          l10n?.ordersHistoryEmptyAllDescription ??
              'Your rides, parcels and food orders will appear here.',
          Icons.receipt_long_outlined,
        ),
      OrdersHistoryFilter.rides => (
          l10n?.ordersHistoryEmptyRidesTitle ?? 'No rides yet',
          l10n?.ordersHistoryEmptyRidesDescription ??
              'Your completed rides will appear here.',
          Icons.directions_car_outlined,
        ),
      OrdersHistoryFilter.parcels => (
          l10n?.ordersHistoryEmptyParcelsTitle ?? 'No parcels yet',
          l10n?.ordersHistoryEmptyParcelsDescription ??
              'Your shipments will appear here.',
          Icons.inventory_2_outlined,
        ),
      OrdersHistoryFilter.food => (
          l10n?.ordersHistoryEmptyFoodTitle ?? 'No food orders yet',
          l10n?.ordersHistoryEmptyFoodDescription ??
              'Your food delivery orders will appear here.',
          Icons.restaurant_outlined,
        ),
    };

    return Center(
      child: Padding(
        padding: EdgeInsets.all(DwSpacing().lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: colorScheme.outline,
            ),
            SizedBox(height: DwSpacing().md),
            Text(
              title,
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DwSpacing().xs),
            Text(
              description,
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
      padding: EdgeInsets.all(DwSpacing().md),
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
          SizedBox(height: DwSpacing().sm),
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
            SizedBox(height: DwSpacing().lg),
        ],

        // Parcels section
        if (parcels.isNotEmpty) ...[
          Text(
            l10n?.ordersSectionParcelsTitle ?? 'Parcels',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: DwSpacing().sm),
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
          if (foodOrders.isNotEmpty) SizedBox(height: DwSpacing().lg),
        ],

        // Food orders section
        if (foodOrders.isNotEmpty) ...[
          Text(
            l10n?.ordersSectionFoodTitle ?? 'Food',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: DwSpacing().sm),
          for (final order in foodOrders) FoodOrderCard(order: order),
        ],
      ],
    );
  }
}


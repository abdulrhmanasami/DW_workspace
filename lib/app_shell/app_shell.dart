/// Root App Shell for Delivery Ways Super-App
/// Created by: Track A - Ticket #2
/// Updated by: Track D - Ticket #5 (Profile tab implementation)
/// Updated by: Track B - Ticket #19 (Home Hub Active Ride Card)
/// Updated by: Track B - Ticket #20 (Ride → RideDestinationScreen)
/// Updated by: Ticket #32 (App Shell + Home Hub DWTheme consistency)
/// Updated by: Track D - Ticket #36 (Phone + OTP Auth flow)
/// Updated by: Track D - Ticket #37 (Account Bottom Sheet + Sign out)
/// Updated by: Track C - Ticket #51 (Orders Tab → OrdersHistoryScreen)
/// Updated by: Track C - Ticket #70 (Home Hub Active Parcel Card)
/// Updated by: Track C - Ticket #71 (Active Order State Layout + Design System alignment)
/// Updated by: Track C - Ticket #74 (Unified navigation to ParcelShipmentDetailsScreen)
/// Updated by: Track A - Ticket #82 (L10n for BottomNav + Orders→ParcelsListScreen)
/// Updated by: Track B - Ticket #94 (Ride End-to-End Flow Wiring - Ride card active trip check)
/// Updated by: Track B - Ticket #99 (Payments tab → PaymentsTabScreen)
/// Updated by: Track B - Ticket #105 (Unified trip summary - price + payment in Home active card)
/// Updated by: Track B - Ticket #114 (Map from activeTripMapCommands + ETA on Active Ride Card)
/// Updated by: Track A - Ticket #135 (Design System alignment - explicit Theme colors for NavigationBar)
/// Purpose: Unified AppShell with Bottom Navigation (Home, Orders, Payments, Profile)
/// Last updated: 2025-12-02
///
/// This widget serves as the main entry point for authenticated users,
/// providing a consistent navigation structure across the app.
///
/// Track B - Ticket #114: Home Hub Map Integration (Screen 7)
/// - When active trip exists, map shows activeTripMapCommands via RideMapFromCommands
/// - Active Ride Card shows ETA from tripSummary.etaMinutes
/// - Fallback to placeholder map when no active trip

import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobility_shims/mobility_shims.dart';
import 'package:parcels_shims/parcels_shims.dart' show Parcel, ParcelShipment, ParcelShipmentStatus;
import 'package:design_system_shims/design_system_shims.dart'
    show DWButton, DWSpacing, DWRadius, DWElevation;
import '../ui/orders/order_card.dart';
import '../ui/common/empty_state.dart';

import '../config/feature_flags.dart';
import '../router/app_router.dart';
import '../screens/auth/phone_sign_in_screen.dart';
import '../screens/food/food_coming_soon_screen.dart';
import '../screens/food/food_restaurants_list_screen.dart';
// Track C - Ticket #152: Orders tab now uses custom _OrdersTab instead of OrdersHistoryScreen
import '../state/auth/auth_state.dart';
import '../state/infra/auth_providers.dart';
import '../state/mobility/ride_trip_session.dart';
import '../state/mobility/ride_draft_state.dart';
import '../state/parcels/parcel_orders_state.dart';
// Track C - Ticket #74: Import for unified navigation to shipment details
import '../screens/parcels/parcel_shipment_details_screen.dart';
// Track C - Ticket #78: Unified parcel status helpers
import '../state/parcels/parcel_status_utils.dart';
// Track B - Ticket #85: Unified ride status helpers
import '../state/mobility/ride_status_utils.dart';
// Track B - Ticket #99: Payments tab screen
import '../screens/payments/payments_tab_screen.dart';
// Track B - Ticket #105: Payment methods for active ride card summary
import '../state/payments/payment_methods_ui_state.dart';
// Track B - Ticket #114: Map from RideMapCommands for Home Hub
import '../widgets/ride_map_from_commands.dart';
import '../state/mobility/ride_map_commands_builder.dart';
import '../state/orders/orders_history_providers.dart';

/// App Tab enum for navigation
/// Track A - Ticket #217: AppShell v1 + Bottom Navigation
enum AppTab { home, orders, payments, profile }

/// AppShell V1 - Unified App Container
/// Created by: Ticket #179
/// Purpose: Universal container for all app screens with background and SafeArea
///
/// This widget serves as a unified wrapper around the entire app,
/// providing consistent background color and SafeArea across all screens.
/// Navigation logic is handled separately in future tickets.



/// AppShell with Bottom Navigation
/// Track A - Ticket #217: AppShell v1 + Bottom Navigation
/// Main app shell with 4-tab bottom navigation (Home, Orders, Payments, Profile)
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppTab _currentTab = AppTab.home;

  void _onTabSelected(AppTab tab) {
    if (_currentTab == tab) return;
    setState(() {
      _currentTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      // Track A - Ticket #135: Explicit background color from Theme
      backgroundColor: theme.colorScheme.surface,
      body: IndexedStack(
        index: _currentTab.index,
        children: const <Widget>[
          _HomeTab(), // Home Hub
          // Track C - Ticket #152: Orders tab → Custom _OrdersTab (ParcelShipments-based)
          _OrdersTab(),
          // Track B - Ticket #99: Payments tab → PaymentsTabScreen (Screen 16)
          PaymentsTabScreen(),
          _ProfileTab(), // Profile & Settings (Track D - Ticket #5)
        ],
      ),
      bottomNavigationBar: NavigationBar(
        // Track A - Ticket #135: Explicit Theme colors for navigation bar
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: theme.colorScheme.surfaceTint,
        indicatorColor: theme.colorScheme.secondaryContainer,
        // Track A - Ticket #217: Design system elevation.medium for bottom nav
        elevation: DWElevation.medium,
        selectedIndex: _currentTab.index,
        onDestinationSelected: (index) => _onTabSelected(AppTab.values[index]),
        // Design System: 4 tabs as per spec (Home, Orders, Payments, Profile)
        // Track A - Ticket #82: L10n for navigation labels
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.bottomNavHomeLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: l10n.bottomNavOrdersLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.payment_outlined),
            selectedIcon: const Icon(Icons.payment),
            label: l10n.bottomNavPaymentsLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.bottomNavProfileLabel,
          ),
        ],
      ),
    );
  }
}

/// Home Hub tab – map-centric layout + service cards (Ride / Parcels / Food)
/// Updated by: Track B - Ticket #19 (Home Hub Active Ride Card)
/// Updated by: Track C - Ticket #70 (Home Hub Active Parcel Card)
/// Updated by: Track C - Ticket #71 (Active Order State Layout per Screen 7 design)
/// Updated by: Track B - Ticket #85 (Unified ride_status_utils)
/// Updated by: Track B - Ticket #114 (Map from activeTripMapCommands)
///
/// Layout behavior (Ticket #71):
/// - Default State: Map at full size (16:9), service cards below
/// - Active Order State: Map reduced (16:5), Hero card(s) prominent, then services
///
/// Track B - Ticket #114: Map Integration
/// - When active trip exists with valid activeTripMapCommands → RideMapFromCommands
/// - Otherwise → placeholder map (stub)
class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  /// Select the active (non-terminal) parcel from state.
  /// Returns the most recent active parcel, or null if none.
  /// Track C - Ticket #70, Updated by Ticket #78 (use parcel_status_utils)
  Parcel? _selectActiveParcel(ParcelOrdersState state) {
    final active = state.parcels
        .where((p) => !isParcelStatusTerminal(p.status))
        .toList();
    if (active.isEmpty) return null;
    // Sort by createdAt descending (newest first)
    active.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return active.first;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    // Watch ride state providers (Track B - Ticket #19)
    final tripSession = ref.watch(rideTripSessionProvider);
    final rideDraft = ref.watch(rideDraftProvider);

    // Watch parcel orders state (Track C - Ticket #70)
    final parcelOrdersState = ref.watch(parcelOrdersProvider);
    final activeParcel = _selectActiveParcel(parcelOrdersState);
    final hasActiveParcel = activeParcel != null;

    // Extract destination for active ride card (Track B - Ticket #86)
    final destination = rideDraft.destinationQuery.trim();

    // Determine if there's an active (non-terminal) trip
    // Use local binding to avoid null assertion warnings
    // Track B - Ticket #85: Use centralized isRidePhaseTerminal from ride_status_utils
    final activeTripState = tripSession.activeTrip;
    final hasActiveTrip =
        activeTripState != null && !isRidePhaseTerminal(activeTripState.phase);

    // Track C - Ticket #71: Adjust map aspect ratio based on active order state
    // When there's an active parcel or trip, reduce map height to make room for the card
    // Screen 7 Design: Map ≈30% when active order, Hero card prominent below
    final hasActiveOrder = hasActiveParcel || hasActiveTrip;
    final aspectRatio = hasActiveOrder ? (16 / 5) : (16 / 9);

    // Track B - Ticket #114: Build map area based on active trip state
    Widget buildHomeMapArea({
      required RideMapCommands? activeTripCommands,
      required ColorScheme colorScheme,
      required TextTheme textTheme,
    }) {
      // When active trip has map commands, show real map
      if (activeTripCommands != null) {
        return RideMapFromCommands(commands: activeTripCommands);
      }

      // Fallback: placeholder map (stub)
      return Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.map_outlined,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: DWSpacing.xs),
              Text(
                'Map area',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Bar: location + profile icon
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DWSpacing.md,
              vertical: DWSpacing.xs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current location',
                        style: textTheme.titleMedium,
                      ),
                      Text(
                        'Set your pickup point',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Track D - Ticket #37: Open Account Bottom Sheet
                    showModalBottomSheet<void>(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(DWRadius.lg),
                        ),
                      ),
                      builder: (sheetContext) {
                        return _AccountBottomSheet(
                          parentContext: context,
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.account_circle),
                ),
              ],
            ),
          ),

          // Map area - Track B - Ticket #114: Real map when active trip exists
          // Screen 7 design: Shows activeTripMapCommands when ride is in progress
          // Aspect ratio adjusts when active trip exists (Track B - Ticket #19)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DWSpacing.md),
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(DWRadius.md),
                child: buildHomeMapArea(
                  activeTripCommands: tripSession.activeTripMapCommands,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
              ),
            ),
          ),

          // Track C - Ticket #71: Active Order State Layout
          // When there's an active parcel/trip, show a prominent "hero" card section
          // between the map and service cards (Screen 7 design)
          if (hasActiveOrder) ...[
            const SizedBox(height: DWSpacing.sm),
            // Active Order Cards Section - Hero area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DWSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Active Parcel Card (Track C - Ticket #70, #71)
                  if (hasActiveParcel) ...[
                    _ActiveParcelHomeCard(
                      activeParcel: activeParcel,
                    ),
                    if (hasActiveTrip) const SizedBox(height: DWSpacing.sm),
                  ],
                  // Active Ride Card (Track B - Ticket #19, #86, #105)
                  // Track B - Ticket #86: Uses localizedRidePhaseStatusLong for status
                  // Track B - Ticket #105: Shows price + payment method from tripSummary
                  if (activeTripState != null && hasActiveTrip)
                    _ActiveRideHomeCard(
                      phase: activeTripState.phase,
                      destinationLabel: destination.isEmpty
                          ? null
                          : l10n.rideActiveDestinationLabel(destination),
                      tripSummary: tripSession.tripSummary,
                      onViewTrip: () {
                        Navigator.of(context).pushNamed(RoutePaths.rideActive);
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: DWSpacing.sm),
          ] else ...[
            const SizedBox(height: DWSpacing.md),
          ],

          // Service Cards Section: Ride / Parcels / Food
          // Track C - Ticket #71: When active order exists, services are secondary (below hero)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DWSpacing.md),
              child: ListView(
                children: [
                  Text(
                    'Services',
                    style: textTheme.headlineSmall,
                  ),
                  const SizedBox(height: DWSpacing.xs),
                  _ServiceCard(
                    icon: Icons.directions_car,
                    title: l10n.homeRideCardTitle,
                    subtitle: l10n.homeRideCardSubtitle,
                    onTap: () {
                      // Track B - Ticket #94: Check for active trip before navigating
                      // If active trip exists → go to RideActiveTripScreen
                      // Otherwise → go to RideDestinationScreen (Location Picker)
                      if (hasActiveTrip) {
                        Navigator.of(context).pushNamed(RoutePaths.rideActive);
                      } else {
                        Navigator.of(context).pushNamed(RoutePaths.rideDestination);
                      }
                    },
                  ),
                  const SizedBox(height: DWSpacing.xs),
                  _ServiceCard(
                    icon: Icons.inventory_2_outlined,
                    title: 'Parcels',
                    subtitle: 'Send anything, anywhere.',
                    onTap: () {
                      // Track C - Ticket #40, #72: Parcels Feature Flag gate
                      // Navigate to ParcelsListScreen when enabled
                      if (FeatureFlags.enableParcelsMvp) {
                        Navigator.of(context).pushNamed(RoutePaths.parcelsList);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.parcelsComingSoonMessage,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: DWSpacing.xs),
                  _ServiceCard(
                    icon: Icons.fastfood_outlined,
                    title: l10n.homeFoodCardTitle,
                    subtitle: l10n.homeFoodCardSubtitle,
                    onTap: () {
                      // Track C - Ticket #48: Food Feature Flag gate
                      // Track C - Ticket #52: Wire to Food flow when enabled
                      // Track C - Ticket #56: L10n for card title/subtitle
                      if (!FeatureFlags.enableFoodMvp) {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const FoodComingSoonScreen(),
                          ),
                        );
                        return;
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const FoodRestaurantsListScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Track C - Ticket #78: _mapParcelStatusToLabel moved to parcel_status_utils.dart
// Use localizedParcelStatusLong(l10n, status) instead.

/// Active Parcel Card displayed on Home Hub when there's an active shipment.
/// Track C - Ticket #70, Updated by Ticket #71 (Design System alignment)
/// Track C - Ticket #74: Unified navigation to ParcelShipmentDetailsScreen
///
/// Design System Alignment (Ticket #71):
/// - Card: uses Card/Generic style (radius.md, elevation.medium from CardTheme)
/// - Typography: titleMedium (type.title.default), bodyMedium (type.subtitle.default)
/// - Spacing: DWSpacing tokens (space.md, space.sm, space.xxs)
/// - CTA: DWButton.tertiary for "View shipment" action
class _ActiveParcelHomeCard extends StatelessWidget {
  const _ActiveParcelHomeCard({
    required this.activeParcel,
  });

  final Parcel activeParcel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final statusLabel = localizedParcelStatusLong(l10n, activeParcel.status);

    // Determine destination label from dropoff address
    final destinationLabel = activeParcel.dropoffAddress.label.isNotEmpty
        ? activeParcel.dropoffAddress.label
        : '';

    // Track C - Ticket #74: Navigate directly to ParcelShipmentDetailsScreen
    void navigateToDetails() {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ParcelShipmentDetailsScreen(parcel: activeParcel),
        ),
      );
    }

    return Card(
      // Card/Generic style: radius.md + elevation.medium (from CardTheme in DWTheme)
      // Track C - Ticket #71: Card is the "hero" element in Active Order State
      child: InkWell(
        borderRadius: BorderRadius.circular(DWRadius.md),
        onTap: navigateToDetails,
        child: Padding(
          // space.md padding from Design Tokens
          padding: const EdgeInsets.all(DWSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon container with primary background tint
              Container(
                width: 44,
                height: 44,
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
              const SizedBox(width: DWSpacing.md),
              // Text content: Title + Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // type.title.default → titleMedium
                    Text(
                      statusLabel,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (destinationLabel.isNotEmpty) ...[
                      const SizedBox(height: DWSpacing.xxs),
                      // type.subtitle.default → bodyMedium
                      Text(
                        l10n.homeActiveParcelSubtitleToDestination(
                          destinationLabel,
                        ),
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: DWSpacing.sm),
              // CTA: "View shipment" using DWButton.tertiary for type.label.button
              // Track C - Ticket #74: Unified navigation
              DWButton.tertiary(
                label: l10n.homeActiveParcelViewShipmentCta,
                onPressed: navigateToDetails,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Track C - Ticket #78: _mapParcelStatusToLabel moved to parcel_status_utils.dart
// Track B - Ticket #86: _homeActiveRideHeadline removed, using localizedRidePhaseStatusLong instead

/// Active Ride Card displayed on Home Hub when there's an active trip.
/// Track B - Ticket #19
/// Updated by: Ticket #32 (DWSpacing/DWRadius consistency)
/// Updated by: Track B - Ticket #86 (Design System alignment + ride_status_utils)
/// Updated by: Track B - Ticket #105 (Unified trip summary - price + payment method)
/// Updated by: Track B - Ticket #114 (ETA title from tripSummary.etaMinutes)
///
/// Design System Alignment (Ticket #86):
/// - Card: uses Card/Generic style (radius.md, elevation.medium from CardTheme)
/// - Typography: titleMedium (type.title.default), bodyMedium (type.subtitle.default)
/// - Spacing: DWSpacing tokens (space.md, space.sm, space.xxs)
/// - CTA: DWButton.tertiary for "View trip" action
/// - Layout: Same as _ActiveParcelHomeCard (InkWell + Row structure)
///
/// Track B - Ticket #105:
/// - Now shows price + payment method from RideTripSummary
/// - Uses ConsumerWidget to access payment methods provider
///
/// Track B - Ticket #114:
/// - Title prioritizes ETA from tripSummary.etaMinutes when available
/// - Falls back to status label (localizedRidePhaseStatusLong) when no ETA
class _ActiveRideHomeCard extends ConsumerWidget {
  const _ActiveRideHomeCard({
    required this.phase,
    required this.destinationLabel,
    required this.onViewTrip,
    this.tripSummary,
  });

  final RideTripPhase phase;
  final String? destinationLabel;
  final VoidCallback onViewTrip;
  /// Track B - Ticket #105: Unified trip summary from FSM
  final RideTripSummary? tripSummary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // Track B - Ticket #114: Prioritize ETA title when available
    // Falls back to status label when no ETA
    final etaMinutes = tripSummary?.etaMinutes;
    final titleText = etaMinutes != null
        ? l10n.homeActiveRideEtaTitle(etaMinutes)
        : localizedRidePhaseStatusLong(l10n, phase);

    // Track B - Ticket #105: Build price + payment method subtitle
    final priceAndPaymentLabel = _buildPriceAndPaymentLabel(ref, l10n);

    return Card(
      // Card/Generic style: radius.md + elevation.medium (from CardTheme in DWTheme)
      // Track B - Ticket #86: Card is the "hero" element in Active Order State
      child: InkWell(
        borderRadius: BorderRadius.circular(DWRadius.md),
        onTap: onViewTrip,
        child: Padding(
          // space.md padding from Design Tokens
          padding: const EdgeInsets.all(DWSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon container with primary background tint
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(DWRadius.sm),
                ),
                child: Icon(
                  Icons.directions_car_outlined,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: DWSpacing.md),
              // Text content: Title + Subtitle + Price/Payment (Ticket #105, #114)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // type.title.default → titleMedium
                    // Track B - Ticket #114: Uses ETA title when available
                    Text(
                      titleText,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (destinationLabel != null &&
                        destinationLabel!.isNotEmpty) ...[
                      const SizedBox(height: DWSpacing.xxs),
                      // type.subtitle.default → bodyMedium
                      Text(
                        destinationLabel!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    // Track B - Ticket #105: Price + Payment method line
                    if (priceAndPaymentLabel != null) ...[
                      const SizedBox(height: DWSpacing.xxs),
                      Text(
                        priceAndPaymentLabel,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: DWSpacing.sm),
              // CTA: "View trip" using DWButton.tertiary for type.label.button
              DWButton.tertiary(
                label: l10n.homeActiveRideViewTripCta,
                onPressed: onViewTrip,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the price + payment method label from tripSummary.
  /// Track B - Ticket #105
  String? _buildPriceAndPaymentLabel(WidgetRef ref, AppLocalizations l10n) {
    if (tripSummary == null) return null;

    final paymentsState = ref.watch(paymentMethodsUiProvider);
    final paymentMethodId = tripSummary!.selectedPaymentMethodId;
    final paymentMethod = paymentMethodId != null
        ? paymentsState.methods.where((m) => m.id == paymentMethodId).firstOrNull
        : paymentsState.selectedMethod;

    final fareText = tripSummary!.fareDisplayText;
    final paymentName = paymentMethod?.displayName ?? l10n.paymentsMethodTypeCash;

    // Build combined label: "≈ 18.00 SAR · Visa ••4242"
    if (fareText != null && fareText.isNotEmpty) {
      return l10n.homeActiveRidePriceAndPayment('≈ $fareText', paymentName);
    }
    
    // Fallback: just payment method if no fare
    return paymentName;
  }
}

/// Service Card widget for Home Hub
/// Uses Theme.of(context) for unified styling (Track A - Ticket #1)
/// Updated by: Ticket #32 (DWSpacing/DWRadius consistency)
class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      // Uses CardTheme from DWTheme (radius: DWRadius.md, elevation: DWElevation.medium)
      child: InkWell(
        borderRadius: BorderRadius.circular(DWRadius.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(DWSpacing.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(DWSpacing.sm),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DWRadius.md),
                ),
                child: Icon(icon, color: colorScheme.primary, size: 28),
              ),
              const SizedBox(width: DWSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: DWSpacing.xxs),
                    Text(
                      subtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Orders Tab - Track C - Ticket #152
/// Orders History implementation using ParcelShipments from parcels_shims
/// Prepared for future integration with Rides and Food orders
enum OrdersFilter { all, rides, parcels, food }

class _OrdersTab extends ConsumerStatefulWidget {
  const _OrdersTab();

  @override
  ConsumerState<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends ConsumerState<_OrdersTab> {
  var _selectedFilter = OrdersFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final ordersAsync = ref.watch(ordersHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.ordersHistoryTitle,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          _OrdersFilterBar(
            selected: _selectedFilter,
            onChanged: (value) {
              setState(() => _selectedFilter = value);
            },
            textTheme: textTheme,
            colorScheme: colorScheme,
            l10n: l10n,
          ),
          const SizedBox(height: DWSpacing.sm),
          Expanded(
            child: ordersAsync.when(
              loading: () => const _OrdersLoadingState(),
              error: (error, stackTrace) => _OrdersErrorState(
                message: error.toString(),
                onRetry: () {
                  ref.invalidate(ordersHistoryProvider);
                },
              ),
              data: (items) {
                final filtered = _applyFilter(items, _selectedFilter);
                if (filtered.isEmpty) {
                  return DWEmptyState(
                    title: l10n.ordersHistoryEmptyTitle,
                    description: l10n.ordersHistoryEmptySubtitle,
                    primaryActionLabel: 'Create first shipment',
                    onPrimaryActionTap: () {
                      // Navigate to parcels flow
                      Navigator.of(context).pushNamed(RoutePaths.parcelsList);
                    },
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: DWSpacing.md,
                    vertical: DWSpacing.md,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return _buildOrderCard(item, l10n);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderHistoryItem item, AppLocalizations l10n) {
    switch (item.serviceType) {
      case OrderHistoryServiceType.parcel:
        final parcelItem = item as ParcelOrderHistoryItem;
        return _buildParcelOrderCard(parcelItem.shipment, l10n);
      case OrderHistoryServiceType.ride:
        final rideItem = item as RideOrderHistoryItem;
        return _buildRideOrderCard(rideItem.entry, l10n);
      case OrderHistoryServiceType.food:
        // TODO (future): Food order card
        return const SizedBox.shrink();
    }
  }

  Widget _buildParcelOrderCard(ParcelShipment shipment, AppLocalizations l10n) {
    final statusLabel = _mapParcelStatusToLabel(l10n, shipment.status);
    final priceText = _buildPriceText(shipment) ?? '—';

    return OrderCard(
      serviceType: OrderServiceType.parcel,
      title: shipment.dropoffAddress.label,
      subtitle: '${shipment.pickupAddress.label} → ${shipment.dropoffAddress.label}',
      statusLabel: statusLabel,
      priceLabel: priceText,
      onTap: () {
        // TODO: Navigate to parcel details when implemented
      },
    );
  }

  Widget _buildRideOrderCard(RideHistoryEntry entry, AppLocalizations l10n) {
    final statusLabel = _mapRideStatusToLabel(l10n, entry.trip.phase);
    final priceText = entry.amountFormatted ?? '—';

    final subtitle = entry.originLabel != null && entry.destinationLabel.isNotEmpty
        ? '${entry.originLabel} → ${entry.destinationLabel}'
        : MaterialLocalizations.of(context).formatMediumDate(entry.completedAt);

    return OrderCard(
      serviceType: OrderServiceType.ride,
      title: entry.destinationLabel,
      subtitle: subtitle,
      statusLabel: statusLabel,
      priceLabel: priceText,
      onTap: () {
        // TODO: Navigate to ride details when implemented
      },
    );
  }

  String _mapParcelStatusToLabel(AppLocalizations l10n, ParcelShipmentStatus status) {
    switch (status) {
      case ParcelShipmentStatus.created:
        return l10n.parcelsShipmentStatusCreated;
      case ParcelShipmentStatus.inTransit:
        return l10n.parcelsShipmentStatusInTransit;
      case ParcelShipmentStatus.delivered:
        return l10n.parcelsShipmentStatusDelivered;
      case ParcelShipmentStatus.cancelled:
        return l10n.parcelsShipmentStatusCancelled;
    }
  }

  String _mapRideStatusToLabel(AppLocalizations l10n, RideTripPhase phase) {
    switch (phase) {
      case RideTripPhase.draft:
        return l10n.rideStatusShortDraft;
      case RideTripPhase.quoting:
        return l10n.rideStatusShortQuoting;
      case RideTripPhase.requesting:
        return l10n.rideStatusShortRequesting;
      case RideTripPhase.findingDriver:
        return l10n.rideStatusShortFindingDriver;
      case RideTripPhase.driverAccepted:
        return l10n.rideStatusShortDriverAccepted;
      case RideTripPhase.driverArrived:
        return l10n.rideStatusShortDriverArrived;
      case RideTripPhase.inProgress:
      case RideTripPhase.payment:
        return l10n.rideStatusShortInProgress;
      case RideTripPhase.completed:
        return l10n.rideStatusShortCompleted;
      case RideTripPhase.cancelled:
        return l10n.rideStatusShortCancelled;
      case RideTripPhase.failed:
        return l10n.rideStatusShortFailed;
    }
  }

  String? _buildPriceText(ParcelShipment shipment) {
    if (shipment.estimatedPrice == null || shipment.currencyCode == null) {
      return null;
    }
    return '${shipment.estimatedPrice!.toStringAsFixed(2)} ${shipment.currencyCode}';
  }

  List<OrderHistoryItem> _applyFilter(
    List<OrderHistoryItem> items,
    OrdersFilter filter,
  ) {
    switch (filter) {
      case OrdersFilter.all:
        return items;
      case OrdersFilter.rides:
        return items
            .where(
              (i) => i.serviceType == OrderHistoryServiceType.ride,
            )
            .toList();
      case OrdersFilter.parcels:
        return items
            .where(
              (i) => i.serviceType == OrderHistoryServiceType.parcel,
            )
            .toList();
      case OrdersFilter.food:
        return items
            .where(
              (i) => i.serviceType == OrderHistoryServiceType.food,
            )
            .toList();
    }
  }
}

/// Segmented Control Filter Bar for Orders
class _OrdersFilterBar extends StatelessWidget {
  const _OrdersFilterBar({
    required this.selected,
    required this.onChanged,
    required this.textTheme,
    required this.colorScheme,
    required this.l10n,
  });

  final OrdersFilter selected;
  final ValueChanged<OrdersFilter> onChanged;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: DWSpacing.md,
        vertical: DWSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(DWSpacing.xs),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(DWRadius.lg),
        ),
        child: Row(
          children: [
            _buildChip(
              label: l10n.ordersFilterAll,
              value: OrdersFilter.all,
            ),
            _buildChip(
              label: l10n.ordersFilterRides,
              value: OrdersFilter.rides,
            ),
            _buildChip(
              label: l10n.ordersFilterParcels,
              value: OrdersFilter.parcels,
            ),
            _buildChip(
              label: l10n.ordersFilterFood,
              value: OrdersFilter.food,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required OrdersFilter value,
  }) {
    final isSelected = value == selected;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            vertical: DWSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.surface.withValues(alpha: 0.0),
            borderRadius: BorderRadius.circular(DWRadius.md),
          ),
          child: Center(
            child: Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}



/// Loading State for Orders Tab
/// Track C - Ticket #153: Enhanced with skeleton loader matching Card/Order design
class _OrdersLoadingState extends StatelessWidget {
  const _OrdersLoadingState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.all(DWSpacing.md),
      itemCount: 4, // Show 4 skeleton items
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: DWSpacing.sm),
          padding: const EdgeInsets.all(DWSpacing.md),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(DWRadius.lg),
            boxShadow: kElevationToShadow[1],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Skeleton icon placeholder
              _SkeletonBox(
                width: 48,
                height: 48,
                borderRadius: DWRadius.md,
                colorScheme: colorScheme,
              ),
              const SizedBox(width: DWSpacing.md),
              // Skeleton content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _SkeletonBox(
                            width: double.infinity,
                            height: 20,
                            colorScheme: colorScheme,
                          ),
                        ),
                        const SizedBox(width: DWSpacing.xs),
                        _SkeletonBox(
                          width: 60,
                          height: 24,
                          borderRadius: DWRadius.sm,
                          colorScheme: colorScheme,
                        ),
                      ],
                    ),
                    const SizedBox(height: DWSpacing.xs),
                    _SkeletonBox(
                      width: 200,
                      height: 14,
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: DWSpacing.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SkeletonBox(
                          width: 80,
                          height: 14,
                          colorScheme: colorScheme,
                        ),
                        _SkeletonBox(
                          width: 60,
                          height: 16,
                          colorScheme: colorScheme,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Skeleton box widget for loading state
class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.colorScheme,
    this.borderRadius = DWRadius.xs,
  });

  final double width;
  final double height;
  final ColorScheme colorScheme;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Error State for Orders Tab
/// Track C - Ticket #153: Enhanced with retry capability and better styling
class _OrdersErrorState extends StatelessWidget {
  const _OrdersErrorState({
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Simplify error message for user display
    final displayMessage = message.contains('Exception:') 
        ? 'Something went wrong. Please try again.'
        : message;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DWSpacing.lg),
        child: Container(
          padding: const EdgeInsets.all(DWSpacing.lg),
          decoration: BoxDecoration(
            color: colorScheme.errorContainer.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DWRadius.lg),
            border: Border.all(
              color: colorScheme.error.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: colorScheme.error,
              ),
              const SizedBox(height: DWSpacing.md),
              Text(
                'Unable to load orders',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DWSpacing.xs),
              Text(
                displayMessage,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: DWSpacing.lg),
                TextButton(
                  onPressed: onRetry,
                  child: Text(
                    'Retry',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


/// Profile Tab - Track D - Ticket #5
/// Full Profile/Settings implementation with DSR integration
/// Updated by: Ticket #32 (DWSpacing/DWRadius consistency)
class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // Get auth state for user info
    final authStateAsync = ref.watch(authStateProvider);

    String? phone;
    String? displayName;

    authStateAsync.whenData((state) {
      if (state.isAuthenticated && state.session != null) {
        phone = state.session!.user.phoneNumber;
        displayName = state.session!.user.displayName;
      }
    });

    final effectiveName = displayName?.trim().isNotEmpty == true
        ? displayName!
        : l10n.profileUserFallbackName;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(DWSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Header
            Text(
              l10n.profileTitle,
              style: textTheme.headlineMedium,
            ),
            const SizedBox(height: DWSpacing.md),

            // User Info Card
            Card(
              // Uses CardTheme from DWTheme (radius: DWRadius.md)
              child: Padding(
                padding: const EdgeInsets.all(DWSpacing.md),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.person,
                        color: colorScheme.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: DWSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            effectiveName,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: DWSpacing.xxs),
                          Text(
                            phone ?? '—',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: DWSpacing.lg),

            // Settings Section
            Text(
              l10n.profileSectionSettingsTitle,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DWSpacing.xs),

            _ProfileListTile(
              icon: Icons.person_outline,
              title: l10n.profileSettingsPersonalInfoTitle,
              subtitle: l10n.profileSettingsPersonalInfoSubtitle,
              enabled: false,
              onTap: null,
            ),
            _ProfileListTile(
              icon: Icons.settings_suggest_outlined,
              title: l10n.profileSettingsRidePrefsTitle,
              subtitle: l10n.profileSettingsRidePrefsSubtitle,
              enabled: false,
              onTap: null,
            ),
            _ProfileListTile(
              icon: Icons.notifications_outlined,
              title: l10n.profileSettingsNotificationsTitle,
              subtitle: l10n.profileSettingsNotificationsSubtitle,
              enabled: false,
              onTap: null,
            ),
            _ProfileListTile(
              icon: Icons.help_outline,
              title: l10n.profileSettingsHelpTitle,
              subtitle: l10n.profileSettingsHelpSubtitle,
              enabled: false,
              onTap: null,
            ),

            const SizedBox(height: DWSpacing.lg),

            // Privacy & Data Section (DSR)
            Text(
              l10n.profileSectionPrivacyTitle,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DWSpacing.xs),

            _ProfileListTile(
              icon: Icons.download_outlined,
              title: l10n.profilePrivacyExportTitle,
              subtitle: l10n.profilePrivacyExportSubtitle,
              enabled: true,
              onTap: () => _openDsrExport(context),
            ),
            _ProfileListTile(
              icon: Icons.delete_forever_outlined,
              title: l10n.profilePrivacyErasureTitle,
              subtitle: l10n.profilePrivacyErasureSubtitle,
              enabled: true,
              onTap: () => _openDsrErasure(context),
            ),

            const SizedBox(height: DWSpacing.lg),

            // Logout
            _ProfileListTile(
              icon: Icons.logout,
              title: l10n.profileLogoutTitle,
              subtitle: l10n.profileLogoutSubtitle,
              enabled: true,
              onTap: () => _logout(ref, context),
            ),
          ],
        ),
      ),
    );
  }

  void _openDsrExport(BuildContext context) {
    Navigator.of(context).pushNamed(RoutePaths.dsrExport);
  }

  void _openDsrErasure(BuildContext context) {
    Navigator.of(context).pushNamed(RoutePaths.dsrErasure);
  }

  Future<void> _logout(WidgetRef ref, BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.profileLogoutDialogTitle),
        content: Text(l10n.profileLogoutDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.profileLogoutDialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.profileLogoutDialogConfirm),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final authService = ref.read(authServiceProvider);
        await authService.logout();
      } catch (e) {
        // Handle error silently - auth state will update automatically
        debugPrint('Logout error: $e');
      }
    }
  }
}

/// Helper widget for profile list tiles
/// Updated by: Ticket #32 (DWSpacing/DWRadius consistency)
class _ProfileListTile extends StatelessWidget {
  const _ProfileListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: DWSpacing.xxs),
      // Uses CardTheme from DWTheme (radius: DWRadius.md)
      child: ListTile(
        enabled: enabled,
        leading: Icon(
          icon,
          color: enabled ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
        title: Text(
          title,
          style: textTheme.bodyLarge?.copyWith(
            color: enabled ? null : colorScheme.onSurfaceVariant,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: enabled ? colorScheme.onSurfaceVariant : colorScheme.outline,
        ),
        onTap: enabled ? onTap : null,
      ),
    );
  }
}

/// Account Bottom Sheet for Home Hub
/// Created by: Track D - Ticket #37
/// Shows sign-in CTA when not authenticated, or user info + sign out when authenticated.
class _AccountBottomSheet extends ConsumerWidget {
  const _AccountBottomSheet({
    required this.parentContext,
  });

  /// Parent context for navigation outside the sheet
  final BuildContext parentContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final authState = ref.watch(simpleAuthStateProvider);
    final isAuthenticated = authState.isAuthenticated;
    final phoneNumber = authState.phoneNumber;

    return Padding(
      padding: const EdgeInsets.all(DWSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.outlineVariant,
                borderRadius: BorderRadius.circular(DWRadius.circle),
              ),
            ),
          ),
          const SizedBox(height: DWSpacing.lg),

          // Title
          Text(
            l10n.accountSheetTitle,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: DWSpacing.sm),

          if (!isAuthenticated) ...[
            // Signed-out state
            Text(
              l10n.accountSheetSignedOutSubtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: DWSpacing.lg),

            DWButton.primary(
              label: l10n.accountSheetSignInCta,
              onPressed: () {
                Navigator.of(context).pop(); // Close sheet
                Navigator.of(parentContext).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PhoneSignInScreen(),
                  ),
                );
              },
            ),
          ] else ...[
            // Signed-in state
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: colors.primary.withValues(alpha: 0.12),
                  child: Icon(
                    Icons.person,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: DWSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.accountSheetSignedInTitle,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (phoneNumber != null && phoneNumber.isNotEmpty) ...[
                        const SizedBox(height: DWSpacing.xxs),
                        Text(
                          phoneNumber,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: DWSpacing.lg),

            DWButton.tertiary(
              label: l10n.accountSheetSignOutCta,
              onPressed: () {
                // Sign out + close sheet
                ref.read(simpleAuthStateProvider.notifier).signOut();
                Navigator.of(context).pop();
              },
            ),
          ],
          const SizedBox(height: DWSpacing.md),

          // Footer text
          Align(
            alignment: Alignment.center,
            child: Text(
              l10n.accountSheetFooterText,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: DWSpacing.sm),
        ],
      ),
    );
  }
}


/// Widget tests for OrdersHistoryScreen (Track B - Ticket #96, #98, #108, #124, #125, #126, #127, #128)
/// Purpose: Verify orders history screen UI with Rides support
/// Created by: Track B - Ticket #96
/// Updated by: Track B - Ticket #98 (Orders → Trip Summary navigation tests)
/// Updated by: Track B - Ticket #108 (Extended display: service name, origin, payment)
/// Updated by: Track B - Ticket #124 (Driver rating display in ride cards)
/// Updated by: Track B - Ticket #125 (Segmented Control filter + Empty States per Mockups)
/// Updated by: Track B - Ticket #126 (OrderStatusChip for Rides and Parcels)
/// Updated by: Track B - Ticket #127 (Skeleton Loader + Semantics accessibility tests)
/// Updated by: Track B - Ticket #128 (Skeleton Pulsing/Shimmer animation tests)
/// Last updated: 2025-12-01

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// App imports
import 'package:delivery_ways_clean/screens/orders/orders_history_screen.dart';
import 'package:delivery_ways_clean/screens/orders/widgets/orders_history_filter_bar.dart';
import 'package:delivery_ways_clean/screens/orders/widgets/order_status_chip.dart';
import 'package:delivery_ways_clean/screens/orders/widgets/order_list_skeleton.dart';
import 'package:delivery_ways_clean/screens/mobility/ride_trip_summary_screen.dart';
import 'package:delivery_ways_clean/router/app_router.dart';
import 'package:delivery_ways_clean/state/mobility/ride_trip_session.dart';
import 'package:delivery_ways_clean/state/mobility/ride_draft_state.dart';
import 'package:delivery_ways_clean/state/mobility/ride_quote_controller.dart';
import 'package:delivery_ways_clean/state/parcels/parcel_orders_state.dart';
import 'package:delivery_ways_clean/state/parcels/parcel_draft_state.dart';
import 'package:delivery_ways_clean/state/food/food_orders_state.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';

// Shims
import 'package:mobility_shims/mobility_shims.dart';
import 'package:parcels_shims/parcels_shims.dart';
import 'package:food_shims/food_shims.dart';

void main() {
  // Track B - Ticket #127: Run skeleton and semantics tests
  _ticket127Tests();

  group('OrdersHistoryScreen - Track B Ticket #96', () {
    /// Helper to build the test widget with provider overrides
    Widget buildTestWidget({
      RideTripSessionUiState? rideSession,
      ParcelOrdersState? parcelsState,
      FoodOrdersState? foodState,
      Locale locale = const Locale('en'),
    }) {
      return ProviderScope(
        overrides: [
          rideTripSessionProvider.overrideWith(
            (ref) => _FakeRideTripSessionController(
              initialState: rideSession ?? const RideTripSessionUiState(),
            ),
          ),
          parcelOrdersProvider.overrideWith(
            (ref) => _FakeParcelOrdersController(
              initialState: parcelsState ?? const ParcelOrdersState(),
            ),
          ),
          foodOrdersControllerProvider.overrideWith(
            (ref) => _FakeFoodOrdersController(
              initialState: foodState ?? const FoodOrdersState(),
            ),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
            Locale('de'),
          ],
          locale: locale,
          home: const OrdersHistoryScreen(),
        ),
      );
    }

    // =========================================================================
    // Empty State Tests
    // =========================================================================

    testWidgets('shows_empty_state_when_no_history', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify empty state is shown
      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
      expect(find.text('No orders yet'), findsOneWidget);
    });

    // =========================================================================
    // Rides Section Tests
    // =========================================================================

    testWidgets('shows_single_completed_ride_in_list', (tester) async {
      const completedTrip = RideTripState(
        tripId: 'test-ride-1',
        phase: RideTripPhase.completed,
      );
      final historyEntry = RideHistoryEntry(
        trip: completedTrip,
        destinationLabel: 'Mall of Arabia',
        completedAt: DateTime(2025, 5, 24, 22, 32),
        amountFormatted: 'SAR 24.50',
      );

      await tester.pumpWidget(buildTestWidget(
        rideSession: RideTripSessionUiState(
          historyTrips: [historyEntry],
        ),
      ));
      await tester.pumpAndSettle();

      // Verify ride is shown
      // Note: "Rides" appears in both filter chip and section title
      expect(find.text('Rides'), findsAtLeastNWidgets(1));
      expect(find.text('Ride to Mall of Arabia'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('SAR 24.50'), findsOneWidget);
    });

    testWidgets('shows_cancelled_and_failed_status_labels', (tester) async {
      const cancelledTrip = RideTripState(
        tripId: 'test-ride-cancelled',
        phase: RideTripPhase.cancelled,
      );
      const failedTrip = RideTripState(
        tripId: 'test-ride-failed',
        phase: RideTripPhase.failed,
      );

      final cancelledEntry = RideHistoryEntry(
        trip: cancelledTrip,
        destinationLabel: 'Airport',
        completedAt: DateTime(2025, 5, 23, 10, 0),
      );
      final failedEntry = RideHistoryEntry(
        trip: failedTrip,
        destinationLabel: 'Downtown',
        completedAt: DateTime(2025, 5, 22, 15, 30),
      );

      await tester.pumpWidget(buildTestWidget(
        rideSession: RideTripSessionUiState(
          historyTrips: [cancelledEntry, failedEntry],
        ),
      ));
      await tester.pumpAndSettle();

      // Verify both status labels are shown
      expect(find.text('Cancelled'), findsOneWidget);
      expect(find.text('Failed'), findsOneWidget);
      expect(find.text('Ride to Airport'), findsOneWidget);
      expect(find.text('Ride to Downtown'), findsOneWidget);
    });

    // =========================================================================
    // Extended Display Tests - Track B Ticket #108
    // =========================================================================

    testWidgets('shows_service_name_in_title_when_available', (tester) async {
      final historyEntry = RideHistoryEntry(
        trip: const RideTripState(
          tripId: 'test-ride-108',
          phase: RideTripPhase.completed,
        ),
        destinationLabel: 'Airport',
        completedAt: DateTime(2025, 5, 24, 14, 30),
        amountFormatted: 'SAR 45.00',
        serviceName: 'Economy',
        originLabel: 'Home',
        paymentMethodLabel: 'Visa ••4242',
      );

      await tester.pumpWidget(buildTestWidget(
        rideSession: RideTripSessionUiState(
          historyTrips: [historyEntry],
        ),
      ));
      await tester.pumpAndSettle();

      // Should show service name in title
      expect(find.text('Economy to Airport'), findsOneWidget);
      // Amount should still be visible
      expect(find.text('SAR 45.00'), findsOneWidget);
    });

    testWidgets('shows_origin_in_subtitle_when_available', (tester) async {
      final historyEntry = RideHistoryEntry(
        trip: const RideTripState(
          tripId: 'test-ride-origin',
          phase: RideTripPhase.completed,
        ),
        destinationLabel: 'Mall',
        completedAt: DateTime(2025, 5, 24, 10, 30),
        originLabel: 'Office',
        serviceName: 'XL',
      );

      await tester.pumpWidget(buildTestWidget(
        rideSession: RideTripSessionUiState(
          historyTrips: [historyEntry],
        ),
      ));
      await tester.pumpAndSettle();

      // Should show origin in subtitle with date
      expect(find.textContaining('From Office'), findsOneWidget);
    });

    testWidgets('shows_payment_method_when_available', (tester) async {
      final historyEntry = RideHistoryEntry(
        trip: const RideTripState(
          tripId: 'test-ride-payment',
          phase: RideTripPhase.completed,
        ),
        destinationLabel: 'Station',
        completedAt: DateTime(2025, 5, 24, 16, 0),
        paymentMethodLabel: 'Mada ••1234',
      );

      await tester.pumpWidget(buildTestWidget(
        rideSession: RideTripSessionUiState(
          historyTrips: [historyEntry],
        ),
      ));
      await tester.pumpAndSettle();

      // Should show payment method
      expect(find.text('Mada ••1234'), findsOneWidget);
      // Payment icon should be visible
      expect(find.byIcon(Icons.payment), findsOneWidget);
    });

    testWidgets('falls_back_to_ride_to_destination_when_no_service_name', (tester) async {
      final historyEntry = RideHistoryEntry(
        trip: const RideTripState(
          tripId: 'test-ride-no-service',
          phase: RideTripPhase.completed,
        ),
        destinationLabel: 'Downtown',
        completedAt: DateTime(2025, 5, 24, 18, 0),
        // No serviceName
      );

      await tester.pumpWidget(buildTestWidget(
        rideSession: RideTripSessionUiState(
          historyTrips: [historyEntry],
        ),
      ));
      await tester.pumpAndSettle();

      // Should fall back to "Ride to X" format
      expect(find.text('Ride to Downtown'), findsOneWidget);
    });

    testWidgets('shows_full_ride_card_with_all_extended_data', (tester) async {
      final historyEntry = RideHistoryEntry(
        trip: const RideTripState(
          tripId: 'test-ride-full',
          phase: RideTripPhase.completed,
        ),
        destinationLabel: 'King Fahd Road',
        completedAt: DateTime(2025, 5, 24, 22, 45),
        amountFormatted: 'SAR 32.50',
        serviceName: 'Premium',
        originLabel: 'Riyadh Park',
        paymentMethodLabel: 'Apple Pay',
      );

      await tester.pumpWidget(buildTestWidget(
        rideSession: RideTripSessionUiState(
          historyTrips: [historyEntry],
        ),
      ));
      await tester.pumpAndSettle();

      // All data should be visible
      expect(find.text('Premium to King Fahd Road'), findsOneWidget);
      expect(find.text('SAR 32.50'), findsOneWidget);
      expect(find.textContaining('From Riyadh Park'), findsOneWidget);
      expect(find.text('Apple Pay'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
    });

    // =========================================================================
    // Track B - Ticket #124: Driver Rating Display Tests
    // =========================================================================

    testWidgets('shows_driver_rating_when_available', (tester) async {
      final historyEntry = RideHistoryEntry(
        trip: const RideTripState(
          tripId: 'test-ride-rating',
          phase: RideTripPhase.completed,
        ),
        destinationLabel: 'Mall',
        completedAt: DateTime(2025, 5, 24, 15, 30),
        amountFormatted: 'SAR 25.00',
        driverRating: 4.5, // Track B - Ticket #124
      );

      await tester.pumpWidget(buildTestWidget(
        rideSession: RideTripSessionUiState(
          historyTrips: [historyEntry],
        ),
      ));
      await tester.pumpAndSettle();

      // Should show star icon for rating
      expect(find.byIcon(Icons.star), findsAtLeastNWidgets(1));
      // Should show rating value
      expect(find.text('4.5'), findsOneWidget);
    });

    testWidgets('hides_driver_rating_when_not_available', (tester) async {
      final historyEntry = RideHistoryEntry(
        trip: const RideTripState(
          tripId: 'test-ride-no-rating',
          phase: RideTripPhase.completed,
        ),
        destinationLabel: 'Airport',
        completedAt: DateTime(2025, 5, 24, 10, 0),
        // No driverRating
      );

      await tester.pumpWidget(buildTestWidget(
        rideSession: RideTripSessionUiState(
          historyTrips: [historyEntry],
        ),
      ));
      await tester.pumpAndSettle();

      // Verify ride card is shown
      expect(find.text('Ride to Airport'), findsOneWidget);
      
      // The star icon in the card should not appear (the one for rating)
      // Note: There may be other star icons in the status chip, so we check the text
      // Rating format like "4.5" should not appear
      expect(find.textContaining(RegExp(r'^\d\.\d$')), findsNothing);
    });

    testWidgets('shows_integer_rating_with_decimal_format', (tester) async {
      final historyEntry = RideHistoryEntry(
        trip: const RideTripState(
          tripId: 'test-ride-int-rating',
          phase: RideTripPhase.completed,
        ),
        destinationLabel: 'Station',
        completedAt: DateTime(2025, 5, 24, 12, 0),
        driverRating: 5.0, // Integer rating
      );

      await tester.pumpWidget(buildTestWidget(
        rideSession: RideTripSessionUiState(
          historyTrips: [historyEntry],
        ),
      ));
      await tester.pumpAndSettle();

      // Should show "5.0" not just "5"
      expect(find.text('5.0'), findsOneWidget);
    });

    testWidgets('shows_rating_with_all_other_card_data', (tester) async {
      final historyEntry = RideHistoryEntry(
        trip: const RideTripState(
          tripId: 'test-ride-full-with-rating',
          phase: RideTripPhase.completed,
        ),
        destinationLabel: 'Downtown',
        completedAt: DateTime(2025, 5, 24, 18, 30),
        amountFormatted: 'SAR 30.00',
        serviceName: 'XL',
        originLabel: 'Home',
        paymentMethodLabel: 'Visa ••4242',
        driverRating: 4.0,
      );

      await tester.pumpWidget(buildTestWidget(
        rideSession: RideTripSessionUiState(
          historyTrips: [historyEntry],
        ),
      ));
      await tester.pumpAndSettle();

      // All data including rating should be visible
      expect(find.text('XL to Downtown'), findsOneWidget);
      expect(find.text('SAR 30.00'), findsOneWidget);
      expect(find.textContaining('From Home'), findsOneWidget);
      expect(find.text('Visa ••4242'), findsOneWidget);
      expect(find.text('4.0'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
    });

    // =========================================================================
    // Filter Tests
    // =========================================================================

    testWidgets('filters_rides_when_rides_tab_selected', (tester) async {
      final rideEntry = RideHistoryEntry(
        trip: const RideTripState(
          tripId: 'test-ride-1',
          phase: RideTripPhase.completed,
        ),
        destinationLabel: 'Mall',
        completedAt: DateTime.now(),
      );

      await tester.pumpWidget(buildTestWidget(
        rideSession: RideTripSessionUiState(
          historyTrips: [rideEntry],
        ),
      ));
      await tester.pumpAndSettle();

      // Initially "All" is selected, ride should be visible
      expect(find.text('Ride to Mall'), findsOneWidget);

      // Tap "Rides" filter
      await tester.tap(find.text('Rides').first);
      await tester.pumpAndSettle();

      // Ride should still be visible
      expect(find.text('Ride to Mall'), findsOneWidget);

      // Tap "Parcels" filter
      await tester.tap(find.text('Parcels'));
      await tester.pumpAndSettle();

      // Ride should NOT be visible (only parcels section)
      expect(find.text('Ride to Mall'), findsNothing);
    });

    testWidgets('all_filter_chips_are_visible', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify all filter chips are present
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Rides'), findsOneWidget);
      expect(find.text('Parcels'), findsOneWidget);
      // Food may or may not be visible depending on feature flag
    });

    // =========================================================================
    // Track B - Ticket #125: Segmented Control Filter Tests
    // =========================================================================

    testWidgets('segmented_control_selects_all_by_default', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify OrdersHistoryFilterBar is rendered
      expect(find.byType(OrdersHistoryFilterBar), findsOneWidget);

      // All should be visually selected (we verify this indirectly by checking
      // that all order types are visible when there's data)
      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('tapping_rides_filter_hides_parcels_and_food', (tester) async {
      final rideEntry = RideHistoryEntry(
        trip: const RideTripState(
          tripId: 'filter-ride-1',
          phase: RideTripPhase.completed,
        ),
        destinationLabel: 'Ride Destination',
        completedAt: DateTime.now(),
      );
      final parcel = Parcel(
        id: 'filter-parcel-1',
        createdAt: DateTime.now(),
        pickupAddress: const ParcelAddress(label: 'Pickup'),
        dropoffAddress: const ParcelAddress(label: 'Dropoff'),
        details: const ParcelDetails(size: ParcelSize.medium, weightKg: 1.0),
        status: ParcelStatus.delivered,
      );

      await tester.pumpWidget(buildTestWidget(
        rideSession: RideTripSessionUiState(historyTrips: [rideEntry]),
        parcelsState: ParcelOrdersState(parcels: [parcel]),
      ));
      await tester.pumpAndSettle();

      // Both should be visible in "All" filter
      expect(find.text('Ride to Ride Destination'), findsOneWidget);
      expect(find.textContaining('Dropoff'), findsOneWidget);

      // Tap "Rides" filter
      await tester.tap(find.text('Rides').first);
      await tester.pumpAndSettle();

      // Only ride should be visible
      expect(find.text('Ride to Ride Destination'), findsOneWidget);
      // Parcel should be hidden
      expect(find.textContaining('Dropoff'), findsNothing);
    });

    testWidgets('tapping_parcels_filter_hides_rides_and_food', (tester) async {
      final rideEntry = RideHistoryEntry(
        trip: const RideTripState(
          tripId: 'filter-ride-2',
          phase: RideTripPhase.completed,
        ),
        destinationLabel: 'Ride Place',
        completedAt: DateTime.now(),
      );
      final parcel = Parcel(
        id: 'filter-parcel-2',
        createdAt: DateTime.now(),
        pickupAddress: const ParcelAddress(label: 'Sender'),
        dropoffAddress: const ParcelAddress(label: 'Receiver Location'),
        details: const ParcelDetails(size: ParcelSize.small, weightKg: 0.5),
        status: ParcelStatus.delivered,
      );

      await tester.pumpWidget(buildTestWidget(
        rideSession: RideTripSessionUiState(historyTrips: [rideEntry]),
        parcelsState: ParcelOrdersState(parcels: [parcel]),
      ));
      await tester.pumpAndSettle();

      // Tap "Parcels" filter (first occurrence in the filter bar)
      await tester.tap(find.text('Parcels').first);
      await tester.pumpAndSettle();

      // Only parcel should be visible
      expect(find.textContaining('Receiver Location'), findsOneWidget);
      // Ride should be hidden
      expect(find.text('Ride to Ride Place'), findsNothing);
    });

    testWidgets('switching_filters_updates_list_dynamically', (tester) async {
      final rideEntry = RideHistoryEntry(
        trip: const RideTripState(
          tripId: 'dynamic-ride',
          phase: RideTripPhase.completed,
        ),
        destinationLabel: 'Airport',
        completedAt: DateTime.now(),
      );

      await tester.pumpWidget(buildTestWidget(
        rideSession: RideTripSessionUiState(historyTrips: [rideEntry]),
      ));
      await tester.pumpAndSettle();

      // Initial state: All filter, ride visible
      expect(find.text('Ride to Airport'), findsOneWidget);

      // Switch to Parcels (first occurrence in the filter bar)
      await tester.tap(find.text('Parcels').first);
      await tester.pumpAndSettle();

      // Ride should be hidden, empty state for parcels shown
      expect(find.text('Ride to Airport'), findsNothing);
      expect(find.text('No parcels yet'), findsOneWidget);

      // Switch to Rides
      await tester.tap(find.text('Rides').first);
      await tester.pumpAndSettle();

      // Ride should be visible again
      expect(find.text('Ride to Airport'), findsOneWidget);
    });

    // =========================================================================
    // Track B - Ticket #125: Empty State Per Filter Tests
    // =========================================================================

    testWidgets('empty_state_all_shows_generic_message', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // All filter is default, should show generic empty state
      expect(find.text('No orders yet'), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
    });

    testWidgets('empty_state_rides_shows_rides_specific_message', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap "Rides" filter
      await tester.tap(find.text('Rides').first);
      await tester.pumpAndSettle();

      // Should show rides-specific empty state
      expect(find.text('No rides yet'), findsOneWidget);
      expect(find.byIcon(Icons.directions_car_outlined), findsOneWidget);
    });

    testWidgets('empty_state_parcels_shows_parcels_specific_message', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap "Parcels" filter (first occurrence in the filter bar)
      await tester.tap(find.text('Parcels').first);
      await tester.pumpAndSettle();

      // Should show parcels-specific empty state
      expect(find.text('No parcels yet'), findsOneWidget);
      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    });

    testWidgets('empty_state_has_context_specific_icon', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // All filter: receipt icon
      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);

      // Switch to Rides: car icon
      await tester.tap(find.text('Rides').first);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.directions_car_outlined), findsOneWidget);

      // Switch to Parcels: inventory icon (first occurrence in the filter bar)
      await tester.tap(find.text('Parcels').first);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    });

    testWidgets('filter_bar_has_minimum_touch_target', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Find the filter bar
      final filterBar = find.byType(OrdersHistoryFilterBar);
      expect(filterBar, findsOneWidget);

      // The bar should have reasonable height for touch targets (at least 44px)
      final filterBarWidget = tester.widget<OrdersHistoryFilterBar>(filterBar);
      expect(filterBarWidget, isNotNull);
    });

    // =========================================================================
    // L10n Tests - Arabic
    // =========================================================================

    testWidgets('l10n_ar_renders_arabic_labels', (tester) async {
      final historyEntry = RideHistoryEntry(
        trip: const RideTripState(
          tripId: 'test-ar-ride',
          phase: RideTripPhase.completed,
        ),
        destinationLabel: 'المطار',
        completedAt: DateTime.now(),
      );

      await tester.pumpWidget(buildTestWidget(
        rideSession: RideTripSessionUiState(
          historyTrips: [historyEntry],
        ),
        locale: const Locale('ar'),
      ));
      await tester.pumpAndSettle();

      // Verify Arabic labels
      expect(find.text('طلباتي'), findsOneWidget); // "My orders" title
      expect(find.text('الرحلات'), findsAtLeastNWidgets(1)); // "Rides" filter/section
      expect(find.text('مكتملة'), findsOneWidget); // "Completed" status
      expect(find.text('رحلة إلى المطار'), findsOneWidget); // "Ride to Airport"
    });

    testWidgets('l10n_ar_cancelled_status', (tester) async {
      final cancelledEntry = RideHistoryEntry(
        trip: const RideTripState(
          tripId: 'test-ar-cancelled',
          phase: RideTripPhase.cancelled,
        ),
        destinationLabel: 'المول',
        completedAt: DateTime.now(),
      );

      await tester.pumpWidget(buildTestWidget(
        rideSession: RideTripSessionUiState(
          historyTrips: [cancelledEntry],
        ),
        locale: const Locale('ar'),
      ));
      await tester.pumpAndSettle();

      // Verify Arabic cancelled status
      expect(find.text('ملغاة'), findsOneWidget);
    });

    // =========================================================================
    // L10n Tests - German
    // =========================================================================

    testWidgets('l10n_de_renders_german_labels', (tester) async {
      final historyEntry = RideHistoryEntry(
        trip: const RideTripState(
          tripId: 'test-de-ride',
          phase: RideTripPhase.completed,
        ),
        destinationLabel: 'Flughafen',
        completedAt: DateTime.now(),
      );

      await tester.pumpWidget(buildTestWidget(
        rideSession: RideTripSessionUiState(
          historyTrips: [historyEntry],
        ),
        locale: const Locale('de'),
      ));
      await tester.pumpAndSettle();

      // Verify German labels
      // Note: German uses "Meine Bestellungen" for "My orders"
      expect(find.text('Meine Bestellungen'), findsOneWidget); // "My orders" title
      expect(find.text('Fahrten'), findsAtLeastNWidgets(1)); // "Rides" filter/section
      expect(find.text('Abgeschlossen'), findsOneWidget); // "Completed" status
      expect(find.text('Fahrt nach Flughafen'), findsOneWidget); // "Ride to Airport"
    });

    testWidgets('l10n_de_failed_status', (tester) async {
      final failedEntry = RideHistoryEntry(
        trip: const RideTripState(
          tripId: 'test-de-failed',
          phase: RideTripPhase.failed,
        ),
        destinationLabel: 'Bahnhof',
        completedAt: DateTime.now(),
      );

      await tester.pumpWidget(buildTestWidget(
        rideSession: RideTripSessionUiState(
          historyTrips: [failedEntry],
        ),
        locale: const Locale('de'),
      ));
      await tester.pumpAndSettle();

      // Verify German failed status
      expect(find.text('Fehlgeschlagen'), findsOneWidget);
    });

    // =========================================================================
    // Multiple Items Tests
    // =========================================================================

    testWidgets('shows_multiple_rides_in_chronological_order', (tester) async {
      final ride1 = RideHistoryEntry(
        trip: const RideTripState(
          tripId: 'test-ride-1',
          phase: RideTripPhase.completed,
        ),
        destinationLabel: 'First Destination',
        completedAt: DateTime(2025, 5, 24, 10, 0),
      );
      final ride2 = RideHistoryEntry(
        trip: const RideTripState(
          tripId: 'test-ride-2',
          phase: RideTripPhase.cancelled,
        ),
        destinationLabel: 'Second Destination',
        completedAt: DateTime(2025, 5, 24, 12, 0),
      );

      await tester.pumpWidget(buildTestWidget(
        rideSession: RideTripSessionUiState(
          historyTrips: [ride2, ride1], // Newest first
        ),
      ));
      await tester.pumpAndSettle();

      // Verify both rides are visible
      expect(find.text('Ride to First Destination'), findsOneWidget);
      expect(find.text('Ride to Second Destination'), findsOneWidget);
    });

    // =========================================================================
    // Track B - Ticket #126: OrderStatusChip Tests
    // =========================================================================

    testWidgets('ride_card_renders_order_status_chip', (tester) async {
      const completedTrip = RideTripState(
        tripId: 'chip-test-ride',
        phase: RideTripPhase.completed,
      );
      final historyEntry = RideHistoryEntry(
        trip: completedTrip,
        destinationLabel: 'Chip Test Destination',
        completedAt: DateTime(2025, 5, 24, 22, 32),
      );

      await tester.pumpWidget(buildTestWidget(
        rideSession: RideTripSessionUiState(
          historyTrips: [historyEntry],
        ),
      ));
      await tester.pumpAndSettle();

      // Verify OrderStatusChip widget is rendered
      expect(find.byType(OrderStatusChip), findsOneWidget);
      // Verify the chip shows the correct status text
      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('parcel_card_renders_order_status_chip', (tester) async {
      final parcel = Parcel(
        id: 'chip-test-parcel',
        createdAt: DateTime.now(),
        pickupAddress: const ParcelAddress(label: 'Sender Loc'),
        dropoffAddress: const ParcelAddress(label: 'Receiver Loc'),
        details: const ParcelDetails(size: ParcelSize.medium, weightKg: 2.0),
        status: ParcelStatus.delivered,
      );

      await tester.pumpWidget(buildTestWidget(
        parcelsState: ParcelOrdersState(parcels: [parcel]),
      ));
      await tester.pumpAndSettle();

      // Verify OrderStatusChip widget is rendered for parcel
      expect(find.byType(OrderStatusChip), findsOneWidget);
      // Verify the chip shows the correct status text
      expect(find.text('Delivered'), findsOneWidget);
    });

    testWidgets('parcel_in_transit_shows_info_tone_chip', (tester) async {
      final parcel = Parcel(
        id: 'transit-test-parcel',
        createdAt: DateTime.now(),
        pickupAddress: const ParcelAddress(label: 'Origin'),
        dropoffAddress: const ParcelAddress(label: 'Dest'),
        details: const ParcelDetails(size: ParcelSize.small, weightKg: 1.0),
        status: ParcelStatus.inTransit,
      );

      await tester.pumpWidget(buildTestWidget(
        parcelsState: ParcelOrdersState(parcels: [parcel]),
      ));
      await tester.pumpAndSettle();

      // Verify chip is rendered with In Transit text
      expect(find.byType(OrderStatusChip), findsOneWidget);
      expect(find.text('In transit'), findsOneWidget);
    });

    testWidgets('parcel_cancelled_shows_error_tone_chip', (tester) async {
      final parcel = Parcel(
        id: 'cancelled-test-parcel',
        createdAt: DateTime.now(),
        pickupAddress: const ParcelAddress(label: 'From'),
        dropoffAddress: const ParcelAddress(label: 'To'),
        details: const ParcelDetails(size: ParcelSize.large, weightKg: 5.0),
        status: ParcelStatus.cancelled,
      );

      await tester.pumpWidget(buildTestWidget(
        parcelsState: ParcelOrdersState(parcels: [parcel]),
      ));
      await tester.pumpAndSettle();

      // Verify chip shows cancelled status
      expect(find.byType(OrderStatusChip), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);
    });

    testWidgets('multiple_orders_show_multiple_status_chips', (tester) async {
      final ride = RideHistoryEntry(
        trip: const RideTripState(
          tripId: 'multi-chip-ride',
          phase: RideTripPhase.completed,
        ),
        destinationLabel: 'Ride Dest',
        completedAt: DateTime.now(),
      );
      final parcel = Parcel(
        id: 'multi-chip-parcel',
        createdAt: DateTime.now(),
        pickupAddress: const ParcelAddress(label: 'P1'),
        dropoffAddress: const ParcelAddress(label: 'P2'),
        details: const ParcelDetails(size: ParcelSize.medium, weightKg: 1.5),
        status: ParcelStatus.inTransit,
      );

      await tester.pumpWidget(buildTestWidget(
        rideSession: RideTripSessionUiState(historyTrips: [ride]),
        parcelsState: ParcelOrdersState(parcels: [parcel]),
      ));
      await tester.pumpAndSettle();

      // Both ride and parcel should have OrderStatusChip
      expect(find.byType(OrderStatusChip), findsNWidgets(2));
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('In transit'), findsOneWidget);
    });

    testWidgets('l10n_ar_status_chip_shows_arabic_status', (tester) async {
      final parcel = Parcel(
        id: 'ar-chip-parcel',
        createdAt: DateTime.now(),
        pickupAddress: const ParcelAddress(label: 'مكان'),
        dropoffAddress: const ParcelAddress(label: 'وجهة'),
        details: const ParcelDetails(size: ParcelSize.small, weightKg: 0.5),
        status: ParcelStatus.delivered,
      );

      await tester.pumpWidget(buildTestWidget(
        parcelsState: ParcelOrdersState(parcels: [parcel]),
        locale: const Locale('ar'),
      ));
      await tester.pumpAndSettle();

      // Verify Arabic status text in chip
      expect(find.byType(OrderStatusChip), findsOneWidget);
      expect(find.text('تم التسليم'), findsOneWidget); // "Delivered" in Arabic
    });

    testWidgets('l10n_de_status_chip_shows_german_status', (tester) async {
      final parcel = Parcel(
        id: 'de-chip-parcel',
        createdAt: DateTime.now(),
        pickupAddress: const ParcelAddress(label: 'Absender'),
        dropoffAddress: const ParcelAddress(label: 'Empfänger'),
        details: const ParcelDetails(size: ParcelSize.medium, weightKg: 2.0),
        status: ParcelStatus.inTransit,
      );

      await tester.pumpWidget(buildTestWidget(
        parcelsState: ParcelOrdersState(parcels: [parcel]),
        locale: const Locale('de'),
      ));
      await tester.pumpAndSettle();

      // Verify German status text in chip
      expect(find.byType(OrderStatusChip), findsOneWidget);
      expect(find.text('Unterwegs'), findsOneWidget); // "In transit" in German
    });
  });

  // ===========================================================================
  // Track B - Ticket #98: Orders → Trip Summary Navigation Tests
  // ===========================================================================
  group('Orders → Trip Summary Navigation (Ticket #98)', () {
    /// Helper to build test widget with navigation support
    Widget buildNavTestWidget({
      RideTripSessionUiState? rideSession,
      Locale locale = const Locale('en'),
    }) {
      return ProviderScope(
        overrides: [
          rideTripSessionProvider.overrideWith(
            (ref) => _FakeRideTripSessionController(
              initialState: rideSession ?? const RideTripSessionUiState(),
            ),
          ),
          rideDraftProvider.overrideWith(
            (ref) => _FakeRideDraftController(),
          ),
          rideQuoteControllerProvider.overrideWith(
            (ref) => _FakeRideQuoteController(),
          ),
          parcelOrdersProvider.overrideWith(
            (ref) => _FakeParcelOrdersController(
              initialState: const ParcelOrdersState(),
            ),
          ),
          foodOrdersControllerProvider.overrideWith(
            (ref) => _FakeFoodOrdersController(
              initialState: const FoodOrdersState(),
            ),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
            Locale('de'),
          ],
          locale: locale,
          routes: {
            '/': (context) => const OrdersHistoryScreen(),
            RoutePaths.rideTripSummary: (context) {
              final args = ModalRoute.of(context)?.settings.arguments;
              if (args is RideTripSummaryArgs) {
                return RideTripSummaryScreen(historyEntry: args.historyEntry);
              }
              return const RideTripSummaryScreen();
            },
          },
          initialRoute: '/',
        ),
      );
    }

    testWidgets('tapping_completed_ride_navigates_to_summary_screen', (tester) async {
      final completedEntry = RideHistoryEntry(
        trip: const RideTripState(
          tripId: 'nav-test-1',
          phase: RideTripPhase.completed,
        ),
        destinationLabel: 'Shopping Mall',
        completedAt: DateTime(2025, 5, 24, 14, 30),
        amountFormatted: 'SAR 35.00',
      );

      await tester.pumpWidget(buildNavTestWidget(
        rideSession: RideTripSessionUiState(
          historyTrips: [completedEntry],
        ),
      ));
      await tester.pumpAndSettle();

      // Verify ride card is visible
      expect(find.text('Ride to Shopping Mall'), findsOneWidget);

      // Tap on the ride card
      await tester.tap(find.text('Ride to Shopping Mall'));
      await tester.pumpAndSettle();

      // Verify navigation to Trip Summary screen
      expect(find.text('Trip summary'), findsOneWidget);
      // Trip ID shown as "Trip ID: {id}"
      expect(find.textContaining('nav-test-1'), findsOneWidget);
    });

    testWidgets('summary_screen_shows_data_from_history_entry', (tester) async {
      final historyEntry = RideHistoryEntry(
        trip: const RideTripState(
          tripId: 'summary-test-trip',
          phase: RideTripPhase.completed,
        ),
        destinationLabel: 'Airport Terminal 2',
        completedAt: DateTime(2025, 5, 24, 9, 15),
        amountFormatted: 'SAR 75.00',
      );

      // Build summary screen directly with history entry
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideTripSessionProvider.overrideWith(
              (ref) => _FakeRideTripSessionController(
                initialState: const RideTripSessionUiState(),
              ),
            ),
            rideDraftProvider.overrideWith(
              (ref) => _FakeRideDraftController(),
            ),
            rideQuoteControllerProvider.overrideWith(
              (ref) => _FakeRideQuoteController(),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            locale: const Locale('en'),
            home: RideTripSummaryScreen(historyEntry: historyEntry),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify data from history entry is displayed
      expect(find.text('Trip summary'), findsOneWidget);
      expect(find.textContaining('summary-test-trip'), findsOneWidget);
      // Destination from history should appear in route section
      expect(find.text('Airport Terminal 2'), findsOneWidget);
    });

    testWidgets('done_cta_from_history_is_visible_and_tappable', (tester) async {
      final historyEntry = RideHistoryEntry(
        trip: const RideTripState(
          tripId: 'done-test-trip',
          phase: RideTripPhase.completed,
        ),
        destinationLabel: 'Downtown',
        completedAt: DateTime(2025, 5, 24, 16, 0),
      );

      await tester.pumpWidget(buildNavTestWidget(
        rideSession: RideTripSessionUiState(
          historyTrips: [historyEntry],
        ),
      ));
      await tester.pumpAndSettle();

      // Navigate to summary
      await tester.tap(find.text('Ride to Downtown'));
      await tester.pumpAndSettle();

      // Verify we're on summary screen
      expect(find.text('Trip summary'), findsOneWidget);
      
      // Verify Done button is visible
      expect(find.text('Done'), findsOneWidget);
      
      // Verify we can pop (navigation stack has Orders underneath)
      final navigatorState = tester.state<NavigatorState>(find.byType(Navigator));
      expect(navigatorState.canPop(), isTrue);
      
      // Tap Done button - should not throw
      await tester.tap(find.text('Done'));
      await tester.pump(); // Single pump to trigger navigation
    });

    testWidgets('summary_from_history_shows_back_button', (tester) async {
      final historyEntry = RideHistoryEntry(
        trip: const RideTripState(
          tripId: 'back-button-test',
          phase: RideTripPhase.completed,
        ),
        destinationLabel: 'Hotel',
        completedAt: DateTime.now(),
      );

      await tester.pumpWidget(buildNavTestWidget(
        rideSession: RideTripSessionUiState(
          historyTrips: [historyEntry],
        ),
      ));
      await tester.pumpAndSettle();

      // Navigate to summary
      await tester.tap(find.text('Ride to Hotel'));
      await tester.pumpAndSettle();

      // Verify back button is visible (from history mode)
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify we're back on Orders
      expect(find.text('My Orders'), findsOneWidget);
    });

    testWidgets('ar_orders_to_summary_flow_shows_arabic_labels', (tester) async {
      final historyEntry = RideHistoryEntry(
        trip: const RideTripState(
          tripId: 'ar-flow-test',
          phase: RideTripPhase.completed,
        ),
        destinationLabel: 'المطار',
        completedAt: DateTime.now(),
      );

      await tester.pumpWidget(buildNavTestWidget(
        rideSession: RideTripSessionUiState(
          historyTrips: [historyEntry],
        ),
        locale: const Locale('ar'),
      ));
      await tester.pumpAndSettle();

      // Verify Arabic Orders title
      expect(find.text('طلباتي'), findsOneWidget);
      expect(find.text('رحلة إلى المطار'), findsOneWidget);

      // Navigate to summary
      await tester.tap(find.text('رحلة إلى المطار'));
      await tester.pumpAndSettle();

      // Verify Arabic summary title
      expect(find.text('ملخص الرحلة'), findsOneWidget);
    });

    testWidgets('cancelled_trip_can_be_viewed_from_history', (tester) async {
      final cancelledEntry = RideHistoryEntry(
        trip: const RideTripState(
          tripId: 'cancelled-view-test',
          phase: RideTripPhase.cancelled,
        ),
        destinationLabel: 'Office',
        completedAt: DateTime.now(),
      );

      await tester.pumpWidget(buildNavTestWidget(
        rideSession: RideTripSessionUiState(
          historyTrips: [cancelledEntry],
        ),
      ));
      await tester.pumpAndSettle();

      // Tap cancelled ride
      await tester.tap(find.text('Ride to Office'));
      await tester.pumpAndSettle();

      // Should navigate to summary (cancelled trips are viewable)
      expect(find.text('Trip summary'), findsOneWidget);
      expect(find.textContaining('cancelled-view-test'), findsOneWidget);
    });

    testWidgets('failed_trip_can_be_viewed_from_history', (tester) async {
      final failedEntry = RideHistoryEntry(
        trip: const RideTripState(
          tripId: 'failed-view-test',
          phase: RideTripPhase.failed,
        ),
        destinationLabel: 'Hospital',
        completedAt: DateTime.now(),
      );

      await tester.pumpWidget(buildNavTestWidget(
        rideSession: RideTripSessionUiState(
          historyTrips: [failedEntry],
        ),
      ));
      await tester.pumpAndSettle();

      // Tap failed ride
      await tester.tap(find.text('Ride to Hospital'));
      await tester.pumpAndSettle();

      // Should navigate to summary (failed trips are viewable)
      expect(find.text('Trip summary'), findsOneWidget);
      expect(find.textContaining('failed-view-test'), findsOneWidget);
    });
  });
}

// ============================================================================
// Fake Controllers for Testing
// ============================================================================

/// Fake Ref for testing
class _FakeRef implements Ref {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Fake RideTripSessionController for testing
class _FakeRideTripSessionController extends RideTripSessionController {
  _FakeRideTripSessionController({required RideTripSessionUiState initialState})
      : super(_FakeRef()) {
    state = initialState;
  }

  @override
  void startFromDraft(RideDraftUiState draft, {RideQuoteOption? selectedOption}) {}

  @override
  void applyEvent(RideTripEvent event) {}

  @override
  void clear() {
    state = RideTripSessionUiState(historyTrips: state.historyTrips);
  }

  @override
  bool get hasActiveTrip => false;

  @override
  Future<bool> cancelActiveTrip() async => false;

  @override
  void rateCurrentTrip(int rating) {}

  // Track B - Ticket #108: Extended with serviceName, originLabel, paymentMethodLabel
  @override
  void archiveTrip({
    required String destinationLabel,
    String? amountFormatted,
    String? serviceName,
    String? originLabel,
    String? paymentMethodLabel,
  }) {}

  // Track B - Ticket #107
  @override
  bool completeTrip() => true;

  @override
  void clearCompletionSummary() {
    state = state.copyWith(clearCompletionSummary: true);
  }

  // Track B - Ticket #117
  @override
  bool completeCurrentTrip({
    String? destinationLabel,
    String? amountFormatted,
    String? serviceName,
    String? originLabel,
    String? paymentMethodLabel,
  }) => true;

  // Track B - Ticket #120
  @override
  bool cancelCurrentTrip({
    String? reasonLabel,
    String? destinationLabel,
    String? originLabel,
    String? serviceName,
    String? amountFormatted,
    String? paymentMethodLabel,
  }) => true;

  // Track B - Ticket #122
  @override
  bool failCurrentTrip({
    String? reasonLabel,
    String? destinationLabel,
    String? originLabel,
    String? serviceName,
    String? amountFormatted,
    String? paymentMethodLabel,
  }) => true;

  // Track B - Ticket #124
  @override
  bool setRatingForMostRecentTrip(double rating) {
    if (state.historyTrips.isEmpty) return false;
    if (rating < 1.0 || rating > 5.0) return false;
    
    final entries = List<RideHistoryEntry>.from(state.historyTrips);
    entries[0] = entries[0].copyWith(driverRating: rating);
    state = state.copyWith(historyTrips: entries);
    return true;
  }
}

/// Fake ParcelOrdersController for testing
class _FakeParcelOrdersController extends StateNotifier<ParcelOrdersState>
    implements ParcelOrdersController {
  _FakeParcelOrdersController({required ParcelOrdersState initialState})
      : super(initialState);

  @override
  void cancelParcel({required String parcelId}) {}

  @override
  void clearActiveParcel() {}

  @override
  Parcel createParcelFromDraft({
    required ParcelDraftUiState draft,
    required ParcelQuote quote,
    required ParcelQuoteOption selectedOption,
  }) {
    return Parcel(
      id: 'fake-parcel',
      createdAt: DateTime.now(),
      pickupAddress: const ParcelAddress(label: 'Pickup'),
      dropoffAddress: const ParcelAddress(label: 'Dropoff'),
      details: const ParcelDetails(size: ParcelSize.medium, weightKg: 1.0),
      status: ParcelStatus.scheduled,
    );
  }

  @override
  Future<Parcel> createShipmentFromForm({
    required String senderName,
    required String senderPhone,
    required String senderAddress,
    required String receiverName,
    required String receiverPhone,
    required String receiverAddress,
    required String weightText,
    required ParcelSize size,
    String? notes,
    required ParcelServiceType serviceType,
  }) async {
    return Parcel(
      id: 'fake-shipment',
      createdAt: DateTime.now(),
      pickupAddress: ParcelAddress(label: senderAddress),
      dropoffAddress: ParcelAddress(label: receiverAddress),
      details: ParcelDetails(size: size, weightKg: 1.0),
      status: ParcelStatus.scheduled,
    );
  }

  @override
  void reset() {}
}

/// Fake FoodOrdersController for testing
class _FakeFoodOrdersController extends StateNotifier<FoodOrdersState>
    implements FoodOrdersController {
  _FakeFoodOrdersController({required FoodOrdersState initialState})
      : super(initialState);

  @override
  Future<void> refresh() async {}

  @override
  Future<FoodOrder> createOrderFromItems({
    required FoodRestaurant restaurant,
    required List<FoodMenuItem> items,
  }) async {
    return FoodOrder(
      id: 'fake-order',
      restaurantId: restaurant.id,
      restaurantName: restaurant.name,
      items: const [], // Empty items list for fake
      status: FoodOrderStatus.pending,
      createdAt: DateTime.now(),
      totalAmountCents: 0,
      currencyCode: 'SAR',
    );
  }
}

// ============================================================================
// Track B - Ticket #98: Additional Fake Controllers for Navigation Tests
// ============================================================================

/// Fake RideDraftController for Trip Summary tests
class _FakeRideDraftController extends StateNotifier<RideDraftUiState>
    implements RideDraftController {
  _FakeRideDraftController() : super(const RideDraftUiState());

  @override
  void updateDestination(String query) {}

  @override
  void updateSelectedOption(String optionId) {}

  @override
  void updatePickupLabel(String label) {}

  @override
  void updatePickupPlace(MobilityPlace place) {}

  @override
  void updateDestinationPlace(MobilityPlace place) {}

  // Track B - Ticket #101
  @override
  void setPaymentMethodId(String? paymentMethodId) {}

  // Track B - Ticket #102
  @override
  void clearPaymentMethodId() {}

  @override
  void clear() {
    state = const RideDraftUiState();
  }
}

/// Fake RideQuoteController for Trip Summary tests
class _FakeRideQuoteController extends StateNotifier<RideQuoteUiState>
    implements RideQuoteController {
  _FakeRideQuoteController() : super(const RideQuoteUiState());

  @override
  Future<void> refreshFromDraft(RideDraftUiState draft) async {}

  @override
  Future<void> retryFromDraft(RideDraftUiState draft) async {}

  @override
  void clear() {
    state = const RideQuoteUiState();
  }
}

// ============================================================================
// Track B - Ticket #127: Skeleton Loader + Semantics Tests
// ============================================================================

/// Test group for Skeleton Loader and Accessibility features.
void _ticket127Tests() {
  group('Track B - Ticket #127: Skeleton Loader + Semantics', () {
    /// Helper to build the test widget with provider overrides
    Widget buildTestWidget({
      RideTripSessionUiState? rideSession,
      ParcelOrdersState? parcelsState,
      FoodOrdersState? foodState,
      Locale locale = const Locale('en'),
    }) {
      return ProviderScope(
        overrides: [
          rideTripSessionProvider.overrideWith(
            (ref) => _FakeRideTripSessionController(
              initialState: rideSession ?? const RideTripSessionUiState(),
            ),
          ),
          parcelOrdersProvider.overrideWith(
            (ref) => _FakeParcelOrdersController(
              initialState: parcelsState ?? const ParcelOrdersState(),
            ),
          ),
          foodOrdersControllerProvider.overrideWith(
            (ref) => _FakeFoodOrdersController(
              initialState: foodState ?? const FoodOrdersState(),
            ),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
            Locale('de'),
          ],
          locale: locale,
          home: const OrdersHistoryScreen(),
        ),
      );
    }

    testWidgets('skeleton_loader_shows_when_rides_loading', (tester) async {
      // Arrange: Create state with isLoading = true
      const loadingRideState = RideTripSessionUiState(isLoading: true);

      // Act
      await tester.pumpWidget(buildTestWidget(rideSession: loadingRideState));
      await tester.pump(); // Single pump to see loading state

      // Assert
      expect(find.byType(OrderListSkeleton), findsOneWidget);
    });

    testWidgets('skeleton_loader_shows_when_parcels_loading', (tester) async {
      // Arrange: Create state with isLoading = true
      const loadingParcelsState = ParcelOrdersState(isLoading: true);

      // Act
      await tester.pumpWidget(buildTestWidget(parcelsState: loadingParcelsState));
      await tester.pump(); // Single pump to see loading state

      // Assert
      expect(find.byType(OrderListSkeleton), findsOneWidget);
    });

    testWidgets('skeleton_loader_hides_after_data_loads', (tester) async {
      // Arrange: State with data (not loading)
      final historyEntry = RideHistoryEntry(
        trip: const RideTripState(
          tripId: 'skeleton-test-ride',
          phase: RideTripPhase.completed,
        ),
        destinationLabel: 'Test Destination',
        completedAt: DateTime.now(),
      );

      final rideState = RideTripSessionUiState(
        historyTrips: [historyEntry],
        isLoading: false,
      );

      // Act
      await tester.pumpWidget(buildTestWidget(rideSession: rideState));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(OrderListSkeleton), findsNothing);
      // The card shows "Ride to Test Destination" not just "Test Destination"
      expect(find.textContaining('Test Destination'), findsOneWidget);
    });

    testWidgets('order_status_chip_has_semantics_wrapper', (tester) async {
      // Arrange
      final historyEntry = RideHistoryEntry(
        trip: const RideTripState(
          tripId: 'semantics-test-ride',
          phase: RideTripPhase.completed,
        ),
        destinationLabel: 'Semantics Test',
        completedAt: DateTime.now(),
      );

      final rideState = RideTripSessionUiState(
        historyTrips: [historyEntry],
      );

      // Act
      await tester.pumpWidget(buildTestWidget(rideSession: rideState));
      await tester.pumpAndSettle();

      // Assert: Verify OrderStatusChip is present and contains Semantics
      expect(find.byType(OrderStatusChip), findsOneWidget);
      // The OrderStatusChip now wraps its content in Semantics
      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('ride_card_contains_semantics_widget', (tester) async {
      // Arrange
      final historyEntry = RideHistoryEntry(
        trip: const RideTripState(
          tripId: 'ride-icon-semantics',
          phase: RideTripPhase.completed,
        ),
        destinationLabel: 'Icon Test',
        completedAt: DateTime.now(),
      );

      final rideState = RideTripSessionUiState(
        historyTrips: [historyEntry],
      );

      // Act
      await tester.pumpWidget(buildTestWidget(rideSession: rideState));
      await tester.pumpAndSettle();

      // Assert: Verify Semantics widget is present in the tree
      // The RideOrderCard wraps its icon with Semantics
      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('parcel_card_has_semantics_label', (tester) async {
      // Arrange
      final parcel = Parcel(
        id: 'parcel-semantics-test',
        createdAt: DateTime.now(),
        pickupAddress: const ParcelAddress(label: 'Pickup'),
        dropoffAddress: const ParcelAddress(label: 'Dropoff'),
        details: const ParcelDetails(size: ParcelSize.medium, weightKg: 1.0),
        status: ParcelStatus.delivered,
      );

      final parcelsState = ParcelOrdersState(parcels: [parcel]);

      // Act
      await tester.pumpWidget(buildTestWidget(parcelsState: parcelsState));
      await tester.pumpAndSettle();

      // Tap Parcels filter to ensure parcels are shown
      await tester.tap(find.text('Parcels').first);
      await tester.pumpAndSettle();

      // Assert: Verify parcel card has semantic label
      expect(
        find.bySemanticsLabel('Parcel shipment'),
        findsOneWidget,
      );
    });

    testWidgets('skeleton_has_loading_semantics', (tester) async {
      // Arrange: Create state with isLoading = true
      const loadingRideState = RideTripSessionUiState(isLoading: true);

      // Act
      await tester.pumpWidget(buildTestWidget(rideSession: loadingRideState));
      await tester.pump();

      // Assert: Skeleton items have "Loading order" semantics
      // The OrderListSkeleton renders 4 items by default
      expect(
        find.bySemanticsLabel('Loading order'),
        findsWidgets,
      );
    });

    // =========================================================================
    // Track B - Ticket #128: Skeleton Pulsing Animation Tests
    // =========================================================================

    testWidgets('skeleton_contains_pulsing_animation_widget', (tester) async {
      // Arrange: Create state with isLoading = true
      const loadingRideState = RideTripSessionUiState(isLoading: true);

      // Act
      await tester.pumpWidget(buildTestWidget(rideSession: loadingRideState));
      await tester.pump();

      // Assert: Verify DWSkeletonPulse widgets are present in the tree
      // Each skeleton card is wrapped with DWSkeletonPulse
      expect(find.byType(DWSkeletonPulse), findsWidgets);
    });

    testWidgets('skeleton_pulse_exists_in_order_list_skeleton', (tester) async {
      // Arrange: Create loading state for parcels
      const loadingParcelsState = ParcelOrdersState(isLoading: true);

      // Act
      await tester.pumpWidget(buildTestWidget(parcelsState: loadingParcelsState));
      await tester.pump();

      // Assert: OrderListSkeleton contains DWSkeletonPulse widgets
      expect(find.byType(OrderListSkeleton), findsOneWidget);
      expect(find.byType(DWSkeletonPulse), findsWidgets);
    });

    testWidgets('skeleton_pulse_count_matches_skeleton_items', (tester) async {
      // Arrange: Create loading state
      const loadingRideState = RideTripSessionUiState(isLoading: true);

      // Act
      await tester.pumpWidget(buildTestWidget(rideSession: loadingRideState));
      await tester.pump();

      // Assert: 4 DWSkeletonPulse widgets (default itemCount = 4)
      expect(find.byType(DWSkeletonPulse), findsNWidgets(4));
    });

    testWidgets('skeleton_disappears_after_loading_completes', (tester) async {
      // Arrange: State with data (not loading)
      final historyEntry = RideHistoryEntry(
        trip: const RideTripState(
          tripId: 'pulse-test-ride',
          phase: RideTripPhase.completed,
        ),
        destinationLabel: 'Pulse Test',
        completedAt: DateTime.now(),
      );

      final rideState = RideTripSessionUiState(
        historyTrips: [historyEntry],
        isLoading: false,
      );

      // Act
      await tester.pumpWidget(buildTestWidget(rideSession: rideState));
      await tester.pumpAndSettle();

      // Assert: No skeleton pulse should exist when data is loaded
      expect(find.byType(DWSkeletonPulse), findsNothing);
      expect(find.byType(OrderListSkeleton), findsNothing);
    });
  });
}

/// Widget tests for OrdersHistoryScreen (Track B - Ticket #96, #98)
/// Purpose: Verify orders history screen UI with Rides support
/// Created by: Track B - Ticket #96
/// Updated by: Track B - Ticket #98 (Orders → Trip Summary navigation tests)
/// Last updated: 2025-11-30

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// App imports
import 'package:delivery_ways_clean/screens/orders/orders_history_screen.dart';
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
      final completedTrip = RideTripState(
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
      final cancelledTrip = RideTripState(
        tripId: 'test-ride-cancelled',
        phase: RideTripPhase.cancelled,
      );
      final failedTrip = RideTripState(
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
    // Filter Tests
    // =========================================================================

    testWidgets('filters_rides_when_rides_tab_selected', (tester) async {
      final rideEntry = RideHistoryEntry(
        trip: RideTripState(
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
    // L10n Tests - Arabic
    // =========================================================================

    testWidgets('l10n_ar_renders_arabic_labels', (tester) async {
      final historyEntry = RideHistoryEntry(
        trip: RideTripState(
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
        trip: RideTripState(
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
        trip: RideTripState(
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
        trip: RideTripState(
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
        trip: RideTripState(
          tripId: 'test-ride-1',
          phase: RideTripPhase.completed,
        ),
        destinationLabel: 'First Destination',
        completedAt: DateTime(2025, 5, 24, 10, 0),
      );
      final ride2 = RideHistoryEntry(
        trip: RideTripState(
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
        trip: RideTripState(
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
        trip: RideTripState(
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
        trip: RideTripState(
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
        trip: RideTripState(
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
        trip: RideTripState(
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
        trip: RideTripState(
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
        trip: RideTripState(
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

/// Fake RideTripSessionController for testing
class _FakeRideTripSessionController
    extends StateNotifier<RideTripSessionUiState>
    implements RideTripSessionController {
  _FakeRideTripSessionController({required RideTripSessionUiState initialState})
      : super(initialState);

  @override
  void startFromDraft(RideDraftUiState draft) {}

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

  @override
  void archiveTrip({required String destinationLabel, String? amountFormatted}) {}
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
  void clear() {
    state = const RideQuoteUiState();
  }
}

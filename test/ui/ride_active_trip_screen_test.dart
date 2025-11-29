/// Widget tests for RideActiveTripScreen (Track B - Ticket #22)
/// Purpose: Verify active trip screen UI and FSM cancel logic
/// Created by: Track B - Ticket #22
/// Last updated: 2025-11-28

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// App imports
import 'package:delivery_ways_clean/screens/mobility/ride_active_trip_screen.dart';
import 'package:delivery_ways_clean/state/mobility/ride_trip_session.dart';
import 'package:delivery_ways_clean/state/mobility/ride_draft_state.dart';
import 'package:delivery_ways_clean/state/mobility/ride_quote_controller.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';

// Shims
import 'package:maps_shims/maps_shims.dart';
import 'package:mobility_shims/mobility_shims.dart';

void main() {
  group('RideActiveTripScreen', () {
    /// Helper to build the test widget with provider overrides
    Widget buildTestWidget({
      RideTripSessionUiState? tripSession,
      RideDraftUiState? rideDraft,
      RideQuoteUiState? quoteState,
      List<Override> additionalOverrides = const [],
    }) {
      return ProviderScope(
        overrides: [
          rideTripSessionProvider.overrideWith(
            (ref) => _FakeRideTripSessionController(
              initialState: tripSession ?? const RideTripSessionUiState(),
            ),
          ),
          rideDraftProvider.overrideWith(
            (ref) => _FakeRideDraftController(
              initialState: rideDraft ?? const RideDraftUiState(),
            ),
          ),
          rideQuoteControllerProvider.overrideWith(
            (ref) => _FakeRideQuoteController(
              initialState: quoteState ?? const RideQuoteUiState(),
            ),
          ),
          ...additionalOverrides,
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: RideActiveTripScreen(),
        ),
      );
    }

    testWidgets('shows no active trip fallback when activeTrip is null',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        tripSession: const RideTripSessionUiState(activeTrip: null),
      ));
      await tester.pumpAndSettle();

      // Verify fallback UI
      expect(find.text('No active trip'), findsOneWidget);
      expect(find.text('Go back'), findsOneWidget);
      expect(find.byIcon(Icons.directions_car_outlined), findsOneWidget);
    });

    testWidgets('shows trip screen when activeTrip exists', (tester) async {
      final activeTrip = RideTripState(
        tripId: 'test-trip-123',
        phase: RideTripPhase.findingDriver,
      );

      await tester.pumpWidget(buildTestWidget(
        tripSession: RideTripSessionUiState(activeTrip: activeTrip),
        rideDraft: const RideDraftUiState(destinationQuery: 'Mall of Arabia'),
      ));
      await tester.pumpAndSettle();

      // Verify trip screen UI
      expect(find.text('Your trip'), findsOneWidget);
      expect(find.text('Finding a driver…'), findsOneWidget);
      expect(find.textContaining('Mall of Arabia'), findsOneWidget);
    });

    testWidgets('shows driver info card with mock driver details',
        (tester) async {
      final activeTrip = RideTripState(
        tripId: 'test-trip-456',
        phase: RideTripPhase.driverAccepted,
      );

      await tester.pumpWidget(buildTestWidget(
        tripSession: RideTripSessionUiState(activeTrip: activeTrip),
      ));
      await tester.pumpAndSettle();

      // Verify driver info (mock data)
      expect(find.text('Ahmad M.'), findsOneWidget);
      expect(find.text('4.9'), findsOneWidget);
      expect(find.text('Toyota Camry'), findsOneWidget);
      expect(find.text('ABC 1234'), findsOneWidget);
    });

    testWidgets('shows Cancel ride button', (tester) async {
      final activeTrip = RideTripState(
        tripId: 'test-trip-789',
        phase: RideTripPhase.findingDriver,
      );

      await tester.pumpWidget(buildTestWidget(
        tripSession: RideTripSessionUiState(activeTrip: activeTrip),
      ));
      await tester.pumpAndSettle();

      // Verify cancel button exists
      expect(find.text('Cancel ride'), findsOneWidget);
    });

    testWidgets('tapping Cancel ride calls cancelActiveTrip on controller',
        (tester) async {
      final fakeController = _FakeRideTripSessionController(
        initialState: RideTripSessionUiState(
          activeTrip: RideTripState(
            tripId: 'test-cancel-trip',
            phase: RideTripPhase.findingDriver,
          ),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideTripSessionProvider.overrideWith((ref) => fakeController),
            rideDraftProvider.overrideWith(
              (ref) =>
                  _FakeRideDraftController(initialState: const RideDraftUiState()),
            ),
            rideQuoteControllerProvider.overrideWith(
              (ref) =>
                  _FakeRideQuoteController(initialState: const RideQuoteUiState()),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const RideActiveTripScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap cancel button
      await tester.tap(find.text('Cancel ride'));
      await tester.pumpAndSettle();

      // Verify cancelActiveTrip was called
      expect(fakeController.cancelCalledCount, equals(1));
    });

    testWidgets('displays correct phase icon for driverArrived phase',
        (tester) async {
      final activeTrip = RideTripState(
        tripId: 'test-arrived',
        phase: RideTripPhase.driverArrived,
      );

      await tester.pumpWidget(buildTestWidget(
        tripSession: RideTripSessionUiState(activeTrip: activeTrip),
      ));
      await tester.pumpAndSettle();

      // Verify headline for driverArrived
      expect(find.text('Driver has arrived'), findsOneWidget);
      expect(find.byIcon(Icons.local_taxi), findsOneWidget);
    });

    testWidgets('displays ETA when quote option is available', (tester) async {
      final activeTrip = RideTripState(
        tripId: 'test-eta',
        phase: RideTripPhase.driverAccepted,
      );

      // Build a proper RideQuoteRequest for the quote
      final request = RideQuoteRequest(
        pickup: LocationPoint(
          latitude: 24.7136,
          longitude: 46.6753,
          accuracyMeters: 10,
          timestamp: DateTime.now(),
        ),
        dropoff: LocationPoint(
          latitude: 24.7200,
          longitude: 46.6800,
          accuracyMeters: 10,
          timestamp: DateTime.now(),
        ),
        currencyCode: 'SAR',
      );

      final quote = RideQuote(
        quoteId: 'quote-1',
        request: request,
        options: [
          RideQuoteOption(
            id: 'opt-1',
            category: RideVehicleCategory.economy,
            displayName: 'Standard',
            etaMinutes: 5,
            priceMinorUnits: 2500,
            currencyCode: 'SAR',
            isRecommended: true,
          ),
        ],
      );

      await tester.pumpWidget(buildTestWidget(
        tripSession: RideTripSessionUiState(activeTrip: activeTrip),
        quoteState: RideQuoteUiState(quote: quote),
      ));
      await tester.pumpAndSettle();

      // Verify ETA headline
      expect(find.text('Driver is 5 min away'), findsOneWidget);
    });

    testWidgets('shows inProgress headline when trip is active',
        (tester) async {
      final activeTrip = RideTripState(
        tripId: 'test-progress',
        phase: RideTripPhase.inProgress,
      );

      await tester.pumpWidget(buildTestWidget(
        tripSession: RideTripSessionUiState(activeTrip: activeTrip),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Trip in progress'), findsOneWidget);
      expect(find.byIcon(Icons.directions_car), findsOneWidget);
    });

    // Track B - Ticket #28: Map integration tests
    testWidgets('MapWidget is present with markers when activeTrip exists',
        (tester) async {
      final activeTrip = RideTripState(
        tripId: 'test-map',
        phase: RideTripPhase.driverAccepted,
      );

      final pickupPlace = MobilityPlace(
        label: 'Home',
        location: LocationPoint(
          latitude: 24.7136,
          longitude: 46.6753,
          accuracyMeters: 10,
          timestamp: DateTime.now(),
        ),
      );

      final destinationPlace = MobilityPlace(
        label: 'Office',
        location: LocationPoint(
          latitude: 24.7500,
          longitude: 46.7000,
          accuracyMeters: 10,
          timestamp: DateTime.now(),
        ),
      );

      await tester.pumpWidget(buildTestWidget(
        tripSession: RideTripSessionUiState(activeTrip: activeTrip),
        rideDraft: RideDraftUiState(
          pickupLabel: 'Home',
          pickupPlace: pickupPlace,
          destinationQuery: 'Office',
          destinationPlace: destinationPlace,
        ),
      ));
      await tester.pumpAndSettle();

      // Verify MapWidget is present
      final mapWidget = tester.widget<MapWidget>(find.byType(MapWidget));
      expect(mapWidget, isNotNull);

      // Verify markers exist (pickup + destination + driver when phase allows)
      // Driver marker should be present for driverAccepted phase
      expect(mapWidget.markers.length, greaterThanOrEqualTo(2));
    });

    testWidgets('MapWidget has polylines when pickup and destination exist',
        (tester) async {
      final activeTrip = RideTripState(
        tripId: 'test-polyline',
        phase: RideTripPhase.findingDriver,
      );

      final pickupPlace = MobilityPlace(
        label: 'Start',
        location: LocationPoint(
          latitude: 24.7136,
          longitude: 46.6753,
          accuracyMeters: 10,
          timestamp: DateTime.now(),
        ),
      );

      final destinationPlace = MobilityPlace(
        label: 'End',
        location: LocationPoint(
          latitude: 24.7500,
          longitude: 46.7000,
          accuracyMeters: 10,
          timestamp: DateTime.now(),
        ),
      );

      await tester.pumpWidget(buildTestWidget(
        tripSession: RideTripSessionUiState(activeTrip: activeTrip),
        rideDraft: RideDraftUiState(
          pickupLabel: 'Start',
          pickupPlace: pickupPlace,
          destinationQuery: 'End',
          destinationPlace: destinationPlace,
        ),
      ));
      await tester.pumpAndSettle();

      // Verify MapWidget has polylines
      final mapWidget = tester.widget<MapWidget>(find.byType(MapWidget));
      expect(mapWidget.polylines, isNotEmpty);
    });

    // Track B - Ticket #29: UI Guard Rails
    testWidgets('no MapWidget when activeTrip is null (guard rail)',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        tripSession: const RideTripSessionUiState(activeTrip: null),
      ));
      await tester.pumpAndSettle();

      // MapWidget should NOT be present when there's no active trip
      expect(find.byType(MapWidget), findsNothing);

      // Fallback UI should be shown instead
      expect(find.text('No active trip'), findsOneWidget);
    });

    testWidgets('screen does not crash with empty draft and active trip',
        (tester) async {
      final activeTrip = RideTripState(
        tripId: 'test-guard',
        phase: RideTripPhase.findingDriver,
      );

      await tester.pumpWidget(buildTestWidget(
        tripSession: RideTripSessionUiState(activeTrip: activeTrip),
        rideDraft: const RideDraftUiState(), // Empty draft
      ));
      await tester.pumpAndSettle();

      // Should not crash, MapWidget should still be present
      expect(find.byType(MapWidget), findsOneWidget);
    });
  });
}

// ============================================================================
// Fake Controllers for Testing
// ============================================================================

/// Fake RideTripSessionController that tracks method calls
class _FakeRideTripSessionController
    extends StateNotifier<RideTripSessionUiState>
    implements RideTripSessionController {
  _FakeRideTripSessionController({required RideTripSessionUiState initialState})
      : super(initialState);

  int cancelCalledCount = 0;

  @override
  void startFromDraft(RideDraftUiState draft) {
    // No-op for tests
  }

  @override
  void applyEvent(RideTripEvent event) {
    // No-op for tests
  }

  @override
  void clear() {
    state = const RideTripSessionUiState();
  }

  @override
  bool get hasActiveTrip {
    final trip = state.activeTrip;
    if (trip == null) return false;
    return trip.phase != RideTripPhase.completed &&
        trip.phase != RideTripPhase.cancelled &&
        trip.phase != RideTripPhase.failed;
  }

  @override
  Future<bool> cancelActiveTrip() async {
    cancelCalledCount++;
    // Simulate successful cancellation
    state = state.copyWith(clearActiveTrip: true);
    return true;
  }

  @override
  void rateCurrentTrip(int rating) {
    // No-op for tests - Track B Ticket #23
  }
}

/// Fake RideDraftController for testing
class _FakeRideDraftController extends StateNotifier<RideDraftUiState>
    implements RideDraftController {
  _FakeRideDraftController({required RideDraftUiState initialState})
      : super(initialState);

  @override
  void updateDestination(String query) {}

  @override
  void updateSelectedOption(String optionId) {}

  @override
  void updatePickupLabel(String label) {}

  @override
  void clear() {}

  @override
  void updatePickupPlace(MobilityPlace place) {}

  @override
  void updateDestinationPlace(MobilityPlace place) {}
}

/// Fake RideQuoteController for testing
class _FakeRideQuoteController extends StateNotifier<RideQuoteUiState>
    implements RideQuoteController {
  _FakeRideQuoteController({required RideQuoteUiState initialState})
      : super(initialState);

  @override
  Future<void> refreshFromDraft(RideDraftUiState draft) async {}

  @override
  void clear() {}
}

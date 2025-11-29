/// Widget tests for RideTripSummaryScreen (Track B - Ticket #23)
/// Purpose: Verify trip summary screen UI, fare display, and driver rating
/// Created by: Track B - Ticket #23
/// Last updated: 2025-11-28

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// App imports
import 'package:delivery_ways_clean/screens/mobility/ride_trip_summary_screen.dart';
import 'package:delivery_ways_clean/state/mobility/ride_trip_session.dart';
import 'package:delivery_ways_clean/state/mobility/ride_draft_state.dart';
import 'package:delivery_ways_clean/state/mobility/ride_quote_controller.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';

// Shims
import 'package:mobility_shims/mobility_shims.dart';

void main() {
  group('RideTripSummaryScreen', () {
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
          home: RideTripSummaryScreen(),
        ),
      );
    }

    testWidgets(
        'builds screen with completed trip showing all sections',
        (tester) async {
      final completedTrip = RideTripState(
        tripId: 'test-trip-completed',
        phase: RideTripPhase.completed,
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
            id: 'economy',
            category: RideVehicleCategory.economy,
            displayName: 'Economy',
            etaMinutes: 5,
            priceMinorUnits: 2500,
            currencyCode: 'SAR',
            isRecommended: true,
          ),
        ],
      );

      await tester.pumpWidget(buildTestWidget(
        tripSession: RideTripSessionUiState(activeTrip: completedTrip),
        rideDraft: const RideDraftUiState(
          pickupLabel: 'King Fahd Road',
          destinationQuery: 'Mall of Arabia',
        ),
        quoteState: RideQuoteUiState(quote: quote),
      ));
      await tester.pumpAndSettle();

      // Verify screen title
      expect(find.text('Trip summary'), findsOneWidget);

      // Verify completed header
      expect(find.text('Trip completed'), findsOneWidget);
      expect(find.text('Thanks for riding with Delivery Ways'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);

      // Verify route section
      expect(find.text('Route'), findsOneWidget);
      expect(find.text('King Fahd Road'), findsOneWidget);
      expect(find.text('Mall of Arabia'), findsOneWidget);

      // Verify fare section
      expect(find.text('Fare'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('25.00 SAR'), findsOneWidget);

      // Verify driver section
      expect(find.text('Your driver'), findsOneWidget);
      expect(find.text('Ahmad M.'), findsOneWidget);

      // Verify rating section
      expect(find.text('Rate your driver'), findsOneWidget);
      expect(find.byIcon(Icons.star_border), findsNWidgets(5));

      // Verify Done CTA
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('Done button triggers navigation back to home', (tester) async {
      final completedTrip = RideTripState(
        tripId: 'test-trip-done',
        phase: RideTripPhase.completed,
      );

      // Build a proper quote
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
        quoteId: 'quote-done',
        request: request,
        options: [
          RideQuoteOption(
            id: 'economy',
            category: RideVehicleCategory.economy,
            displayName: 'Economy',
            etaMinutes: 5,
            priceMinorUnits: 1800,
            currencyCode: 'SAR',
            isRecommended: true,
          ),
        ],
      );

      final fakeController = _FakeRideTripSessionController(
        initialState: RideTripSessionUiState(activeTrip: completedTrip),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideTripSessionProvider.overrideWith((ref) => fakeController),
            rideDraftProvider.overrideWith(
              (ref) => _FakeRideDraftController(
                  initialState: const RideDraftUiState()),
            ),
            rideQuoteControllerProvider.overrideWith(
              (ref) => _FakeRideQuoteController(
                  initialState: RideQuoteUiState(quote: quote)),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const RideTripSummaryScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find Done button and scroll to it
      final doneButton = find.text('Done');
      expect(doneButton, findsOneWidget);
      
      // Scroll to make button visible
      await tester.ensureVisible(doneButton);
      await tester.pumpAndSettle();
      
      await tester.tap(doneButton);
      await tester.pumpAndSettle();

      // Verify clear was called
      expect(fakeController.clearCalledCount, equals(1));
    });

    testWidgets('tapping star rating calls rateCurrentTrip', (tester) async {
      final completedTrip = RideTripState(
        tripId: 'test-trip-rating',
        phase: RideTripPhase.completed,
      );

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
        quoteId: 'quote-rating',
        request: request,
        options: [
          RideQuoteOption(
            id: 'economy',
            category: RideVehicleCategory.economy,
            displayName: 'Economy',
            etaMinutes: 5,
            priceMinorUnits: 2000,
            currencyCode: 'SAR',
            isRecommended: true,
          ),
        ],
      );

      final fakeController = _FakeRideTripSessionController(
        initialState: RideTripSessionUiState(activeTrip: completedTrip),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideTripSessionProvider.overrideWith((ref) => fakeController),
            rideDraftProvider.overrideWith(
              (ref) => _FakeRideDraftController(
                  initialState: const RideDraftUiState()),
            ),
            rideQuoteControllerProvider.overrideWith(
              (ref) => _FakeRideQuoteController(
                  initialState: RideQuoteUiState(quote: quote)),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const RideTripSummaryScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap the 4th star (index 3)
      final stars = find.byIcon(Icons.star_border);
      expect(stars, findsNWidgets(5));

      // Scroll to make stars visible
      await tester.ensureVisible(stars.first);
      await tester.pumpAndSettle();

      // Tap the 4th star
      await tester.tap(stars.at(3));
      await tester.pumpAndSettle();

      // Verify rateCurrentTrip was called with rating 4
      expect(fakeController.rateCalledCount, equals(1));
      expect(fakeController.lastRating, equals(4));

      // Verify UI updated - 4 stars should be filled, 1 empty
      expect(find.byIcon(Icons.star), findsNWidgets(4));
      expect(find.byIcon(Icons.star_border), findsNWidgets(1));
    });

    testWidgets('shows placeholder when no trip is completed', (tester) async {
      // Trip not completed - should show nothing and trigger pop
      await tester.pumpWidget(buildTestWidget(
        tripSession: const RideTripSessionUiState(activeTrip: null),
      ));
      await tester.pump();

      // Screen should be empty (SizedBox.shrink)
      expect(find.byType(Scaffold), findsNothing);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('displays fare from selected quote option', (tester) async {
      final completedTrip = RideTripState(
        tripId: 'test-trip-fare',
        phase: RideTripPhase.completed,
      );

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
        quoteId: 'quote-fare',
        request: request,
        options: [
          RideQuoteOption(
            id: 'economy',
            category: RideVehicleCategory.economy,
            displayName: 'Economy',
            etaMinutes: 5,
            priceMinorUnits: 1500,
            currencyCode: 'SAR',
            isRecommended: false,
          ),
          RideQuoteOption(
            id: 'premium',
            category: RideVehicleCategory.premium,
            displayName: 'Premium',
            etaMinutes: 3,
            priceMinorUnits: 3500,
            currencyCode: 'SAR',
            isRecommended: true,
          ),
        ],
      );

      await tester.pumpWidget(buildTestWidget(
        tripSession: RideTripSessionUiState(activeTrip: completedTrip),
        rideDraft: const RideDraftUiState(
          selectedOptionId: 'premium',
        ),
        quoteState: RideQuoteUiState(quote: quote),
      ));
      await tester.pumpAndSettle();

      // Verify premium price is shown (since it was selected)
      expect(find.text('35.00 SAR'), findsOneWidget);
    });

    testWidgets('displays payment method as Cash', (tester) async {
      final completedTrip = RideTripState(
        tripId: 'test-trip-payment',
        phase: RideTripPhase.completed,
      );

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
        quoteId: 'quote-payment',
        request: request,
        options: [
          RideQuoteOption(
            id: 'economy',
            category: RideVehicleCategory.economy,
            displayName: 'Economy',
            etaMinutes: 5,
            priceMinorUnits: 2000,
            currencyCode: 'SAR',
            isRecommended: true,
          ),
        ],
      );

      await tester.pumpWidget(buildTestWidget(
        tripSession: RideTripSessionUiState(activeTrip: completedTrip),
        quoteState: RideQuoteUiState(quote: quote),
      ));
      await tester.pumpAndSettle();

      // Verify payment method shows Cash
      expect(find.text('Cash'), findsOneWidget);
      expect(find.byIcon(Icons.payments_outlined), findsOneWidget);
    });

    // Track B - Ticket #29: UI Guard Rails
    testWidgets('build does not fail with non-completed phase', (tester) async {
      // Trip in progress (not completed) - should show placeholder/pop
      final inProgressTrip = RideTripState(
        tripId: 'test-trip-inprogress',
        phase: RideTripPhase.inProgress,
      );

      await tester.pumpWidget(buildTestWidget(
        tripSession: RideTripSessionUiState(activeTrip: inProgressTrip),
      ));
      await tester.pump();

      // Screen should show empty placeholder (SizedBox.shrink)
      // because trip is not completed
      expect(find.byType(Scaffold), findsNothing);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('build does not crash with null quote', (tester) async {
      final completedTrip = RideTripState(
        tripId: 'test-trip-no-quote',
        phase: RideTripPhase.completed,
      );

      await tester.pumpWidget(buildTestWidget(
        tripSession: RideTripSessionUiState(activeTrip: completedTrip),
        quoteState: const RideQuoteUiState(quote: null), // No quote
      ));
      await tester.pumpAndSettle();

      // Should not crash, screen should build with fallback values
      expect(find.text('Trip summary'), findsOneWidget);
      expect(find.text('Trip completed'), findsOneWidget);
    });

    testWidgets('build handles cancelled trip gracefully', (tester) async {
      // Cancelled trip - should show placeholder/pop
      final cancelledTrip = RideTripState(
        tripId: 'test-trip-cancelled',
        phase: RideTripPhase.cancelled,
      );

      await tester.pumpWidget(buildTestWidget(
        tripSession: RideTripSessionUiState(activeTrip: cancelledTrip),
      ));
      await tester.pump();

      // Screen should show empty placeholder
      expect(find.byType(Scaffold), findsNothing);
      expect(find.byType(SizedBox), findsOneWidget);
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

  int clearCalledCount = 0;
  int rateCalledCount = 0;
  int? lastRating;

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
    clearCalledCount++;
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
    state = state.copyWith(clearActiveTrip: true);
    return true;
  }

  @override
  void rateCurrentTrip(int rating) {
    rateCalledCount++;
    lastRating = rating;
    state = state.copyWith(driverRating: rating);
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


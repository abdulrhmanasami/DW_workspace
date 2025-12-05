/// Widget tests for RideTripSummaryScreen (Track B - Ticket #92, #124)
/// Purpose: Verify trip receipt/summary screen UI with receipt breakdown and rating
/// Created by: Ticket #92
/// Updated by: Ticket #124 (Driver rating persistence tests)
/// Last updated: 2025-12-01

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// App imports
import 'package:delivery_ways_clean/screens/mobility/ride_trip_summary_screen.dart';
import 'package:delivery_ways_clean/state/mobility/ride_trip_session.dart';
import 'package:delivery_ways_clean/state/mobility/ride_draft_state.dart';
import 'package:delivery_ways_clean/state/mobility/ride_quote_controller.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';

// Shims
import 'package:mobility_shims/mobility_shims.dart';
import 'package:design_system_shims/design_system_shims.dart';

// Test support
import '../support/design_system_harness.dart';

void main() {
  setUpAll(() {
    ensureDesignSystemStubsForTests();
  });

  group('RideTripSummaryScreen Widget Tests (Ticket #92)', () {
    /// Helper to get AppLocalizations from the test widget
    AppLocalizations l10n0(WidgetTester tester) =>
        AppLocalizations.of(tester.element(find.byType(RideTripSummaryScreen)))!;

    /// Helper to create a completed trip state
    RideTripState createCompletedTrip() {
      return const RideTripState(
        tripId: 'test-trip-receipt-123',
        phase: RideTripPhase.completed,
      );
    }

    /// Helper to create a mock RideQuote with price breakdown
    RideQuote createMockQuoteWithBreakdown() {
      const pickup = LocationPoint(latitude: 24.7136, longitude: 46.6753);
      const dropoff = LocationPoint(latitude: 24.7236, longitude: 46.6853);

      return RideQuote(
        quoteId: 'quote_receipt_test',
        request: const RideQuoteRequest(
          pickup: pickup,
          dropoff: dropoff,
          currencyCode: 'SAR',
        ),
        options: const [
          RideQuoteOption(
            id: 'economy',
            category: RideVehicleCategory.economy,
            displayName: 'Economy',
            etaMinutes: 5,
            priceMinorUnits: 1800,
            currencyCode: 'SAR',
            isRecommended: true,
            priceBreakdown: RidePriceBreakdown(
              currencyCode: 'SAR',
              baseFareMinorUnits: 500,
              distanceComponentMinorUnits: 700,
              timeComponentMinorUnits: 300,
              feesMinorUnits: 300,
            ),
          ),
        ],
      );
    }

    /// Helper to build the test widget with provider overrides
    /// Track B - Ticket #118: Updated to include draftSnapshot for completeCurrentTrip
    Widget buildTestWidget({
      RideTripSessionUiState? tripSession,
      RideDraftUiState? rideDraft,
      RideQuoteUiState? quoteState,
      Locale locale = const Locale('en'),
    }) {
      final draft = rideDraft ??
          const RideDraftUiState(
            pickupLabel: 'Current location',
            destinationQuery: 'Mall of Arabia',
          );
      // Track B - Ticket #118: Include draftSnapshot so completeCurrentTrip has data
      final session = tripSession ??
          RideTripSessionUiState(
            activeTrip: createCompletedTrip(),
            draftSnapshot: draft,
          );
      final quote = quoteState ??
          RideQuoteUiState(
            isLoading: false,
            quote: createMockQuoteWithBreakdown(),
          );

      return ProviderScope(
        overrides: [
          rideTripSessionProvider.overrideWith(
            (ref) => _FakeRideTripSessionController(initialState: session),
          ),
          rideDraftProvider.overrideWith((ref) {
            final controller = RideDraftController();
            controller.updatePickupLabel(draft.pickupLabel);
            controller.updateDestination(draft.destinationQuery);
            return controller;
          }),
          rideQuoteControllerProvider.overrideWith(
            (ref) => _FakeRideQuoteController(initialState: quote),
          ),
        ],
        child: MaterialApp(
          locale: locale,
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
          home: const RideTripSummaryScreen(),
        ),
      );
    }

    // ========================================================================
    // Test: displays_all_receipt_sections_in_english
    // ========================================================================

    testWidgets('displays all receipt sections in English', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // AppBar title
      expect(find.text('Trip summary'), findsOneWidget);

      // Trip completed header
      expect(find.text('Trip completed'), findsOneWidget);
      expect(find.text('Thanks for riding with Delivery Ways'), findsOneWidget);

      // Trip ID
      expect(find.textContaining('Trip ID:'), findsOneWidget);

      // Route section
      expect(find.text('Route'), findsOneWidget);
      expect(find.text('From'), findsOneWidget);
      expect(find.text('To'), findsOneWidget);

      // Fare section title
      expect(find.text('Trip fare'), findsOneWidget);

      // Fare breakdown labels
      expect(find.text('Base fare'), findsOneWidget);
      expect(find.text('Distance'), findsOneWidget);
      expect(find.text('Time'), findsOneWidget);
      expect(find.text('Fees & surcharges'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);

      // Driver section
      expect(find.text('Driver & vehicle'), findsOneWidget);
      expect(find.text('Rate your driver'), findsOneWidget);

      // Done CTA
      expect(find.text('Done'), findsOneWidget);
    });

    // ========================================================================
    // Test: l10n_ar_shows_arabic_labels
    // ========================================================================

    testWidgets('l10n AR shows Arabic labels', (tester) async {
      await tester.pumpWidget(buildTestWidget(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      // AppBar title in Arabic
      expect(find.text('ملخص الرحلة'), findsOneWidget);

      // Trip completed header (actual translation from app_ar.arb)
      expect(find.text('تم إنهاء الرحلة'), findsOneWidget);

      // Route labels (from new keys added in Ticket #92)
      expect(find.text('من'), findsOneWidget);
      expect(find.text('إلى'), findsOneWidget);

      // Fare section (from new keys added in Ticket #92)
      expect(find.text('أجرة الرحلة'), findsOneWidget);
      expect(find.text('الإجمالي'), findsOneWidget);

      // Driver section (from new keys added in Ticket #92)
      expect(find.text('السائق والمركبة'), findsOneWidget);

      // Done CTA (actual translation from app_ar.arb)
      expect(find.text('إنهاء'), findsOneWidget);
    });

    // ========================================================================
    // Test: l10n_de_shows_german_labels
    // ========================================================================

    testWidgets('l10n DE shows German labels', (tester) async {
      await tester.pumpWidget(buildTestWidget(locale: const Locale('de')));
      await tester.pumpAndSettle();

      // AppBar title - DE uses English fallback for some keys
      expect(find.text('Trip summary'), findsOneWidget);

      // Fare section (from new keys added in Ticket #92)
      expect(find.text('Fahrpreis'), findsOneWidget);
      expect(find.text('Grundpreis'), findsOneWidget);
      expect(find.text('Strecke'), findsOneWidget);
      expect(find.text('Zeit'), findsOneWidget);
      expect(find.text('Gesamt'), findsOneWidget);

      // Driver section (from new keys added in Ticket #92)
      expect(find.text('Fahrer & Fahrzeug'), findsOneWidget);
      expect(find.text('Fahrer bewerten'), findsOneWidget);

      // Done CTA - uses English fallback 'Done' for rideTripSummaryDoneCta
      expect(find.text('Done'), findsOneWidget);
    });

    // ========================================================================
    // Test: fare_breakdown_uses_price_breakdown_values
    // ========================================================================

    testWidgets('fare breakdown uses price breakdown values', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify price values from RidePriceBreakdown
      // Base: 500 -> 5.00
      // Distance: 700 -> 7.00
      // Time: 300 -> 3.00
      // Fees: 300 -> 3.00
      // Total: 1800 -> 18.00

      expect(find.textContaining('5.00'), findsAtLeastNWidgets(1));
      expect(find.textContaining('7.00'), findsAtLeastNWidgets(1));
      expect(find.textContaining('3.00'), findsAtLeastNWidgets(1)); // Time or Fees
      expect(find.textContaining('18.00'), findsAtLeastNWidgets(1));
    });

    // ========================================================================
    // Test: rate_driver_section_allows_selecting_a_rating
    // ========================================================================

    testWidgets('rate driver section allows selecting a rating', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Find star icons (5 stars total)
      final starBorderIcons = find.byIcon(Icons.star_border);
      expect(starBorderIcons, findsAtLeastNWidgets(1));

      // Scroll to make stars visible
      await tester.ensureVisible(starBorderIcons.first);
      await tester.pumpAndSettle();

      // Tap on a star (this should change state)
      await tester.tap(starBorderIcons.first, warnIfMissed: false);
      await tester.pumpAndSettle();

      // After tapping, we should have at least one filled star
      expect(find.byIcon(Icons.star), findsAtLeastNWidgets(1));
    });

    // ========================================================================
    // Test: uses_design_system_button_for_done_cta
    // ========================================================================

    testWidgets('uses DWButton for Done CTA', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify DWButton is used
      expect(find.byType(DWButton), findsOneWidget);
    });

    // ========================================================================
    // Test: displays_route_summary_with_pickup_and_destination
    // ========================================================================

    // Track B - Ticket #118: Updated to use draftSnapshot in session
    testWidgets('displays route summary with pickup and destination',
        (tester) async {
      const draft = RideDraftUiState(
        pickupLabel: 'Home Address',
        destinationQuery: 'Airport Terminal 1',
      );
      await tester.pumpWidget(buildTestWidget(
        rideDraft: draft,
        tripSession: RideTripSessionUiState(
          activeTrip: createCompletedTrip(),
          draftSnapshot: draft,
        ),
      ));
      await tester.pumpAndSettle();

      // Verify pickup and destination are displayed (from historyEntry after completeCurrentTrip)
      expect(find.text('Home Address'), findsOneWidget);
      expect(find.text('Airport Terminal 1'), findsOneWidget);
    });

    // ========================================================================
    // Test: shows_payment_method_section
    // ========================================================================

    testWidgets('shows payment method section', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify payment method is shown
      expect(find.text('Payment'), findsOneWidget);
      expect(find.text('Cash'), findsOneWidget);
    });

    // ========================================================================
    // Test: done_button_is_present
    // ========================================================================

    testWidgets('Done button is present and tappable', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Scroll to Done button
      final doneButton = find.text('Done');
      expect(doneButton, findsOneWidget);

      // Ensure the button is visible
      await tester.ensureVisible(doneButton);
      await tester.pumpAndSettle();

      // Verify it's a DWButton
      expect(find.byType(DWButton), findsOneWidget);
    });

    // ========================================================================
    // Test: displays_driver_mock_info
    // ========================================================================

    testWidgets('displays driver mock info', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify mock driver info using l10n
      final l10n = l10n0(tester);
      expect(find.text(l10n.rideDriverMockName), findsOneWidget);
      expect(find.text(l10n.rideDriverMockCarInfo), findsOneWidget);
      expect(find.text(l10n.rideDriverMockRating), findsOneWidget); // Rating badge
    });

    // ========================================================================
    // Test: comment_field_is_present
    // ========================================================================

    testWidgets('comment field is present and editable', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Find comment TextField
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // Verify hint text
      expect(find.text('Add a comment (optional)'), findsOneWidget);

      // Enter text
      await tester.enterText(textField, 'Great driver!');
      await tester.pumpAndSettle();

      expect(find.text('Great driver!'), findsOneWidget);
    });

    // ========================================================================
    // Track B - Ticket #124: Driver Rating Persistence Tests
    // ========================================================================

    testWidgets('tapping_rating_stars_calls_setRatingForMostRecentTrip', (tester) async {
      const completedTrip = RideTripState(
        tripId: 'rating-test-123',
        phase: RideTripPhase.completed,
      );
      const draft = RideDraftUiState(
        pickupLabel: 'Home',
        destinationQuery: 'Mall',
      );
      final historyEntry = RideHistoryEntry(
        trip: completedTrip,
        destinationLabel: 'Mall',
        completedAt: DateTime.now(),
      );

      // Create fake controller to track setRatingForMostRecentTrip calls
      final fakeController = _FakeRideTripSessionController(
        initialState: RideTripSessionUiState(
          historyTrips: [historyEntry],
          draftSnapshot: draft,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideTripSessionProvider.overrideWith(
              (ref) => fakeController,
            ),
            rideDraftProvider.overrideWith((ref) {
              final controller = RideDraftController();
              controller.updatePickupLabel('Home');
              controller.updateDestination('Mall');
              return controller;
            }),
            rideQuoteControllerProvider.overrideWith(
              (ref) => _FakeRideQuoteController(
                initialState: RideQuoteUiState(
                  isLoading: false,
                  quote: createMockQuoteWithBreakdown(),
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en')],
            home: RideTripSummaryScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find star icons
      final starBorderIcons = find.byIcon(Icons.star_border);
      expect(starBorderIcons, findsAtLeastNWidgets(1));

      // Scroll to make stars visible
      await tester.ensureVisible(starBorderIcons.first);
      await tester.pumpAndSettle();

      // Tap on 4th star (index 3) to give 4-star rating
      await tester.tap(find.byIcon(Icons.star_border).at(3), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify setRatingForMostRecentTrip was called with 4.0
      expect(fakeController.setRatingCallCount, greaterThan(0));
      expect(fakeController.lastSetRating, 4.0);
    });

    testWidgets('rating_from_history_entry_shows_initial_stars', (tester) async {
      const completedTrip = RideTripState(
        tripId: 'initial-rating-test',
        phase: RideTripPhase.completed,
      );
      const draft = RideDraftUiState(
        pickupLabel: 'Office',
        destinationQuery: 'Airport',
      );
      final historyEntry = RideHistoryEntry(
        trip: completedTrip,
        destinationLabel: 'Airport',
        completedAt: DateTime.now(),
        driverRating: 4.0, // Pre-existing rating
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideTripSessionProvider.overrideWith(
              (ref) => _FakeRideTripSessionController(
                initialState: RideTripSessionUiState(
                  historyTrips: [historyEntry],
                  draftSnapshot: draft,
                ),
              ),
            ),
            rideDraftProvider.overrideWith((ref) {
              final controller = RideDraftController();
              controller.updatePickupLabel('Office');
              controller.updateDestination('Airport');
              return controller;
            }),
            rideQuoteControllerProvider.overrideWith(
              (ref) => _FakeRideQuoteController(
                initialState: RideQuoteUiState(
                  isLoading: false,
                  quote: createMockQuoteWithBreakdown(),
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en')],
            home: RideTripSummaryScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // With initial rating of 4, we should have 4 filled stars
      expect(find.byIcon(Icons.star), findsAtLeastNWidgets(4));
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

  /// Track B - Ticket #124: Track calls to setRatingForMostRecentTrip
  double? lastSetRating;
  int setRatingCallCount = 0;

  @override
  void rateCurrentTrip(int rating) {
    // No-op for tests (rating stored in-memory)
  }

  /// Track B - Ticket #124: Override to track calls and update history
  @override
  bool setRatingForMostRecentTrip(double rating) {
    lastSetRating = rating;
    setRatingCallCount++;
    
    // Also update the actual state for verification
    if (state.historyTrips.isEmpty) return false;
    if (rating < 1.0 || rating > 5.0) return false;
    
    final entries = List<RideHistoryEntry>.from(state.historyTrips);
    entries[0] = entries[0].copyWith(driverRating: rating);
    state = state.copyWith(historyTrips: entries);
    return true;
  }

  @override
  void clear() {
    state = const RideTripSessionUiState();
  }

  // Track B - Ticket #118: Override completeCurrentTrip to simulate behavior
  @override
  bool completeCurrentTrip({
    String? destinationLabel,
    String? amountFormatted,
    String? serviceName,
    String? originLabel,
    String? paymentMethodLabel,
  }) {
    final current = state.activeTrip;
    if (current == null) return false;
    
    // Create completed trip
    final completedTrip = RideTripState(
      tripId: current.tripId,
      phase: RideTripPhase.completed,
    );
    
    // Create history entry using passed labels or defaults
    final entry = RideHistoryEntry(
      trip: completedTrip,
      destinationLabel: destinationLabel ?? 'Unknown',
      completedAt: DateTime.now(),
      amountFormatted: amountFormatted,
      serviceName: serviceName,
      originLabel: originLabel,
      paymentMethodLabel: paymentMethodLabel,
    );
    
    // Add to history and clear active trip
    state = RideTripSessionUiState(
      historyTrips: [entry, ...state.historyTrips],
    );
    
    return true;
  }

  // Track B - Ticket #120
  @override
  bool cancelCurrentTrip({
    String? reasonLabel,
    String? destinationLabel,
    String? originLabel,
    String? serviceName,
    String? amountFormatted,
    String? paymentMethodLabel,
  }) {
    final current = state.activeTrip;
    if (current == null) return false;
    
    // Create cancelled trip
    final cancelledTrip = RideTripState(
      tripId: current.tripId,
      phase: RideTripPhase.cancelled,
    );
    
    // Create history entry
    final entry = RideHistoryEntry(
      trip: cancelledTrip,
      destinationLabel: destinationLabel ?? 'Unknown',
      completedAt: DateTime.now(),
      amountFormatted: amountFormatted,
      serviceName: serviceName,
      originLabel: originLabel,
      paymentMethodLabel: paymentMethodLabel,
    );
    
    // Add to history and clear active trip
    state = RideTripSessionUiState(
      historyTrips: [entry, ...state.historyTrips],
    );
    
    return true;
  }

  // Track B - Ticket #122
  @override
  bool failCurrentTrip({
    String? reasonLabel,
    String? destinationLabel,
    String? originLabel,
    String? serviceName,
    String? amountFormatted,
    String? paymentMethodLabel,
  }) {
    final current = state.activeTrip;
    if (current == null) return false;
    
    // Create failed trip
    final failedTrip = RideTripState(
      tripId: current.tripId,
      phase: RideTripPhase.failed,
    );
    
    // Create history entry
    final entry = RideHistoryEntry(
      trip: failedTrip,
      destinationLabel: destinationLabel ?? 'Unknown',
      completedAt: DateTime.now(),
      amountFormatted: amountFormatted,
      serviceName: serviceName,
      originLabel: originLabel,
      paymentMethodLabel: paymentMethodLabel,
    );
    
    // Add to history and clear active trip
    state = RideTripSessionUiState(
      historyTrips: [entry, ...state.historyTrips],
    );
    
    return true;
  }
}

/// Fake RideQuoteController for testing
class _FakeRideQuoteController extends RideQuoteController {
  _FakeRideQuoteController({required RideQuoteUiState initialState})
      : _state = initialState,
        super.legacy(const MockRideQuoteService());

  final RideQuoteUiState _state;

  @override
  RideQuoteUiState get state => _state;

  @override
  Future<void> refreshFromDraft(RideDraftUiState draft) async {
    // No-op for tests
  }

  @override
  Future<void> retryFromDraft(RideDraftUiState draft) async {
    // No-op for tests
  }
}

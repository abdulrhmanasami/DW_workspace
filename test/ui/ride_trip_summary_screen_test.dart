/// Widget tests for RideTripSummaryScreen (Track B - Ticket #92)
/// Purpose: Verify trip receipt/summary screen UI with receipt breakdown and rating
/// Created by: Ticket #92
/// Last updated: 2025-11-30

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
    /// Helper to create a completed trip state
    RideTripState createCompletedTrip() {
      return RideTripState(
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
    Widget buildTestWidget({
      RideTripSessionUiState? tripSession,
      RideDraftUiState? rideDraft,
      RideQuoteUiState? quoteState,
      Locale locale = const Locale('en'),
    }) {
      final session = tripSession ??
          RideTripSessionUiState(activeTrip: createCompletedTrip());
      final draft = rideDraft ??
          const RideDraftUiState(
            pickupLabel: 'Current location',
            destinationQuery: 'Mall of Arabia',
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

    testWidgets('displays route summary with pickup and destination',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        rideDraft: const RideDraftUiState(
          pickupLabel: 'Home Address',
          destinationQuery: 'Airport Terminal 1',
        ),
      ));
      await tester.pumpAndSettle();

      // Verify pickup and destination are displayed
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

      // Verify mock driver info
      expect(find.text('Ahmad M.'), findsOneWidget);
      expect(find.text('Toyota Camry • ABC 1234'), findsOneWidget);
      expect(find.text('4.9'), findsOneWidget); // Rating badge
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
  });
}

// ============================================================================
// Fake Controllers for Testing
// ============================================================================

/// Fake RideTripSessionController for testing
class _FakeRideTripSessionController extends RideTripSessionController {
  _FakeRideTripSessionController({required RideTripSessionUiState initialState})
      : super() {
    state = initialState;
  }

  @override
  void rateCurrentTrip(int rating) {
    // No-op for tests (rating stored in-memory)
  }

  @override
  void clear() {
    state = const RideTripSessionUiState();
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
}

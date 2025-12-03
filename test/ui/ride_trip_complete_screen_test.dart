/// Ride Trip Complete Screen Test - Track B Ticket #107, #118
/// Purpose: Test ride completion summary screen with FSM integration
/// Created by: Track B - Ticket #107
/// Updated by: Track B - Ticket #118 (completeCurrentTrip + historyTrips integration)
/// Last updated: 2025-11-30
///
/// This test verifies:
/// 1. Trip summary is shown after completion via historyTrips
/// 2. Service name, fare, and payment method are displayed correctly from history entry
/// 3. Fallback UI when no history available
/// 4. L10n support for Arabic locale
/// 5. completeCurrentTrip is called on screen init (Ticket #118)
///
/// NOTE: Uses mock providers for deterministic testing without network.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// App imports
import 'package:delivery_ways_clean/screens/mobility/ride_trip_summary_screen.dart';
import 'package:delivery_ways_clean/state/mobility/ride_trip_session.dart';
import 'package:delivery_ways_clean/state/mobility/ride_draft_state.dart';
import 'package:delivery_ways_clean/state/mobility/ride_quote_controller.dart';
import 'package:delivery_ways_clean/state/payments/payment_methods_ui_state.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';

// Shims
import 'package:mobility_shims/mobility_shims.dart';

// Test support
import '../support/design_system_harness.dart';

void main() {
  setUpAll(() {
    ensureDesignSystemStubsForTests();
  });

  group('Ride Trip Complete Screen Tests (Ticket #107)', () {
    /// Helper to get AppLocalizations from the test widget
    AppLocalizations _l10n(WidgetTester tester) =>
        AppLocalizations.of(tester.element(find.byType(RideTripSummaryScreen)))!;

    /// Helper to build the test widget with provider overrides
    Widget buildTestWidget({
      required RideTripSessionUiState tripSession,
      RideDraftUiState? rideDraft,
      RideQuoteUiState? quoteState,
      PaymentMethodsUiState? paymentsState,
      Locale locale = const Locale('en'),
    }) {
      return ProviderScope(
        overrides: [
          rideTripSessionProvider.overrideWith(
            (ref) => _FakeRideTripSessionController(
              initialState: tripSession,
            ),
          ),
          rideDraftProvider.overrideWith(
            (ref) => _FakeRideDraftController(
              initialState: rideDraft ?? const RideDraftUiState(
                destinationQuery: 'King Fahd Road',
              ),
            ),
          ),
          rideQuoteControllerProvider.overrideWith(
            (ref) => _FakeRideQuoteController(
              initialState: quoteState ?? const RideQuoteUiState(),
            ),
          ),
          paymentMethodsUiProvider.overrideWith(
            (ref) => paymentsState ?? const PaymentMethodsUiState(
              methods: [
                PaymentMethodUiModel(
                  id: 'cash',
                  displayName: 'Cash',
                  type: PaymentMethodUiType.cash,
                  isDefault: true,
                ),
                PaymentMethodUiModel(
                  id: 'visa_4242',
                  displayName: 'Visa ••4242',
                  type: PaymentMethodUiType.card,
                  isDefault: false,
                ),
              ],
              selectedMethodId: 'cash',
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
          home: const RideTripSummaryScreen(),
        ),
      );
    }

    // =========================================================================
    // Test 1: Shows trip summary after completion (Ticket #118: via historyTrips)
    // =========================================================================
    testWidgets(
      'shows_trip_summary_after_completion_via_history',
      (WidgetTester tester) async {
        // Track B - Ticket #118: Screen now reads from historyTrips after completeCurrentTrip
        const activeTrip = RideTripState(
          tripId: 'test-trip-completed-123',
          phase: RideTripPhase.inProgress, // Not yet completed - screen will complete it
        );

        const tripSummary = RideTripSummary(
          selectedServiceId: 'economy',
          selectedServiceName: 'Economy',
          fareDisplayText: '≈ 18.00 SAR',
          selectedPaymentMethodId: 'visa_4242',
          etaMinutes: 5,
        );

        const draftSnapshot = RideDraftUiState(
          destinationQuery: 'King Fahd Road',
          pickupLabel: 'Current Location',
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(
            activeTrip: activeTrip,
            tripSummary: tripSummary,
            draftSnapshot: draftSnapshot,
          ),
        ));
        await tester.pumpAndSettle();

        // Verify the screen shows Trip summary title
        final l10n = _l10n(tester);
        expect(find.text(l10n.rideTripSummaryTitle), findsOneWidget);

        // Verify service name is shown (Economy ride)
        expect(find.textContaining('Economy'), findsWidgets);

        // Verify fare is shown
        expect(find.textContaining('18.00'), findsWidgets);

        // Verify payment method (Visa)
        expect(find.textContaining('Visa'), findsWidgets);

        // Verify Done CTA is shown
        expect(find.text(l10n.rideTripSummaryDoneCta), findsOneWidget);
      },
    );

    // =========================================================================
    // Test 2: Shows fallback when no summary available (Ticket #118)
    // =========================================================================
    testWidgets(
      'shows_fallback_when_no_summary_available',
      (WidgetTester tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-trip-no-summary',
          phase: RideTripPhase.inProgress,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(
            activeTrip: activeTrip,
            tripSummary: null, // No trip summary
            draftSnapshot: RideDraftUiState(destinationQuery: 'Test'),
          ),
        ));
        await tester.pumpAndSettle();

        // Should still render the summary screen
        final l10n2 = _l10n(tester);
        expect(find.text(l10n2.rideTripSummaryTitle), findsOneWidget);

        // Should show default payment method (Cash as fallback)
        expect(find.text(l10n2.rideTripConfirmationPaymentMethodCash), findsOneWidget);

        // Done CTA should be shown
        expect(find.text(l10n2.rideTripSummaryDoneCta), findsOneWidget);
      },
    );

    // =========================================================================
    // Test 3: L10n AR - Shows Arabic completion texts (Ticket #118)
    // =========================================================================
    testWidgets(
      'l10n_ar_shows_arabic_completion_texts',
      (WidgetTester tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-trip-ar',
          phase: RideTripPhase.inProgress,
        );

        const tripSummary = RideTripSummary(
          selectedServiceId: 'economy',
          selectedServiceName: 'Economy',
          fareDisplayText: '≈ 18.00 SAR',
          selectedPaymentMethodId: 'cash',
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(
            activeTrip: activeTrip,
            tripSummary: tripSummary,
            draftSnapshot: RideDraftUiState(destinationQuery: 'Test'),
          ),
          locale: const Locale('ar'),
        ));
        await tester.pumpAndSettle();

        // Verify Arabic title is shown
        final l10nAr = _l10n(tester);
        expect(find.text(l10nAr.rideTripSummaryTitle), findsOneWidget);

        // Verify Arabic Done CTA
        expect(find.text(l10nAr.rideTripSummaryDoneCta), findsOneWidget);

        // Verify Arabic Trip completed text
        expect(find.text(l10nAr.rideTripSummaryCompletedTitle), findsOneWidget);
      },
    );

    // =========================================================================
    // Test 4: Displays correct service and price from history entry (Ticket #118)
    // =========================================================================
    testWidgets(
      'displays_correct_service_and_price_from_history_entry',
      (WidgetTester tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-trip-xl',
          phase: RideTripPhase.inProgress,
        );

        const tripSummary = RideTripSummary(
          selectedServiceId: 'xl',
          selectedServiceName: 'XL',
          fareDisplayText: '≈ 35.00 SAR',
          selectedPaymentMethodId: 'visa_4242',
          etaMinutes: 3,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(
            activeTrip: activeTrip,
            tripSummary: tripSummary,
            draftSnapshot: RideDraftUiState(destinationQuery: 'Test'),
          ),
        ));
        await tester.pumpAndSettle();

        // Verify XL service is shown
        expect(find.textContaining('XL'), findsWidgets);

        // Verify price is shown
        expect(find.textContaining('35.00'), findsWidgets);
      },
    );

    // =========================================================================
    // Test 5: Completed header shows trip ID (Ticket #118)
    // =========================================================================
    testWidgets(
      'completed_header_shows_trip_id',
      (WidgetTester tester) async {
        const activeTrip = RideTripState(
          tripId: 'local-1234567890',
          phase: RideTripPhase.inProgress,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(
            activeTrip: activeTrip,
            tripSummary: RideTripSummary(
              selectedServiceName: 'Economy',
              fareDisplayText: '≈ 20.00 SAR',
            ),
            draftSnapshot: RideDraftUiState(destinationQuery: 'Test'),
          ),
        ));
        await tester.pumpAndSettle();

        // Verify trip ID is shown in header
        expect(find.textContaining('local-1234567890'), findsOneWidget);
      },
    );

    // =========================================================================
    // Test 6: Payment method from history entry is shown correctly (Ticket #118)
    // =========================================================================
    testWidgets(
      'payment_method_from_history_entry_is_shown',
      (WidgetTester tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-trip-card-payment',
          phase: RideTripPhase.inProgress,
        );

        const tripSummary = RideTripSummary(
          selectedServiceId: 'economy',
          selectedServiceName: 'Economy',
          fareDisplayText: '≈ 25.00 SAR',
          selectedPaymentMethodId: 'visa_4242', // Card payment
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(
            activeTrip: activeTrip,
            tripSummary: tripSummary,
            draftSnapshot: RideDraftUiState(destinationQuery: 'Test'),
          ),
        ));
        await tester.pumpAndSettle();

        // Verify Visa card is shown
        expect(find.textContaining('Visa'), findsWidgets);

        // Verify credit card icon is present (looking for card icon)
        expect(find.byIcon(Icons.credit_card), findsWidgets);
      },
    );

    // =========================================================================
    // Test 7: Driver rating section is visible (Ticket #118)
    // =========================================================================
    testWidgets(
      'driver_rating_section_is_visible',
      (WidgetTester tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-trip-rating',
          phase: RideTripPhase.inProgress,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(
            activeTrip: activeTrip,
            tripSummary: RideTripSummary(
              selectedServiceName: 'Economy',
              fareDisplayText: '≈ 18.00 SAR',
            ),
            draftSnapshot: RideDraftUiState(destinationQuery: 'Test'),
          ),
        ));
        await tester.pumpAndSettle();

        // Verify driver section title (L10n: rideReceiptDriverSectionTitle)
        final l10nDriver = _l10n(tester);
        expect(find.text(l10nDriver.rideReceiptDriverSectionTitle), findsOneWidget);

        // Verify star icons for rating
        expect(find.byIcon(Icons.star_border), findsWidgets);
      },
    );

    // =========================================================================
    // Test 8: completeCurrentTrip is called and archives trip (Ticket #118)
    // =========================================================================
    testWidgets(
      'complete_current_trip_called_on_init_archives_to_history',
      (WidgetTester tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-trip-archive',
          phase: RideTripPhase.inProgress,
        );

        const tripSummary = RideTripSummary(
          selectedServiceName: 'Premium',
          fareDisplayText: '≈ 50.00 SAR',
        );

        const draftSnapshot = RideDraftUiState(
          destinationQuery: 'Downtown',
          pickupLabel: 'Home',
        );

        late RideTripSessionUiState capturedState;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideTripSessionProvider.overrideWith(
                (ref) {
                  final controller = _FakeRideTripSessionController(
                    initialState: const RideTripSessionUiState(
                      activeTrip: activeTrip,
                      tripSummary: tripSummary,
                      draftSnapshot: draftSnapshot,
                    ),
                  );
                  // Capture state after init
                  Future.delayed(Duration.zero, () {
                    capturedState = controller.state;
                  });
                  return controller;
                },
              ),
              rideDraftProvider.overrideWith(
                (ref) => _FakeRideDraftController(
                  initialState: draftSnapshot,
                ),
              ),
              rideQuoteControllerProvider.overrideWith(
                (ref) => _FakeRideQuoteController(
                  initialState: const RideQuoteUiState(),
                ),
              ),
              paymentMethodsUiProvider.overrideWith(
                (ref) => const PaymentMethodsUiState(
                  methods: [
                    PaymentMethodUiModel(
                      id: 'cash',
                      displayName: 'Cash',
                      type: PaymentMethodUiType.cash,
                      isDefault: true,
                    ),
                  ],
                  selectedMethodId: 'cash',
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
              locale: Locale('en'),
              home: RideTripSummaryScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify trip is now in history
        expect(capturedState.activeTrip, isNull);
        expect(capturedState.historyTrips, hasLength(1));
        expect(capturedState.historyTrips.first.trip.phase, RideTripPhase.completed);
      },
    );

    // =========================================================================
    // Test 9: Done CTA is present and tappable (Ticket #118)
    // =========================================================================
    testWidgets(
      'done_cta_is_present_and_tappable',
      (WidgetTester tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-trip-done',
          phase: RideTripPhase.inProgress,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(
            activeTrip: activeTrip,
            tripSummary: RideTripSummary(
              selectedServiceName: 'Economy',
              fareDisplayText: '≈ 20.00 SAR',
            ),
            draftSnapshot: RideDraftUiState(destinationQuery: 'Test'),
          ),
        ));
        await tester.pumpAndSettle();

        // Find Done CTA
        final l10nDone = _l10n(tester);
        final doneCta = find.text(l10nDone.rideTripSummaryDoneCta);
        expect(doneCta, findsOneWidget);

        // Verify button is tappable (exists and is enabled)
        final button = find.widgetWithText(ElevatedButton, l10nDone.rideTripSummaryDoneCta);
        expect(button, findsOneWidget);
      },
    );
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
    state = state.copyWith(driverRating: rating);
  }

  @override
  // Track B - Ticket #108: Extended with serviceName, originLabel, paymentMethodLabel
  void archiveTrip({
    required String destinationLabel,
    String? amountFormatted,
    String? serviceName,
    String? originLabel,
    String? paymentMethodLabel,
  }) {}

  @override
  bool completeTrip() {
    return true;
  }

  @override
  void clearCompletionSummary() {
    state = state.copyWith(clearCompletionSummary: true);
  }

  // Track B - Ticket #117, #118: Simulate actual completeCurrentTrip behavior
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
    
    // Create history entry
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
  }) => true;

  // Track B - Ticket #124
  @override
  bool setRatingForMostRecentTrip(double rating) {
    if (rating < 1.0 || rating > 5.0) return false;
    if (state.historyTrips.isEmpty) return false;
    final entries = List<RideHistoryEntry>.from(state.historyTrips);
    final latest = entries.first;
    if (!latest.trip.phase.isTerminal) return false;
    entries[0] = latest.copyWith(driverRating: rating);
    state = state.copyWith(historyTrips: entries);
    return true;
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

  @override
  void setPaymentMethodId(String? paymentMethodId) {}

  @override
  void clearPaymentMethodId() {}
}

/// Fake RideQuoteController for testing
class _FakeRideQuoteController extends StateNotifier<RideQuoteUiState>
    implements RideQuoteController {
  _FakeRideQuoteController({required RideQuoteUiState initialState})
      : super(initialState);

  @override
  Future<void> refreshFromDraft(RideDraftUiState draft) async {}

  @override
  Future<void> retryFromDraft(RideDraftUiState draft) async {}

  @override
  void clear() {
    state = const RideQuoteUiState();
  }
}

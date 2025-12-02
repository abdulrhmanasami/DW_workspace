/// Ride Flow Happy Path Test - Track B Ticket #94
/// Purpose: End-to-end widget test for Ride flow navigation and state management
/// Created by: Track B - Ticket #94
/// Updated by: Track B - Ticket #102 (Payment method lifecycle tests)
/// Updated by: Track B - Ticket #107 (Trip completion with completionSummary)
/// Updated by: Track B - Ticket #108 (archiveTrip with extended parameters)
/// Last updated: 2025-11-30
///
/// This test verifies the ride booking flow wiring:
/// 1. Active Ride Card appears when trip is active
/// 2. Ride card navigates to Active Trip when trip exists
/// 3. Active status labels are correct for each phase
/// 4. Terminal phases don't show active card
///
/// NOTE: Uses mock providers for deterministic testing without network.
/// Full Happy Path flow tests will be added when AppShell providers are fully mockable.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// App imports
import 'package:delivery_ways_clean/app_shell/app_shell.dart';
import 'package:delivery_ways_clean/router/app_router.dart';
import 'package:delivery_ways_clean/state/mobility/ride_trip_session.dart';
import 'package:delivery_ways_clean/state/mobility/ride_draft_state.dart';
import 'package:delivery_ways_clean/state/auth/auth_state.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';

// Shims
import 'package:mobility_shims/mobility_shims.dart';

// Test support
import '../support/design_system_harness.dart';

void main() {
  setUpAll(() {
    ensureDesignSystemStubsForTests();
  });

  group('Ride Flow Happy Path Tests (Ticket #94)', () {
    /// Helper to build the test widget with provider overrides
    /// Based on home_active_ride_card_test.dart pattern
    Widget buildTestWidget({
      required RideTripSessionUiState tripSession,
      RideDraftUiState? rideDraft,
      List<Override> additionalOverrides = const [],
      Map<String, WidgetBuilder>? routes,
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
              initialState: rideDraft ?? const RideDraftUiState(),
            ),
          ),
          // Mock auth state as authenticated
          simpleAuthStateProvider.overrideWith(
            (ref) => _FakeAuthController(),
          ),
          ...additionalOverrides,
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
          routes: routes ??
              {
                RoutePaths.rideActive: (_) => const Scaffold(
                      body: Center(child: Text('Ride Active Trip Screen')),
                    ),
                RoutePaths.rideDestination: (_) => const Scaffold(
                      body: Center(child: Text('Ride Destination Screen')),
                    ),
              },
          home: const AppShell(),
        ),
      );
    }

    // =========================================================================
    // Test 1: Active Ride Card appears when trip is active (findingDriver)
    // =========================================================================
    testWidgets(
      'active_ride_card_appears_for_finding_driver_phase',
      (WidgetTester tester) async {
        final activeTrip = RideTripState(
          tripId: 'test-trip-1',
          phase: RideTripPhase.findingDriver,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: RideTripSessionUiState(activeTrip: activeTrip),
          rideDraft: const RideDraftUiState(destinationQuery: 'King Fahd Road'),
        ));
        await tester.pumpAndSettle();

        // Verify Active Ride Card is shown with correct status
        expect(find.text('Looking for a driver...'), findsOneWidget);
        expect(find.text('View trip'), findsOneWidget);
      },
    );

    // =========================================================================
    // Test 2: Ride card navigates to Active Trip when trip exists
    // =========================================================================
    testWidgets(
      'ride_card_navigates_to_active_trip_when_trip_exists',
      (WidgetTester tester) async {
        final activeTrip = RideTripState(
          tripId: 'existing-trip-123',
          phase: RideTripPhase.driverAccepted,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: RideTripSessionUiState(activeTrip: activeTrip),
          rideDraft: const RideDraftUiState(destinationQuery: 'Mall of Arabia'),
        ));
        await tester.pumpAndSettle();

        // Verify Active Ride Card is shown
        expect(find.text('View trip'), findsOneWidget);
        expect(find.text('Driver on the way'), findsOneWidget);

        // Tap the Ride service card (should go to Active Trip)
        await tester.tap(find.text('Ride'));
        await tester.pumpAndSettle();

        // Verify we navigated to Active Trip Screen
        expect(find.text('Ride Active Trip Screen'), findsOneWidget);
      },
    );

    // =========================================================================
    // Test 3: Active Ride Card shows correct status for driverArrived phase
    // =========================================================================
    testWidgets(
      'active_ride_card_shows_driver_arrived_status',
      (WidgetTester tester) async {
        final activeTrip = RideTripState(
          tripId: 'test-arrived',
          phase: RideTripPhase.driverArrived,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        // Verify status for driverArrived
        expect(find.text('Driver has arrived'), findsOneWidget);
        expect(find.text('View trip'), findsOneWidget);
      },
    );

    // =========================================================================
    // Test 4: Active Ride Card shows correct status for inProgress phase
    // =========================================================================
    testWidgets(
      'active_ride_card_shows_in_progress_status',
      (WidgetTester tester) async {
        final activeTrip = RideTripState(
          tripId: 'test-in-progress',
          phase: RideTripPhase.inProgress,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        // Verify status for inProgress
        expect(find.text('Trip in progress'), findsOneWidget);
        expect(find.text('View trip'), findsOneWidget);
      },
    );

    // =========================================================================
    // Test 5: Active Ride Card shows correct status for payment phase
    // =========================================================================
    testWidgets(
      'active_ride_card_shows_payment_status',
      (WidgetTester tester) async {
        final activeTrip = RideTripState(
          tripId: 'test-payment',
          phase: RideTripPhase.payment,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        // Verify status for payment
        expect(find.text('Finalizing payment'), findsOneWidget);
        expect(find.text('View trip'), findsOneWidget);
      },
    );

    // =========================================================================
    // Test 6: Terminal phase (completed) does NOT show active card
    // =========================================================================
    testWidgets(
      'completed_phase_does_not_show_active_ride_card',
      (WidgetTester tester) async {
        final completedTrip = RideTripState(
          tripId: 'test-completed',
          phase: RideTripPhase.completed,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: RideTripSessionUiState(activeTrip: completedTrip),
        ));
        await tester.pumpAndSettle();

        // Completed is terminal - no active ride card
        expect(find.text('View trip'), findsNothing);
      },
    );

    // =========================================================================
    // Test 7: Terminal phase (cancelled) does NOT show active card
    // =========================================================================
    testWidgets(
      'cancelled_phase_does_not_show_active_ride_card',
      (WidgetTester tester) async {
        final cancelledTrip = RideTripState(
          tripId: 'test-cancelled',
          phase: RideTripPhase.cancelled,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: RideTripSessionUiState(activeTrip: cancelledTrip),
        ));
        await tester.pumpAndSettle();

        // Cancelled is terminal - no active ride card
        expect(find.text('View trip'), findsNothing);
      },
    );

    // =========================================================================
    // Test 8: Terminal phase (failed) does NOT show active card
    // =========================================================================
    testWidgets(
      'failed_phase_does_not_show_active_ride_card',
      (WidgetTester tester) async {
        final failedTrip = RideTripState(
          tripId: 'test-failed',
          phase: RideTripPhase.failed,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: RideTripSessionUiState(activeTrip: failedTrip),
        ));
        await tester.pumpAndSettle();

        // Failed is terminal - no active ride card
        expect(find.text('View trip'), findsNothing);
      },
    );

    // =========================================================================
    // Test 9: L10n AR - Active card shows Arabic status
    // =========================================================================
    testWidgets(
      'active_ride_card_shows_arabic_status',
      (WidgetTester tester) async {
        final activeTrip = RideTripState(
          tripId: 'test-ar',
          phase: RideTripPhase.findingDriver,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: RideTripSessionUiState(activeTrip: activeTrip),
          locale: const Locale('ar'),
        ));
        await tester.pumpAndSettle();

        // Verify Arabic status
        expect(find.text('جاري البحث عن سائق...'), findsOneWidget);
        expect(find.text('عرض الرحلة'), findsOneWidget);
      },
    );

    // =========================================================================
    // Test 10: L10n DE - Active card shows German status
    // =========================================================================
    testWidgets(
      'active_ride_card_shows_german_status',
      (WidgetTester tester) async {
        final activeTrip = RideTripState(
          tripId: 'test-de',
          phase: RideTripPhase.inProgress,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: RideTripSessionUiState(activeTrip: activeTrip),
          locale: const Locale('de'),
        ));
        await tester.pumpAndSettle();

        // Verify German status
        expect(find.text('Fahrt läuft'), findsOneWidget);
        expect(find.text('Fahrt ansehen'), findsOneWidget);
      },
    );

    // =========================================================================
    // Track B - Ticket #102: Payment method lifecycle in second ride
    // =========================================================================
    testWidgets(
      'second_ride_starts_with_clean_paymentMethodId',
      (WidgetTester tester) async {
        // Use a real controller to track state changes
        final draftController = RideDraftController();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideTripSessionProvider.overrideWith(
                (ref) => _FakeRideTripSessionController(
                  initialState: const RideTripSessionUiState(),
                ),
              ),
              rideDraftProvider.overrideWith((ref) => draftController),
              simpleAuthStateProvider.overrideWith(
                (ref) => _FakeAuthController(),
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
              routes: {
                RoutePaths.rideActive: (_) => const Scaffold(
                      body: Center(child: Text('Ride Active Trip Screen')),
                    ),
                RoutePaths.rideDestination: (_) => const Scaffold(
                      body: Center(child: Text('Ride Destination Screen')),
                    ),
              },
              home: const AppShell(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // ===== First Ride =====
        // Set payment method for first ride
        draftController.updateDestination('Airport');
        draftController.setPaymentMethodId('visa_4242');
        expect(draftController.state.paymentMethodId, 'visa_4242',
            reason: 'First ride should have Visa');

        // Simulate ride completion - clear draft
        draftController.clear();

        // ===== Second Ride =====
        // After clear, paymentMethodId should be null
        expect(draftController.state.paymentMethodId, isNull,
            reason: 'After clear, paymentMethodId should be null');
        expect(draftController.state.destinationQuery, '',
            reason: 'After clear, destination should be empty');

        // Start second ride flow
        draftController.updateDestination('Mall');
        expect(draftController.state.paymentMethodId, isNull,
            reason: 'Before setting, paymentMethodId should still be null');

        // Simulate user selecting payment method in confirmation screen
        draftController.setPaymentMethodId('cash');
        expect(draftController.state.paymentMethodId, 'cash',
            reason: 'Second ride should use Cash (set fresh)');
        expect(draftController.state.destinationQuery, 'Mall',
            reason: 'Destination should be set for second ride');
      },
    );

    testWidgets(
      'clear_prevents_payment_method_leakage_between_rides',
      (WidgetTester tester) async {
        final draftController = RideDraftController();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideTripSessionProvider.overrideWith(
                (ref) => _FakeRideTripSessionController(
                  initialState: const RideTripSessionUiState(),
                ),
              ),
              rideDraftProvider.overrideWith((ref) => draftController),
              simpleAuthStateProvider.overrideWith(
                (ref) => _FakeAuthController(),
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
              home: const AppShell(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // First ride with premium payment method
        draftController.updateDestination('Airport');
        draftController.updateSelectedOption('premium');
        draftController.setPaymentMethodId('mastercard_5555');

        // Verify first ride state
        expect(draftController.state.destinationQuery, 'Airport');
        expect(draftController.state.selectedOptionId, 'premium');
        expect(draftController.state.paymentMethodId, 'mastercard_5555');

        // Clear after ride completion
        draftController.clear();

        // Verify all fields are reset
        expect(draftController.state.destinationQuery, '',
            reason: 'Destination should be reset');
        expect(draftController.state.selectedOptionId, isNull,
            reason: 'Selected option should be reset');
        expect(draftController.state.paymentMethodId, isNull,
            reason: 'Payment method should be reset - no leakage');
        expect(draftController.state.pickupLabel, 'Current location',
            reason: 'Pickup label should be reset to default');
      },
    );

    // =========================================================================
    // Track B - Ticket #107: Trip completion with completionSummary
    // =========================================================================
    testWidgets(
      'complete_trip_sets_completion_summary_snapshot',
      (WidgetTester tester) async {
        // Use a real controller to track state changes
        final sessionController = RideTripSessionController();
        final draftController = RideDraftController();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideTripSessionProvider.overrideWith(
                (ref) => sessionController,
              ),
              rideDraftProvider.overrideWith((ref) => draftController),
              simpleAuthStateProvider.overrideWith(
                (ref) => _FakeAuthController(),
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
              home: const AppShell(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Setup: Start a ride from draft
        draftController.updateDestination('Mall');
        draftController.setPaymentMethodId('visa_4242');

        // Create a mock quote option for the trip
        final mockOption = RideQuoteOption(
          id: 'economy',
          category: RideVehicleCategory.economy,
          displayName: 'Economy',
          priceMinorUnits: 1800,
          currencyCode: 'SAR',
          etaMinutes: 5,
        );

        // Start trip from draft with the selected option
        sessionController.startFromDraft(
          draftController.state,
          selectedOption: mockOption,
        );

        // Verify trip started with summary populated
        expect(sessionController.state.tripSummary, isNotNull);
        expect(sessionController.state.tripSummary?.selectedServiceName, 'Economy');
        expect(sessionController.state.tripSummary?.selectedPaymentMethodId, 'visa_4242');

        // Verify completionSummary is null before completion
        expect(sessionController.state.completionSummary, isNull);

        // Advance trip to inProgress (simulate FSM transitions)
        sessionController.applyEvent(RideTripEvent.driverAccepted);
        sessionController.applyEvent(RideTripEvent.driverArrived);
        sessionController.applyEvent(RideTripEvent.startTrip);

        expect(sessionController.state.activeTrip?.phase, RideTripPhase.inProgress);

        // Complete the trip
        final completed = sessionController.completeTrip();

        // Verify completion was successful
        expect(completed, isTrue);
        expect(sessionController.state.activeTrip?.phase, RideTripPhase.completed);

        // Verify completionSummary is now set (frozen snapshot)
        expect(sessionController.state.completionSummary, isNotNull);
        expect(sessionController.state.completionSummary?.selectedServiceName, 'Economy');
        expect(sessionController.state.completionSummary?.selectedPaymentMethodId, 'visa_4242');
      },
    );

    testWidgets(
      'clear_completion_summary_resets_snapshot',
      (WidgetTester tester) async {
        final sessionController = RideTripSessionController();
        final draftController = RideDraftController();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideTripSessionProvider.overrideWith(
                (ref) => sessionController,
              ),
              rideDraftProvider.overrideWith((ref) => draftController),
              simpleAuthStateProvider.overrideWith(
                (ref) => _FakeAuthController(),
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
              home: const AppShell(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Setup and complete a ride
        draftController.updateDestination('Airport');
        sessionController.startFromDraft(
          draftController.state,
          selectedOption: RideQuoteOption(
            id: 'xl',
            category: RideVehicleCategory.xl,
            displayName: 'XL',
            priceMinorUnits: 3500,
            currencyCode: 'SAR',
            etaMinutes: 3,
          ),
        );

        // Advance to completion
        sessionController.applyEvent(RideTripEvent.driverAccepted);
        sessionController.applyEvent(RideTripEvent.driverArrived);
        sessionController.applyEvent(RideTripEvent.startTrip);
        sessionController.completeTrip();

        // Verify completionSummary is set
        expect(sessionController.state.completionSummary, isNotNull);
        expect(sessionController.state.completionSummary?.selectedServiceName, 'XL');

        // Clear completion summary (simulates user pressing Done)
        sessionController.clearCompletionSummary();

        // Verify completionSummary is now null
        expect(sessionController.state.completionSummary, isNull);
      },
    );

    // =========================================================================
    // Test: Archive trip with extended parameters (Ticket #108)
    // =========================================================================
    testWidgets(
      'archive_trip_stores_full_ride_data_in_history',
      (WidgetTester tester) async {
        // Create real controllers to track state
        final sessionController = RideTripSessionController();
        final draftController = RideDraftController();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideTripSessionProvider.overrideWith(
                (ref) => sessionController,
              ),
              rideDraftProvider.overrideWith((ref) => draftController),
              simpleAuthStateProvider.overrideWith(
                (ref) => _FakeAuthController(),
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
              home: const AppShell(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Setup draft state
        draftController.updatePickupLabel('Home');
        draftController.updateDestination('Mall of Arabia');

        // Setup and complete a ride
        sessionController.startFromDraft(
          draftController.state,
          selectedOption: RideQuoteOption(
            id: 'premium',
            category: RideVehicleCategory.premium,
            displayName: 'Premium',
            priceMinorUnits: 8000,
            currencyCode: 'SAR',
            etaMinutes: 5,
          ),
        );

        // Advance to completion
        sessionController.applyEvent(RideTripEvent.driverAccepted);
        sessionController.applyEvent(RideTripEvent.driverArrived);
        sessionController.applyEvent(RideTripEvent.startTrip);
        sessionController.completeTrip();

        // Archive trip with extended data
        sessionController.archiveTrip(
          destinationLabel: 'Mall of Arabia',
          amountFormatted: 'SAR 80.00',
          serviceName: 'Premium',
          originLabel: 'Home',
          paymentMethodLabel: 'Visa ••4242',
        );

        // Verify historyTrips contains the archived ride with all data
        expect(sessionController.state.historyTrips, hasLength(1));
        final historyEntry = sessionController.state.historyTrips.first;
        expect(historyEntry.destinationLabel, 'Mall of Arabia');
        expect(historyEntry.amountFormatted, 'SAR 80.00');
        expect(historyEntry.serviceName, 'Premium');
        expect(historyEntry.originLabel, 'Home');
        expect(historyEntry.paymentMethodLabel, 'Visa ••4242');
        expect(historyEntry.trip.phase, RideTripPhase.completed);
      },
    );
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
  void rateCurrentTrip(int rating) {}

  // Track B - Ticket #108: Extended with serviceName, originLabel, paymentMethodLabel
  @override
  void archiveTrip({
    required String destinationLabel,
    String? amountFormatted,
    String? serviceName,
    String? originLabel,
    String? paymentMethodLabel,
  }) {
    final trip = state.activeTrip;
    if (trip == null || !trip.phase.isTerminal) return;
    final entry = RideHistoryEntry(
      trip: trip,
      destinationLabel: destinationLabel,
      completedAt: DateTime.now(),
      amountFormatted: amountFormatted,
      serviceName: serviceName,
      originLabel: originLabel,
      paymentMethodLabel: paymentMethodLabel,
    );
    state = state.copyWith(historyTrips: [entry, ...state.historyTrips]);
  }

  // Track B - Ticket #107
  @override
  bool completeTrip() {
    return true;
  }

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

  // Track B - Ticket #101
  @override
  void setPaymentMethodId(String? paymentMethodId) {}

  // Track B - Ticket #102
  @override
  void clearPaymentMethodId() {}
}

/// Fake AuthController for testing
class _FakeAuthController extends StateNotifier<AuthState>
    implements AuthController {
  _FakeAuthController() : super(const AuthState(isAuthenticated: false));

  @override
  void startPhoneSignIn(String phoneNumber) {
    state = AuthState(
      phoneNumber: phoneNumber,
      isVerifying: true,
      isAuthenticated: false,
    );
  }

  @override
  void verifyOtpCode(String code) {
    state = AuthState(
      isAuthenticated: true,
      isVerifying: false,
      phoneNumber: state.phoneNumber,
    );
  }

  @override
  void signOut() {
    state = const AuthState();
  }

  @override
  void cancelVerification() {
    state = const AuthState();
  }
}

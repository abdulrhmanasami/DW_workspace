/// Ride Flow Chaos Tests - Track B Ticket #97
/// Purpose: Chaos & Resilience testing for Ride flow
/// Created by: Track B - Ticket #97
/// Last updated: 2025-11-30
///
/// This test file focuses on chaos/failure scenarios in the ride flow:
/// 1. Pricing failures followed by retry success
/// 2. FSM resilience under abnormal conditions
/// 3. UI stability under error states
///
/// NOTE: Uses mock providers to simulate failure scenarios.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// App imports
import 'package:delivery_ways_clean/screens/mobility/ride_confirmation_screen.dart';
import 'package:delivery_ways_clean/screens/mobility/ride_active_trip_screen.dart';
import 'package:delivery_ways_clean/state/mobility/ride_trip_session.dart';
import 'package:delivery_ways_clean/state/mobility/ride_draft_state.dart';
import 'package:delivery_ways_clean/state/mobility/ride_quote_controller.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';

// Shims
import 'package:mobility_shims/mobility_shims.dart';

// Test support
import '../support/design_system_harness.dart';

void main() {
  setUpAll(() {
    ensureDesignSystemStubsForTests();
  });

  group('Ride Flow Chaos Tests (Ticket #97)', () {
    // =========================================================================
    // Test: ride_flow_pricing_fails_then_succeeds_on_retry_en
    // =========================================================================
    testWidgets(
      'ride_flow_pricing_fails_then_succeeds_on_retry_en',
      (WidgetTester tester) async {
        // Create controller that simulates: first call fails, second succeeds
        final chaosController = _ChaosRideQuoteController();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideDraftProvider.overrideWith((ref) {
                final controller = RideDraftController();
                controller.updateDestination('Airport Terminal 1');
                controller.updatePickupPlace(MobilityPlace(
                  label: 'Home',
                  location: LocationPoint(
                    latitude: 24.7136,
                    longitude: 46.6753,
                    accuracyMeters: 10,
                    timestamp: DateTime.now(),
                  ),
                ));
                controller.updateDestinationPlace(MobilityPlace(
                  label: 'Airport Terminal 1',
                  location: LocationPoint(
                    latitude: 24.7743,
                    longitude: 46.7386,
                    accuracyMeters: 10,
                    timestamp: DateTime.now(),
                  ),
                ));
                return controller;
              }),
              rideQuoteControllerProvider.overrideWith((ref) => chaosController),
              rideTripSessionProvider.overrideWith(
                  (ref) => RideTripSessionController()),
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
                '/ride/active': (context) => const RideActiveTripScreen(),
              },
              home: const RideConfirmationScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Step 1: Initially should show error (first call fails)
        expect(find.text("We couldn't load ride options"), findsOneWidget,
            reason: 'Initial pricing call should fail');
        expect(find.text('Retry'), findsOneWidget,
            reason: 'Retry button should be visible');

        // Step 2: Tap Retry button
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        // Step 3: After retry, should show success - vehicle options visible
        expect(find.text('Economy'), findsOneWidget,
            reason: 'Economy option should be visible after successful retry');
        expect(find.text('XL'), findsOneWidget,
            reason: 'XL option should be visible');

        // Error should be gone
        expect(find.text("We couldn't load ride options"), findsNothing,
            reason: 'Error message should disappear');

        // Step 4: Select Economy option (should be pre-selected as recommended)
        // Economy card should be selectable
        expect(find.text('Economy'), findsOneWidget);

        // Step 5: Verify Request Ride button is now enabled
        expect(find.text('Request Ride'), findsOneWidget,
            reason: 'Request Ride CTA should be visible');
      },
    );

    // =========================================================================
    // Test: pricing_error_state_persists_through_multiple_failures
    // =========================================================================
    testWidgets(
      'pricing_error_state_persists_through_multiple_failures',
      (WidgetTester tester) async {
        // Create controller that always fails
        final persistentFailController = _PersistentFailController();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideDraftProvider.overrideWith((ref) {
                final controller = RideDraftController();
                controller.updateDestination('Test Destination');
                return controller;
              }),
              rideQuoteControllerProvider
                  .overrideWith((ref) => persistentFailController),
              rideTripSessionProvider.overrideWith(
                  (ref) => RideTripSessionController()),
            ],
            child: MaterialApp(
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en')],
              home: const RideConfirmationScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Initial error state
        expect(find.text("We couldn't load ride options"), findsOneWidget);

        // Retry multiple times
        for (int i = 0; i < 5; i++) {
          await tester.tap(find.text('Retry'));
          await tester.pumpAndSettle();

          // Error should still be shown (exactly once, no duplicates)
          expect(find.text("We couldn't load ride options"), findsOneWidget,
              reason: 'Error should be shown exactly once after retry $i');
        }

        // Verify no crash and error state is stable
        expect(persistentFailController.failCount, equals(6),
            reason: '1 initial + 5 retries = 6 calls');
        expect(find.byType(RideConfirmationScreen), findsOneWidget,
            reason: 'Screen should not crash');
      },
    );

    // =========================================================================
    // Test: trip_confirmation_with_empty_quote_shows_empty_state
    // =========================================================================
    testWidgets(
      'trip_confirmation_with_empty_quote_shows_empty_state',
      (WidgetTester tester) async {
        // Create controller that returns empty state (no quote, no error)
        final emptyController = _EmptyQuoteController();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideDraftProvider.overrideWith((ref) {
                final controller = RideDraftController();
                controller.updateDestination('Some Place');
                return controller;
              }),
              rideQuoteControllerProvider
                  .overrideWith((ref) => emptyController),
              rideTripSessionProvider.overrideWith(
                  (ref) => RideTripSessionController()),
            ],
            child: MaterialApp(
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en')],
              home: const RideConfirmationScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify empty state is shown
        expect(find.text('No rides available'), findsOneWidget,
            reason: 'Empty state title should be shown');
        expect(find.text('Please try again in a few minutes.'), findsOneWidget,
            reason: 'Empty state subtitle should be shown');

        // Vehicle options should NOT be visible
        expect(find.text('Economy'), findsNothing);
        expect(find.text('XL'), findsNothing);
      },
    );

    // =========================================================================
    // Test: fsm_phase_stability_under_rapid_state_changes
    // =========================================================================
    testWidgets(
      'fsm_phase_stability_under_rapid_state_changes',
      (WidgetTester tester) async {
        // Create a trip that goes through rapid phase changes
        final rapidChangeController = _RapidPhaseChangeController();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideTripSessionProvider
                  .overrideWith((ref) => rapidChangeController),
              rideDraftProvider.overrideWith(
                (ref) => _FakeRideDraftController(
                    initialState: const RideDraftUiState(
                        destinationQuery: 'Test Destination')),
              ),
              rideQuoteControllerProvider.overrideWith(
                (ref) => _FakeRideQuoteController(
                    initialState: const RideQuoteUiState()),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('en'),
              routes: {
                '/ride/trip_summary': (context) => const Scaffold(
                      body: Center(child: Text('Trip Summary')),
                    ),
              },
              home: const RideActiveTripScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Initially shows findingDriver
        expect(find.text('Finding a driver…'), findsOneWidget);

        // Simulate rapid phase changes
        rapidChangeController.advanceToAccepted();
        await tester.pumpAndSettle();
        expect(find.text('Driver on the way'), findsOneWidget);

        rapidChangeController.advanceToArrived();
        await tester.pumpAndSettle();
        expect(find.text('Driver has arrived'), findsOneWidget);

        rapidChangeController.advanceToProgress();
        await tester.pumpAndSettle();
        expect(find.text('Trip in progress'), findsOneWidget);

        // Don't advance to completed as it triggers navigation
        // Test inProgress phase stability instead
        // No crash occurred throughout
        expect(find.byType(RideActiveTripScreen), findsOneWidget);
      },
    );

    // =========================================================================
    // Test: ar_chaos_flow_error_recovery
    // =========================================================================
    testWidgets(
      'ar_chaos_flow_error_recovery_with_arabic_locale',
      (WidgetTester tester) async {
        final chaosController = _ChaosRideQuoteController();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideDraftProvider.overrideWith((ref) {
                final controller = RideDraftController();
                controller.updateDestination('المطار');
                return controller;
              }),
              rideQuoteControllerProvider.overrideWith((ref) => chaosController),
              rideTripSessionProvider.overrideWith(
                  (ref) => RideTripSessionController()),
            ],
            child: const MaterialApp(
              locale: Locale('ar'),
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: [Locale('en'), Locale('ar'), Locale('de')],
              home: RideConfirmationScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Initial error in Arabic
        expect(find.text('تعذر تحميل خيارات الرحلة'), findsOneWidget);
        expect(find.text('إعادة المحاولة'), findsOneWidget);

        // Retry
        await tester.tap(find.text('إعادة المحاولة'));
        await tester.pumpAndSettle();

        // Success - vehicle options visible
        expect(find.text('Economy'), findsOneWidget);
      },
    );

    // =========================================================================
    // Test: de_chaos_flow_error_recovery
    // =========================================================================
    testWidgets(
      'de_chaos_flow_error_recovery_with_german_locale',
      (WidgetTester tester) async {
        final chaosController = _ChaosRideQuoteController();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideDraftProvider.overrideWith((ref) {
                final controller = RideDraftController();
                controller.updateDestination('Flughafen');
                return controller;
              }),
              rideQuoteControllerProvider.overrideWith((ref) => chaosController),
              rideTripSessionProvider.overrideWith(
                  (ref) => RideTripSessionController()),
            ],
            child: const MaterialApp(
              locale: Locale('de'),
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: [Locale('en'), Locale('ar'), Locale('de')],
              home: RideConfirmationScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Initial error in German
        expect(find.text('Fahrtoptionen konnten nicht geladen werden'), findsOneWidget);
        expect(find.text('Erneut versuchen'), findsOneWidget);

        // Retry
        await tester.tap(find.text('Erneut versuchen'));
        await tester.pumpAndSettle();

        // Success - vehicle options visible
        expect(find.text('Economy'), findsOneWidget);
      },
    );
  });
}

// ============================================================================
// Fake/Mock Controllers for Chaos Testing
// ============================================================================

/// Controller that simulates: first call fails, subsequent calls succeed.
/// Uses StateNotifier properly to trigger UI rebuilds.
class _ChaosRideQuoteController extends StateNotifier<RideQuoteUiState>
    implements RideQuoteController {
  _ChaosRideQuoteController()
      : super(const RideQuoteUiState(
          isLoading: false,
          errorMessage: 'Initial chaos failure',
        ));

  int _callCount = 0;

  @override
  Future<void> refreshFromDraft(RideDraftUiState draft) async {
    _callCount++;

    if (_callCount == 1) {
      // First call fails
      state = const RideQuoteUiState(
        isLoading: false,
        errorMessage: 'Chaos pricing service failure',
      );
    } else {
      // Subsequent calls succeed
      state = RideQuoteUiState(
        isLoading: false,
        quote: RideQuote(
          quoteId: 'chaos-success-quote',
          request: RideQuoteRequest(
            pickup: LocationPoint(
              latitude: 24.7136,
              longitude: 46.6753,
              accuracyMeters: 10,
              timestamp: DateTime.now(),
            ),
            dropoff: LocationPoint(
              latitude: 24.7743,
              longitude: 46.7386,
              accuracyMeters: 10,
              timestamp: DateTime.now(),
            ),
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
            ),
            RideQuoteOption(
              id: 'xl',
              category: RideVehicleCategory.xl,
              displayName: 'XL',
              etaMinutes: 7,
              priceMinorUnits: 2500,
              currencyCode: 'SAR',
            ),
          ],
        ),
      );
    }
  }

  @override
  void clear() {
    state = const RideQuoteUiState();
  }
}

/// Controller that always fails.
/// Uses StateNotifier properly to trigger UI rebuilds.
class _PersistentFailController extends StateNotifier<RideQuoteUiState>
    implements RideQuoteController {
  _PersistentFailController()
      : super(const RideQuoteUiState(
          isLoading: false,
          errorMessage: 'Persistent failure',
        ));

  int failCount = 0;

  @override
  Future<void> refreshFromDraft(RideDraftUiState draft) async {
    failCount++;
    state = const RideQuoteUiState(
      isLoading: false,
      errorMessage: 'Persistent failure',
    );
  }

  @override
  void clear() {
    state = const RideQuoteUiState();
  }
}

/// Controller that returns empty state (no quote, no error).
/// Uses StateNotifier properly to trigger UI rebuilds.
class _EmptyQuoteController extends StateNotifier<RideQuoteUiState>
    implements RideQuoteController {
  _EmptyQuoteController()
      : super(const RideQuoteUiState(
          isLoading: false,
          // No quote, no error = empty state
        ));

  @override
  Future<void> refreshFromDraft(RideDraftUiState draft) async {
    state = const RideQuoteUiState(isLoading: false);
  }

  @override
  void clear() {
    state = const RideQuoteUiState();
  }
}

/// Controller that allows programmatic phase changes for testing.
class _RapidPhaseChangeController extends StateNotifier<RideTripSessionUiState>
    implements RideTripSessionController {
  _RapidPhaseChangeController()
      : super(RideTripSessionUiState(
          activeTrip: RideTripState(
            tripId: 'rapid-test',
            phase: RideTripPhase.findingDriver,
          ),
        ));

  void advanceToAccepted() {
    state = RideTripSessionUiState(
      activeTrip: RideTripState(
        tripId: 'rapid-test',
        phase: RideTripPhase.driverAccepted,
      ),
    );
  }

  void advanceToArrived() {
    state = RideTripSessionUiState(
      activeTrip: RideTripState(
        tripId: 'rapid-test',
        phase: RideTripPhase.driverArrived,
      ),
    );
  }

  void advanceToProgress() {
    state = RideTripSessionUiState(
      activeTrip: RideTripState(
        tripId: 'rapid-test',
        phase: RideTripPhase.inProgress,
      ),
    );
  }

  void advanceToCompleted() {
    state = RideTripSessionUiState(
      activeTrip: RideTripState(
        tripId: 'rapid-test',
        phase: RideTripPhase.completed,
      ),
    );
  }

  @override
  void startFromDraft(RideDraftUiState draft) {}

  @override
  void applyEvent(RideTripEvent event) {}

  @override
  void clear() {
    state = const RideTripSessionUiState();
  }

  @override
  bool get hasActiveTrip => state.activeTrip != null;

  @override
  Future<bool> cancelActiveTrip() async => false;

  @override
  void rateCurrentTrip(int rating) {}

  @override
  void archiveTrip({required String destinationLabel, String? amountFormatted}) {}
}

/// Fake RideDraftController
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

/// Fake RideQuoteController
class _FakeRideQuoteController extends StateNotifier<RideQuoteUiState>
    implements RideQuoteController {
  _FakeRideQuoteController({required RideQuoteUiState initialState})
      : super(initialState);

  @override
  Future<void> refreshFromDraft(RideDraftUiState draft) async {}

  @override
  void clear() {}
}


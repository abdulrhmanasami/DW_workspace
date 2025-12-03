/// Ride Flow Chaos Tests - Track B Ticket #97
/// Purpose: Chaos & Resilience testing for Ride flow
/// Created by: Track B - Ticket #97
/// Updated by: Track B - Ticket #102 (Payment method lifecycle chaos tests)
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
                  (ref) => RideTripSessionController(ref)),
            ],
            // ignore: prefer_const_constructors
            child: MaterialApp(
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en')],
              routes: {
                '/ride/active': (context) => RideActiveTripScreen(),
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
                  (ref) => RideTripSessionController(ref)),
            ],
            // ignore: prefer_const_constructors
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
                  (ref) => RideTripSessionController(ref)),
            ],
            // ignore: prefer_const_constructors
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
            // ignore: prefer_const_constructors
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('en'),
              routes: {
                '/ride/trip_summary': (context) => const Scaffold(
                      body: Center(child: Text('Trip Summary')),
                    ),
              },
              home: RideActiveTripScreen(),
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
                  (ref) => RideTripSessionController(ref)),
            ],
            child: MaterialApp(
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
        expect(find.text('تعذّر تحميل خيارات الرحلة'), findsOneWidget);
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
                  (ref) => RideTripSessionController(ref)),
            ],
            child: MaterialApp(
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

    // =========================================================================
    // Track B - Ticket #197: Request failure chaos tests
    // =========================================================================

    testWidgets(
      'ride_request_fails_after_successful_quoting_shows_proper_error_en',
      (WidgetTester tester) async {
        // Create controller that succeeds on quoting but fails on trip request
        final requestFailingController = _RequestFailingTripController();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideDraftProvider.overrideWith((ref) {
                final controller = RideDraftController();
                controller.updateDestination('Airport Terminal');
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
                  label: 'Airport Terminal',
                  location: LocationPoint(
                    latitude: 24.7743,
                    longitude: 46.7386,
                    accuracyMeters: 10,
                    timestamp: DateTime.now(),
                  ),
                ));
                return controller;
              }),
              rideQuoteControllerProvider.overrideWith(
                  (ref) => _SuccessQuoteController()), // Quoting succeeds
              rideTripSessionProvider.overrideWith((ref) => requestFailingController),
            ],
            // ignore: prefer_const_constructors
            child: MaterialApp(
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en')],
              routes: {
                '/ride/active': (context) => RideActiveTripScreen(),
              },
              home: const RideConfirmationScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Step 1: Verify quoting succeeded and options are shown
        expect(find.text('Economy'), findsOneWidget,
            reason: 'Economy option should be visible after successful quoting');
        expect(find.text('Request Ride'), findsOneWidget,
            reason: 'Request Ride CTA should be visible');

        // Step 2: Select and request ride - should fail during request
        await tester.tap(find.text('Request Ride'));
        await tester.pumpAndSettle();

        // Step 3: Verify error handling - should navigate to active trip screen
        // and show failure state
        expect(find.byType(RideActiveTripScreen), findsOneWidget,
            reason: 'Should navigate to active trip screen');
        expect(find.text('Trip failed'), findsOneWidget,
            reason: 'Should show trip failed message');
        expect(find.text('No driver available'), findsOneWidget,
            reason: 'Should show specific failure reason');

        // Step 4: Verify user can retry or go back
        expect(find.text('Try again'), findsOneWidget,
            reason: 'Retry option should be available');
        expect(find.text('Back to home'), findsOneWidget,
            reason: 'Back to home option should be available');
      },
    );

    testWidgets(
      'ride_request_network_failure_shows_retry_option_ar',
      (WidgetTester tester) async {
        // Create controller that simulates network failure during request
        final networkFailureController = _NetworkFailureTripController();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideDraftProvider.overrideWith((ref) {
                final controller = RideDraftController();
                controller.updateDestination('المستشفى');
                return controller;
              }),
              rideQuoteControllerProvider.overrideWith(
                  (ref) => _SuccessQuoteController()),
              rideTripSessionProvider.overrideWith((ref) => networkFailureController),
            ],
            child: MaterialApp(
              locale: Locale('ar'),
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: [Locale('en'), Locale('ar'), Locale('de')],
              home: RideConfirmationScreen(),
              routes: {
                '/ride/active': (context) => RideActiveTripScreen(),
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Navigate to active trip screen to simulate failed request
        await tester.tap(find.text('Request Ride'));
        await tester.pumpAndSettle();

        // Verify Arabic error messages
        expect(find.text('فشل في الرحلة'), findsOneWidget,
            reason: 'Arabic trip failed message should be shown');
        expect(find.text('مشكلة في الشبكة'), findsOneWidget,
            reason: 'Arabic network error message should be shown');
        expect(find.text('حاول مرة أخرى'), findsOneWidget,
            reason: 'Arabic retry button should be available');
      },
    );

    testWidgets(
      'ride_request_timeout_shows_timeout_error_and_retry_flow',
      (WidgetTester tester) async {
        // Create controller that simulates timeout during driver search
        final timeoutController = _TimeoutFailureTripController();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideDraftProvider.overrideWith((ref) {
                final controller = RideDraftController();
                controller.updateDestination('Downtown');
                return controller;
              }),
              rideQuoteControllerProvider.overrideWith(
                  (ref) => _SuccessQuoteController()),
              rideTripSessionProvider.overrideWith((ref) => timeoutController),
            ],
            // ignore: prefer_const_constructors
            child: MaterialApp(
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en')],
              home: const RideConfirmationScreen(),
              routes: {
                '/ride/active': (context) => RideActiveTripScreen(),
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Request ride
        await tester.tap(find.text('Request Ride'));
        await tester.pumpAndSettle();

        // Verify timeout error is shown
        expect(find.text('Request timeout'), findsOneWidget,
            reason: 'Timeout error should be displayed');
        expect(find.text('Driver search took too long'), findsOneWidget,
            reason: 'Timeout explanation should be shown');

        // Test retry functionality
        await tester.tap(find.text('Try again'));
        await tester.pumpAndSettle();

        // Should attempt new request (controller tracks retry count)
        expect(timeoutController.retryCount, equals(2),
            reason: 'Retry should increment retry count to 2');
      },
    );

    // =========================================================================
    // Track B - Ticket #102: Payment method lifecycle chaos tests
    // =========================================================================

    testWidgets(
      'cancelled_ride_does_not_leak_paymentMethodId_into_new_draft',
      (WidgetTester tester) async {
        // Use a real controller to track state changes
        final draftController = RideDraftController();
        final sessionController = _CancellableRideTripSessionController();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideDraftProvider.overrideWith((ref) => draftController),
              rideQuoteControllerProvider.overrideWith(
                  (ref) => _SuccessQuoteController()),
              rideTripSessionProvider.overrideWith((ref) => sessionController),
            ],
            // ignore: prefer_const_constructors
            child: MaterialApp(
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en')],
              home: const RideConfirmationScreen(),
              routes: {
                '/ride/active': (context) => RideActiveTripScreen(),
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Step 1: First ride - set Card as payment method
        draftController.updateDestination('Airport');
        draftController.setPaymentMethodId('visa_4242');
        expect(draftController.state.paymentMethodId, 'visa_4242',
            reason: 'First ride should have Visa card set');

        // Step 2: Start the trip
        sessionController.simulateStartTrip();
        await tester.pumpAndSettle();

        // Step 3: Cancel the trip
        await sessionController.cancelActiveTrip();
        expect(sessionController.state.activeTrip?.phase, RideTripPhase.cancelled,
            reason: 'Trip should be cancelled');

        // Step 4: Clear draft (as would happen when user returns to home)
        draftController.clear();

        // Step 5: Verify no leakage
        expect(draftController.state.paymentMethodId, isNull,
            reason: 'After cancellation and clear, paymentMethodId should be null');

        // Step 6: Start a new ride and verify fresh state
        draftController.updateDestination('Mall');
        expect(draftController.state.paymentMethodId, isNull,
            reason: 'New ride should not have old paymentMethodId');

        // Step 7: Set new payment method (simulating user selection)
        draftController.setPaymentMethodId('cash');
        expect(draftController.state.paymentMethodId, 'cash',
            reason: 'New ride should use Cash (set fresh, not leaked Visa)');
      },
    );

    testWidgets(
      'completed_ride_clears_paymentMethodId_on_draft_reset',
      (WidgetTester tester) async {
        final draftController = RideDraftController();
        final sessionController = _CompletableRideTripSessionController();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideDraftProvider.overrideWith((ref) => draftController),
              rideQuoteControllerProvider.overrideWith(
                  (ref) => _SuccessQuoteController()),
              rideTripSessionProvider.overrideWith((ref) => sessionController),
            ],
            // ignore: prefer_const_constructors
            child: MaterialApp(
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en')],
              home: const RideConfirmationScreen(),
              routes: {
                '/ride/active': (context) => RideActiveTripScreen(),
                '/ride/trip_summary': (context) => const Scaffold(
                      body: Center(child: Text('Trip Summary')),
                    ),
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // First ride with premium payment
        draftController.updateDestination('Office');
        draftController.setPaymentMethodId('mastercard_5555');

        // Start and complete the trip
        sessionController.simulateStartTrip();
        await tester.pumpAndSettle();

        sessionController.completeTrip();
        await tester.pumpAndSettle();

        // Clear draft after completion
        draftController.clear();

        // Verify clean state
        expect(draftController.state.paymentMethodId, isNull,
            reason: 'After completion and clear, paymentMethodId should be null');
        expect(draftController.state.destinationQuery, '',
            reason: 'Destination should be reset');
      },
    );

    testWidgets(
      'clearPaymentMethodId_only_clears_payment_preserves_other_fields',
      (WidgetTester tester) async {
        final draftController = RideDraftController();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideDraftProvider.overrideWith((ref) => draftController),
              rideQuoteControllerProvider.overrideWith(
                  (ref) => _SuccessQuoteController()),
              rideTripSessionProvider.overrideWith(
                  (ref) => RideTripSessionController(ref)),
            ],
            // ignore: prefer_const_constructors
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

        // Set up full draft state
        draftController.updateDestination('Airport');
        draftController.updateSelectedOption('xl');
        draftController.setPaymentMethodId('visa_4242');

        // Verify initial state
        expect(draftController.state.destinationQuery, 'Airport');
        expect(draftController.state.selectedOptionId, 'xl');
        expect(draftController.state.paymentMethodId, 'visa_4242');

        // Clear only payment method
        draftController.clearPaymentMethodId();

        // Verify only paymentMethodId is cleared
        expect(draftController.state.paymentMethodId, isNull,
            reason: 'Only paymentMethodId should be cleared');
        expect(draftController.state.destinationQuery, 'Airport',
            reason: 'Destination should be preserved');
        expect(draftController.state.selectedOptionId, 'xl',
            reason: 'Selected option should be preserved');
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
          error: RideQuoteError.pricingFailed('Initial chaos failure'),
        ));

  int _callCount = 0;

  @override
  Future<void> refreshFromDraft(RideDraftUiState draft) async {
    _callCount++;

    if (_callCount == 1) {
      // First call fails
      state = const RideQuoteUiState(
        isLoading: false,
        error: RideQuoteError.pricingFailed('Chaos pricing service failure'),
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
  Future<void> retryFromDraft(RideDraftUiState draft) async {
    await refreshFromDraft(draft);
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
          error: RideQuoteError.pricingFailed('Persistent failure'),
        ));

  int failCount = 0;

  @override
  Future<void> refreshFromDraft(RideDraftUiState draft) async {
    failCount++;
    state = const RideQuoteUiState(
      isLoading: false,
      error: RideQuoteError.pricingFailed('Persistent failure'),
    );
  }

  @override
  Future<void> retryFromDraft(RideDraftUiState draft) async {
    await refreshFromDraft(draft);
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
  Future<void> retryFromDraft(RideDraftUiState draft) async {
    await refreshFromDraft(draft);
  }

  @override
  void clear() {
    state = const RideQuoteUiState();
  }
}

/// Fake Ref for testing
class _FakeRef implements Ref {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Controller that allows programmatic phase changes for testing.
class _RapidPhaseChangeController extends RideTripSessionController {
  _RapidPhaseChangeController()
      : super(_FakeRef()) {
    state = const RideTripSessionUiState(
      activeTrip: RideTripState(
        tripId: 'rapid-test',
        phase: RideTripPhase.findingDriver,
      ),
    );
  }

  void advanceToAccepted() {
    state = const RideTripSessionUiState(
      activeTrip: RideTripState(
        tripId: 'rapid-test',
        phase: RideTripPhase.driverAccepted,
      ),
    );
  }

  void advanceToArrived() {
    state = const RideTripSessionUiState(
      activeTrip: RideTripState(
        tripId: 'rapid-test',
        phase: RideTripPhase.driverArrived,
      ),
    );
  }

  void advanceToProgress() {
    state = const RideTripSessionUiState(
      activeTrip: RideTripState(
        tripId: 'rapid-test',
        phase: RideTripPhase.inProgress,
      ),
    );
  }

  void advanceToCompleted() {
    state = const RideTripSessionUiState(
      activeTrip: RideTripState(
        tripId: 'rapid-test',
        phase: RideTripPhase.completed,
      ),
    );
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
  bool get hasActiveTrip => state.activeTrip != null;

  @override
  Future<bool> cancelActiveTrip() async => false;

  @override
  void rateCurrentTrip(int rating) {}

  @override
  // Track B - Ticket #108: Extended with serviceName, originLabel, paymentMethodLabel
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
  void clearCompletionSummary() {}
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

  // Track B - Ticket #101
  @override
  void setPaymentMethodId(String? paymentMethodId) {}

  // Track B - Ticket #102
  @override
  void clearPaymentMethodId() {}
}

/// Fake RideQuoteController
class _FakeRideQuoteController extends StateNotifier<RideQuoteUiState>
    implements RideQuoteController {
  _FakeRideQuoteController({required RideQuoteUiState initialState})
      : super(initialState);

  @override
  Future<void> refreshFromDraft(RideDraftUiState draft) async {}

  @override
  Future<void> retryFromDraft(RideDraftUiState draft) async {}

  @override
  void clear() {}
}

// ============================================================================
// Track B - Ticket #102: Additional Controllers for Payment Lifecycle Tests
// ============================================================================

/// Controller that always returns success quote
class _SuccessQuoteController extends StateNotifier<RideQuoteUiState>
    implements RideQuoteController {
  _SuccessQuoteController()
      : super(RideQuoteUiState(
          isLoading: false,
          quote: RideQuote(
            quoteId: 'success-quote',
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
            ],
          ),
        ));

  @override
  Future<void> refreshFromDraft(RideDraftUiState draft) async {}

  @override
  Future<void> retryFromDraft(RideDraftUiState draft) async {}

  @override
  void clear() {}
}

/// Controller that can simulate trip cancellation
class _CancellableRideTripSessionController extends RideTripSessionController {
  _CancellableRideTripSessionController()
      : super(_FakeRef()) {
    state = const RideTripSessionUiState();
  }

  void simulateStartTrip() {
    state = const RideTripSessionUiState(
      activeTrip: RideTripState(
        tripId: 'cancellable-test',
        phase: RideTripPhase.findingDriver,
      ),
    );
  }

  @override
  void startFromDraft(RideDraftUiState draft, {RideQuoteOption? selectedOption}) {
    simulateStartTrip();
  }

  @override
  void applyEvent(RideTripEvent event) {}

  @override
  void clear() {
    state = const RideTripSessionUiState();
  }

  @override
  bool get hasActiveTrip => state.activeTrip != null;

  @override
  Future<bool> cancelActiveTrip() async {
    if (state.activeTrip == null) return false;
    state = RideTripSessionUiState(
      activeTrip: RideTripState(
        tripId: state.activeTrip!.tripId,
        phase: RideTripPhase.cancelled,
      ),
    );
    return true;
  }

  @override
  void rateCurrentTrip(int rating) {}

  @override
  // Track B - Ticket #108: Extended with serviceName, originLabel, paymentMethodLabel
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
  void clearCompletionSummary() {}
}

/// Controller that can simulate trip completion
class _CompletableRideTripSessionController extends RideTripSessionController {
  _CompletableRideTripSessionController()
      : super(_FakeRef()) {
    state = const RideTripSessionUiState();
  }

  void simulateStartTrip() {
    state = const RideTripSessionUiState(
      activeTrip: RideTripState(
        tripId: 'completable-test',
        phase: RideTripPhase.inProgress,
      ),
    );
  }

  // Track B - Ticket #107: Changed signature to match interface
  @override
  bool completeTrip() {
    if (state.activeTrip == null) return false;
    state = RideTripSessionUiState(
      activeTrip: RideTripState(
        tripId: state.activeTrip!.tripId,
        phase: RideTripPhase.completed,
      ),
    );
    return true;
  }

  @override
  void startFromDraft(RideDraftUiState draft, {RideQuoteOption? selectedOption}) {
    simulateStartTrip();
  }

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
  // Track B - Ticket #108: Extended with serviceName, originLabel, paymentMethodLabel
  void archiveTrip({
    required String destinationLabel,
    String? amountFormatted,
    String? serviceName,
    String? originLabel,
    String? paymentMethodLabel,
  }) {}

  @override
  void clearCompletionSummary() {}
}


// ============================================================================
// Track B - Ticket #197: Request Failure Controllers for Chaos Tests
// ============================================================================

/// Controller that fails during ride request (after successful quoting)
class _RequestFailingTripController extends RideTripSessionController {
  _RequestFailingTripController()
      : super(_FakeRef()) {
    state = const RideTripSessionUiState();
  }

  @override
  void startFromDraft(RideDraftUiState draft, {RideQuoteOption? selectedOption}) {
    // Simulate successful quoting -> requesting -> findingDriver
    final tripId = "failed-request-${DateTime.now().microsecondsSinceEpoch}";
    var tripState = RideTripState(
      tripId: tripId,
      phase: RideTripPhase.findingDriver,
    );

    // Immediately fail the request (simulates no drivers available)
    tripState = applyRideTripEvent(tripState, RideTripEvent.fail);

    state = RideTripSessionUiState(
      activeTrip: tripState,
      tripSummary: RideTripSummary(
        selectedServiceId: selectedOption?.id ?? "economy",
        selectedServiceName: selectedOption?.displayName ?? "Economy",
        fareDisplayText: selectedOption?.formattedPrice ?? "SAR 18.00",
        etaMinutes: selectedOption?.etaMinutes ?? 5,
      ),
      draftSnapshot: draft,
    );
  }

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
  void archiveTrip({
    required String destinationLabel,
    String? amountFormatted,
    String? serviceName,
    String? originLabel,
    String? paymentMethodLabel,
  }) {}

  @override
  bool completeTrip() => true;

  @override
  void clearCompletionSummary() {}
}

/// Controller that simulates network failure during ride request
class _NetworkFailureTripController extends RideTripSessionController {
  _NetworkFailureTripController()
      : super(_FakeRef()) {
    state = const RideTripSessionUiState();
  }

  @override
  void startFromDraft(RideDraftUiState draft, {RideQuoteOption? selectedOption}) {
    // Simulate network failure during request
    final tripId = "network-failed-${DateTime.now().microsecondsSinceEpoch}";
    final tripState = RideTripState(
      tripId: tripId,
      phase: RideTripPhase.failed, // Immediately failed
    );

    state = RideTripSessionUiState(
      activeTrip: tripState,
      tripSummary: RideTripSummary(
        selectedServiceId: "economy",
        selectedServiceName: "Economy",
        fareDisplayText: "SAR 18.00",
        etaMinutes: 5,
      ),
      draftSnapshot: draft,
    );
  }

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
  void archiveTrip({
    required String destinationLabel,
    String? amountFormatted,
    String? serviceName,
    String? originLabel,
    String? paymentMethodLabel,
  }) {}

  @override
  bool completeTrip() => true;

  @override
  void clearCompletionSummary() {}
}

/// Controller that simulates timeout during driver search
class _TimeoutFailureTripController extends RideTripSessionController {
  _TimeoutFailureTripController()
      : super(_FakeRef()) {
    state = const RideTripSessionUiState();
  }

  int retryCount = 0;

  @override
  void startFromDraft(RideDraftUiState draft, {RideQuoteOption? selectedOption}) {
    retryCount++;
    // Simulate timeout failure
    final tripId = "timeout-failed-${DateTime.now().microsecondsSinceEpoch}";
    final tripState = RideTripState(
      tripId: tripId,
      phase: RideTripPhase.failed,
    );

    state = RideTripSessionUiState(
      activeTrip: tripState,
      tripSummary: RideTripSummary(
        selectedServiceId: "economy",
        selectedServiceName: "Economy",
        fareDisplayText: "SAR 18.00",
        etaMinutes: 5,
      ),
      draftSnapshot: draft,
    );
  }

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
  void archiveTrip({
    required String destinationLabel,
    String? amountFormatted,
    String? serviceName,
    String? originLabel,
    String? paymentMethodLabel,
  }) {}

  @override
  bool completeTrip() => true;

  @override
  void clearCompletionSummary() {}
}

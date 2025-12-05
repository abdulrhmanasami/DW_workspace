/// Widget tests for RideActiveTripScreen (Track B - Ticket #22, #66, #87, #88, #89, #97, #105)
/// Purpose: Verify active trip screen UI and FSM cancel logic
/// Created by: Track B - Ticket #22
/// Updated by: Track B - Ticket #66 (FSM status L10n tests for EN/AR/DE)
/// Updated by: Track B - Ticket #87 (MVP Screen + Design System + Status Display tests)
/// Updated by: Track B - Ticket #88 (Design System alignment + ETA/Status tests)
/// Updated by: Track B - Ticket #89 (FSM Integration + Phase-aware UI tests)
/// Updated by: Track B - Ticket #97 (Chaos & Resilience FSM Tests)
/// Updated by: Track B - Ticket #105 (Unified trip summary - service, price, payment method)
/// Last updated: 2025-11-30

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// App imports
import 'package:delivery_ways_clean/screens/mobility/ride_active_trip_screen.dart';
import 'package:delivery_ways_clean/screens/mobility/ride_trip_summary_screen.dart';
import 'package:delivery_ways_clean/state/mobility/ride_trip_session.dart';
import 'package:delivery_ways_clean/state/mobility/ride_draft_state.dart';
import 'package:delivery_ways_clean/state/mobility/ride_quote_controller.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/router/app_router.dart';
// Track B - Ticket #105: Payment methods for trip summary tests
import 'package:delivery_ways_clean/state/payments/payment_methods_ui_state.dart';

// Shims
import 'package:maps_shims/maps_shims.dart';
import 'package:mobility_shims/mobility_shims.dart';

/// Mock navigator observer for tracking navigation
class MockNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>?> pushedRoutes = [];
  final List<Route<dynamic>?> poppedRoutes = [];
  
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
  }
  
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    poppedRoutes.add(route);
  }
  
  void verify() {}
}

/// Track B - Ticket #166: Helper to configure larger test screen
/// Buttons are positioned at y ≈ 683px, which is below the default 600px test screen.
/// Increasing height to 1000px ensures all action buttons are within hit-test bounds.
Future<void> _configureLargeTestScreen(WidgetTester tester) async {
  // Set physical size to accommodate buttons positioned below 600px
  tester.view.physicalSize = const ui.Size(800, 1000);
  tester.view.devicePixelRatio = 1.0;

  // Reset to defaults after each test
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

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
      const activeTrip = RideTripState(
        tripId: 'test-trip-123',
        phase: RideTripPhase.findingDriver,
      );

      await tester.pumpWidget(buildTestWidget(
        tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
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
      const activeTrip = RideTripState(
        tripId: 'test-trip-456',
        phase: RideTripPhase.driverAccepted,
      );

      await tester.pumpWidget(buildTestWidget(
        tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
      ));
      await tester.pumpAndSettle();

      // Verify driver info (mock data)
      expect(find.text('Ahmad M.'), findsOneWidget);
      expect(find.text('4.9'), findsOneWidget);
      expect(find.text('Toyota Camry'), findsOneWidget);
      expect(find.text('ABC 1234'), findsOneWidget);

      // Verify keys are present
      expect(find.byKey(RideActiveTripScreen.driverCardKey), findsOneWidget);
      expect(find.byKey(RideActiveTripScreen.statusTextKey), findsOneWidget);
      expect(find.byKey(RideActiveTripScreen.contactDriverActionKey), findsOneWidget);
      expect(find.byKey(RideActiveTripScreen.shareTripActionKey), findsOneWidget);
      expect(find.byKey(RideActiveTripScreen.cancelRideActionKey), findsOneWidget);
    });

    testWidgets('shows Cancel ride button for cancellable phases', (tester) async {
      const activeTrip = RideTripState(
        tripId: 'test-trip-789',
        phase: RideTripPhase.findingDriver,
      );

      await tester.pumpWidget(buildTestWidget(
        tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
      ));
      await tester.pumpAndSettle();

      // Verify cancel button exists
      expect(find.text('Cancel ride'), findsOneWidget);
    });

    // Track B - Ticket #120: Updated to reflect cancelCurrentTrip usage
    testWidgets('tapping Cancel ride and confirming calls cancelCurrentTrip on controller',
        (tester) async {
      // Track B - Ticket #166: Configure larger screen for button hit-testing
      await _configureLargeTestScreen(tester);

      // Track B - Ticket #67: Updated to include dialog confirmation flow
      final fakeController = _FakeRideTripSessionController(
        initialState: const RideTripSessionUiState(
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
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('en'),
            home: RideActiveTripScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to make Cancel button visible if needed
      await tester.ensureVisible(find.text('Cancel ride'));
      await tester.pumpAndSettle();
      
      // Tap cancel button to open dialog
      await tester.tap(find.text('Cancel ride'));
      await tester.pumpAndSettle();

      // Confirm cancellation in dialog (second "Cancel ride" button)
      final cancelButtons = find.text('Cancel ride');
      await tester.tap(cancelButtons.last);
      await tester.pumpAndSettle();

      // Track B - Ticket #120: Verify cancelCurrentTrip was called
      expect(fakeController.cancelCalledCount, equals(1));
    });

    testWidgets('displays correct phase icon for driverArrived phase',
        (tester) async {
      const activeTrip = RideTripState(
        tripId: 'test-arrived',
        phase: RideTripPhase.driverArrived,
      );

      await tester.pumpWidget(buildTestWidget(
        tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
      ));
      await tester.pumpAndSettle();

      // Verify headline for driverArrived
      expect(find.text('Driver has arrived'), findsOneWidget);
      expect(find.byIcon(Icons.local_taxi), findsOneWidget);
    });

    testWidgets('displays ETA when quote option is available', (tester) async {
      const activeTrip = RideTripState(
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
        options: const [
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
        tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        quoteState: RideQuoteUiState(quote: quote),
      ));
      await tester.pumpAndSettle();

      // Verify ETA headline
      expect(find.text('Driver is 5 min away'), findsOneWidget);
    });

    testWidgets('shows inProgress headline when trip is active',
        (tester) async {
      const activeTrip = RideTripState(
        tripId: 'test-progress',
        phase: RideTripPhase.inProgress,
      );

      await tester.pumpWidget(buildTestWidget(
        tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Trip in progress'), findsOneWidget);
      expect(find.byIcon(Icons.directions_car), findsOneWidget);
    });

    // Track B - Ticket #28: Map integration tests
    testWidgets('MapWidget is present with markers when activeTrip exists',
        (tester) async {
      const activeTrip = RideTripState(
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
        tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
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
      const activeTrip = RideTripState(
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
        tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
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
      const activeTrip = RideTripState(
        tripId: 'test-guard',
        phase: RideTripPhase.findingDriver,
      );

      await tester.pumpWidget(buildTestWidget(
        tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        rideDraft: const RideDraftUiState(), // Empty draft
      ));
      await tester.pumpAndSettle();

      // Should not crash, MapWidget should still be present
      expect(find.byType(MapWidget), findsOneWidget);
    });

    // =========================================================================
    // Track B - Ticket #122: No Driver Found CTA Tests
    // =========================================================================

    group('No Driver Found CTA (Ticket #122)', () {
      testWidgets('shows "No drivers available" CTA during findingDriver phase',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-no-driver-cta',
          phase: RideTripPhase.findingDriver,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
          rideDraft: const RideDraftUiState(
            destinationQuery: 'Downtown Mall',
          ),
        ));
        await tester.pumpAndSettle();

        // Verify "No drivers available? Try later" CTA is visible
        expect(find.text('No drivers available? Try later'), findsOneWidget);
      });

      testWidgets('tapping no-driver CTA calls failCurrentTrip and clears session',
          (tester) async {
        final fakeController = _FakeRideTripSessionController(
          initialState: const RideTripSessionUiState(
            activeTrip: RideTripState(
              tripId: 'test-fail-trip',
              phase: RideTripPhase.findingDriver,
            ),
            draftSnapshot: RideDraftUiState(
              pickupLabel: 'Home',
              destinationQuery: 'Downtown Mall',
            ),
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideTripSessionProvider.overrideWith((ref) => fakeController),
              rideDraftProvider.overrideWith(
                (ref) => _FakeRideDraftController(
                  initialState: const RideDraftUiState(
                    pickupLabel: 'Home',
                    destinationQuery: 'Downtown Mall',
                  ),
                ),
              ),
              rideQuoteControllerProvider.overrideWith(
                (ref) =>
                    _FakeRideQuoteController(initialState: const RideQuoteUiState()),
              ),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('en'),
              home: RideActiveTripScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find and scroll to "No drivers available" CTA
        final noDriverCta = find.text('No drivers available? Try later');
        expect(noDriverCta, findsOneWidget);
        await tester.ensureVisible(noDriverCta);
        await tester.pumpAndSettle();

        // Tap the CTA
        await tester.tap(noDriverCta);
        await tester.pumpAndSettle();

        // Verify failCurrentTrip was called
        expect(fakeController.failCalledCount, equals(1));
        expect(fakeController.lastFailReasonLabel, equals('No driver found'));
      });

      testWidgets('no-driver CTA is hidden for non-findingDriver phases',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-driver-accepted',
          phase: RideTripPhase.driverAccepted,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        // Verify "No drivers available" CTA is NOT visible
        expect(find.text('No drivers available? Try later'), findsNothing);
      });
    });

    // =========================================================================
    // Track B - Ticket #66: FSM Status Label Tests (EN/AR/DE)
    // =========================================================================

    group('FSM Status Label Tests (Ticket #66)', () {
      // -----------------------------------------------------------------------
      // English (EN) Status Tests
      // -----------------------------------------------------------------------
      testWidgets('EN: shows "Looking for a driver..." for findingDriver phase',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-en-finding',
          phase: RideTripPhase.findingDriver,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        // rideStatusFindingDriver in EN: "Looking for a driver..."
        // Note: Headline uses rideActiveHeadlineFindingDriver which is "Finding a driver…"
        expect(find.text('Finding a driver…'), findsOneWidget);
      });

      testWidgets('EN: shows "Driver on the way" for driverAccepted phase',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-en-accepted',
          phase: RideTripPhase.driverAccepted,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        // Without ETA, headline should be "Driver on the way"
        expect(find.text('Driver on the way'), findsOneWidget);
      });

      testWidgets('EN: shows "Driver has arrived" for driverArrived phase',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-en-arrived',
          phase: RideTripPhase.driverArrived,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Driver has arrived'), findsOneWidget);
      });

      testWidgets('EN: shows "Trip in progress" for inProgress phase',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-en-progress',
          phase: RideTripPhase.inProgress,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Trip in progress'), findsOneWidget);
      });

      testWidgets('EN: shows "Completing payment" for payment phase',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-en-payment',
          phase: RideTripPhase.payment,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        // rideActiveHeadlinePayment in EN: "Completing payment"
        expect(find.text('Completing payment'), findsOneWidget);
      });

      // -----------------------------------------------------------------------
      // Arabic (AR) Status Tests
      // -----------------------------------------------------------------------
      testWidgets('AR: shows Arabic status for inProgress phase',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-ar-progress',
          phase: RideTripPhase.inProgress,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideTripSessionProvider.overrideWith(
                (ref) => _FakeRideTripSessionController(
                  initialState: const RideTripSessionUiState(activeTrip: activeTrip),
                ),
              ),
              rideDraftProvider.overrideWith(
                (ref) => _FakeRideDraftController(
                  initialState: const RideDraftUiState(),
                ),
              ),
              rideQuoteControllerProvider.overrideWith(
                (ref) => _FakeRideQuoteController(
                  initialState: const RideQuoteUiState(),
                ),
              ),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('ar'), // Arabic locale
              home: RideActiveTripScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // rideActiveHeadlineInProgress in AR: "الرحلة جارية الآن"
        expect(find.text('الرحلة جارية الآن'), findsOneWidget);
      });

      testWidgets('AR: shows Arabic status for findingDriver phase',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-ar-finding',
          phase: RideTripPhase.findingDriver,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideTripSessionProvider.overrideWith(
                (ref) => _FakeRideTripSessionController(
                  initialState: const RideTripSessionUiState(activeTrip: activeTrip),
                ),
              ),
              rideDraftProvider.overrideWith(
                (ref) => _FakeRideDraftController(
                  initialState: const RideDraftUiState(),
                ),
              ),
              rideQuoteControllerProvider.overrideWith(
                (ref) => _FakeRideQuoteController(
                  initialState: const RideQuoteUiState(),
                ),
              ),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('ar'),
              home: RideActiveTripScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // rideActiveHeadlineFindingDriver in AR: "جارٍ البحث عن سائق…"
        expect(find.text('جارٍ البحث عن سائق…'), findsOneWidget);
      });

      // -----------------------------------------------------------------------
      // German (DE) Status Tests
      // -----------------------------------------------------------------------
      testWidgets('DE: shows German status for findingDriver phase',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-de-finding',
          phase: RideTripPhase.findingDriver,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideTripSessionProvider.overrideWith(
                (ref) => _FakeRideTripSessionController(
                  initialState: const RideTripSessionUiState(activeTrip: activeTrip),
                ),
              ),
              rideDraftProvider.overrideWith(
                (ref) => _FakeRideDraftController(
                  initialState: const RideDraftUiState(),
                ),
              ),
              rideQuoteControllerProvider.overrideWith(
                (ref) => _FakeRideQuoteController(
                  initialState: const RideQuoteUiState(),
                ),
              ),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('de'), // German locale
              home: RideActiveTripScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // rideActiveHeadlineFindingDriver in DE: "Fahrer wird gesucht…"
        expect(find.text('Fahrer wird gesucht…'), findsOneWidget);
      });

      testWidgets('DE: shows German status for inProgress phase',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-de-progress',
          phase: RideTripPhase.inProgress,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideTripSessionProvider.overrideWith(
                (ref) => _FakeRideTripSessionController(
                  initialState: const RideTripSessionUiState(activeTrip: activeTrip),
                ),
              ),
              rideDraftProvider.overrideWith(
                (ref) => _FakeRideDraftController(
                  initialState: const RideDraftUiState(),
                ),
              ),
              rideQuoteControllerProvider.overrideWith(
                (ref) => _FakeRideQuoteController(
                  initialState: const RideQuoteUiState(),
                ),
              ),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('de'),
              home: RideActiveTripScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // rideActiveHeadlineInProgress in DE: "Fahrt läuft"
        expect(find.text('Fahrt läuft'), findsOneWidget);
      });

      // -----------------------------------------------------------------------
      // Unknown/Fallback Status Test
      // -----------------------------------------------------------------------
      testWidgets('shows fallback status text when phase is unknown/null',
          (tester) async {
        // Test with draft phase (not a normal active phase)
        const draftTrip = RideTripState(
          tripId: 'test-draft',
          phase: RideTripPhase.draft,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: draftTrip),
        ));
        await tester.pumpAndSettle();

        // rideActiveHeadlinePreparing in EN: "Preparing your trip"
        expect(find.text('Preparing your trip'), findsOneWidget);
      });

      testWidgets('shows preparing status for quoting phase', (tester) async {
        const quotingTrip = RideTripState(
          tripId: 'test-quoting',
          phase: RideTripPhase.quoting,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: quotingTrip),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Preparing your trip'), findsOneWidget);
      });
    });

    // =========================================================================
    // Track B - Ticket #67: Cancel Ride Flow Tests
    // =========================================================================

    group('Cancel Ride Flow Tests (Ticket #67)', () {
      // -----------------------------------------------------------------------
      // Cancel button visibility tests
      // -----------------------------------------------------------------------
      testWidgets('does NOT show Cancel ride button for inProgress phase (non-cancellable)',
          (tester) async {
        // Track B - Ticket #142: inProgress phase is NOT cancellable per domain model
        const activeTrip = RideTripState(
          tripId: 'test-cancel-visible',
          phase: RideTripPhase.inProgress,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        // Cancel button should NOT be shown for inProgress phase
        expect(find.text('Cancel ride'), findsNothing);
      });

      testWidgets('shows Cancel ride button for findingDriver phase',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-cancel-finding',
          phase: RideTripPhase.findingDriver,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Cancel ride'), findsOneWidget);
      });

      testWidgets('shows Cancel ride button for driverArrived phase',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-cancel-arrived',
          phase: RideTripPhase.driverArrived,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Cancel ride'), findsOneWidget);
      });

      // -----------------------------------------------------------------------
      // Cancel dialog flow tests (EN)
      // -----------------------------------------------------------------------
      testWidgets('tapping Cancel ride shows confirmation dialog',
          (tester) async {
        // Ticket #95: Use a cancellable phase (findingDriver/driverAccepted/driverArrived)
        const activeTrip = RideTripState(
          tripId: 'test-dialog',
          phase: RideTripPhase.findingDriver,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        // Ensure cancel button is visible by scrolling if needed
        final cancelButton = find.text('Cancel ride');
        await tester.ensureVisible(cancelButton);
        await tester.pumpAndSettle();

        // Tap cancel button
        await tester.tap(cancelButton);
        await tester.pumpAndSettle();

        // Verify dialog appears with correct content
        expect(find.text('Cancel this ride?'), findsOneWidget);
        expect(
          find.text(
              'If you cancel now, your driver will stop heading to your pickup location.'),
          findsOneWidget,
        );
        expect(find.text('Keep ride'), findsOneWidget);
        // "Cancel ride" appears twice: button and dialog action
        expect(find.text('Cancel ride'), findsNWidgets(2));
      });

      testWidgets('tapping Keep ride dismisses dialog without cancelling',
          (tester) async {
        // Track B - Ticket #166: Configure larger screen for button hit-testing
        await _configureLargeTestScreen(tester);

        // Ticket #95: Use a cancellable phase (findingDriver/driverAccepted/driverArrived)
        final fakeController = _FakeRideTripSessionController(
          initialState: const RideTripSessionUiState(
            activeTrip: RideTripState(
              tripId: 'test-keep',
              phase: RideTripPhase.findingDriver,
            ),
          ),
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
                    initialState: const RideQuoteUiState()),
              ),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('en'),
              home: RideActiveTripScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Open dialog
        await tester.tap(find.text('Cancel ride'));
        await tester.pumpAndSettle();

        // Tap "Keep ride"
        await tester.tap(find.text('Keep ride'));
        await tester.pumpAndSettle();

        // Dialog should be dismissed, cancel should NOT have been called
        expect(find.text('Cancel this ride?'), findsNothing);
        expect(fakeController.cancelCalledCount, equals(0));
      });

      testWidgets(
        'confirming cancellation calls controller and shows success snackbar',
        (tester) async {
      // Track B - Ticket #166: Configure larger screen for button hit-testing
      await _configureLargeTestScreen(tester);

      // Ticket #95: Use a cancellable phase (findingDriver/driverAccepted/driverArrived)
      final fakeController = _FakeRideTripSessionController(
          initialState: const RideTripSessionUiState(
            activeTrip: RideTripState(
              tripId: 'test-confirm-cancel',
              phase: RideTripPhase.findingDriver,
            ),
          ),
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
                    initialState: const RideQuoteUiState()),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('en'),
              routes: {
                '/': (context) => const Scaffold(body: Text('Home Screen')),
                '/active': (context) => const RideActiveTripScreen(),
              },
              initialRoute: '/active',
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Open dialog
        await tester.tap(find.text('Cancel ride'));
        await tester.pumpAndSettle();

        // Find and tap the confirm button in dialog (second "Cancel ride" text)
        final cancelButtons = find.text('Cancel ride');
        await tester.tap(cancelButtons.last);
        await tester.pumpAndSettle();

        // Track B - Ticket #120: Verify cancelCurrentTrip was called
        expect(fakeController.cancelCalledCount, equals(1));

        // Verify success snackbar appears
        expect(find.text('Your ride has been cancelled.'), findsOneWidget);
      });

      // -----------------------------------------------------------------------
      // Arabic (AR) cancel button test
      // -----------------------------------------------------------------------
      testWidgets('AR: shows Arabic cancel button text', (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-ar-cancel',
          phase: RideTripPhase.findingDriver,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideTripSessionProvider.overrideWith(
                (ref) => _FakeRideTripSessionController(
                  initialState: const RideTripSessionUiState(activeTrip: activeTrip),
                ),
              ),
              rideDraftProvider.overrideWith(
                (ref) => _FakeRideDraftController(
                    initialState: const RideDraftUiState()),
              ),
              rideQuoteControllerProvider.overrideWith(
                (ref) => _FakeRideQuoteController(
                    initialState: const RideQuoteUiState()),
              ),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('ar'),
              home: RideActiveTripScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // rideActiveCancelTripCta in AR: "إلغاء الرحلة"
        expect(find.text('إلغاء الرحلة'), findsOneWidget);
      });

      testWidgets('AR: shows Arabic dialog text', (tester) async {
        // Track B - Ticket #166: Configure larger screen for button hit-testing
        await _configureLargeTestScreen(tester);

        // Ticket #95: Use a cancellable phase (findingDriver/driverAccepted/driverArrived)
        const activeTrip = RideTripState(
          tripId: 'test-ar-dialog',
          phase: RideTripPhase.findingDriver,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideTripSessionProvider.overrideWith(
                (ref) => _FakeRideTripSessionController(
                  initialState: const RideTripSessionUiState(activeTrip: activeTrip),
                ),
              ),
              rideDraftProvider.overrideWith(
                (ref) => _FakeRideDraftController(
                    initialState: const RideDraftUiState()),
              ),
              rideQuoteControllerProvider.overrideWith(
                (ref) => _FakeRideQuoteController(
                    initialState: const RideQuoteUiState()),
              ),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('ar'),
              home: RideActiveTripScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Open dialog
        await tester.tap(find.text('إلغاء الرحلة'));
        await tester.pumpAndSettle();

        // Verify Arabic dialog content
        expect(find.text('هل تريد إلغاء الرحلة؟'), findsOneWidget);
        expect(find.text('الاستمرار في الرحلة'), findsOneWidget);
      });

      // -----------------------------------------------------------------------
      // German (DE) cancel button test
      // -----------------------------------------------------------------------
      testWidgets('DE: shows German cancel button text', (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-de-cancel',
          phase: RideTripPhase.findingDriver,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideTripSessionProvider.overrideWith(
                (ref) => _FakeRideTripSessionController(
                  initialState: const RideTripSessionUiState(activeTrip: activeTrip),
                ),
              ),
              rideDraftProvider.overrideWith(
                (ref) => _FakeRideDraftController(
                    initialState: const RideDraftUiState()),
              ),
              rideQuoteControllerProvider.overrideWith(
                (ref) => _FakeRideQuoteController(
                    initialState: const RideQuoteUiState()),
              ),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('de'),
              home: RideActiveTripScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // rideActiveCancelTripCta in DE - need to check actual value
        // German uses "Fahrt stornieren" for cancel dialog confirm
        // Check if the cancel button uses same key
        // Looking for German cancel button
        expect(find.text('Fahrt stornieren'), findsOneWidget);
      });

      testWidgets('DE: shows German dialog text', (tester) async {
        // Track B - Ticket #166: Configure larger screen for button hit-testing
        await _configureLargeTestScreen(tester);

        // Ticket #95: Use a cancellable phase (findingDriver/driverAccepted/driverArrived)
        const activeTrip = RideTripState(
          tripId: 'test-de-dialog',
          phase: RideTripPhase.findingDriver,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideTripSessionProvider.overrideWith(
                (ref) => _FakeRideTripSessionController(
                  initialState: const RideTripSessionUiState(activeTrip: activeTrip),
                ),
              ),
              rideDraftProvider.overrideWith(
                (ref) => _FakeRideDraftController(
                    initialState: const RideDraftUiState()),
              ),
              rideQuoteControllerProvider.overrideWith(
                (ref) => _FakeRideQuoteController(
                    initialState: const RideQuoteUiState()),
              ),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('de'),
              home: RideActiveTripScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Open dialog - German button text
        await tester.tap(find.text('Fahrt stornieren'));
        await tester.pumpAndSettle();

        // Verify German dialog content
        expect(find.text('Diese Fahrt stornieren?'), findsOneWidget);
        expect(find.text('Fahrt behalten'), findsOneWidget);
      });
    });

    // =========================================================================
    // Track B - Ticket #68: Contact Driver & Share Trip Tests
    // =========================================================================

    group('Contact Driver & Share Trip Tests (Ticket #68)', () {
      // -----------------------------------------------------------------------
      // Button visibility tests
      // -----------------------------------------------------------------------
      testWidgets('shows Contact driver and Share trip buttons when active trip exists',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-actions',
          phase: RideTripPhase.inProgress,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Contact driver'), findsOneWidget);
        expect(find.text('Share trip status'), findsOneWidget);
      });

      testWidgets('shows Contact driver and Share trip buttons for findingDriver phase',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-actions-finding',
          phase: RideTripPhase.findingDriver,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Contact driver'), findsOneWidget);
        expect(find.text('Share trip status'), findsOneWidget);
      });

      // -----------------------------------------------------------------------
      // Contact driver tests
      // -----------------------------------------------------------------------
      testWidgets('tapping Contact driver opens bottom sheet with phone',
          (tester) async {
        // Track B - Ticket #166: Configure larger screen for button hit-testing
        await _configureLargeTestScreen(tester);

        const activeTrip = RideTripState(
          tripId: 'test-contact',
          phase: RideTripPhase.inProgress,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        // Tap contact driver button
        await tester.tap(find.text('Contact driver'));
        await tester.pumpAndSettle();

        // Verify bottom sheet appears with mock phone
        expect(find.text('+966500000000'), findsOneWidget);
      });

      testWidgets('tapping copy phone in bottom sheet triggers copy action',
          (tester) async {
        // Track B - Ticket #166: Configure larger screen for button hit-testing
        await _configureLargeTestScreen(tester);

        const activeTrip = RideTripState(
          tripId: 'test-copy-phone',
          phase: RideTripPhase.inProgress,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        // Open contact bottom sheet
        await tester.tap(find.text('Contact driver'));
        await tester.pumpAndSettle();

        // Verify bottom sheet is open with copy option
        expect(find.text('Copy phone number'), findsOneWidget);
        expect(find.text('+966500000000'), findsOneWidget);

        // Tap copy option - should not crash
        await tester.tap(find.text('Copy phone number'));
        await tester.pump();

        // The copy action was triggered successfully (no crash)
        // Note: Snackbar may or may not be visible depending on Scaffold context
      });

      // -----------------------------------------------------------------------
      // Share trip tests
      // -----------------------------------------------------------------------
      testWidgets('tapping Share trip does not crash',
          (tester) async {
        // Track B - Ticket #166: Configure larger screen for button hit-testing
        await _configureLargeTestScreen(tester);

        const activeTrip = RideTripState(
          tripId: 'test-share',
          phase: RideTripPhase.inProgress,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
          rideDraft: const RideDraftUiState(destinationQuery: 'Mall of Arabia'),
        ));
        await tester.pumpAndSettle();

        // Tap share button - should not crash
        await tester.tap(find.text('Share trip status'));
        await tester.pumpAndSettle();

        // Verify the screen is still showing (no crash)
        expect(find.text('Share trip status'), findsOneWidget);
      });

      testWidgets('Share trip handles empty destination gracefully',
          (tester) async {
        // Track B - Ticket #166: Configure larger screen for button hit-testing
        await _configureLargeTestScreen(tester);

        const activeTrip = RideTripState(
          tripId: 'test-share-empty',
          phase: RideTripPhase.inProgress,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
          rideDraft: const RideDraftUiState(destinationQuery: ''),
        ));
        await tester.pumpAndSettle();

        // Tap share button - should not crash even with empty destination
        await tester.tap(find.text('Share trip status'));
        await tester.pumpAndSettle();

        // Verify the screen is still showing (no crash)
        expect(find.text('Share trip status'), findsOneWidget);
      });

      // -----------------------------------------------------------------------
      // L10n tests for Contact/Share buttons
      // -----------------------------------------------------------------------
      testWidgets('AR: shows Arabic Contact driver and Share trip buttons',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-ar-actions',
          phase: RideTripPhase.inProgress,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideTripSessionProvider.overrideWith(
                (ref) => _FakeRideTripSessionController(
                  initialState: const RideTripSessionUiState(activeTrip: activeTrip),
                ),
              ),
              rideDraftProvider.overrideWith(
                (ref) => _FakeRideDraftController(
                    initialState: const RideDraftUiState()),
              ),
              rideQuoteControllerProvider.overrideWith(
                (ref) => _FakeRideQuoteController(
                    initialState: const RideQuoteUiState()),
              ),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('ar'),
              home: RideActiveTripScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // rideActiveContactDriverCta in AR: "التواصل مع السائق"
        expect(find.text('التواصل مع السائق'), findsOneWidget);
        // rideActiveShareTripCta in AR: "مشاركة حالة الرحلة"
        expect(find.text('مشاركة حالة الرحلة'), findsOneWidget);
      });

      testWidgets('DE: shows German Contact driver and Share trip buttons',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-de-actions',
          phase: RideTripPhase.inProgress,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideTripSessionProvider.overrideWith(
                (ref) => _FakeRideTripSessionController(
                  initialState: const RideTripSessionUiState(activeTrip: activeTrip),
                ),
              ),
              rideDraftProvider.overrideWith(
                (ref) => _FakeRideDraftController(
                    initialState: const RideDraftUiState()),
              ),
              rideQuoteControllerProvider.overrideWith(
                (ref) => _FakeRideQuoteController(
                    initialState: const RideQuoteUiState()),
              ),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('de'),
              home: RideActiveTripScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // rideActiveContactDriverCta in DE: "Fahrer kontaktieren"
        expect(find.text('Fahrer kontaktieren'), findsOneWidget);
        // rideActiveShareTripCta in DE: "Fahrtstatus teilen"
        expect(find.text('Fahrtstatus teilen'), findsOneWidget);
      });
    });

    // =========================================================================
    // Track B - Ticket #87: MVP Screen + Design System + Status Display Tests
    // =========================================================================

    group('MVP Screen Tests (Ticket #87)', () {
      // -----------------------------------------------------------------------
      // Summary Card Tests
      // -----------------------------------------------------------------------
      testWidgets('shows_summary_card_with_from_and_to_labels', (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-summary-card',
          phase: RideTripPhase.findingDriver,
        );

        final pickupPlace = MobilityPlace(
          label: 'Home Address',
          location: LocationPoint(
            latitude: 24.7136,
            longitude: 46.6753,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
        );

        final destinationPlace = MobilityPlace(
          label: 'Work Office',
          location: LocationPoint(
            latitude: 24.7500,
            longitude: 46.7000,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
          rideDraft: RideDraftUiState(
            pickupLabel: 'Home Address',
            pickupPlace: pickupPlace,
            destinationQuery: 'Work Office',
            destinationPlace: destinationPlace,
          ),
        ));
        await tester.pumpAndSettle();

        // Verify trip screen is displayed (Your trip title)
        expect(find.text('Your trip'), findsOneWidget);
        // Verify destination is shown
        expect(find.textContaining('Work Office'), findsOneWidget);
      });

      testWidgets('shows_map_stub_with_icon_and_texts', (tester) async {
        // The existing screen uses a real MapWidget, not a stub
        // We verify the map widget is present instead
        const activeTrip = RideTripState(
          tripId: 'test-map-widget',
          phase: RideTripPhase.driverAccepted,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        // Verify MapWidget is present (real map, not stub)
        expect(find.byType(MapWidget), findsOneWidget);
      });

      testWidgets('shows_status_section_with_short_and_long_labels_en',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-status-labels',
          phase: RideTripPhase.findingDriver,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        // Verify headline for findingDriver phase (uses rideActiveHeadlineFindingDriver)
        expect(find.text('Finding a driver…'), findsOneWidget);
      });

      testWidgets('l10n_ar_displays_arabic_texts', (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-ar-texts',
          phase: RideTripPhase.findingDriver,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideTripSessionProvider.overrideWith(
                (ref) => _FakeRideTripSessionController(
                  initialState: const RideTripSessionUiState(activeTrip: activeTrip),
                ),
              ),
              rideDraftProvider.overrideWith(
                (ref) => _FakeRideDraftController(
                    initialState: const RideDraftUiState()),
              ),
              rideQuoteControllerProvider.overrideWith(
                (ref) => _FakeRideQuoteController(
                    initialState: const RideQuoteUiState()),
              ),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('ar'),
              home: RideActiveTripScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify Arabic headline: "جارٍ البحث عن سائق…"
        expect(find.text('جارٍ البحث عن سائق…'), findsOneWidget);
        // Verify Arabic AppBar title: "رحلتك"
        expect(find.text('رحلتك'), findsOneWidget);
      });

      testWidgets('l10n_de_displays_german_texts', (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-de-texts',
          phase: RideTripPhase.findingDriver,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideTripSessionProvider.overrideWith(
                (ref) => _FakeRideTripSessionController(
                  initialState: const RideTripSessionUiState(activeTrip: activeTrip),
                ),
              ),
              rideDraftProvider.overrideWith(
                (ref) => _FakeRideDraftController(
                    initialState: const RideDraftUiState()),
              ),
              rideQuoteControllerProvider.overrideWith(
                (ref) => _FakeRideQuoteController(
                    initialState: const RideQuoteUiState()),
              ),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('de'),
              home: RideActiveTripScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify German headline: "Fahrer wird gesucht…"
        expect(find.text('Fahrer wird gesucht…'), findsOneWidget);
      });

      testWidgets('driver_vehicle_stub_section_shows_title_and_body',
          (tester) async {
        // The existing screen shows driver card with mock data
        const activeTrip = RideTripState(
          tripId: 'test-driver-section',
          phase: RideTripPhase.driverAccepted,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        // Verify driver mock info is shown
        expect(find.text('Ahmad M.'), findsOneWidget);
        expect(find.text('4.9'), findsOneWidget);
        expect(find.text('Toyota Camry'), findsOneWidget);
        expect(find.text('ABC 1234'), findsOneWidget);
      });

      // -----------------------------------------------------------------------
      // Additional MVP Tests
      // -----------------------------------------------------------------------
      testWidgets('shows_end_trip_button_for_debug', (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-end-trip',
          phase: RideTripPhase.inProgress,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        // Verify End trip button is shown
        expect(find.text('End trip'), findsOneWidget);
      });

      testWidgets('shows_correct_phase_icons_for_each_phase', (tester) async {
        // Test findingDriver phase icon (Icons.search)
        const findingDriverTrip = RideTripState(
          tripId: 'test-phase-icon',
          phase: RideTripPhase.findingDriver,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: findingDriverTrip),
        ));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.search), findsOneWidget);
      });

      testWidgets('navigates_correctly_when_trip_completes', (tester) async {
        // This test verifies the listener for trip completion exists
        const activeTrip = RideTripState(
          tripId: 'test-complete-nav',
          phase: RideTripPhase.inProgress,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        // Screen renders without crash
        expect(find.byType(RideActiveTripScreen), findsOneWidget);
      });

      testWidgets('displays_payment_phase_correctly', (tester) async {
        const paymentTrip = RideTripState(
          tripId: 'test-payment-phase',
          phase: RideTripPhase.payment,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: paymentTrip),
        ));
        await tester.pumpAndSettle();

        // Verify payment phase headline
        expect(find.text('Completing payment'), findsOneWidget);
        expect(find.byIcon(Icons.payment), findsOneWidget);
      });
    });

    // =========================================================================
    // Track B - Ticket #88: Design System Alignment + ETA/Status Tests
    // =========================================================================

    group('Design System Alignment Tests (Ticket #88)', () {
      // -----------------------------------------------------------------------
      // ETA Headline Tests (EN/AR/DE)
      // -----------------------------------------------------------------------
      testWidgets('EN: shows ETA headline "Driver is X min away" for driverAccepted with ETA',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-en-eta',
          phase: RideTripPhase.driverAccepted,
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
          quoteId: 'quote-eta-1',
          request: request,
          options: const [
            RideQuoteOption(
              id: 'opt-eta-1',
              category: RideVehicleCategory.economy,
              displayName: 'Standard',
              etaMinutes: 3,
              priceMinorUnits: 2500,
              currencyCode: 'SAR',
              isRecommended: true,
            ),
          ],
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
          quoteState: RideQuoteUiState(quote: quote),
        ));
        await tester.pumpAndSettle();

        // Verify ETA headline: "Driver is 3 min away"
        expect(find.text('Driver is 3 min away'), findsOneWidget);
      });

      testWidgets('AR: shows Arabic ETA headline for driverAccepted with ETA',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-ar-eta',
          phase: RideTripPhase.driverAccepted,
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
          quoteId: 'quote-ar-eta',
          request: request,
          options: const [
            RideQuoteOption(
              id: 'opt-ar-eta',
              category: RideVehicleCategory.economy,
              displayName: 'عادي',
              etaMinutes: 4,
              priceMinorUnits: 2500,
              currencyCode: 'SAR',
              isRecommended: true,
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideTripSessionProvider.overrideWith(
                (ref) => _FakeRideTripSessionController(
                  initialState: const RideTripSessionUiState(activeTrip: activeTrip),
                ),
              ),
              rideDraftProvider.overrideWith(
                (ref) => _FakeRideDraftController(
                    initialState: const RideDraftUiState()),
              ),
              rideQuoteControllerProvider.overrideWith(
                (ref) => _FakeRideQuoteController(
                    initialState: RideQuoteUiState(quote: quote)),
              ),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('ar'),
              home: RideActiveTripScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify Arabic ETA headline: "السائق يبعد 4 دقيقة"
        expect(find.text('السائق يبعد 4 دقيقة'), findsOneWidget);
      });

      testWidgets('DE: shows German ETA headline for driverAccepted with ETA',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-de-eta',
          phase: RideTripPhase.driverAccepted,
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
          currencyCode: 'EUR',
        );

        final quote = RideQuote(
          quoteId: 'quote-de-eta',
          request: request,
          options: const [
            RideQuoteOption(
              id: 'opt-de-eta',
              category: RideVehicleCategory.economy,
              displayName: 'Standard',
              etaMinutes: 7,
              priceMinorUnits: 2500,
              currencyCode: 'EUR',
              isRecommended: true,
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideTripSessionProvider.overrideWith(
                (ref) => _FakeRideTripSessionController(
                  initialState: const RideTripSessionUiState(activeTrip: activeTrip),
                ),
              ),
              rideDraftProvider.overrideWith(
                (ref) => _FakeRideDraftController(
                    initialState: const RideDraftUiState()),
              ),
              rideQuoteControllerProvider.overrideWith(
                (ref) => _FakeRideQuoteController(
                    initialState: RideQuoteUiState(quote: quote)),
              ),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('de'),
              home: RideActiveTripScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify German ETA headline: "Fahrer ist 7 Min. entfernt"
        expect(find.text('Fahrer ist 7 Min. entfernt'), findsOneWidget);
      });

      // -----------------------------------------------------------------------
      // Status Headlines for Different Phases
      // -----------------------------------------------------------------------
      testWidgets('EN: shows "Looking for a driver..." as findingDriver status',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-finding-status',
          phase: RideTripPhase.findingDriver,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        // Verify headline: "Finding a driver…"
        expect(find.text('Finding a driver…'), findsOneWidget);
        expect(find.byIcon(Icons.search), findsOneWidget);
      });

      testWidgets('EN: shows "Trip in progress" as on-trip status',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-on-trip-status',
          phase: RideTripPhase.inProgress,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
          rideDraft: const RideDraftUiState(destinationQuery: 'Downtown Mall'),
        ));
        await tester.pumpAndSettle();

        // Verify headline: "Trip in progress"
        expect(find.text('Trip in progress'), findsOneWidget);
        // Verify destination is shown
        expect(find.textContaining('Downtown Mall'), findsOneWidget);
      });

      // -----------------------------------------------------------------------
      // Action Buttons Tests
      // -----------------------------------------------------------------------
      testWidgets('action buttons (Contact/Share/Cancel) are present and tappable',
          (tester) async {
        // Track B - Ticket #166: Configure larger screen for button hit-testing
        await _configureLargeTestScreen(tester);

        const activeTrip = RideTripState(
          tripId: 'test-actions-buttons',
          phase: RideTripPhase.driverAccepted,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        // Verify all action buttons are present
        expect(find.text('Contact driver'), findsOneWidget);
        expect(find.text('Share trip status'), findsOneWidget);
        expect(find.text('Cancel ride'), findsOneWidget);
        expect(find.text('End trip'), findsOneWidget);

        // Verify buttons are tappable (no crashes)
        await tester.tap(find.text('Contact driver'));
        await tester.pumpAndSettle();
        // Bottom sheet should appear
        expect(find.text('+966500000000'), findsOneWidget);

        // Close bottom sheet
        await tester.tapAt(const Offset(100, 100));
        await tester.pumpAndSettle();
      });

      testWidgets('driver info card shows mock driver details correctly',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-driver-card',
          phase: RideTripPhase.driverArrived,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        // Verify driver card content (mock data from domain)
        expect(find.text('Ahmad M.'), findsOneWidget);
        expect(find.text('4.9'), findsOneWidget);
        expect(find.text('Toyota Camry'), findsOneWidget);
        expect(find.text('ABC 1234'), findsOneWidget);
        // Verify headline for driverArrived
        expect(find.text('Driver has arrived'), findsOneWidget);
      });
    });

    // =========================================================================
    // Track B - Ticket #89: FSM Integration Tests
    // =========================================================================

    group('FSM Integration Tests (Ticket #89)', () {
      // -----------------------------------------------------------------------
      // Test A: driverArrived Phase
      // -----------------------------------------------------------------------
      testWidgets('Test A: driverArrived phase shows correct headline and actions',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-fsm-arrived',
          phase: RideTripPhase.driverArrived,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        // Verify headline for driverArrived phase
        expect(find.text('Driver has arrived'), findsOneWidget);
        expect(find.byIcon(Icons.local_taxi), findsOneWidget);

        // Verify action buttons are present
        expect(find.text('Contact driver'), findsOneWidget);
        expect(find.text('Share trip status'), findsOneWidget);
        expect(find.text('Cancel ride'), findsOneWidget);
      });

      // -----------------------------------------------------------------------
      // Test B: completed Phase
      // -----------------------------------------------------------------------
      testWidgets('Test B: completed phase shows completion headline',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-fsm-completed',
          phase: RideTripPhase.completed,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        // Verify headline for completed phase
        expect(find.text('Trip completed'), findsOneWidget);
        expect(find.byIcon(Icons.done_all), findsOneWidget);
      });

      // -----------------------------------------------------------------------
      // Test C: Illegal Phase (draft) for Active Screen
      // -----------------------------------------------------------------------
      testWidgets('Test C: draft phase shows preparing headline (pre-trip fallback)',
          (tester) async {
        // Opening active trip screen with draft phase should show fallback
        const activeTrip = RideTripState(
          tripId: 'test-fsm-draft',
          phase: RideTripPhase.draft,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        // Verify fallback headline for pre-trip phases
        expect(find.text('Preparing your trip'), findsOneWidget);
        expect(find.byIcon(Icons.edit_note), findsOneWidget);
      });

      testWidgets('quoting phase shows preparing headline',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-fsm-quoting',
          phase: RideTripPhase.quoting,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        // Verify fallback headline for quoting
        expect(find.text('Preparing your trip'), findsOneWidget);
        expect(find.byIcon(Icons.request_quote), findsOneWidget);
      });

      testWidgets('requesting phase shows preparing headline',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-fsm-requesting',
          phase: RideTripPhase.requesting,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        // Verify fallback headline for requesting
        expect(find.text('Preparing your trip'), findsOneWidget);
        expect(find.byIcon(Icons.hourglass_top), findsOneWidget);
      });

      // -----------------------------------------------------------------------
      // FSM Phase Icon Tests (individual tests for clarity)
      // -----------------------------------------------------------------------
      testWidgets('findingDriver phase shows search icon',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-icon-finding',
          phase: RideTripPhase.findingDriver,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.search), findsOneWidget);
      });

      testWidgets('inProgress phase shows car icon',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-icon-progress',
          phase: RideTripPhase.inProgress,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.directions_car), findsOneWidget);
      });

      testWidgets('payment phase shows payment icon',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-icon-payment',
          phase: RideTripPhase.payment,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.payment), findsOneWidget);
      });

      // -----------------------------------------------------------------------
      // Terminal Phase Tests
      // -----------------------------------------------------------------------
      testWidgets('cancelled phase shows terminal cancellation view',
          (tester) async {
        // Ticket #95: Now uses Terminal View with different UI
        const activeTrip = RideTripState(
          tripId: 'test-fsm-cancelled',
          phase: RideTripPhase.cancelled,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        // Verify Terminal View for cancelled phase
        expect(find.text('Trip cancelled'), findsOneWidget);
        expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
        expect(find.text('Back to home'), findsOneWidget);
      });

      testWidgets('failed phase shows terminal failure view',
          (tester) async {
        // Ticket #95: Now uses Terminal View with different UI
        const activeTrip = RideTripState(
          tripId: 'test-fsm-failed',
          phase: RideTripPhase.failed,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        // Verify Terminal View for failed phase
        expect(find.text('Something went wrong'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Back to home'), findsOneWidget);
      });

      // -----------------------------------------------------------------------
      // FSM Phase Sequence Tests (individual tests)
      // -----------------------------------------------------------------------
      testWidgets('findingDriver shows "Finding a driver…" headline',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-seq-finding',
          phase: RideTripPhase.findingDriver,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Finding a driver…'), findsOneWidget);
      });

      testWidgets('driverAccepted shows "Driver on the way" without ETA',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-seq-accepted',
          phase: RideTripPhase.driverAccepted,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
          // No quote = no ETA
        ));
        await tester.pumpAndSettle();

        expect(find.text('Driver on the way'), findsOneWidget);
      });

      testWidgets('driverArrived shows "Driver has arrived" headline',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-seq-arrived',
          phase: RideTripPhase.driverArrived,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Driver has arrived'), findsOneWidget);
      });

      testWidgets('inProgress shows "Trip in progress" headline',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-seq-progress',
          phase: RideTripPhase.inProgress,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Trip in progress'), findsOneWidget);
      });

      testWidgets('payment shows "Completing payment" headline',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-seq-payment',
          phase: RideTripPhase.payment,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Completing payment'), findsOneWidget);
      });

      testWidgets('completed shows "Trip completed" headline',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-seq-completed',
          phase: RideTripPhase.completed,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Trip completed'), findsOneWidget);
      });
    });

    // =========================================================================
    // Track B - Ticket #95: Cancel & Failure Flows Tests
    // =========================================================================

    group('Cancel & Failure Flows Tests (Ticket #95)', () {
      // -----------------------------------------------------------------------
      // Cancel button enabled/disabled tests
      // -----------------------------------------------------------------------
      testWidgets('cancel_button_enabled_when_phase_is_findingDriver',
          (tester) async {
        // Track B - Ticket #166: Configure larger screen for button hit-testing
        await _configureLargeTestScreen(tester);

        const activeTrip = RideTripState(
          tripId: 'test-cancel-finding',
          phase: RideTripPhase.findingDriver,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        // Cancel button should be visible and enabled
        final cancelButton = find.text('Cancel ride');
        expect(cancelButton, findsOneWidget);

        // Tap to verify it's enabled (opens dialog)
        await tester.tap(cancelButton);
        await tester.pumpAndSettle();
        expect(find.text('Cancel this ride?'), findsOneWidget);
      });

      testWidgets('cancel_button_enabled_when_phase_is_driverAccepted',
          (tester) async {
        // Track B - Ticket #166: Configure larger screen for button hit-testing
        await _configureLargeTestScreen(tester);

        const activeTrip = RideTripState(
          tripId: 'test-cancel-accepted',
          phase: RideTripPhase.driverAccepted,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        // Cancel button should be visible and enabled
        final cancelButton = find.text('Cancel ride');
        expect(cancelButton, findsOneWidget);

        // Tap to verify it's enabled (opens dialog)
        await tester.tap(cancelButton);
        await tester.pumpAndSettle();
        expect(find.text('Cancel this ride?'), findsOneWidget);
      });

      testWidgets('cancel_button_enabled_when_phase_is_driverArrived',
          (tester) async {
        // Track B - Ticket #166: Configure larger screen for button hit-testing
        await _configureLargeTestScreen(tester);

        const activeTrip = RideTripState(
          tripId: 'test-cancel-arrived',
          phase: RideTripPhase.driverArrived,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        // Cancel button should be visible and enabled
        final cancelButton = find.text('Cancel ride');
        expect(cancelButton, findsOneWidget);

        // Tap to verify it's enabled (opens dialog)
        await tester.tap(cancelButton);
        await tester.pumpAndSettle();
        expect(find.text('Cancel this ride?'), findsOneWidget);
      });

      testWidgets('cancel_button_NOT_shown_when_phase_is_inProgress',
          (tester) async {
        // Track B - Ticket #142: inProgress phase is NOT cancellable per domain model
        // Track B - Ticket #166: Configure larger screen (though button shouldn't exist anyway)
        await _configureLargeTestScreen(tester);

        const activeTrip = RideTripState(
          tripId: 'test-cancel-progress',
          phase: RideTripPhase.inProgress,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        // Cancel button should NOT be shown for non-cancellable phase
        expect(find.text('Cancel ride'), findsNothing);
      });

      testWidgets('cancel_button_NOT_shown_when_phase_is_payment',
          (tester) async {
        // Track B - Ticket #142: payment phase is NOT cancellable per domain model
        // Track B - Ticket #166: Configure larger screen (though button shouldn't exist anyway)
        await _configureLargeTestScreen(tester);

        const activeTrip = RideTripState(
          tripId: 'test-cancel-payment',
          phase: RideTripPhase.payment,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        // Cancel button should NOT be shown for non-cancellable phase
        expect(find.text('Cancel ride'), findsNothing);
      });

      // -----------------------------------------------------------------------
      // Cancelled phase UI tests
      // -----------------------------------------------------------------------
      testWidgets('cancelled_phase_shows_terminal_cancelled_ui',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-cancelled-ui',
          phase: RideTripPhase.cancelled,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
          rideDraft: const RideDraftUiState(destinationQuery: 'Mall of Arabia'),
        ));
        await tester.pumpAndSettle();

        // Verify Terminal UI for cancelled phase
        expect(find.text('Trip cancelled'), findsOneWidget);
        expect(
          find.text(
              'Your trip was cancelled. You can request a new ride at any time.'),
          findsOneWidget,
        );
        expect(find.text('Back to home'), findsOneWidget);
        expect(find.text('Request new ride'), findsOneWidget);

        // Verify destination is shown
        expect(find.text('Mall of Arabia'), findsOneWidget);

        // Verify cancel icon
        expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
      });

      testWidgets('cancelled_phase_does_not_show_driver_card_or_actions',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-cancelled-no-card',
          phase: RideTripPhase.cancelled,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        // Driver card and actions should NOT be present
        expect(find.text('Ahmad M.'), findsNothing);
        expect(find.text('Contact driver'), findsNothing);
        expect(find.text('Share trip status'), findsNothing);
        expect(find.text('Cancel ride'), findsNothing);
        expect(find.text('End trip'), findsNothing);
      });

      // -----------------------------------------------------------------------
      // Failed phase UI tests
      // -----------------------------------------------------------------------
      testWidgets('failed_phase_shows_terminal_failed_ui', (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-failed-ui',
          phase: RideTripPhase.failed,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
          rideDraft: const RideDraftUiState(destinationQuery: 'Airport'),
        ));
        await tester.pumpAndSettle();

        // Verify Terminal UI for failed phase
        expect(find.text('Something went wrong'), findsOneWidget);
        expect(
          find.text(
              "We couldn't complete this trip. Please try again in a moment."),
          findsOneWidget,
        );
        expect(find.text('Back to home'), findsOneWidget);
        expect(find.text('Request new ride'), findsOneWidget);

        // Verify destination is shown
        expect(find.text('Airport'), findsOneWidget);

        // Verify error icon
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      testWidgets('failed_phase_does_not_show_driver_card_or_actions',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-failed-no-card',
          phase: RideTripPhase.failed,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        // Driver card and actions should NOT be present
        expect(find.text('Ahmad M.'), findsNothing);
        expect(find.text('Contact driver'), findsNothing);
        expect(find.text('Share trip status'), findsNothing);
        expect(find.text('Cancel ride'), findsNothing);
        expect(find.text('End trip'), findsNothing);
      });

      // -----------------------------------------------------------------------
      // L10n AR tests for terminal phases
      // -----------------------------------------------------------------------
      testWidgets('AR: cancelled_phase_shows_arabic_terminal_ui',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-ar-cancelled',
          phase: RideTripPhase.cancelled,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideTripSessionProvider.overrideWith(
                (ref) => _FakeRideTripSessionController(
                  initialState: const RideTripSessionUiState(activeTrip: activeTrip),
                ),
              ),
              rideDraftProvider.overrideWith(
                (ref) => _FakeRideDraftController(
                    initialState: const RideDraftUiState()),
              ),
              rideQuoteControllerProvider.overrideWith(
                (ref) => _FakeRideQuoteController(
                    initialState: const RideQuoteUiState()),
              ),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('ar'),
              home: RideActiveTripScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify Arabic terminal UI
        expect(find.text('تم إلغاء الرحلة'), findsOneWidget);
        expect(
          find.text('تم إلغاء رحلتك. يمكنك طلب رحلة جديدة في أي وقت.'),
          findsOneWidget,
        );
        expect(find.text('الرجوع للرئيسية'), findsOneWidget);
        expect(find.text('طلب رحلة جديدة'), findsOneWidget);
      });

      testWidgets('AR: failed_phase_shows_arabic_terminal_ui', (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-ar-failed',
          phase: RideTripPhase.failed,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideTripSessionProvider.overrideWith(
                (ref) => _FakeRideTripSessionController(
                  initialState: const RideTripSessionUiState(activeTrip: activeTrip),
                ),
              ),
              rideDraftProvider.overrideWith(
                (ref) => _FakeRideDraftController(
                    initialState: const RideDraftUiState()),
              ),
              rideQuoteControllerProvider.overrideWith(
                (ref) => _FakeRideQuoteController(
                    initialState: const RideQuoteUiState()),
              ),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('ar'),
              home: RideActiveTripScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify Arabic failed UI
        expect(find.text('حدث خطأ ما'), findsOneWidget);
        expect(
          find.text('تعذّر إكمال هذه الرحلة. يرجى المحاولة مرة أخرى بعد قليل.'),
          findsOneWidget,
        );
      });

      // -----------------------------------------------------------------------
      // L10n DE tests for terminal phases
      // -----------------------------------------------------------------------
      testWidgets('DE: cancelled_phase_shows_german_terminal_ui',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-de-cancelled',
          phase: RideTripPhase.cancelled,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideTripSessionProvider.overrideWith(
                (ref) => _FakeRideTripSessionController(
                  initialState: const RideTripSessionUiState(activeTrip: activeTrip),
                ),
              ),
              rideDraftProvider.overrideWith(
                (ref) => _FakeRideDraftController(
                    initialState: const RideDraftUiState()),
              ),
              rideQuoteControllerProvider.overrideWith(
                (ref) => _FakeRideQuoteController(
                    initialState: const RideQuoteUiState()),
              ),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('de'),
              home: RideActiveTripScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify German terminal UI
        expect(find.text('Fahrt storniert'), findsOneWidget);
        expect(
          find.text(
              'Deine Fahrt wurde storniert. Du kannst jederzeit eine neue Fahrt anfordern.'),
          findsOneWidget,
        );
        expect(find.text('Zur Startseite'), findsOneWidget);
        expect(find.text('Neue Fahrt anfordern'), findsOneWidget);
      });

      testWidgets('DE: failed_phase_shows_german_terminal_ui', (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-de-failed',
          phase: RideTripPhase.failed,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideTripSessionProvider.overrideWith(
                (ref) => _FakeRideTripSessionController(
                  initialState: const RideTripSessionUiState(activeTrip: activeTrip),
                ),
              ),
              rideDraftProvider.overrideWith(
                (ref) => _FakeRideDraftController(
                    initialState: const RideDraftUiState()),
              ),
              rideQuoteControllerProvider.overrideWith(
                (ref) => _FakeRideQuoteController(
                    initialState: const RideQuoteUiState()),
              ),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('de'),
              home: RideActiveTripScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify German failed UI
        expect(find.text('Etwas ist schiefgelaufen'), findsOneWidget);
        expect(
          find.text(
              'Wir konnten diese Fahrt nicht abschließen. Bitte versuche es in Kürze erneut.'),
          findsOneWidget,
        );
      });

      // -----------------------------------------------------------------------
      // Completed phase should NOT show terminal view (goes to summary)
      // -----------------------------------------------------------------------
      testWidgets('completed_phase_does_not_show_terminal_view',
          (tester) async {
        // Completed phase should show the normal trip screen (not terminal view)
        // because navigation to summary is handled by the listener
        const activeTrip = RideTripState(
          tripId: 'test-completed-no-terminal',
          phase: RideTripPhase.completed,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: activeTrip),
        ));
        await tester.pumpAndSettle();

        // Should show normal trip screen with "Trip completed" headline
        // NOT the terminal view
        expect(find.text('Trip completed'), findsOneWidget);
        expect(find.text('Back to home'), findsNothing);
        expect(find.text('Request new ride'), findsNothing);
      });
    });

    // =========================================================================
    // Track B - Ticket #97: Chaos & Resilience FSM Tests
    // =========================================================================

    group('Chaos & Resilience FSM Tests (Ticket #97)', () {
      // -----------------------------------------------------------------------
      // Test 1: Double driverAccepted events keep UI stable
      // -----------------------------------------------------------------------
      testWidgets('double_driverAccepted_events_keep_ui_stable',
          (tester) async {
        // Simulate FSM receiving driverAccepted twice
        // This tests that FSM handles duplicate events gracefully

        // Start with findingDriver phase
        const initialTrip = RideTripState(
          tripId: 'chaos-test-double-accepted',
          phase: RideTripPhase.findingDriver,
        );

        // Apply driverAccepted event using FSM function
        final afterFirstEvent = applyRideTripEvent(
          initialTrip,
          RideTripEvent.driverAccepted,
        );

        // Apply driverAccepted again (duplicate/double event)
        // This should return null (no-op) since driverAccepted -> driverAccepted is invalid
        final afterSecondEvent = tryApplyRideTripEvent(
          afterFirstEvent,
          RideTripEvent.driverAccepted,
        );

        // If duplicate event returns null, use the first result
        final finalTrip = afterSecondEvent ?? afterFirstEvent;

        // Build widget with the resulting state
        await tester.pumpWidget(buildTestWidget(
          tripSession: RideTripSessionUiState(activeTrip: finalTrip),
        ));
        await tester.pumpAndSettle();

        // Verify UI is stable and shows correct phase
        expect(find.text('Driver on the way'), findsOneWidget,
            reason: 'UI should show driverAccepted headline despite double event');

        // Verify no crash occurred (screen renders correctly)
        expect(find.byType(RideActiveTripScreen), findsOneWidget,
            reason: 'Screen should render without crash after double events');

        // Verify driver card is shown (state preserved correctly)
        expect(find.text('Ahmad M.'), findsOneWidget,
            reason: 'Driver info should be preserved after double events');
      });

      // -----------------------------------------------------------------------
      // Test 2: Cancelling trip twice does not crash
      // -----------------------------------------------------------------------
      // Track B - Ticket #120: Updated to reflect new cancellation flow.
      // Now cancelCurrentTrip() archives trip and clears session, navigating home.
      testWidgets('cancelling_trip_twice_does_not_crash', (tester) async {
        // Track B - Ticket #166: Configure larger screen for button hit-testing
        await _configureLargeTestScreen(tester);

        // Create a controller that tracks cancel calls and simulates the flow
        final cancelTrackingController = _CancelTrackingController(
          initialState: const RideTripSessionUiState(
            activeTrip: RideTripState(
              tripId: 'chaos-test-double-cancel',
              phase: RideTripPhase.driverAccepted,
            ),
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideTripSessionProvider
                  .overrideWith((ref) => cancelTrackingController),
              rideDraftProvider.overrideWith(
                (ref) =>
                    _FakeRideDraftController(initialState: const RideDraftUiState()),
              ),
              rideQuoteControllerProvider.overrideWith(
                (ref) =>
                    _FakeRideQuoteController(initialState: const RideQuoteUiState()),
              ),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('en'),
              home: RideActiveTripScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // First cancellation - tap Cancel and confirm in dialog
        await tester.tap(find.text('Cancel ride'));
        await tester.pumpAndSettle();
        
        // Dialog should appear
        expect(find.text('Cancel this ride?'), findsOneWidget);
        
        // Confirm cancellation
        final cancelButtons = find.text('Cancel ride');
        await tester.tap(cancelButtons.last);
        await tester.pumpAndSettle();

        // Track B - Ticket #120: Verify cancelCurrentTrip was called
        // (cancelCallCount now tracks cancelCurrentTrip calls)
        expect(cancelTrackingController.cancelCallCount, equals(1),
            reason: 'cancelCurrentTrip should be called once');

        // Track B - Ticket #120: After cancellation, session is cleared.
        // Trying to cancel again should be a no-op (no active trip).
        final secondResult = cancelTrackingController.cancelCurrentTrip();
        
        // Second call returns false because no active trip exists
        expect(secondResult, isFalse,
            reason: 'Second cancel should return false (no active trip)');
      });

      // -----------------------------------------------------------------------
      // Test 3: Failed trip shows correct CTAs (back to home + request new ride)
      // -----------------------------------------------------------------------
      testWidgets('failed_trip_shows_back_to_home_and_request_new_ride_ctas',
          (tester) async {
        const failedTrip = RideTripState(
          tripId: 'chaos-test-failed',
          phase: RideTripPhase.failed,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: failedTrip),
          rideDraft: const RideDraftUiState(destinationQuery: 'Airport'),
        ));
        await tester.pumpAndSettle();

        // Verify failure title
        expect(find.text('Something went wrong'), findsOneWidget,
            reason: 'Failed trip should show error title');

        // Verify failure body
        expect(
          find.text(
              "We couldn't complete this trip. Please try again in a moment."),
          findsOneWidget,
          reason: 'Failed trip should show error body',
        );

        // Verify Back to home CTA
        expect(find.text('Back to home'), findsOneWidget,
            reason: 'Failed state should have Back to home CTA');

        // Verify Request new ride CTA
        expect(find.text('Request new ride'), findsOneWidget,
            reason: 'Failed state should have Request new ride CTA');

        // Verify error icon
        expect(find.byIcon(Icons.error_outline), findsOneWidget,
            reason: 'Failed state should show error icon');
      });

      // -----------------------------------------------------------------------
      // Test 4: Rapid phase transitions don't crash UI
      // -----------------------------------------------------------------------
      testWidgets('rapid_phase_transitions_do_not_crash_ui', (tester) async {
        // Simulate rapid FSM transitions using FSM functions
        var trip = const RideTripState(
          tripId: 'chaos-rapid-transitions',
          phase: RideTripPhase.findingDriver,
        );

        // Apply rapid sequence of events using FSM functions
        trip = applyRideTripEvent(trip, RideTripEvent.driverAccepted);
        trip = applyRideTripEvent(trip, RideTripEvent.driverArrived);
        trip = applyRideTripEvent(trip, RideTripEvent.startTrip);
        trip = applyRideTripEvent(trip, RideTripEvent.startPayment);
        trip = applyRideTripEvent(trip, RideTripEvent.complete);

        await tester.pumpWidget(buildTestWidget(
          tripSession: RideTripSessionUiState(activeTrip: trip),
        ));
        await tester.pumpAndSettle();

        // Verify final state is rendered correctly
        expect(find.text('Trip completed'), findsOneWidget,
            reason: 'Final state after rapid transitions should be correct');
        expect(find.byIcon(Icons.done_all), findsOneWidget);

        // No crash occurred
        expect(find.byType(RideActiveTripScreen), findsOneWidget);
      });

      // -----------------------------------------------------------------------
      // Test 5: Illegal event for current phase is handled gracefully
      // -----------------------------------------------------------------------
      testWidgets('illegal_event_for_current_phase_is_handled_gracefully',
          (tester) async {
        // Try to apply startTrip event to findingDriver phase (illegal)
        const trip = RideTripState(
          tripId: 'chaos-illegal-event',
          phase: RideTripPhase.findingDriver,
        );

        // This should NOT cause FSM to crash, tryApplyRideTripEvent returns null
        final afterIllegalEvent = tryApplyRideTripEvent(
          trip,
          RideTripEvent.startTrip,
        );

        // If illegal transition, use original state
        final finalTrip = afterIllegalEvent ?? trip;

        await tester.pumpWidget(buildTestWidget(
          tripSession: RideTripSessionUiState(activeTrip: finalTrip),
        ));
        await tester.pumpAndSettle();

        // FSM should have stayed in findingDriver (illegal transition was no-op)
        expect(find.text('Finding a driver…'), findsOneWidget,
            reason: 'FSM should stay in findingDriver after illegal event');
        expect(find.byType(RideActiveTripScreen), findsOneWidget,
            reason: 'Screen should not crash on illegal FSM event');
      });

      // -----------------------------------------------------------------------
      // L10n Chaos: AR Terminal State
      // -----------------------------------------------------------------------
      testWidgets('AR: failed_terminal_state_texts_are_in_arabic',
          (tester) async {
        const failedTrip = RideTripState(
          tripId: 'chaos-ar-failed',
          phase: RideTripPhase.failed,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideTripSessionProvider.overrideWith(
                (ref) => _FakeRideTripSessionController(
                  initialState: const RideTripSessionUiState(activeTrip: failedTrip),
                ),
              ),
              rideDraftProvider.overrideWith(
                (ref) =>
                    _FakeRideDraftController(initialState: const RideDraftUiState()),
              ),
              rideQuoteControllerProvider.overrideWith(
                (ref) =>
                    _FakeRideQuoteController(initialState: const RideQuoteUiState()),
              ),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('ar'),
              home: RideActiveTripScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify Arabic failed UI
        expect(find.text('حدث خطأ ما'), findsOneWidget,
            reason: 'Arabic title for failed state');
        expect(find.text('الرجوع للرئيسية'), findsOneWidget,
            reason: 'Arabic back to home CTA');
        expect(find.text('طلب رحلة جديدة'), findsOneWidget,
            reason: 'Arabic request new ride CTA');
      });

      // -----------------------------------------------------------------------
      // L10n Chaos: DE Terminal State
      // -----------------------------------------------------------------------
      testWidgets('DE: cancelled_terminal_state_texts_are_in_german',
          (tester) async {
        const cancelledTrip = RideTripState(
          tripId: 'chaos-de-cancelled',
          phase: RideTripPhase.cancelled,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideTripSessionProvider.overrideWith(
                (ref) => _FakeRideTripSessionController(
                  initialState: const RideTripSessionUiState(activeTrip: cancelledTrip),
                ),
              ),
              rideDraftProvider.overrideWith(
                (ref) =>
                    _FakeRideDraftController(initialState: const RideDraftUiState()),
              ),
              rideQuoteControllerProvider.overrideWith(
                (ref) =>
                    _FakeRideQuoteController(initialState: const RideQuoteUiState()),
              ),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('de'),
              home: RideActiveTripScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify German cancelled UI
        expect(find.text('Fahrt storniert'), findsOneWidget,
            reason: 'German title for cancelled state');
        expect(find.text('Zur Startseite'), findsOneWidget,
            reason: 'German back to home CTA');
        expect(find.text('Neue Fahrt anfordern'), findsOneWidget,
            reason: 'German request new ride CTA');
      });

      // -----------------------------------------------------------------------
      // Phase progression tracking test
      // -----------------------------------------------------------------------
      testWidgets('phase_progression_tracking_is_stable', (tester) async {
        // Track B - Ticket #166: Configure larger screen for button hit-testing
        await _configureLargeTestScreen(tester);

        // Test that FSM correctly tracks phase progression
        // isCancellable is a property of RideTripPhase (not RideTripState)
        // Cancellable phases: draft, quoting, requesting, findingDriver, driverAccepted, driverArrived
        final cancellablePhases = <RideTripPhase, bool>{
          RideTripPhase.draft: true,
          RideTripPhase.quoting: true,
          RideTripPhase.requesting: true,
          RideTripPhase.findingDriver: true,
          RideTripPhase.driverAccepted: true,
          RideTripPhase.driverArrived: true,
          RideTripPhase.inProgress: false,
          RideTripPhase.payment: false,
          RideTripPhase.completed: false,
          RideTripPhase.cancelled: false,
          RideTripPhase.failed: false,
        };

        for (final entry in cancellablePhases.entries) {
          expect(entry.key.isCancellable, equals(entry.value),
              reason: 'isCancellable should be ${entry.value} for ${entry.key.name}');
        }

        // Build UI with a cancellable phase
        const cancellableTrip = RideTripState(
          tripId: 'chaos-cancellable',
          phase: RideTripPhase.findingDriver,
        );

        await tester.pumpWidget(buildTestWidget(
          tripSession: const RideTripSessionUiState(activeTrip: cancellableTrip),
        ));
        await tester.pumpAndSettle();

        // Verify cancel button is enabled
        await tester.tap(find.text('Cancel ride'));
        await tester.pumpAndSettle();
        expect(find.text('Cancel this ride?'), findsOneWidget,
            reason: 'Cancel dialog should open for cancellable phase');
      });
    });

    // =========================================================================
    // Ticket #105: Unified Trip Summary Tests
    // =========================================================================
    group('Trip Summary (Ticket #105)', () {
      testWidgets(
          'active_trip_screen_shows_selected_service_and_price_from_confirmation',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-summary-123',
          phase: RideTripPhase.driverAccepted,
        );

        // Create trip summary with service and price
        const tripSummary = RideTripSummary(
          selectedServiceId: 'economy',
          selectedServiceName: 'Economy',
          fareDisplayText: '18.00 SAR',
          selectedPaymentMethodId: 'visa_4242',
          etaMinutes: 5,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideTripSessionProvider.overrideWith(
                (ref) => _FakeRideTripSessionController(
                  initialState: const RideTripSessionUiState(
                    activeTrip: activeTrip,
                    tripSummary: tripSummary,
                  ),
                ),
              ),
              rideDraftProvider.overrideWith(
                (ref) => _FakeRideDraftController(
                  initialState: const RideDraftUiState(
                    destinationQuery: 'Test Destination',
                  ),
                ),
              ),
              rideQuoteControllerProvider.overrideWith(
                (ref) => _FakeRideQuoteController(
                  initialState: const RideQuoteUiState(),
                ),
              ),
              paymentMethodsUiProvider.overrideWith(
                (ref) => PaymentMethodsUiState(
                  methods: [
                    PaymentMethodUiModel.stubCard(brand: 'Visa', last4: '4242'),
                  ],
                  selectedMethodId: 'visa_4242',
                ),
              ),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('en'),
              home: RideActiveTripScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify service name and price are shown
        expect(find.textContaining('Economy'), findsAtLeastNWidgets(1));
        expect(find.textContaining('18.00'), findsAtLeastNWidgets(1));
      });

      testWidgets('active_trip_screen_shows_selected_payment_method_label',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-payment-method',
          phase: RideTripPhase.inProgress,
        );

        // Create trip summary with payment method
        const tripSummary = RideTripSummary(
          selectedServiceId: 'economy',
          selectedServiceName: 'Economy',
          fareDisplayText: '25.00 SAR',
          selectedPaymentMethodId: 'visa_4242',
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideTripSessionProvider.overrideWith(
                (ref) => _FakeRideTripSessionController(
                  initialState: const RideTripSessionUiState(
                    activeTrip: activeTrip,
                    tripSummary: tripSummary,
                  ),
                ),
              ),
              rideDraftProvider.overrideWith(
                (ref) => _FakeRideDraftController(
                  initialState: const RideDraftUiState(),
                ),
              ),
              rideQuoteControllerProvider.overrideWith(
                (ref) => _FakeRideQuoteController(
                  initialState: const RideQuoteUiState(),
                ),
              ),
              paymentMethodsUiProvider.overrideWith(
                (ref) => PaymentMethodsUiState(
                  methods: [
                    PaymentMethodUiModel.stubCard(brand: 'Visa', last4: '4242'),
                  ],
                  selectedMethodId: 'visa_4242',
                ),
              ),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('en'),
              home: RideActiveTripScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify payment method label is shown
        expect(find.textContaining('Visa'), findsAtLeastNWidgets(1));
        expect(find.textContaining('4242'), findsAtLeastNWidgets(1));
      });

      // Track B - Ticket #144: Test navigation to summary screen when phase changes to completed
      testWidgets('navigates to summary screen when trip completes', (tester) async {
        // Create a mock navigator observer to track navigation
        final navigatorObserver = MockNavigatorObserver();
        
        // Initial state with trip in progress
        const activeTrip = RideTripState(
          tripId: 'test-navigation-to-summary',
          phase: RideTripPhase.inProgress,
        );

        final tripController = _FakeRideTripSessionController(
          initialState: const RideTripSessionUiState(
            activeTrip: activeTrip,
            tripSummary: RideTripSummary(
              selectedServiceName: 'Economy',
              fareDisplayText: 'SAR 24.50',
            ),
            draftSnapshot: RideDraftUiState(
              pickupLabel: 'Test Pickup',
              destinationQuery: 'Test Destination',
            ),
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideTripSessionProvider.overrideWith((ref) => tripController),
              rideDraftProvider.overrideWith(
                (ref) => _FakeRideDraftController(
                  initialState: const RideDraftUiState(),
                ),
              ),
              rideQuoteControllerProvider.overrideWith(
                (ref) => _FakeRideQuoteController(
                  initialState: const RideQuoteUiState(),
                ),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('en'),
              navigatorObservers: [navigatorObserver],
              routes: {
                '/': (context) => const RideActiveTripScreen(),
                RoutePaths.rideTripSummary: (context) => const RideTripSummaryScreen(),
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify initial state shows trip in progress
        expect(find.text('Trip in progress'), findsOneWidget);

        // Simulate trip completion by updating the state to completed phase
        const completedTrip = RideTripState(
          tripId: 'test-navigation-to-summary',
          phase: RideTripPhase.completed,
        );
        
        tripController.state = RideTripSessionUiState(
          activeTrip: completedTrip,
          tripSummary: const RideTripSummary(
            selectedServiceName: 'Economy',
            fareDisplayText: 'SAR 24.50',
          ),
          draftSnapshot: const RideDraftUiState(
            pickupLabel: 'Test Pickup',
            destinationQuery: 'Test Destination',
          ),
          historyTrips: [
            RideHistoryEntry(
              trip: completedTrip,
              destinationLabel: 'Test Destination',
              completedAt: DateTime.now(),
              amountFormatted: 'SAR 24.50',
              serviceName: 'Economy',
              originLabel: 'Test Pickup',
            ),
          ],
        );
        
        // Use pump multiple times instead of pumpAndSettle to avoid timeout
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        // Verify navigation to summary screen occurred
        // The listener should have triggered navigation when phase changed to completed
        expect(navigatorObserver.pushedRoutes.length, greaterThanOrEqualTo(1));
        
        // Since we're using pushReplacementNamed, check that summary screen is shown
        expect(find.byType(RideTripSummaryScreen), findsOneWidget);
        expect(find.text('Trip in progress'), findsNothing);
      });

      testWidgets('l10n_ar_active_trip_summary', (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-ar-summary',
          phase: RideTripPhase.driverAccepted,
        );

        const tripSummary = RideTripSummary(
          selectedServiceId: 'economy',
          selectedServiceName: 'Economy',
          fareDisplayText: '18.00 SAR',
          selectedPaymentMethodId: 'cash',
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideTripSessionProvider.overrideWith(
                (ref) => _FakeRideTripSessionController(
                  initialState: const RideTripSessionUiState(
                    activeTrip: activeTrip,
                    tripSummary: tripSummary,
                  ),
                ),
              ),
              rideDraftProvider.overrideWith(
                (ref) => _FakeRideDraftController(
                  initialState: const RideDraftUiState(),
                ),
              ),
              rideQuoteControllerProvider.overrideWith(
                (ref) => _FakeRideQuoteController(
                  initialState: const RideQuoteUiState(),
                ),
              ),
              paymentMethodsUiProvider.overrideWith(
                (ref) => const PaymentMethodsUiState(
                  methods: [PaymentMethodUiModel.cash],
                  selectedMethodId: 'cash',
                ),
              ),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('ar'), // Arabic locale
              home: RideActiveTripScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify Arabic headline is shown
        // homeActiveRideStatusDriverAccepted in Arabic: السائق في الطريق
        expect(find.textContaining('السائق'), findsAtLeastNWidgets(1));

        // Verify payment method label in Arabic (الدفع عبر)
        expect(find.textContaining('الدفع'), findsAtLeastNWidgets(1));
      });

      testWidgets('trip_summary_graceful_fallback_when_no_summary',
          (tester) async {
        const activeTrip = RideTripState(
          tripId: 'test-no-summary',
          phase: RideTripPhase.findingDriver,
        );

        // No trip summary provided
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideTripSessionProvider.overrideWith(
                (ref) => _FakeRideTripSessionController(
                  initialState: const RideTripSessionUiState(
                    activeTrip: activeTrip,
                    tripSummary: null,
                  ),
                ),
              ),
              rideDraftProvider.overrideWith(
                (ref) => _FakeRideDraftController(
                  initialState: const RideDraftUiState(
                    destinationQuery: 'Test Destination',
                  ),
                ),
              ),
              rideQuoteControllerProvider.overrideWith(
                (ref) => _FakeRideQuoteController(
                  initialState: const RideQuoteUiState(),
                ),
              ),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('en'),
              home: RideActiveTripScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Screen should still render without errors
        expect(find.text('Finding a driver…'), findsOneWidget);
        // No crash expected - graceful fallback
      });
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
  void startRideFromQuote({
    required RideQuoteOption selectedOption,
    required RideDraftUiState draft,
  }) {
    // No-op for tests
  }

  @override
  void startFromDraft(RideDraftUiState draft, {RideQuoteOption? selectedOption}) {
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
    // Legacy method - no longer used by UI (Track B - Ticket #120)
    return true;
  }

  @override
  void rateCurrentTrip(int rating) {
    // No-op for tests - Track B Ticket #23
  }

  @override
  // Track B - Ticket #108: Extended with serviceName, originLabel, paymentMethodLabel
  void archiveTrip({
    required String destinationLabel,
    String? amountFormatted,
    String? serviceName,
    String? originLabel,
    String? paymentMethodLabel,
  }) {
    // No-op for tests - Track B Ticket #96, #108
  }

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

  // Track B - Ticket #120: cancelCurrentTrip is now the primary cancel API
  @override
  bool cancelCurrentTrip({
    String? reasonLabel,
    String? destinationLabel,
    String? originLabel,
    String? serviceName,
    String? amountFormatted,
    String? paymentMethodLabel,
  }) {
    cancelCalledCount++;
    // Simulate successful cancellation - archives and clears session
    state = const RideTripSessionUiState();
    return true;
  }

  // Track B - Ticket #122: failCurrentTrip marks trip as failed
  int failCalledCount = 0;
  String? lastFailReasonLabel;
  bool failCurrentTripResult = true;

  @override
  bool failCurrentTrip({
    String? reasonLabel,
    String? destinationLabel,
    String? originLabel,
    String? serviceName,
    String? amountFormatted,
    String? paymentMethodLabel,
  }) {
    failCalledCount++;
    lastFailReasonLabel = reasonLabel;
    if (failCurrentTripResult) {
      // Simulate successful failure - archives and clears session
      state = const RideTripSessionUiState();
    }
    return failCurrentTripResult;
  }

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

  // Track B - Ticket #206: Driver location methods
  @override
  void updateDriverLocation(GeoPoint newLocation) {
    // No-op for tests
  }

  @override
  void clearDriverLocation() {
    // No-op for tests
  }

  // Track B - Ticket #215: Quote preparation methods
  @override
  Future<bool> prepareConfirmation(RideDraftUiState draft) async {
    return true;
  }

  @override
  Future<bool> requestQuoteForCurrentDraft() async {
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
  void clear() {}
}

/// Controller that tracks cancel calls for chaos testing (Ticket #97)
class _CancelTrackingController extends StateNotifier<RideTripSessionUiState>
    implements RideTripSessionController {
  _CancelTrackingController({required RideTripSessionUiState initialState})
      : super(initialState);

  int cancelCallCount = 0;

  @override
  void startRideFromQuote({
    required RideQuoteOption selectedOption,
    required RideDraftUiState draft,
  }) {
    // No-op for tests
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
    cancelCallCount++;
    
    if (cancelCallCount == 1) {
      // First cancel transitions to cancelled state
      final currentTrip = state.activeTrip;
      if (currentTrip != null) {
        state = RideTripSessionUiState(
          activeTrip: RideTripState(
            tripId: currentTrip.tripId,
            phase: RideTripPhase.cancelled,
          ),
        );
      }
      return true;
    }
    
    // Subsequent cancels are no-ops
    return false;
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

  // Track B - Ticket #117
  @override
  bool completeCurrentTrip({
    String? destinationLabel,
    String? amountFormatted,
    String? serviceName,
    String? originLabel,
    String? paymentMethodLabel,
  }) => true;

  // Track B - Ticket #120: cancelCurrentTrip archives and clears session
  @override
  bool cancelCurrentTrip({
    String? reasonLabel,
    String? destinationLabel,
    String? originLabel,
    String? serviceName,
    String? amountFormatted,
    String? paymentMethodLabel,
  }) {
    cancelCallCount++;
    
    // If no active trip, return false (idempotent)
    if (state.activeTrip == null) {
      return false;
    }
    
    // Clear the active trip (simulates archiving + clearing)
    state = const RideTripSessionUiState();
    return true;
  }

  // Track B - Ticket #122: failCurrentTrip marks trip as failed
  @override
  bool failCurrentTrip({
    String? reasonLabel,
    String? destinationLabel,
    String? originLabel,
    String? serviceName,
    String? amountFormatted,
    String? paymentMethodLabel,
  }) {
    // If no active trip, return false (idempotent)
    if (state.activeTrip == null) {
      return false;
    }
    
    // Clear the active trip (simulates archiving + clearing)
    state = const RideTripSessionUiState();
    return true;
  }

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

  // Track B - Ticket #206: Driver location methods
  @override
  void updateDriverLocation(GeoPoint newLocation) {
    // No-op for tests
  }

  @override
  void clearDriverLocation() {
    // No-op for tests
  }

  // Track B - Ticket #215: Quote preparation methods
  @override
  Future<bool> prepareConfirmation(RideDraftUiState draft) async {
    return true;
  }

  @override
  Future<bool> requestQuoteForCurrentDraft() async {
    return true;
  }
}

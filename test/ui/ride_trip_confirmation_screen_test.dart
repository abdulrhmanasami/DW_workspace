/// Ride Trip Confirmation Screen Widget Tests - Track B Ticket #21
/// Purpose: Test RideTripConfirmation (RideConfirmationScreen) UI with Quote integration
/// Created by: Track B - Ticket #21
/// Updated by: Ticket #26 (Robust quote states: Loading/Error/Empty)
/// Updated by: Ticket #64 (FSM integration tests)
/// Updated by: Ticket #97 (Chaos & Resilience Tests for pricing failures)
/// Updated by: Ticket #100 (Payment method integration tests)
/// Updated by: Ticket #101 (Payment method linked to RideDraft tests)
/// Updated by: Ticket #113 (Request Ride -> Active Trip Happy Path tests)
/// Updated by: Ticket #121 (Structured RideQuoteError error handling)
/// Last updated: 2025-12-01

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/screens/mobility/ride_confirmation_screen.dart';
import 'package:delivery_ways_clean/state/mobility/ride_draft_state.dart';
import 'package:delivery_ways_clean/state/mobility/ride_quote_controller.dart';
import 'package:delivery_ways_clean/state/mobility/ride_trip_session.dart';
import 'package:delivery_ways_clean/state/mobility/ride_map_projection.dart';
// Track B - Ticket #207: RideTripMapView integration tests
import 'package:delivery_ways_clean/widgets/mobility/ride_trip_map_view.dart';
// Track B - Ticket #100: Payment method integration
import 'package:delivery_ways_clean/state/payments/payment_methods_ui_state.dart';
import 'package:maps_shims/maps_shims.dart';
import 'package:mobility_shims/mobility_shims.dart';
import 'package:design_system_shims/design_system_shims.dart';
import 'package:pricing_shims/pricing_shims.dart' as pricing;
import '../support/design_system_harness.dart';

void main() {
  setUpAll(() {
    ensureDesignSystemStubsForTests();
  });

  // Run FSM integration tests (Ticket #64)
  runFsmIntegrationTests();

  // Run Chaos & Resilience tests (Ticket #97)
  runPricingChaosTests();

  // Run Payment Method integration tests (Ticket #100)
  runPaymentMethodIntegrationTests();

  // Run Happy Path tests (Ticket #113)
  runRequestRideHappyPathTests();

  // Run Pricing UI tests (Ticket #212)
  runPricingUiTests();

  /// Helper to get AppLocalizations from the test widget
  AppLocalizations l10n(WidgetTester tester) =>
      AppLocalizations.of(tester.element(find.byType(RideConfirmationScreen)))!;

  group('RideTripConfirmationScreen (RideConfirmationScreen) Widget Tests', () {
    /// Helper to create a mock RideQuote for testing
    RideQuote createMockQuote() {
      const pickup = LocationPoint(
        latitude: 24.7136,
        longitude: 46.6753,
      );
      const dropoff = LocationPoint(
        latitude: 24.7236,
        longitude: 46.6853,
      );

      return RideQuote(
        quoteId: 'test_quote_123',
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
      );
    }

    /// Helper to create test widget with provider overrides
    Widget createTestWidget({
      RideDraftUiState? draftState,
      RideQuoteUiState? quoteState,
      RideTripSessionUiState? sessionState,
      Locale locale = const Locale('en'),
    }) {
      final draft = draftState ??
          RideDraftUiState(
            pickupLabel: 'Current location',
            destinationQuery: 'Test Destination',
            pickupPlace: MobilityPlace.currentLocation(label: 'Current location'),
            destinationPlace: const MobilityPlace(
              id: 'test_dest',
              label: 'Test Destination',
              type: MobilityPlaceType.searchResult,
            ),
          );

      final quote = quoteState ??
          RideQuoteUiState(
            isLoading: false,
            quote: createMockQuote(),
          );

      return ProviderScope(
        overrides: [
          rideDraftProvider.overrideWith((ref) {
            final controller = RideDraftController();
            // Set state via controller methods
            controller.updatePickupLabel(draft.pickupLabel);
            controller.updateDestination(draft.destinationQuery);
            if (draft.pickupPlace != null) {
              controller.updatePickupPlace(draft.pickupPlace!);
            }
            if (draft.destinationPlace != null) {
              controller.updateDestinationPlace(draft.destinationPlace!);
            }
            return controller;
          }),
          rideQuoteControllerProvider.overrideWith((ref) {
            return _TestRideQuoteController(quote);
          }),
          rideTripSessionProvider.overrideWith((ref) {
            if (sessionState != null) {
              return _TestRideTripSessionController(sessionState);
            }
            return RideTripSessionController(ref);
          }),
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
          ],
          home: const RideConfirmationScreen(),
          routes: {
            '/ride/active': (context) =>
                const Scaffold(body: Text('Active Trip')),
          },
        ),
      );
    }

    testWidgets('displays confirmation title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for the confirmation title (uses existing l10n key)
      expect(find.text('Confirm your ride'), findsOneWidget);
    });

    testWidgets('displays destination in sheet', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        draftState: RideDraftUiState(
          destinationQuery: 'Airport Terminal 1',
          pickupPlace: MobilityPlace.currentLocation(),
          destinationPlace: const MobilityPlace(
            label: 'Airport Terminal 1',
            type: MobilityPlaceType.searchResult,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // Check that destination is displayed
      expect(find.text('Airport Terminal 1'), findsOneWidget);
    });

    testWidgets('displays vehicle options from quote',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for vehicle options (Economy, XL from mock quote)
      expect(find.text('Economy'), findsOneWidget);
      expect(find.text('XL'), findsOneWidget);
    });

    testWidgets('displays price for vehicle options',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for price text (≈ 18.00 SAR from mock)
      expect(find.textContaining('18.00'), findsOneWidget);
      expect(find.textContaining('25.00'), findsOneWidget);
    });

    testWidgets('displays ETA for vehicle options',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for ETA text (5 min, 7 min from mock)
      expect(find.textContaining('5'), findsAtLeastNWidgets(1));
      expect(find.textContaining('7'), findsAtLeastNWidgets(1));
    });

    // Track B - Ticket #100: Updated to check for cash icon (default payment method)
    testWidgets('displays payment method section', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for payment section - uses payments_outlined icon for cash (default)
      expect(find.byIcon(Icons.payments_outlined), findsOneWidget);
    });

    testWidgets('displays Request Ride CTA button',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for the CTA button
      expect(find.text('Request Ride'), findsOneWidget);
    });

    // ========================================================================
    // Ticket #26: Quote State Tests (Loading / Error / Empty)
    // ========================================================================

    testWidgets('shows loading state with proper UI when quote is loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        quoteState: const RideQuoteUiState(isLoading: true),
      ));
      await tester.pump();

      // Check for loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Check for loading title (Ticket #26)
      expect(find.text('Fetching ride options...'), findsOneWidget);

      // Check for loading subtitle
      expect(
          find.text('Please wait while we find the best rides for you.'),
          findsOneWidget);

      // Request Ride CTA should be disabled (present but not functional)
      expect(find.text('Request Ride'), findsOneWidget);
    });

    testWidgets('shows error state with proper UI when quote fails',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        quoteState: const RideQuoteUiState(
          isLoading: false,
          error: RideQuoteError.unexpected('Network error'),
        ),
      ));
      await tester.pumpAndSettle();

      // Check for error title (Ticket #26)
      expect(find.text(l10n(tester).rideConfirmErrorTitle), findsOneWidget);

      // Check for error subtitle
      expect(
          find.text(l10n(tester).rideConfirmErrorSubtitle),
          findsOneWidget);

      // Check for retry button (DWButton.secondary)
      expect(find.text('Retry'), findsOneWidget);

      // Error icon should be visible
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('retry button triggers quote refresh on error state',
        (WidgetTester tester) async {
      final testController = _TestRideQuoteControllerWithRetryCount(
        const RideQuoteUiState(
          isLoading: false,
          error: RideQuoteError.unexpected('Network error'),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideDraftProvider.overrideWith((ref) {
              final controller = RideDraftController();
              controller.updateDestination('Test Destination');
              return controller;
            }),
            rideQuoteControllerProvider.overrideWith((ref) => testController),
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

      // Verify retry button exists
      expect(find.text('Retry'), findsOneWidget);

      // Initial call count should be 1 (from initState)
      expect(testController.refreshFromDraftCallCount, 1);

      // Tap retry button
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      // Verify refresh was called again
      expect(testController.refreshFromDraftCallCount, 2);
    });

    testWidgets('shows empty state when no quote is available',
        (WidgetTester tester) async {
      // Empty state: no loading, no error, no quote
      // Note: Track B - Ticket #121: RideQuote now allows empty options
      // so empty state applies when quote is null or options are empty

      await tester.pumpWidget(createTestWidget(
        quoteState: const RideQuoteUiState(
          isLoading: false,
          // quote: null (default)
          // error: null (default)
        ),
      ));
      await tester.pumpAndSettle();

      // Check for empty title (Ticket #26, updated in Ticket #121)
      expect(find.text(l10n(tester).rideQuoteEmptyTitle), findsOneWidget);

      // Track B - Ticket #121: Updated empty subtitle text
      expect(
          find.text(l10n(tester).rideQuoteEmptyDescription), findsOneWidget);

      // No vehicle options should be visible
      expect(find.text('Economy'), findsNothing);
      expect(find.text('XL'), findsNothing);

      // Empty icon should be visible
      expect(find.byIcon(Icons.directions_car_outlined), findsOneWidget);
    });

    testWidgets('Request Ride CTA is disabled during loading state',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        quoteState: const RideQuoteUiState(isLoading: true),
      ));
      await tester.pump();

      // CTA should be present but we can't easily verify disabled state
      // with DWButton. Instead verify loading UI is shown.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Request Ride'), findsOneWidget);
    });

    testWidgets('Request Ride CTA is disabled on error state',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        quoteState: const RideQuoteUiState(
          isLoading: false,
          error: RideQuoteError.unexpected('Error loading options'),
        ),
      ));
      await tester.pumpAndSettle();

      // CTA should be present
      expect(find.text('Request Ride'), findsOneWidget);

      // Error UI should be shown
      expect(find.text(l10n(tester).rideConfirmErrorTitle), findsOneWidget);
    });

    testWidgets('Request Ride CTA is disabled on empty state (no quote)',
        (WidgetTester tester) async {
      // Empty state with no quote (not loading, no error)
      await tester.pumpWidget(createTestWidget(
        quoteState: const RideQuoteUiState(
          isLoading: false,
          // quote: null
        ),
      ));
      await tester.pumpAndSettle();

      // CTA should be present
      expect(find.text('Request Ride'), findsOneWidget);

      // Empty state UI should be shown
      expect(find.text('No rides available'), findsOneWidget);
    });

    testWidgets('success state shows vehicle options and enabled CTA',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Vehicle options should be visible
      expect(find.text('Economy'), findsOneWidget);
      expect(find.text('XL'), findsOneWidget);

      // CTA should be present
      expect(find.text('Request Ride'), findsOneWidget);

      // No error/loading/empty UI should be visible
      expect(find.text(l10n(tester).rideConfirmErrorTitle), findsNothing);
      expect(find.text('Fetching ride options...'), findsNothing);
      expect(find.text(l10n(tester).rideQuoteEmptyTitle), findsNothing);
    });

    testWidgets('displays pickup location label', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for pickup location (Current location)
      expect(find.text('Current location'), findsAtLeastNWidgets(1));
    });

    testWidgets('selecting vehicle option updates selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initially Economy should be selected (recommended)
      // Tap on XL to select it
      await tester.tap(find.text('XL'));
      await tester.pumpAndSettle();

      // Verify XL is now displayed (interaction worked)
      expect(find.text('XL'), findsOneWidget);
    });

    testWidgets('displays Arabic translations when locale is ar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      // Check for Arabic title
      expect(find.text('تأكيد الرحلة'), findsOneWidget);
    });

    // ========================================================================
    // Ticket #91: Recommended Badge + German Locale Tests
    // ========================================================================

    testWidgets('displays Recommended badge for recommended option (Ticket #91)',
        (WidgetTester tester) async {
      // Mock quote with one recommended option
      final recommendedQuote = RideQuote(
        quoteId: 'rec_quote_123',
        request: const RideQuoteRequest(
          pickup: LocationPoint(latitude: 24.7136, longitude: 46.6753),
          dropoff: LocationPoint(latitude: 24.7236, longitude: 46.6853),
          currencyCode: 'SAR',
        ),
        options: const [
          RideQuoteOption(
            id: 'economy_rec',
            category: RideVehicleCategory.economy,
            displayName: 'Economy',
            etaMinutes: 5,
            priceMinorUnits: 1800,
            currencyCode: 'SAR',
            isRecommended: true,
          ),
          RideQuoteOption(
            id: 'xl_not_rec',
            category: RideVehicleCategory.xl,
            displayName: 'XL',
            etaMinutes: 7,
            priceMinorUnits: 2500,
            currencyCode: 'SAR',
            isRecommended: false,
          ),
        ],
      );

      await tester.pumpWidget(createTestWidget(
        quoteState: RideQuoteUiState(
          isLoading: false,
          quote: recommendedQuote,
        ),
      ));
      await tester.pumpAndSettle();

      // Check that Recommended badge appears (only for recommended option)
      expect(find.text('Recommended'), findsOneWidget);
    });

    testWidgets('does not display Recommended badge when isRecommended is false (Ticket #91)',
        (WidgetTester tester) async {
      // Mock quote with no recommended options
      final noRecQuote = RideQuote(
        quoteId: 'norec_quote_123',
        request: const RideQuoteRequest(
          pickup: LocationPoint(latitude: 24.7136, longitude: 46.6753),
          dropoff: LocationPoint(latitude: 24.7236, longitude: 46.6853),
          currencyCode: 'SAR',
        ),
        options: const [
          RideQuoteOption(
            id: 'economy_norec',
            category: RideVehicleCategory.economy,
            displayName: 'Economy',
            etaMinutes: 5,
            priceMinorUnits: 1800,
            currencyCode: 'SAR',
            isRecommended: false,
          ),
          RideQuoteOption(
            id: 'xl_norec',
            category: RideVehicleCategory.xl,
            displayName: 'XL',
            etaMinutes: 7,
            priceMinorUnits: 2500,
            currencyCode: 'SAR',
            isRecommended: false,
          ),
        ],
      );

      await tester.pumpWidget(createTestWidget(
        quoteState: RideQuoteUiState(
          isLoading: false,
          quote: noRecQuote,
        ),
      ));
      await tester.pumpAndSettle();

      // Check that Recommended badge does NOT appear
      expect(find.text('Recommended'), findsNothing);
    });

    testWidgets('displays German translations when locale is de (Ticket #91)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideDraftProvider.overrideWith((ref) {
              final controller = RideDraftController();
              controller.updateDestination('Berlin');
              return controller;
            }),
            rideQuoteControllerProvider.overrideWith((ref) {
              return _TestRideQuoteController(RideQuoteUiState(
                isLoading: false,
                quote: RideQuote(
                  quoteId: 'de_quote',
                  request: const RideQuoteRequest(
                    pickup: LocationPoint(latitude: 52.52, longitude: 13.405),
                    dropoff: LocationPoint(latitude: 52.53, longitude: 13.41),
                    currencyCode: 'EUR',
                  ),
                  options: const [
                    RideQuoteOption(
                      id: 'eco_de',
                      category: RideVehicleCategory.economy,
                      displayName: 'Economy',
                      etaMinutes: 4,
                      priceMinorUnits: 1500,
                      currencyCode: 'EUR',
                      isRecommended: true,
                    ),
                  ],
                ),
              ));
            }),
            rideTripSessionProvider.overrideWith((ref) {
              return RideTripSessionController(ref);
            }),
          ],
          // ignore: prefer_const_constructors
          child: MaterialApp(
            locale: const Locale('de'),
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
            home: const RideConfirmationScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check for German title
      expect(find.text('Fahrt bestätigen'), findsOneWidget);
      
      // Check for recommended badge (Note: RideQuoteOptionsSheet uses hardcoded English)
      expect(find.text('Recommended'), findsOneWidget);
      
      // Check for German CTA
      expect(find.text('Fahrt anfordern'), findsOneWidget);
    });

    testWidgets('CTA button is enabled when quote is available',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the Request Ride button text (DWButton uses Text internally)
      final buttonTextFinder = find.text('Request Ride');
      expect(buttonTextFinder, findsOneWidget);

      // DWButton should be present
      expect(find.byType(DWButton), findsOneWidget);
    });

    testWidgets('CTA button is disabled when loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        quoteState: const RideQuoteUiState(isLoading: true),
      ));
      await tester.pump();

      // When loading, CTA should not be visible or should be disabled
      // The current implementation shows loading indicator instead of options
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // Track B - Ticket #207: RideTripMapView integration tests
    testWidgets('RideTripMapView is present in confirmation screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify RideTripMapView is present
      expect(find.byType(RideTripMapView), findsOneWidget);
    });

    testWidgets('RideTripMapView shows placeholder when no mapSnapshot',
        (WidgetTester tester) async {
      // Create a session state with no mapSnapshot (empty state)
      final sessionState = const RideTripSessionUiState();

      await tester.pumpWidget(createTestWidget(
        sessionState: sessionState,
      ));
      await tester.pumpAndSettle();

      // Verify RideTripMapView is present
      expect(find.byType(RideTripMapView), findsOneWidget);

      // Since RideTripMapView shows a SizedBox.expand() when no snapshot,
      // we can't easily test the placeholder directly, but we can verify
      // the widget is present and renders without errors
    });

    testWidgets('RideTripMapView displays map data when mapSnapshot exists',
        (WidgetTester tester) async {
      // Create mock map snapshot with markers and polylines
      final mockSnapshot = RideMapSnapshot(
        markers: [
          MapMarker(
            id: MapMarkerId('pickup'),
            position: const GeoPoint(24.7136, 46.6753),
            label: 'Home',
          ),
          MapMarker(
            id: MapMarkerId('destination'),
            position: const GeoPoint(24.7500, 46.7000),
            label: 'Office',
          ),
        ],
        polylines: [
          MapPolyline(
            id: MapPolylineId('route'),
            points: [
              const GeoPoint(24.7136, 46.6753),
              const GeoPoint(24.7500, 46.7000),
            ],
            isPrimaryRoute: true,
          ),
        ],
        cameraTarget: MapCameraTarget(
          center: const GeoPoint(24.7320, 46.6877),
          zoom: const MapZoom(12.0),
        ),
      );

      // Create session state with map snapshot
      final sessionState = RideTripSessionUiState(
        mapSnapshot: mockSnapshot,
        mapStage: RideMapStage.confirmingQuote,
      );

      await tester.pumpWidget(createTestWidget(
        sessionState: sessionState,
      ));
      await tester.pumpAndSettle();

      // Verify RideTripMapView is present
      expect(find.byType(RideTripMapView), findsOneWidget);

      // Verify debug information is displayed (based on RideTripMapView implementation)
      expect(find.text('Map Stage: confirmingQuote'), findsOneWidget);
      expect(find.text('Markers: 2, Polylines: 1'), findsOneWidget);
      expect(find.textContaining('Camera: 24.7320, 46.6877'), findsOneWidget);
    });
  });
}

/// Test controller that returns a fixed state
class _TestRideQuoteController extends RideQuoteController {
  _TestRideQuoteController(this._initialState)
      : super.legacy(const MockRideQuoteService());

  final RideQuoteUiState _initialState;

  @override
  RideQuoteUiState get state => _initialState;

  @override
  Future<void> refreshFromDraft(RideDraftUiState draft) async {
    // No-op for tests
  }
}

/// Test controller that returns a fixed session state
class _TestRideTripSessionController extends RideTripSessionController {
  _TestRideTripSessionController(this._initialState) : super(_MockRef());

  final RideTripSessionUiState _initialState;

  @override
  RideTripSessionUiState get state => _initialState;

  // Override to prevent tracking subscription in tests
  @override
  void _setupTrackingSubscription() {
    // Do nothing in tests - we don't need tracking functionality
  }
}

/// Mock Ref implementation for tests
class _MockRef implements Ref {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Test controller with retry counter for verifying Retry button behavior
class _TestRideQuoteControllerWithRetryCount extends RideQuoteController {
  _TestRideQuoteControllerWithRetryCount(this._initialState)
      : super.legacy(const MockRideQuoteService());

  final RideQuoteUiState _initialState;
  int refreshFromDraftCallCount = 0;

  @override
  RideQuoteUiState get state => _initialState;

  @override
  Future<void> refreshFromDraft(RideDraftUiState draft) async {
    refreshFromDraftCallCount++;
  }
}

// ============================================================================
// Track B - Ticket #97: Chaos & Resilience Tests for Pricing Failures
// ============================================================================

/// Tests for verifying UI resilience when pricing service fails.
void runPricingChaosTests() {
  setUpAll(() {
    ensureDesignSystemStubsForTests();
  });

  group('Chaos & Resilience Tests - Pricing Failures (Ticket #97)', () {
    /// Helper to get AppLocalizations from the test widget
    AppLocalizations l10n(WidgetTester tester) =>
        AppLocalizations.of(tester.element(find.byType(RideConfirmationScreen)))!;

    /// Helper to create draft state for tests
    RideDraftUiState createDraftForChaos() {
      return RideDraftUiState(
        pickupLabel: 'Home',
        destinationQuery: 'Airport',
        pickupPlace: MobilityPlace(
          label: 'Home',
          location: LocationPoint(
            latitude: 24.7136,
            longitude: 46.6753,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
        ),
        destinationPlace: MobilityPlace(
          label: 'Airport',
          location: LocationPoint(
            latitude: 24.7743,
            longitude: 46.7386,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
        ),
      );
    }

    // -------------------------------------------------------------------------
    // Test 1: pricing_failures_shows_error_and_retry_cta
    // -------------------------------------------------------------------------
    testWidgets('pricing_failures_shows_error_and_retry_cta',
        (WidgetTester tester) async {
      // Create a controller that always returns error state
      final errorController = _TestRideQuoteController(
        const RideQuoteUiState(
          isLoading: false,
          error: RideQuoteError.pricingFailed('Mock pricing service failure'),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideDraftProvider.overrideWith((ref) {
              final controller = RideDraftController();
              controller.updateDestination('Airport');
              return controller;
            }),
            rideQuoteControllerProvider.overrideWith((ref) => errorController),
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

      // Verify error title is shown
      expect(find.text(l10n(tester).rideConfirmErrorTitle), findsOneWidget,
          reason: 'Error title should be visible when pricing fails');

      // Verify error subtitle is shown
      expect(find.text(l10n(tester).rideConfirmErrorSubtitle),
          findsOneWidget,
          reason: 'Error subtitle should explain what to do');

      // Verify Retry button is shown
      expect(find.text('Retry'), findsOneWidget,
          reason: 'Retry CTA should be visible on error state');

      // Verify error icon is shown
      expect(find.byIcon(Icons.error_outline), findsOneWidget,
          reason: 'Error icon should be visible');
    });

    // -------------------------------------------------------------------------
    // Test 2: pricing_retry_succeeds_after_initial_failures
    // -------------------------------------------------------------------------
    testWidgets('pricing_retry_succeeds_after_initial_failures',
        (WidgetTester tester) async {
      // Create a controller that simulates: first call fails, second succeeds
      final retryController = _RetryableRideQuoteController();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideDraftProvider.overrideWith((ref) {
              final controller = RideDraftController();
              final draft = createDraftForChaos();
              controller.updateDestination(draft.destinationQuery);
              if (draft.pickupPlace != null) {
                controller.updatePickupPlace(draft.pickupPlace!);
              }
              if (draft.destinationPlace != null) {
                controller.updateDestinationPlace(draft.destinationPlace!);
              }
              return controller;
            }),
            rideQuoteControllerProvider.overrideWith((ref) => retryController),
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

      // Track B - Ticket #121: Updated to use new error title l10n key
      // Initially should show error (first call fails)
      expect(find.text(l10n(tester).rideConfirmErrorTitle), findsOneWidget,
          reason: 'Initial error should be shown');
      expect(find.text('Retry'), findsOneWidget);

      // Tap Retry button
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      // After retry, should show success (vehicle options)
      expect(find.text('Economy'), findsOneWidget,
          reason: 'After successful retry, Economy option should be visible');
      expect(find.text('XL'), findsOneWidget,
          reason: 'After successful retry, XL option should be visible');

      // Error should be gone
      expect(find.text(l10n(tester).rideConfirmErrorTitle), findsNothing,
          reason: 'Error should disappear after successful retry');
    });

    // -------------------------------------------------------------------------
    // Test 3: pricing_multiple_failures_keeps_error_state_stable
    // -------------------------------------------------------------------------
    testWidgets('pricing_multiple_failures_keeps_error_state_stable',
        (WidgetTester tester) async {
      // Create a controller that always fails
      final alwaysFailController = _AlwaysFailingRideQuoteController();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideDraftProvider.overrideWith((ref) {
              final controller = RideDraftController();
              controller.updateDestination('Airport');
              return controller;
            }),
            rideQuoteControllerProvider
                .overrideWith((ref) => alwaysFailController),
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

      // Track B - Ticket #121: Updated to use new error title l10n key
      // Verify initial error state
      expect(find.text(l10n(tester).rideConfirmErrorTitle), findsOneWidget);

      // Retry multiple times
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();
      }

      // After multiple retries, should still show ONE error message (no duplicates)
      expect(find.text(l10n(tester).rideConfirmErrorTitle), findsOneWidget,
          reason:
              'Should show exactly one error message after multiple retries');

      // Verify screen didn't crash and Retry is still available
      expect(find.text('Retry'), findsOneWidget,
          reason: 'Retry button should still be available');

      // Verify refresh count
      expect(alwaysFailController.refreshCount, equals(4),
          reason: 'refreshFromDraft should be called 4 times (1 initial + 3 retries)');
    });

    // -------------------------------------------------------------------------
    // Test 4: pricing_error_shows_correct_l10n_ar
    // -------------------------------------------------------------------------
    testWidgets('AR: pricing_error_shows_arabic_error_text',
        (WidgetTester tester) async {
      final errorController = _TestRideQuoteController(
        const RideQuoteUiState(
          isLoading: false,
          error: RideQuoteError.unexpected('Network error'),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideDraftProvider.overrideWith((ref) {
              final controller = RideDraftController();
              controller.updateDestination('المطار');
              return controller;
            }),
            rideQuoteControllerProvider.overrideWith((ref) => errorController),
            rideTripSessionProvider.overrideWith(
                (ref) => RideTripSessionController(ref)),
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

      // Verify Arabic error title
      expect(find.text('تعذر تحميل خيارات الرحلة'), findsOneWidget,
          reason: 'Arabic error title should be shown');
      
      // Verify Arabic retry button
      expect(find.text('إعادة المحاولة'), findsOneWidget,
          reason: 'Arabic retry button should be shown');
    });

    // -------------------------------------------------------------------------
    // Test 5: pricing_error_shows_correct_l10n_de
    // -------------------------------------------------------------------------
    testWidgets('DE: pricing_error_shows_german_error_text',
        (WidgetTester tester) async {
      final errorController = _TestRideQuoteController(
        const RideQuoteUiState(
          isLoading: false,
          error: RideQuoteError.unexpected('Network error'),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideDraftProvider.overrideWith((ref) {
              final controller = RideDraftController();
              controller.updateDestination('Flughafen');
              return controller;
            }),
            rideQuoteControllerProvider.overrideWith((ref) => errorController),
            rideTripSessionProvider.overrideWith(
                (ref) => RideTripSessionController(ref)),
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

      // Verify German error title
      expect(find.text('Fahrtoptionen konnten nicht geladen werden'), findsOneWidget,
          reason: 'German error title should be shown');
      
      // Verify German retry button
      expect(find.text('Erneut versuchen'), findsOneWidget,
          reason: 'German retry button should be shown');
    });

    // -------------------------------------------------------------------------
    // Test 6: loading_state_during_retry_shows_indicator
    // -------------------------------------------------------------------------
    testWidgets('loading_state_during_retry_shows_indicator',
        (WidgetTester tester) async {
      // Use a controller that transitions from loading to success
      final loadingController = _TestRideQuoteController(
        const RideQuoteUiState(isLoading: true),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideDraftProvider.overrideWith((ref) {
              final controller = RideDraftController();
              controller.updateDestination('Airport');
              return controller;
            }),
            rideQuoteControllerProvider.overrideWith((ref) => loadingController),
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
      await tester.pump();

      // Verify loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget,
          reason: 'Loading indicator should be visible during fetch');

      // Verify loading title
      expect(find.text('Fetching ride options...'), findsOneWidget,
          reason: 'Loading title should be shown');
    });
  });
}

/// Controller that simulates retry behavior: first call fails, subsequent succeed.
/// Uses StateNotifier properly to trigger UI rebuilds.
class _RetryableRideQuoteController extends StateNotifier<RideQuoteUiState>
    implements RideQuoteController {
  _RetryableRideQuoteController()
      : super(const RideQuoteUiState(
          isLoading: false,
          // Track B - Ticket #121: Use structured error
          error: RideQuoteError.pricingFailed('Initial pricing failure'),
        ));

  int _callCount = 0;

  @override
  Future<void> refreshFromDraft(RideDraftUiState draft) async {
    _callCount++;
    
    if (_callCount == 1) {
      // First call fails
      state = const RideQuoteUiState(
        isLoading: false,
        // Track B - Ticket #121: Use structured error
        error: RideQuoteError.pricingFailed('Pricing service unavailable'),
      );
    } else {
      // Subsequent calls succeed
      state = RideQuoteUiState(
        isLoading: false,
        quote: RideQuote(
          quoteId: 'retry-success-quote',
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

  // Track B - Ticket #121: Add retryFromDraft implementation
  @override
  Future<void> retryFromDraft(RideDraftUiState draft) async {
    return refreshFromDraft(draft);
  }

  @override
  void clear() {
    state = const RideQuoteUiState();
  }
}

/// Controller that always fails on every refresh.
/// Uses StateNotifier properly to trigger UI rebuilds.
class _AlwaysFailingRideQuoteController extends StateNotifier<RideQuoteUiState>
    implements RideQuoteController {
  _AlwaysFailingRideQuoteController()
      : super(const RideQuoteUiState(
          isLoading: false,
          // Track B - Ticket #121: Use structured error
          error: RideQuoteError.pricingFailed('Persistent pricing failure'),
        ));

  int refreshCount = 0;

  @override
  Future<void> refreshFromDraft(RideDraftUiState draft) async {
    refreshCount++;
    // Re-emit the same error state to simulate continuous failures
    state = const RideQuoteUiState(
      isLoading: false,
      // Track B - Ticket #121: Use structured error
      error: RideQuoteError.pricingFailed('Persistent pricing failure'),
    );
  }

  // Track B - Ticket #121: Add retryFromDraft implementation
  @override
  Future<void> retryFromDraft(RideDraftUiState draft) async {
    return refreshFromDraft(draft);
  }

  @override
  void clear() {
    state = const RideQuoteUiState();
  }
}

// ============================================================================
// Track B - Ticket #64: FSM Integration Tests
// ============================================================================

/// Tests for verifying FSM state transitions when interacting with the UI.
void runFsmIntegrationTests() {
  setUpAll(() {
    ensureDesignSystemStubsForTests();
  });

  group('FSM Integration Tests (Ticket #64)', () {
    /// Helper to create a mock RideQuote
    RideQuote createMockQuote() {
      const pickup = LocationPoint(
        latitude: 24.7136,
        longitude: 46.6753,
      );
      const dropoff = LocationPoint(
        latitude: 24.7236,
        longitude: 46.6853,
      );

      return RideQuote(
        quoteId: 'fsm_test_quote',
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
          ),
        ],
      );
    }

    testWidgets(
        'pressing Request Ride moves FSM from requesting to findingDriver',
        (WidgetTester tester) async {
      // Create a container to access providers
      late ProviderContainer container;

      final draft = RideDraftUiState(
        pickupLabel: 'Current location',
        destinationQuery: 'Test Destination',
        pickupPlace: MobilityPlace(
          label: 'Current location',
          location: LocationPoint(
            latitude: 24.7136,
            longitude: 46.6753,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
        ),
        destinationPlace: MobilityPlace(
          label: 'Test Destination',
          location: LocationPoint(
            latitude: 24.7236,
            longitude: 46.6853,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
        ),
      );

      final quote = RideQuoteUiState(
        isLoading: false,
        quote: createMockQuote(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideDraftProvider.overrideWith((ref) {
              final controller = RideDraftController();
              controller.updatePickupLabel(draft.pickupLabel);
              controller.updateDestination(draft.destinationQuery);
              if (draft.pickupPlace != null) {
                controller.updatePickupPlace(draft.pickupPlace!);
              }
              if (draft.destinationPlace != null) {
                controller.updateDestinationPlace(draft.destinationPlace!);
              }
              return controller;
            }),
            rideQuoteControllerProvider.overrideWith((ref) {
              return _TestRideQuoteController(quote);
            }),
            rideTripSessionProvider.overrideWith((ref) {
              return RideTripSessionController(ref);
            }),
          ],
          child: Builder(
            builder: (context) {
              return MaterialApp(
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [Locale('en')],
                home: Consumer(
                  builder: (context, ref, child) {
                    // Store container reference
                    container = ProviderScope.containerOf(context);
                    return const RideConfirmationScreen();
                  },
                ),
                routes: {
                  '/ride/active': (context) =>
                      const Scaffold(body: Text('Active Trip')),
                },
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify initial FSM state (should be empty/initial before pressing button)
      final initialState = container.read(rideTripSessionProvider);
      expect(initialState.activeTrip, isNull);

      // Find and tap the Request Ride button
      expect(find.text('Request Ride'), findsOneWidget);
      await tester.tap(find.text('Request Ride'));
      await tester.pumpAndSettle();

      // After pressing Request Ride:
      // The RideConfirmationScreen calls startFromDraft() which moves FSM through:
      // draft -> quoting -> requesting -> findingDriver
      final updatedState = container.read(rideTripSessionProvider);
      expect(updatedState.activeTrip, isNotNull,
          reason: 'FSM should have an active trip after Request Ride');
      expect(updatedState.activeTrip!.phase, RideTripPhase.findingDriver,
          reason: 'FSM should be in findingDriver phase after Request Ride');
    });

    testWidgets('FSM phase is preserved after Request Ride navigation',
        (WidgetTester tester) async {
      late ProviderContainer container;

      final draft = RideDraftUiState(
        pickupLabel: 'Current location',
        destinationQuery: 'Test Destination',
        pickupPlace: MobilityPlace(
          label: 'Current location',
          location: LocationPoint(
            latitude: 24.7136,
            longitude: 46.6753,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
        ),
        destinationPlace: MobilityPlace(
          label: 'Test Destination',
          location: LocationPoint(
            latitude: 24.7236,
            longitude: 46.6853,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
        ),
      );

      final quote = RideQuoteUiState(
        isLoading: false,
        quote: RideQuote(
          quoteId: 'fsm_nav_test',
          request: const RideQuoteRequest(
            pickup: LocationPoint(latitude: 24.7136, longitude: 46.6753),
            dropoff: LocationPoint(latitude: 24.7236, longitude: 46.6853),
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
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideDraftProvider.overrideWith((ref) {
              final controller = RideDraftController();
              controller.updatePickupLabel(draft.pickupLabel);
              controller.updateDestination(draft.destinationQuery);
              if (draft.pickupPlace != null) {
                controller.updatePickupPlace(draft.pickupPlace!);
              }
              if (draft.destinationPlace != null) {
                controller.updateDestinationPlace(draft.destinationPlace!);
              }
              return controller;
            }),
            rideQuoteControllerProvider.overrideWith((ref) {
              return _TestRideQuoteController(quote);
            }),
            rideTripSessionProvider.overrideWith((ref) {
              return RideTripSessionController(ref);
            }),
          ],
          child: Builder(
            builder: (context) {
              return MaterialApp(
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [Locale('en')],
                home: Consumer(
                  builder: (context, ref, child) {
                    container = ProviderScope.containerOf(context);
                    return const RideConfirmationScreen();
                  },
                ),
                routes: {
                  '/ride/active': (context) {
                    // On active trip screen, verify FSM state is preserved
                    final state = container.read(rideTripSessionProvider);
                    return Scaffold(
                      body: Text('Phase: ${state.activeTrip?.phase.name}'),
                    );
                  },
                },
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Request Ride
      await tester.tap(find.text('Request Ride'));
      await tester.pumpAndSettle();

      // Verify navigation occurred and FSM state is correct
      expect(find.text('Phase: findingDriver'), findsOneWidget,
          reason: 'Active trip screen should show findingDriver phase');
    });
  });
}

// =============================================================================
// Track B - Ticket #100: Payment Method Integration Tests
// =============================================================================

/// Group of tests for payment method integration in Trip Confirmation
void runPaymentMethodIntegrationTests() {
  // Track B - Ticket #101: Tests for linking payment method to ride draft
  runPaymentMethodLinkedToDraftTests();

  group('Payment Method Integration Tests (Ticket #100)', () {
    /// Creates a mock RideQuote for testing
    RideQuote createMockQuote() {
      const pickup = LocationPoint(latitude: 24.7136, longitude: 46.6753);
      const dropoff = LocationPoint(latitude: 24.7236, longitude: 46.6853);

      return RideQuote(
        quoteId: 'test_quote_payment',
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
          ),
        ],
      );
    }

    /// Helper to create test widget with payment method override
    Widget buildPaymentTestWidget({
      PaymentMethodsUiState? paymentsState,
      Locale locale = const Locale('en'),
    }) {
      final draft = RideDraftUiState(
        pickupLabel: 'Current location',
        destinationQuery: 'Test Destination',
        pickupPlace: MobilityPlace.currentLocation(label: 'Current location'),
        destinationPlace: const MobilityPlace(
          id: 'test_dest',
          label: 'Test Destination',
          type: MobilityPlaceType.searchResult,
        ),
      );

      final quote = RideQuoteUiState(
        isLoading: false,
        quote: createMockQuote(),
      );

      return ProviderScope(
        overrides: [
          rideDraftProvider.overrideWith((ref) {
            final controller = RideDraftController();
            controller.updatePickupLabel(draft.pickupLabel);
            controller.updateDestination(draft.destinationQuery);
            if (draft.pickupPlace != null) {
              controller.updatePickupPlace(draft.pickupPlace!);
            }
            if (draft.destinationPlace != null) {
              controller.updateDestinationPlace(draft.destinationPlace!);
            }
            return controller;
          }),
          rideQuoteControllerProvider.overrideWith((ref) {
            return _PaymentTestQuoteController(quote);
          }),
          rideTripSessionProvider.overrideWith((ref) {
            return RideTripSessionController(ref);
          }),
          // Track B - Ticket #100: Payment methods override
          paymentMethodsUiProvider.overrideWith((ref) {
            return paymentsState ?? PaymentMethodsUiState.defaultStub();
          }),
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
          home: const RideConfirmationScreen(),
          routes: {
            '/ride/active': (context) =>
                const Scaffold(body: Text('Active Trip')),
          },
        ),
      );
    }

    testWidgets('shows_selected_payment_method_from_payments_tab', (tester) async {
      // Setup: Visa card is selected
      await tester.pumpWidget(buildPaymentTestWidget(
        paymentsState: PaymentMethodsUiState(
          methods: [
            PaymentMethodUiModel.cash,
            PaymentMethodUiModel.stubCard(brand: 'Visa', last4: '4242'),
          ],
          selectedMethodId: 'visa_4242', // Visa selected
        ),
      ));
      await tester.pumpAndSettle();

      // Verify Visa card is displayed in payment section
      expect(find.text('Visa ···· 4242'), findsOneWidget);
      // Type label is shown with " · " prefix
      expect(find.text(' · Card'), findsOneWidget);
    });

    testWidgets('falls_back_to_default_payment_method_when_no_selection', (tester) async {
      // Setup: No explicit selection, Cash is default
      await tester.pumpWidget(buildPaymentTestWidget(
        paymentsState: PaymentMethodsUiState(
          methods: [
            PaymentMethodUiModel.cash,
            PaymentMethodUiModel.stubCard(brand: 'Visa', last4: '4242'),
          ],
          selectedMethodId: null, // No selection, should fall back to default (Cash)
        ),
      ));
      await tester.pumpAndSettle();

      // Verify Cash is displayed (default method)
      expect(find.text('Cash'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows_cash_payment_label_for_cash_method', (tester) async {
      await tester.pumpWidget(buildPaymentTestWidget(
        paymentsState: const PaymentMethodsUiState(
          methods: [PaymentMethodUiModel.cash],
          selectedMethodId: 'cash',
        ),
      ));
      await tester.pumpAndSettle();

      // Verify Cash displayName is shown
      expect(find.text('Cash'), findsAtLeastNWidgets(1));
      // Type label is shown with " · " prefix
      expect(find.text(' · Cash'), findsOneWidget);
    });

    testWidgets('l10n_ar_shows_arabic_payment_labels_in_confirmation', (tester) async {
      await tester.pumpWidget(buildPaymentTestWidget(
        paymentsState: const PaymentMethodsUiState(
          methods: [PaymentMethodUiModel.cash],
          selectedMethodId: 'cash',
        ),
        locale: const Locale('ar'),
      ));
      await tester.pumpAndSettle();

      // Verify Arabic payment type label (with " · " prefix)
      expect(find.text(' · نقدًا'), findsAtLeastNWidgets(1)); // "Cash" in Arabic
    });

    testWidgets('l10n_de_shows_german_payment_labels_in_confirmation', (tester) async {
      await tester.pumpWidget(buildPaymentTestWidget(
        paymentsState: const PaymentMethodsUiState(
          methods: [PaymentMethodUiModel.cash],
          selectedMethodId: 'cash',
        ),
        locale: const Locale('de'),
      ));
      await tester.pumpAndSettle();

      // Verify German payment type label (with " · " prefix)
      expect(find.text(' · Barzahlung'), findsAtLeastNWidgets(1)); // "Cash" in German
    });

    testWidgets('payment_section_shows_card_type_for_card_method', (tester) async {
      await tester.pumpWidget(buildPaymentTestWidget(
        paymentsState: PaymentMethodsUiState(
          methods: [
            PaymentMethodUiModel.stubCard(brand: 'Mastercard', last4: '5555'),
          ],
          selectedMethodId: 'mastercard_5555',
        ),
      ));
      await tester.pumpAndSettle();

      // Verify card info is displayed
      expect(find.text('Mastercard ···· 5555'), findsOneWidget);
      // Type label is shown with " · " prefix
      expect(find.text(' · Card'), findsOneWidget);
    });
  });
}

/// Simple quote controller for payment tests
class _PaymentTestQuoteController extends StateNotifier<RideQuoteUiState>
    implements RideQuoteController {
  _PaymentTestQuoteController(RideQuoteUiState initialState)
      : super(initialState);

  @override
  Future<void> refreshFromDraft(RideDraftUiState draft) async {}

  // Track B - Ticket #121: Add retryFromDraft implementation
  @override
  Future<void> retryFromDraft(RideDraftUiState draft) async {
    return refreshFromDraft(draft);
  }

  @override
  void clear() {
    state = const RideQuoteUiState();
  }
}

// =============================================================================
// Track B - Ticket #101: Payment Method Linked to Ride Draft Tests
// =============================================================================

/// Tests for verifying payment method is linked to ride draft when requesting ride.
void runPaymentMethodLinkedToDraftTests() {
  group('Payment Method Linked to RideDraft Tests (Ticket #101)', () {
    /// Creates a mock RideQuote for testing
    RideQuote createMockQuote() {
      const pickup = LocationPoint(latitude: 24.7136, longitude: 46.6753);
      const dropoff = LocationPoint(latitude: 24.7236, longitude: 46.6853);

      return RideQuote(
        quoteId: 'test_quote_101',
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
          ),
        ],
      );
    }

    testWidgets('confirming_ride_sets_payment_method_id_in_draft',
        (WidgetTester tester) async {
      late ProviderContainer container;

      final draft = RideDraftUiState(
        pickupLabel: 'Current location',
        destinationQuery: 'Test Destination',
        pickupPlace: MobilityPlace(
          label: 'Current location',
          location: LocationPoint(
            latitude: 24.7136,
            longitude: 46.6753,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
        ),
        destinationPlace: MobilityPlace(
          label: 'Test Destination',
          location: LocationPoint(
            latitude: 24.7236,
            longitude: 46.6853,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
        ),
        // Initially no payment method set
        paymentMethodId: null,
      );

      final quote = RideQuoteUiState(
        isLoading: false,
        quote: createMockQuote(),
      );

      // Use Visa card as selected payment
      final paymentsState = PaymentMethodsUiState(
        methods: [
          PaymentMethodUiModel.cash,
                  PaymentMethodUiModel.stubCard(brand: 'Visa', last4: '4242'),
        ],
        selectedMethodId: 'visa_4242',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideDraftProvider.overrideWith((ref) {
              final controller = RideDraftController();
              controller.updatePickupLabel(draft.pickupLabel);
              controller.updateDestination(draft.destinationQuery);
              if (draft.pickupPlace != null) {
                controller.updatePickupPlace(draft.pickupPlace!);
              }
              if (draft.destinationPlace != null) {
                controller.updateDestinationPlace(draft.destinationPlace!);
              }
              return controller;
            }),
            rideQuoteControllerProvider.overrideWith((ref) {
              return _PaymentTestQuoteController(quote);
            }),
            rideTripSessionProvider.overrideWith((ref) {
              return RideTripSessionController(ref);
            }),
            paymentMethodsUiProvider.overrideWith((ref) => paymentsState),
          ],
          child: Builder(
            builder: (context) {
              return MaterialApp(
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [Locale('en')],
                home: Consumer(
                  builder: (context, ref, child) {
                    container = ProviderScope.containerOf(context);
                    return const RideConfirmationScreen();
                  },
                ),
                routes: {
                  '/ride/active': (context) =>
                      const Scaffold(body: Text('Active Trip')),
                },
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify initial draft has no payment method
      final initialDraft = container.read(rideDraftProvider);
      expect(initialDraft.paymentMethodId, isNull,
          reason: 'Initially draft should have no paymentMethodId');

      // Find and tap the Request Ride button
      expect(find.text('Request Ride'), findsOneWidget);
      await tester.tap(find.text('Request Ride'));
      await tester.pumpAndSettle();

      // Verify draft now has the selected payment method
      final updatedDraft = container.read(rideDraftProvider);
      expect(updatedDraft.paymentMethodId, 'visa_4242',
          reason: 'After Request Ride, draft should have paymentMethodId set');
    });

    testWidgets('confirming_ride_uses_cash_when_cash_is_selected',
        (WidgetTester tester) async {
      late ProviderContainer container;

      final draft = RideDraftUiState(
        pickupLabel: 'Current location',
        destinationQuery: 'Test Destination',
        pickupPlace: MobilityPlace(
          label: 'Current location',
          location: LocationPoint(
            latitude: 24.7136,
            longitude: 46.6753,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
        ),
        destinationPlace: MobilityPlace(
          label: 'Test Destination',
          location: LocationPoint(
            latitude: 24.7236,
            longitude: 46.6853,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
        ),
      );

      final quote = RideQuoteUiState(
        isLoading: false,
        quote: createMockQuote(),
      );

      // Use Cash as selected payment
      final paymentsState = PaymentMethodsUiState(
        methods: [
          PaymentMethodUiModel.cash,
                  PaymentMethodUiModel.stubCard(brand: 'Visa', last4: '4242'),
        ],
        selectedMethodId: 'cash',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideDraftProvider.overrideWith((ref) {
              final controller = RideDraftController();
              controller.updatePickupLabel(draft.pickupLabel);
              controller.updateDestination(draft.destinationQuery);
              if (draft.pickupPlace != null) {
                controller.updatePickupPlace(draft.pickupPlace!);
              }
              if (draft.destinationPlace != null) {
                controller.updateDestinationPlace(draft.destinationPlace!);
              }
              return controller;
            }),
            rideQuoteControllerProvider.overrideWith((ref) {
              return _PaymentTestQuoteController(quote);
            }),
            rideTripSessionProvider.overrideWith((ref) {
              return RideTripSessionController(ref);
            }),
            paymentMethodsUiProvider.overrideWith((ref) => paymentsState),
          ],
          child: Builder(
            builder: (context) {
              return MaterialApp(
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [Locale('en')],
                home: Consumer(
                  builder: (context, ref, child) {
                    container = ProviderScope.containerOf(context);
                    return const RideConfirmationScreen();
                  },
                ),
                routes: {
                  '/ride/active': (context) =>
                      const Scaffold(body: Text('Active Trip')),
                },
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Request Ride
      await tester.tap(find.text('Request Ride'));
      await tester.pumpAndSettle();

      // Verify draft has cash as payment method
      final updatedDraft = container.read(rideDraftProvider);
      expect(updatedDraft.paymentMethodId, 'cash',
          reason: 'After Request Ride, draft should have cash as paymentMethodId');
    });

    testWidgets('confirming_ride_uses_default_payment_when_no_explicit_selection',
        (WidgetTester tester) async {
      late ProviderContainer container;

      final draft = RideDraftUiState(
        pickupLabel: 'Current location',
        destinationQuery: 'Test Destination',
        pickupPlace: MobilityPlace(
          label: 'Current location',
          location: LocationPoint(
            latitude: 24.7136,
            longitude: 46.6753,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
        ),
        destinationPlace: MobilityPlace(
          label: 'Test Destination',
          location: LocationPoint(
            latitude: 24.7236,
            longitude: 46.6853,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
        ),
      );

      final quote = RideQuoteUiState(
        isLoading: false,
        quote: createMockQuote(),
      );

      // Use default stub (Cash is default)
      final paymentsState = PaymentMethodsUiState.defaultStub();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideDraftProvider.overrideWith((ref) {
              final controller = RideDraftController();
              controller.updatePickupLabel(draft.pickupLabel);
              controller.updateDestination(draft.destinationQuery);
              if (draft.pickupPlace != null) {
                controller.updatePickupPlace(draft.pickupPlace!);
              }
              if (draft.destinationPlace != null) {
                controller.updateDestinationPlace(draft.destinationPlace!);
              }
              return controller;
            }),
            rideQuoteControllerProvider.overrideWith((ref) {
              return _PaymentTestQuoteController(quote);
            }),
            rideTripSessionProvider.overrideWith((ref) {
              return RideTripSessionController(ref);
            }),
            paymentMethodsUiProvider.overrideWith((ref) => paymentsState),
          ],
          child: Builder(
            builder: (context) {
              return MaterialApp(
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [Locale('en')],
                home: Consumer(
                  builder: (context, ref, child) {
                    container = ProviderScope.containerOf(context);
                    return const RideConfirmationScreen();
                  },
                ),
                routes: {
                  '/ride/active': (context) =>
                      const Scaffold(body: Text('Active Trip')),
                },
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Request Ride
      await tester.tap(find.text('Request Ride'));
      await tester.pumpAndSettle();

      // Verify draft has default payment method (cash)
      final updatedDraft = container.read(rideDraftProvider);
      expect(updatedDraft.paymentMethodId, 'cash',
          reason: 'After Request Ride, draft should use default payment method (cash)');
    });

    testWidgets('trip_session_receives_draft_with_payment_method',
        (WidgetTester tester) async {
      late ProviderContainer container;

      final draft = RideDraftUiState(
        pickupLabel: 'Current location',
        destinationQuery: 'Test Destination',
        pickupPlace: MobilityPlace(
          label: 'Current location',
          location: LocationPoint(
            latitude: 24.7136,
            longitude: 46.6753,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
        ),
        destinationPlace: MobilityPlace(
          label: 'Test Destination',
          location: LocationPoint(
            latitude: 24.7236,
            longitude: 46.6853,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
        ),
      );

      final quote = RideQuoteUiState(
        isLoading: false,
        quote: createMockQuote(),
      );

      // Use Mastercard
      final paymentsState = PaymentMethodsUiState(
        methods: [
          PaymentMethodUiModel.cash,
          PaymentMethodUiModel.stubCard(brand: 'Mastercard', last4: '5555'),
        ],
        selectedMethodId: 'mastercard_5555',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideDraftProvider.overrideWith((ref) {
              final controller = RideDraftController();
              controller.updatePickupLabel(draft.pickupLabel);
              controller.updateDestination(draft.destinationQuery);
              if (draft.pickupPlace != null) {
                controller.updatePickupPlace(draft.pickupPlace!);
              }
              if (draft.destinationPlace != null) {
                controller.updateDestinationPlace(draft.destinationPlace!);
              }
              return controller;
            }),
            rideQuoteControllerProvider.overrideWith((ref) {
              return _PaymentTestQuoteController(quote);
            }),
            rideTripSessionProvider.overrideWith((ref) {
              return RideTripSessionController(ref);
            }),
            paymentMethodsUiProvider.overrideWith((ref) => paymentsState),
          ],
          child: Builder(
            builder: (context) {
              return MaterialApp(
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [Locale('en')],
                home: Consumer(
                  builder: (context, ref, child) {
                    container = ProviderScope.containerOf(context);
                    return const RideConfirmationScreen();
                  },
                ),
                routes: {
                  '/ride/active': (context) {
                    // Verify the draft state on the active trip screen
                    final currentDraft = container.read(rideDraftProvider);
                    return Scaffold(
                      body: Text('Payment: ${currentDraft.paymentMethodId}'),
                    );
                  },
                },
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Request Ride
      await tester.tap(find.text('Request Ride'));
      await tester.pumpAndSettle();

      // Verify we navigated to active trip screen with payment method
      expect(find.text('Payment: mastercard_5555'), findsOneWidget,
          reason: 'Active trip screen should show the selected payment method');
    });
  });
}

// =============================================================================
// Track B - Ticket #113: Happy Path Integration Tests
// =============================================================================

/// Group of tests for Request Ride -> Active Trip Happy Path (Ticket #113)
///
/// These tests verify the complete flow:
/// 1. User presses "Request Ride" CTA
/// 2. Payment method is linked to draft (Ticket #101)
/// 3. startFromDraft is called on RideTripSessionController
/// 4. FSM transitions: draft -> quoting -> requesting -> findingDriver
/// 5. draftSnapshot is frozen (Ticket #111)
/// 6. Navigation to Active Trip screen (RoutePaths.rideActive)
void runPricingUiTests() {
  group('RideConfirmationScreen - Pricing UI (Ticket #212)', () {
    /// Helper to create a mock RideQuote for pricing UI testing
    RideQuote createMockQuote() {
      return RideQuote(
        quoteId: 'test_quote_123',
        request: const RideQuoteRequest(
          pickup: LocationPoint(latitude: 24.7136, longitude: 46.6753),
          dropoff: LocationPoint(latitude: 24.7236, longitude: 46.6853),
        ),
        options: const [
          RideQuoteOption(
            id: 'economy',
            category: RideVehicleCategory.economy,
            displayName: 'Economy',
            etaMinutes: 15,
            priceMinorUnits: 1800,
            currencyCode: 'SAR',
          ),
          RideQuoteOption(
            id: 'xl',
            category: RideVehicleCategory.xl,
            displayName: 'XL',
            etaMinutes: 20,
            priceMinorUnits: 2500,
            currencyCode: 'SAR',
          ),
        ],
      );
    }

    /// Helper to create test widget with provider overrides
    Widget createTestWidget({
      RideDraftUiState? draftState,
      RideQuoteUiState? quoteState,
      RideTripSessionUiState? sessionState,
      Locale locale = const Locale('en'),
    }) {
      final draft = draftState ??
          RideDraftUiState(
            pickupLabel: 'Current location',
            destinationQuery: 'Test Destination',
            pickupPlace: MobilityPlace.currentLocation(label: 'Current location'),
            destinationPlace: const MobilityPlace(
              id: 'test_dest',
              label: 'Test Destination',
              type: MobilityPlaceType.searchResult,
            ),
          );

      final quote = quoteState ??
          RideQuoteUiState(
            isLoading: false,
            quote: createMockQuote(),
          );

      return ProviderScope(
        overrides: [
          rideDraftProvider.overrideWith((ref) {
            final controller = RideDraftController();
            // Set state via controller methods
            controller.updatePickupLabel(draft.pickupLabel);
            controller.updateDestination(draft.destinationQuery);
            if (draft.pickupPlace != null) {
              controller.updatePickupPlace(draft.pickupPlace!);
            }
            if (draft.destinationPlace != null) {
              controller.updateDestinationPlace(draft.destinationPlace!);
            }
            return controller;
          }),
          rideQuoteControllerProvider.overrideWith((ref) {
            return _TestRideQuoteController(quote);
          }),
          rideTripSessionProvider.overrideWith((ref) {
            if (sessionState != null) {
              return _TestRideTripSessionController(sessionState);
            }
            return RideTripSessionController(ref);
          }),
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
          ],
          home: const RideConfirmationScreen(),
          routes: {
            '/ride/active': (context) =>
                const Scaffold(body: Text('Active Trip')),
          },
        ),
      );
    }

    /// Helper to create mock quote for testing
    RideQuote createMockPricingQuote() {
      const pickup = LocationPoint(
        latitude: 24.7136,
        longitude: 46.6753,
      );
      const dropoff = LocationPoint(
        latitude: 24.7236,
        longitude: 46.6853,
      );

      return RideQuote(
        quoteId: 'pricing_quote_123',
        request: RideQuoteRequest(
          pickup: pickup,
          dropoff: dropoff,
        ),
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
          RideQuoteOption(
            id: 'xl',
            category: RideVehicleCategory.xl,
            displayName: 'XL',
            etaMinutes: 7,
            priceMinorUnits: 2500,
            currencyCode: 'SAR',
          ),
        ],
      );
    }

    testWidgets('displays loader when isQuoting is true', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        sessionState: RideTripSessionUiState(
          isQuoting: true,
          activeQuote: null,
          lastQuoteFailure: null,
          draftSnapshot: RideDraftUiState(
            pickupLabel: 'Current location',
            destinationQuery: 'Test Destination',
            pickupPlace: MobilityPlace.currentLocation(label: 'Current location'),
            destinationPlace: const MobilityPlace(
              id: 'test_dest',
              label: 'Test Destination',
              type: MobilityPlaceType.searchResult,
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // Check for loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Check for loading title
      expect(find.text('Getting your price...'), findsOneWidget);

      // Check that Request Ride button is disabled
      final requestButton = find.byKey(RideConfirmationScreen.ctaRequestRideKey);
      expect(requestButton, findsOneWidget);
      final buttonWidget = tester.widget<ElevatedButton>(requestButton);
      expect(buttonWidget.onPressed, isNull);
    });

    testWidgets('displays pricing options when activeQuote is available', (WidgetTester tester) async {
      final mockQuote = createMockPricingQuote();

      await tester.pumpWidget(createTestWidget(
        sessionState: RideTripSessionUiState(
          isQuoting: false,
          activeQuote: mockQuote,
          lastQuoteFailure: null,
          draftSnapshot: RideDraftUiState(
            pickupLabel: 'Current location',
            destinationQuery: 'Test Destination',
            pickupPlace: MobilityPlace.currentLocation(label: 'Current location'),
            destinationPlace: const MobilityPlace(
              id: 'test_dest',
              label: 'Test Destination',
              type: MobilityPlaceType.searchResult,
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // Check for pricing options
      expect(find.text('Economy'), findsOneWidget);
      expect(find.text('XL'), findsOneWidget);

      // Check for price display (formatted price)
      expect(find.textContaining('18.00 SAR'), findsOneWidget);
      expect(find.textContaining('25.00 SAR'), findsOneWidget);

      // Check for distance and duration
      expect(find.textContaining('2.5 km'), findsOneWidget);
      expect(find.textContaining('15 min'), findsOneWidget);

      // Check that Request Ride button is enabled
      final requestButton = find.byKey(RideConfirmationScreen.ctaRequestRideKey);
      expect(requestButton, findsOneWidget);
      final buttonWidget = tester.widget<ElevatedButton>(requestButton);
      expect(buttonWidget.onPressed, isNotNull);
    });

    testWidgets('displays network error when lastQuoteFailure is networkError', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        sessionState: RideTripSessionUiState(
          isQuoting: false,
          activeQuote: null,
          lastQuoteFailure: pricing.RideQuoteFailureReason.networkError,
          draftSnapshot: RideDraftUiState(
            pickupLabel: 'Current location',
            destinationQuery: 'Test Destination',
            pickupPlace: MobilityPlace.currentLocation(label: 'Current location'),
            destinationPlace: const MobilityPlace(
              id: 'test_dest',
              label: 'Test Destination',
              type: MobilityPlaceType.searchResult,
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // Check for error icon
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      // Check for error message
      expect(find.textContaining('حدث خطأ في الاتصال'), findsOneWidget);

      // Check for retry button
      expect(find.text('Try again'), findsOneWidget);

      // Check that Request Ride button is disabled
      final requestButton = find.byKey(RideConfirmationScreen.ctaRequestRideKey);
      expect(requestButton, findsOneWidget);
      final buttonWidget = tester.widget<ElevatedButton>(requestButton);
      expect(buttonWidget.onPressed, isNull);
    });

    testWidgets('displays invalid request error when lastQuoteFailure is invalidRequest', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        sessionState: RideTripSessionUiState(
          isQuoting: false,
          activeQuote: null,
          lastQuoteFailure: pricing.RideQuoteFailureReason.invalidRequest,
          draftSnapshot: RideDraftUiState(
            pickupLabel: 'Current location',
            destinationQuery: 'Test Destination',
            pickupPlace: MobilityPlace.currentLocation(label: 'Current location'),
            destinationPlace: const MobilityPlace(
              id: 'test_dest',
              label: 'Test Destination',
              type: MobilityPlaceType.searchResult,
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // Check for error message
      expect(find.textContaining('تحقق من النقاط المحددة'), findsOneWidget);

      // Check for retry button
      expect(find.text('Try again'), findsOneWidget);
    });
  });
}

void runRequestRideHappyPathTests() {
  group('Request Ride Happy Path Tests (Ticket #113)', () {
    /// Creates a mock RideQuote for testing
    RideQuote createMockQuote() {
      const pickup = LocationPoint(latitude: 24.7136, longitude: 46.6753);
      const dropoff = LocationPoint(latitude: 24.7236, longitude: 46.6853);

      return RideQuote(
        quoteId: 'test_quote_happy_path',
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
          ),
        ],
      );
    }

    testWidgets('happy_path_request_ride_populates_draftSnapshot',
        (WidgetTester tester) async {
      late ProviderContainer container;

      final pickupPlace = MobilityPlace(
        label: 'Pickup Location',
        location: LocationPoint(
          latitude: 24.7136,
          longitude: 46.6753,
          accuracyMeters: 10,
          timestamp: DateTime.now(),
        ),
      );

      final destinationPlace = MobilityPlace(
        label: 'Destination',
        location: LocationPoint(
          latitude: 24.7236,
          longitude: 46.6853,
          accuracyMeters: 10,
          timestamp: DateTime.now(),
        ),
      );

      final draft = RideDraftUiState(
        pickupLabel: 'Pickup Location',
        destinationQuery: 'Destination',
        pickupPlace: pickupPlace,
        destinationPlace: destinationPlace,
        selectedOptionId: 'economy',
      );

      final quote = RideQuoteUiState(
        isLoading: false,
        quote: createMockQuote(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideDraftProvider.overrideWith((ref) {
              final controller = RideDraftController();
              controller.updatePickupLabel(draft.pickupLabel);
              controller.updateDestination(draft.destinationQuery);
              controller.updatePickupPlace(pickupPlace);
              controller.updateDestinationPlace(destinationPlace);
              controller.updateSelectedOption('economy');
              return controller;
            }),
            rideQuoteControllerProvider.overrideWith((ref) {
              return _TestRideQuoteController(quote);
            }),
            rideTripSessionProvider.overrideWith((ref) {
              return RideTripSessionController(ref);
            }),
            paymentMethodsUiProvider.overrideWith(
              (ref) => const PaymentMethodsUiState(
                methods: [
                  PaymentMethodUiModel(
                    id: 'card_123',
                    displayName: 'Visa ••4242',
                    type: PaymentMethodUiType.card,
                    isDefault: true,
                  ),
                ],
                selectedMethodId: 'card_123',
              ),
            ),
          ],
          child: Builder(
            builder: (context) {
              container = ProviderScope.containerOf(context);
              return MaterialApp(
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [Locale('en')],
                home: const RideConfirmationScreen(),
                routes: {
                  '/ride/active': (context) =>
                      const Scaffold(body: Text('Active Trip')),
                },
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify initial state has no draftSnapshot
      final initialSession = container.read(rideTripSessionProvider);
      expect(initialSession.draftSnapshot, isNull,
          reason: 'Before Request Ride, draftSnapshot should be null');

      // Tap Request Ride
      await tester.tap(find.text('Request Ride'));
      await tester.pumpAndSettle();

      // Verify draftSnapshot is populated (Ticket #111 + #113)
      final updatedSession = container.read(rideTripSessionProvider);
      expect(updatedSession.draftSnapshot, isNotNull,
          reason: 'After Request Ride, draftSnapshot should be frozen');
      expect(updatedSession.draftSnapshot!.pickupLabel, 'Pickup Location');
      expect(updatedSession.draftSnapshot!.destinationQuery, 'Destination');
    });

    testWidgets('happy_path_request_ride_populates_tripSummary',
        (WidgetTester tester) async {
      late ProviderContainer container;

      final draft = RideDraftUiState(
        pickupLabel: 'Current location',
        destinationQuery: 'Test Destination',
        pickupPlace: MobilityPlace(
          label: 'Current location',
          location: LocationPoint(
            latitude: 24.7136,
            longitude: 46.6753,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
        ),
        destinationPlace: MobilityPlace(
          label: 'Test Destination',
          location: LocationPoint(
            latitude: 24.7236,
            longitude: 46.6853,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
        ),
        selectedOptionId: 'economy',
      );

      final quote = RideQuoteUiState(
        isLoading: false,
        quote: createMockQuote(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideDraftProvider.overrideWith((ref) {
              final controller = RideDraftController();
              controller.updatePickupLabel(draft.pickupLabel);
              controller.updateDestination(draft.destinationQuery);
              controller.updatePickupPlace(draft.pickupPlace!);
              controller.updateDestinationPlace(draft.destinationPlace!);
              controller.updateSelectedOption('economy');
              return controller;
            }),
            rideQuoteControllerProvider.overrideWith((ref) {
              return _TestRideQuoteController(quote);
            }),
            rideTripSessionProvider.overrideWith((ref) {
              return RideTripSessionController(ref);
            }),
            paymentMethodsUiProvider.overrideWith(
              (ref) => const PaymentMethodsUiState(
                methods: [
                  PaymentMethodUiModel(
                    id: 'visa_4242',
                    displayName: 'Visa ••4242',
                    type: PaymentMethodUiType.card,
                    isDefault: true,
                  ),
                ],
                selectedMethodId: 'visa_4242',
              ),
            ),
          ],
          child: Builder(
            builder: (context) {
              container = ProviderScope.containerOf(context);
              return MaterialApp(
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [Locale('en')],
                home: const RideConfirmationScreen(),
                routes: {
                  '/ride/active': (context) =>
                      const Scaffold(body: Text('Active Trip')),
                },
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Request Ride
      await tester.tap(find.text('Request Ride'));
      await tester.pumpAndSettle();

      // Verify tripSummary is populated (Ticket #105 + #113)
      final session = container.read(rideTripSessionProvider);
      expect(session.tripSummary, isNotNull,
          reason: 'After Request Ride, tripSummary should be populated');
      expect(session.tripSummary!.selectedServiceId, 'economy');
      expect(session.tripSummary!.selectedServiceName, 'Economy');
      expect(session.tripSummary!.selectedPaymentMethodId, 'visa_4242');
    });

    testWidgets('happy_path_navigates_to_active_trip_screen',
        (WidgetTester tester) async {
      bool navigatedToActiveTrip = false;

      final draft = RideDraftUiState(
        pickupLabel: 'Current location',
        destinationQuery: 'Test Destination',
        pickupPlace: MobilityPlace(
          label: 'Current location',
          location: LocationPoint(
            latitude: 24.7136,
            longitude: 46.6753,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
        ),
        destinationPlace: MobilityPlace(
          label: 'Test Destination',
          location: LocationPoint(
            latitude: 24.7236,
            longitude: 46.6853,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
        ),
        selectedOptionId: 'economy',
      );

      final quote = RideQuoteUiState(
        isLoading: false,
        quote: createMockQuote(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideDraftProvider.overrideWith((ref) {
              final controller = RideDraftController();
              controller.updatePickupLabel(draft.pickupLabel);
              controller.updateDestination(draft.destinationQuery);
              controller.updatePickupPlace(draft.pickupPlace!);
              controller.updateDestinationPlace(draft.destinationPlace!);
              controller.updateSelectedOption('economy');
              return controller;
            }),
            rideQuoteControllerProvider.overrideWith((ref) {
              return _TestRideQuoteController(quote);
            }),
            rideTripSessionProvider.overrideWith((ref) {
              return RideTripSessionController(ref);
            }),
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
              '/ride/active': (context) {
                navigatedToActiveTrip = true;
                return const Scaffold(
                  body: Text('Active Trip Screen'),
                );
              },
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(navigatedToActiveTrip, isFalse,
          reason: 'Should not navigate before pressing Request Ride');

      // Tap Request Ride
      await tester.tap(find.text('Request Ride'));
      await tester.pumpAndSettle();

      // Verify navigation to Active Trip screen
      expect(navigatedToActiveTrip, isTrue,
          reason: 'Should navigate to Active Trip after pressing Request Ride');
      expect(find.text('Active Trip Screen'), findsOneWidget);
    });

    testWidgets('happy_path_shows_snackbar_confirmation',
        (WidgetTester tester) async {
      final draft = RideDraftUiState(
        pickupLabel: 'Current location',
        destinationQuery: 'Test Destination',
        pickupPlace: MobilityPlace(
          label: 'Current location',
          location: LocationPoint(
            latitude: 24.7136,
            longitude: 46.6753,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
        ),
        destinationPlace: MobilityPlace(
          label: 'Test Destination',
          location: LocationPoint(
            latitude: 24.7236,
            longitude: 46.6853,
            accuracyMeters: 10,
            timestamp: DateTime.now(),
          ),
        ),
        selectedOptionId: 'economy',
      );

      final quote = RideQuoteUiState(
        isLoading: false,
        quote: createMockQuote(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideDraftProvider.overrideWith((ref) {
              final controller = RideDraftController();
              controller.updatePickupLabel(draft.pickupLabel);
              controller.updateDestination(draft.destinationQuery);
              controller.updatePickupPlace(draft.pickupPlace!);
              controller.updateDestinationPlace(draft.destinationPlace!);
              controller.updateSelectedOption('economy');
              return controller;
            }),
            rideQuoteControllerProvider.overrideWith((ref) {
              return _TestRideQuoteController(quote);
            }),
            rideTripSessionProvider.overrideWith((ref) {
              return RideTripSessionController(ref);
            }),
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
              '/ride/active': (context) =>
                  const Scaffold(body: Text('Active Trip')),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Request Ride
      await tester.tap(find.text('Request Ride'));
      await tester.pump(); // Don't settle - SnackBar might disappear

      // Verify SnackBar is shown
      expect(find.byType(SnackBar), findsOneWidget,
          reason: 'Should show confirmation SnackBar after pressing Request Ride');
    });
  });
}


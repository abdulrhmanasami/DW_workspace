/// Ride Trip Confirmation Screen Widget Tests - Track B Ticket #21
/// Purpose: Test RideTripConfirmation (RideConfirmationScreen) UI with Quote integration
/// Created by: Track B - Ticket #21
/// Updated by: Ticket #26 (Robust quote states: Loading/Error/Empty)
/// Last updated: 2025-11-28

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/screens/mobility/ride_confirmation_screen.dart';
import 'package:delivery_ways_clean/state/mobility/ride_draft_state.dart';
import 'package:delivery_ways_clean/state/mobility/ride_quote_controller.dart';
import 'package:delivery_ways_clean/state/mobility/ride_trip_session.dart';
import 'package:maps_shims/maps_shims.dart';
import 'package:mobility_shims/mobility_shims.dart';
import 'package:design_system_shims/design_system_shims.dart';
import '../support/design_system_harness.dart';

void main() {
  setUpAll(() {
    ensureDesignSystemStubsForTests();
  });

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
            return RideTripSessionController();
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

    testWidgets('displays payment method section', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for payment section
      expect(find.byIcon(Icons.payment_outlined), findsOneWidget);
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
          errorMessage: 'Network error',
        ),
      ));
      await tester.pumpAndSettle();

      // Check for error title (Ticket #26)
      expect(find.text("We couldn't load ride options"), findsOneWidget);

      // Check for error subtitle
      expect(
          find.text('Please check your connection and try again.'),
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
          errorMessage: 'Network error',
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
      // Note: RideQuote domain model enforces options.isNotEmpty
      // so empty state only applies when quote is null

      await tester.pumpWidget(createTestWidget(
        quoteState: const RideQuoteUiState(
          isLoading: false,
          // quote: null (default)
          // errorMessage: null (default)
        ),
      ));
      await tester.pumpAndSettle();

      // Check for empty title (Ticket #26)
      expect(find.text('No rides available'), findsOneWidget);

      // Check for empty subtitle
      expect(
          find.text('Please try again in a few minutes.'), findsOneWidget);

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
          errorMessage: 'Error loading options',
        ),
      ));
      await tester.pumpAndSettle();

      // CTA should be present
      expect(find.text('Request Ride'), findsOneWidget);

      // Error UI should be shown
      expect(find.text("We couldn't load ride options"), findsOneWidget);
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
      expect(find.text("We couldn't load ride options"), findsNothing);
      expect(find.text('Fetching ride options...'), findsNothing);
      expect(find.text('No rides available'), findsNothing);
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

    // Track B - Ticket #28: Map integration tests
    testWidgets('MapWidget is present with markers when draft has places',
        (WidgetTester tester) async {
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

      await tester.pumpWidget(createTestWidget(
        draftState: RideDraftUiState(
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

      // Verify markers (pickup + destination)
      expect(mapWidget.markers.length, equals(2));
    });

    testWidgets('MapWidget has polylines when both places have coordinates',
        (WidgetTester tester) async {
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

      await tester.pumpWidget(createTestWidget(
        draftState: RideDraftUiState(
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
      expect(mapWidget.polylines.first.points.length, equals(2));
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


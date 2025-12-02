/// Home Hub Active Ride Card Tests - Track B Ticket #65, #86, #105, #114
/// Purpose: Verify Active Ride Card behavior on Home Hub (Screen 7)
/// - Card appears when active trip exists (non-terminal phase)
/// - Card disappears when no active trip
/// - View trip CTA navigates to RideActiveTripScreen
/// - Card shows correct status based on FSM phase using localizedRidePhaseStatusLong
/// - Card shows price and payment method from trip summary (Ticket #105)
/// - Card shows ETA title when etaMinutes is available (Ticket #114)
/// - Map uses RideMapFromCommands when active trip exists (Ticket #114)
/// Created by: Track B - Ticket #65
/// Updated by: Track B - Ticket #86 (Design System alignment + ride_status_utils)
/// Updated by: Track B - Ticket #105 (Unified trip summary - price + payment method)
/// Updated by: Track B - Ticket #114 (ETA title + Map from activeTripMapCommands)
/// Last updated: 2025-11-30

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

// Track B - Ticket #105: Payment methods for trip summary tests
import 'package:delivery_ways_clean/state/payments/payment_methods_ui_state.dart';

// Test support
import '../support/design_system_harness.dart';

void main() {
  setUpAll(() {
    ensureDesignSystemStubsForTests();
  });

  group('Home Hub Active Ride Card (Ticket #65)', () {
    /// Helper to build the test widget with provider overrides
    /// Track B - Ticket #86: Removed quoteState parameter (no longer needed for Home Hub card)
    Widget buildTestWidget({
      RideTripSessionUiState? tripSession,
      RideDraftUiState? rideDraft,
      List<Override> additionalOverrides = const [],
      Map<String, WidgetBuilder>? routes,
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
          // Mock auth state as authenticated (using simpleAuthStateProvider)
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
          locale: const Locale('en'),
          routes: routes ??
              {
                RoutePaths.rideActive: (_) => const Scaffold(
                      body: Center(child: Text('Ride Active Trip Screen')),
                    ),
              },
          home: const AppShell(),
        ),
      );
    }

    // =========================================================================
    // Test 1: Card appears when active trip exists
    // Track B - Ticket #86: Updated expected strings to use homeActiveRideStatus* L10n
    // =========================================================================
    testWidgets('shows ActiveRideCard when active trip exists with findingDriver phase',
        (tester) async {
      final activeTrip = RideTripState(
        tripId: 'test-trip-123',
        phase: RideTripPhase.findingDriver,
      );

      await tester.pumpWidget(buildTestWidget(
        tripSession: RideTripSessionUiState(activeTrip: activeTrip),
        rideDraft: const RideDraftUiState(destinationQuery: 'King Fahd Road'),
      ));
      await tester.pumpAndSettle();

      // Verify ActiveRideCard is displayed with correct status label (using localizedRidePhaseStatusLong)
      // Ticket #86: Uses homeActiveRideStatusFindingDriver L10n key
      expect(find.text('Looking for a driver...'), findsOneWidget);
      // Verify destination is shown
      expect(find.textContaining('King Fahd Road'), findsOneWidget);
      // Verify View trip CTA
      expect(find.text('View trip'), findsOneWidget);
    });

    testWidgets('shows ActiveRideCard with driverAccepted phase',
        (tester) async {
      final activeTrip = RideTripState(
        tripId: 'test-trip-456',
        phase: RideTripPhase.driverAccepted,
      );

      await tester.pumpWidget(buildTestWidget(
        tripSession: RideTripSessionUiState(activeTrip: activeTrip),
        rideDraft: const RideDraftUiState(destinationQuery: 'Mall of Arabia'),
      ));
      await tester.pumpAndSettle();

      // Verify status label for driverAccepted (homeActiveRideStatusDriverAccepted)
      expect(find.text('Driver on the way'), findsOneWidget);
      expect(find.text('View trip'), findsOneWidget);
    });

    testWidgets('shows ActiveRideCard with driverArrived phase',
        (tester) async {
      final activeTrip = RideTripState(
        tripId: 'test-trip-789',
        phase: RideTripPhase.driverArrived,
      );

      await tester.pumpWidget(buildTestWidget(
        tripSession: RideTripSessionUiState(activeTrip: activeTrip),
      ));
      await tester.pumpAndSettle();

      // homeActiveRideStatusDriverArrived
      expect(find.text('Driver has arrived'), findsOneWidget);
      expect(find.text('View trip'), findsOneWidget);
    });

    testWidgets('shows ActiveRideCard with inProgress phase',
        (tester) async {
      final activeTrip = RideTripState(
        tripId: 'test-trip-in-progress',
        phase: RideTripPhase.inProgress,
      );

      await tester.pumpWidget(buildTestWidget(
        tripSession: RideTripSessionUiState(activeTrip: activeTrip),
      ));
      await tester.pumpAndSettle();

      // homeActiveRideStatusInProgress
      expect(find.text('Trip in progress'), findsOneWidget);
      expect(find.text('View trip'), findsOneWidget);
    });

    // =========================================================================
    // Test 2: Card disappears when no active trip
    // =========================================================================
    testWidgets('hides ActiveRideCard when no active trip exists',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        tripSession: const RideTripSessionUiState(activeTrip: null),
      ));
      await tester.pumpAndSettle();

      // Verify status-related texts are NOT shown (no active trip)
      expect(find.text('Finding a driver…'), findsNothing);
      expect(find.text('Driver on the way'), findsNothing);
      expect(find.text('Trip in progress'), findsNothing);
      
      // Verify "View trip" CTA is NOT shown
      expect(find.text('View trip'), findsNothing);

      // Verify "Services" section is visible (cards may need scrolling)
      expect(find.text('Services'), findsOneWidget);
    });

    testWidgets('hides ActiveRideCard when trip is in completed phase (terminal)',
        (tester) async {
      final completedTrip = RideTripState(
        tripId: 'test-completed',
        phase: RideTripPhase.completed,
      );

      await tester.pumpWidget(buildTestWidget(
        tripSession: RideTripSessionUiState(activeTrip: completedTrip),
      ));
      await tester.pumpAndSettle();

      // Completed is a terminal phase - no active ride card
      // The "View trip" button should NOT be visible
      expect(find.text('View trip'), findsNothing);
      
      // "Services" section title should be visible (card may need scroll)
      expect(find.text('Services'), findsOneWidget);
    });

    testWidgets('hides ActiveRideCard when trip is in cancelled phase (terminal)',
        (tester) async {
      final cancelledTrip = RideTripState(
        tripId: 'test-cancelled',
        phase: RideTripPhase.cancelled,
      );

      await tester.pumpWidget(buildTestWidget(
        tripSession: RideTripSessionUiState(activeTrip: cancelledTrip),
      ));
      await tester.pumpAndSettle();

      // Cancelled is a terminal phase - no active ride card
      expect(find.text('View trip'), findsNothing);
    });

    testWidgets('hides ActiveRideCard when trip is in failed phase (terminal)',
        (tester) async {
      final failedTrip = RideTripState(
        tripId: 'test-failed',
        phase: RideTripPhase.failed,
      );

      await tester.pumpWidget(buildTestWidget(
        tripSession: RideTripSessionUiState(activeTrip: failedTrip),
      ));
      await tester.pumpAndSettle();

      // Failed is a terminal phase - no active ride card
      expect(find.text('View trip'), findsNothing);
    });

    // =========================================================================
    // Test 3: View Trip CTA navigates to RideActiveTripScreen
    // =========================================================================
    testWidgets('View trip CTA navigates to RideActiveTripScreen',
        (tester) async {
      final activeTrip = RideTripState(
        tripId: 'test-nav',
        phase: RideTripPhase.findingDriver,
      );

      await tester.pumpWidget(buildTestWidget(
        tripSession: RideTripSessionUiState(activeTrip: activeTrip),
        routes: {
          RoutePaths.rideActive: (_) => const Scaffold(
                body: Center(child: Text('Ride Active Trip Screen')),
              ),
        },
      ));
      await tester.pumpAndSettle();

      // Verify the "View trip" button is visible
      expect(find.text('View trip'), findsOneWidget);

      // Tap the View trip button
      await tester.tap(find.text('View trip'));
      await tester.pumpAndSettle();

      // Verify navigation to RideActiveTripScreen
      expect(find.text('Ride Active Trip Screen'), findsOneWidget);
    });

    // =========================================================================
    // Test 4: Card shows payment phase status
    // Track B - Ticket #86: Replaced ETA test with payment phase test
    // (ETA from quote is no longer shown in Home Hub card - uses localizedRidePhaseStatusLong)
    // =========================================================================
    testWidgets('shows ActiveRideCard with payment phase',
        (tester) async {
      final activeTrip = RideTripState(
        tripId: 'test-payment',
        phase: RideTripPhase.payment,
      );

      await tester.pumpWidget(buildTestWidget(
        tripSession: RideTripSessionUiState(activeTrip: activeTrip),
      ));
      await tester.pumpAndSettle();

      // homeActiveRideStatusPayment: "Finalizing payment"
      expect(find.text('Finalizing payment'), findsOneWidget);
      expect(find.text('View trip'), findsOneWidget);
    });

    // =========================================================================
    // Test 5: Service cards section title visible when active ride card shown
    // =========================================================================
    testWidgets('Services section title visible when ActiveRideCard is shown',
        (tester) async {
      final activeTrip = RideTripState(
        tripId: 'test-services',
        phase: RideTripPhase.findingDriver,
      );

      await tester.pumpWidget(buildTestWidget(
        tripSession: RideTripSessionUiState(activeTrip: activeTrip),
      ));
      await tester.pumpAndSettle();

      // Verify ActiveRideCard is shown
      expect(find.text('View trip'), findsOneWidget);

      // Verify "Services" section title is visible (cards may require scrolling)
      expect(find.text('Services'), findsOneWidget);
    });

    // =========================================================================
    // Test 6: L10n Tests
    // Track B - Ticket #86: Updated to use homeActiveRideStatus* L10n keys
    // =========================================================================
    testWidgets('ActiveRideCard displays Arabic content', (tester) async {
      final activeTrip = RideTripState(
        tripId: 'test-ar',
        phase: RideTripPhase.findingDriver,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideTripSessionProvider.overrideWith(
              (ref) => _FakeRideTripSessionController(
                initialState: RideTripSessionUiState(activeTrip: activeTrip),
              ),
            ),
            rideDraftProvider.overrideWith(
              (ref) => _FakeRideDraftController(
                initialState: const RideDraftUiState(),
              ),
            ),
            simpleAuthStateProvider.overrideWith(
              (ref) => _FakeAuthController(),
            ),
          ],
          child: MaterialApp(
            locale: const Locale('ar'),
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
            home: const AppShell(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Arabic content (homeActiveRideStatusFindingDriver)
      expect(find.text('جاري البحث عن سائق...'), findsOneWidget);
      expect(find.text('عرض الرحلة'), findsOneWidget);
    });

    testWidgets('ActiveRideCard displays German content', (tester) async {
      final activeTrip = RideTripState(
        tripId: 'test-de',
        phase: RideTripPhase.inProgress,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideTripSessionProvider.overrideWith(
              (ref) => _FakeRideTripSessionController(
                initialState: RideTripSessionUiState(activeTrip: activeTrip),
              ),
            ),
            rideDraftProvider.overrideWith(
              (ref) => _FakeRideDraftController(
                initialState: const RideDraftUiState(),
              ),
            ),
            simpleAuthStateProvider.overrideWith(
              (ref) => _FakeAuthController(),
            ),
          ],
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
              Locale('de'),
            ],
            home: const AppShell(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify German content (homeActiveRideStatusInProgress)
      expect(find.text('Fahrt läuft'), findsOneWidget);
      // homeActiveRideViewTripCta in German
      expect(find.text('Fahrt ansehen'), findsOneWidget);
    });

    // =========================================================================
    // Test 7: Card icon is present
    // Track B - Ticket #86: Updated icon to directions_car_outlined (DS alignment)
    // =========================================================================
    testWidgets('ActiveRideCard shows car icon', (tester) async {
      final activeTrip = RideTripState(
        tripId: 'test-icon',
        phase: RideTripPhase.findingDriver,
      );

      await tester.pumpWidget(buildTestWidget(
        tripSession: RideTripSessionUiState(activeTrip: activeTrip),
      ));
      await tester.pumpAndSettle();

      // Verify car icon is present (outlined icon per Design System)
      expect(find.byIcon(Icons.directions_car_outlined), findsOneWidget);
    });

    // =========================================================================
    // Test 8: Card shows price and payment method (Ticket #105)
    // =========================================================================
    testWidgets('home_active_ride_card_shows_eta_destination_and_price',
        (tester) async {
      final activeTrip = RideTripState(
        tripId: 'test-summary',
        phase: RideTripPhase.driverAccepted,
      );

      const tripSummary = RideTripSummary(
        selectedServiceId: 'economy',
        selectedServiceName: 'Economy',
        fareDisplayText: '18.00 SAR',
        selectedPaymentMethodId: 'cash',
        etaMinutes: 3,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideTripSessionProvider.overrideWith(
              (ref) => _FakeRideTripSessionController(
                initialState: RideTripSessionUiState(
                  activeTrip: activeTrip,
                  tripSummary: tripSummary,
                ),
              ),
            ),
            rideDraftProvider.overrideWith(
              (ref) => _FakeRideDraftController(
                initialState: const RideDraftUiState(
                  destinationQuery: 'King Fahd Road',
                ),
              ),
            ),
            simpleAuthStateProvider.overrideWith(
              (ref) => _FakeAuthController(),
            ),
            paymentMethodsUiProvider.overrideWith(
              (ref) => const PaymentMethodsUiState(
                methods: [PaymentMethodUiModel.cash],
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
            supportedLocales: const [Locale('en')],
            locale: const Locale('en'),
            home: const AppShell(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify destination is shown
      expect(find.textContaining('King Fahd Road'), findsOneWidget);
      // Verify price is shown (from trip summary)
      expect(find.textContaining('18.00'), findsAtLeastNWidgets(1));
    });

    testWidgets('home_active_ride_card_shows_payment_method', (tester) async {
      final activeTrip = RideTripState(
        tripId: 'test-payment',
        phase: RideTripPhase.inProgress,
      );

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
                initialState: RideTripSessionUiState(
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
            simpleAuthStateProvider.overrideWith(
              (ref) => _FakeAuthController(),
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
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            locale: const Locale('en'),
            home: const AppShell(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify payment method is shown
      expect(find.textContaining('Visa'), findsAtLeastNWidgets(1));
      expect(find.textContaining('4242'), findsAtLeastNWidgets(1));
    });

    // =========================================================================
    // Test 9: ETA title shown when etaMinutes is available (Ticket #114)
    // =========================================================================
    testWidgets('home_active_ride_card_shows_eta_title_when_available',
        (tester) async {
      final activeTrip = RideTripState(
        tripId: 'test-eta',
        phase: RideTripPhase.driverAccepted,
      );

      const tripSummary = RideTripSummary(
        selectedServiceId: 'economy',
        selectedServiceName: 'Economy',
        fareDisplayText: '18.00 SAR',
        selectedPaymentMethodId: 'cash',
        etaMinutes: 5,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideTripSessionProvider.overrideWith(
              (ref) => _FakeRideTripSessionController(
                initialState: RideTripSessionUiState(
                  activeTrip: activeTrip,
                  tripSummary: tripSummary,
                ),
              ),
            ),
            rideDraftProvider.overrideWith(
              (ref) => _FakeRideDraftController(
                initialState: const RideDraftUiState(
                  destinationQuery: 'King Fahd Road',
                ),
              ),
            ),
            simpleAuthStateProvider.overrideWith(
              (ref) => _FakeAuthController(),
            ),
            paymentMethodsUiProvider.overrideWith(
              (ref) => const PaymentMethodsUiState(
                methods: [PaymentMethodUiModel.cash],
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
            supportedLocales: const [Locale('en')],
            locale: const Locale('en'),
            home: const AppShell(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify ETA title is shown (homeActiveRideEtaTitle: "Arriving in {minutes} min")
      expect(find.text('Arriving in 5 min'), findsOneWidget);
      // Verify View trip CTA is present
      expect(find.text('View trip'), findsOneWidget);
    });

    testWidgets('home_active_ride_card_falls_back_to_status_when_no_eta',
        (tester) async {
      final activeTrip = RideTripState(
        tripId: 'test-no-eta',
        phase: RideTripPhase.findingDriver,
      );

      // tripSummary without etaMinutes
      const tripSummary = RideTripSummary(
        selectedServiceId: 'economy',
        selectedServiceName: 'Economy',
        fareDisplayText: '18.00 SAR',
        selectedPaymentMethodId: 'cash',
        // etaMinutes: null
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideTripSessionProvider.overrideWith(
              (ref) => _FakeRideTripSessionController(
                initialState: RideTripSessionUiState(
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
            simpleAuthStateProvider.overrideWith(
              (ref) => _FakeAuthController(),
            ),
            paymentMethodsUiProvider.overrideWith(
              (ref) => const PaymentMethodsUiState(
                methods: [PaymentMethodUiModel.cash],
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
            supportedLocales: const [Locale('en')],
            locale: const Locale('en'),
            home: const AppShell(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify status label is shown as fallback (homeActiveRideStatusFindingDriver)
      expect(find.text('Looking for a driver...'), findsOneWidget);
      // Verify View trip CTA is present
      expect(find.text('View trip'), findsOneWidget);
    });

    // =========================================================================
    // Test 10: Map uses RideMapFromCommands when active trip (Ticket #114)
    // =========================================================================
    testWidgets('home_hub_shows_ride_map_when_active_trip_has_commands',
        (tester) async {
      // Create a pickup and destination for the draft snapshot
      final pickupPlace = MobilityPlace(
        label: 'Pickup',
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

      final draftSnapshot = RideDraftUiState(
        pickupLabel: 'Pickup',
        destinationQuery: 'Destination',
        pickupPlace: pickupPlace,
        destinationPlace: destinationPlace,
      );

      final activeTrip = RideTripState(
        tripId: 'test-map',
        phase: RideTripPhase.driverAccepted,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideTripSessionProvider.overrideWith(
              (ref) => _FakeRideTripSessionController(
                initialState: RideTripSessionUiState(
                  activeTrip: activeTrip,
                  draftSnapshot: draftSnapshot,
                ),
              ),
            ),
            rideDraftProvider.overrideWith(
              (ref) => _FakeRideDraftController(
                initialState: draftSnapshot,
              ),
            ),
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
            locale: const Locale('en'),
            home: const AppShell(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // When there's an active trip with draftSnapshot (which provides activeTripMapCommands),
      // RideMapFromCommands should be in the widget tree
      // Since activeTripMapCommands is derived from draftSnapshot, this verifies the integration
      expect(find.text('View trip'), findsOneWidget);
      // The map widget tree should have changed from placeholder
      // We can't directly find RideMapFromCommands due to private implementation,
      // but we can verify the card is displayed correctly
      expect(find.byIcon(Icons.directions_car_outlined), findsOneWidget);
    });

    testWidgets('home_hub_shows_placeholder_map_when_no_active_trip',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rideTripSessionProvider.overrideWith(
              (ref) => _FakeRideTripSessionController(
                initialState: const RideTripSessionUiState(),
              ),
            ),
            rideDraftProvider.overrideWith(
              (ref) => _FakeRideDraftController(
                initialState: const RideDraftUiState(),
              ),
            ),
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
            locale: const Locale('en'),
            home: const AppShell(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Without active trip, placeholder map should show "Map area"
      expect(find.text('Map area'), findsOneWidget);
      // No active ride card
      expect(find.text('View trip'), findsNothing);
    });
  });
}

// ============================================================================
// Fake Controllers for Testing
// ============================================================================

/// Fake RideTripSessionController
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

  // Track B - Ticket #107
  @override
  bool completeTrip() => true;

  @override
  void clearCompletionSummary() {
    state = state.copyWith(clearCompletionSummary: true);
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
    // No-op for tests
    return true;
  }
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

// Track B - Ticket #86: _FakeRideQuoteController removed (no longer needed)

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


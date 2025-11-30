/// Ride Flow Happy Path Test - Track B Ticket #94
/// Purpose: End-to-end widget test for Ride flow navigation and state management
/// Created by: Track B - Ticket #94
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
  void startFromDraft(RideDraftUiState draft) {}

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

  @override
  void archiveTrip({required String destinationLabel, String? amountFormatted}) {}
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

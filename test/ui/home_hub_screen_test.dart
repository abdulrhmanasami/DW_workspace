/// Home Hub Screen Widget Tests - Ticket #180
/// Purpose: Test HomeHubScreen UI components and navigation behavior
/// Created by: Ticket #180 - Home Hub V1
/// Last updated: 2025-12-03

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/app_shell/app_shell.dart';
import 'package:delivery_ways_clean/screens/home/home_hub_screen.dart';
import 'package:delivery_ways_clean/router/app_router.dart';
import 'package:delivery_ways_clean/wiring/maps_binding.dart';
import 'package:delivery_ways_clean/state/mobility/ride_trip_session.dart';
import 'package:delivery_ways_clean/state/mobility/ride_draft_state.dart';
import 'package:delivery_ways_clean/state/mobility/ride_recent_locations_providers.dart';
import 'package:delivery_ways_clean/config/feature_flags.dart';
import 'package:mobility_shims/mobility_shims.dart';

// Test support
import '../support/design_system_harness.dart';

void main() {
  setUpAll(() {
    ensureDesignSystemStubsForTests();
  });

  // Reset feature flags after each test to prevent state leakage
  setUp(() {
    FeatureFlags.resetForTests();
  });

  tearDown(() {
    FeatureFlags.resetForTests();
  });
  setUpAll(() {
    ensureDesignSystemStubsForTests();
  });

  group('HomeHubScreen Widget Tests', () {
    Widget createTestWidget({
      List<Override> overrides = const [],
      Locale locale = const Locale('en'),
      Map<String, WidgetBuilder>? routes,
    }) {
      // Include maps binding overrides for consistent map behavior in tests
      final allOverrides = [
        ...mapsOverrides,
        ...overrides,
      ];

      return ProviderScope(
        overrides: allOverrides,
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
          home: const AppShell(
            child: HomeHubScreen(),
          ),
          routes: routes ??
              {
                RoutePaths.rideDestination: (_) => const Scaffold(
                  body: Center(child: Text('Ride Destination Screen')),
                ),
              },
        ),
      );
    }

    testWidgets('displays greeting text', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Where do you want to go?'), findsOneWidget);
    });

    testWidgets('displays current location text', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Current location'), findsOneWidget);
    });

    testWidgets('displays location icon', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
    });

    testWidgets('displays map widget in the background on HomeHub', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byKey(const Key('home_hub_map')), findsOneWidget);
    });

    testWidgets('displays Ride service chip', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Ride'), findsOneWidget);
    });

    testWidgets('displays Parcels service chip when Parcels MVP is enabled', (WidgetTester tester) async {
      // Parcels MVP is enabled by default in debug mode, but let's be explicit
      await tester.pumpWidget(createTestWidget(
        overrides: [
          ...mapsOverrides,
        ],
      ));
      await tester.pump();

      expect(find.text('Parcels'), findsOneWidget);
    });

    testWidgets('displays Food service chip when Food MVP is enabled', (WidgetTester tester) async {
      // Enable Food MVP, keep Parcels as default (true)
      FeatureFlags.overrideForTests(const FeatureFlags(
        enableFoodMvpValue: true,
        enableParcelsMvpValue: true,
      ));

      await tester.pumpWidget(createTestWidget(
        overrides: [
          ...mapsOverrides,
        ],
      ));
      await tester.pump();

      expect(find.text('Food'), findsOneWidget);
    });

    testWidgets('does not display Parcels service chip when Parcels MVP is disabled', (WidgetTester tester) async {
      // Set enableParcelsMvp to false, keep Food as default (false)
      FeatureFlags.overrideForTests(const FeatureFlags(
        enableFoodMvpValue: false,
        enableParcelsMvpValue: false,
      ));

      await tester.pumpWidget(createTestWidget(
        overrides: [
          ...mapsOverrides,
        ],
      ));
      await tester.pump();

      // Parcels chip should not be visible when flag is disabled
      expect(find.text('Parcels'), findsNothing);
    });

    testWidgets('does not display Food service chip when Food MVP is disabled', (WidgetTester tester) async {
      // Set enableFoodMvp to false (default)
      FeatureFlags.overrideForTests(const FeatureFlags(
        enableFoodMvpValue: false,
        enableParcelsMvpValue: true,
      ));

      await tester.pumpWidget(createTestWidget(
        overrides: [
          ...mapsOverrides,
        ],
      ));
      await tester.pump();

      // Food chip should not be visible when flag is disabled
      expect(find.text('Food'), findsNothing);
    });

    testWidgets('navigates to RideDestinationScreen when Ride chip is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Find and tap the Ride service chip using its key
      await tester.tap(find.byKey(HomeHubScreen.rideServiceKey));
      await tester.pumpAndSettle();

      // Verify navigation to ride destination screen (mock)
      expect(find.text('Ride Destination Screen'), findsOneWidget);
    });

    testWidgets('has correct keys for service chips when all MVPs are enabled', (WidgetTester tester) async {
      // Enable both Parcels and Food MVP for this test
      FeatureFlags.overrideForTests(const FeatureFlags(
        enableFoodMvpValue: true,
        enableParcelsMvpValue: true,
      ));

      await tester.pumpWidget(createTestWidget(
        overrides: [
          ...mapsOverrides,
        ],
      ));
      await tester.pump();

      // Verify the keys are present
      expect(find.byKey(HomeHubScreen.rideServiceKey), findsOneWidget);
      expect(find.byKey(HomeHubScreen.parcelsServiceKey), findsOneWidget);
      expect(find.byKey(HomeHubScreen.foodServiceKey), findsOneWidget);
    });

    testWidgets('HomeHubScreen displays Arabic translations when locale is ar and all MVPs are enabled (Ticket #182)',
        (WidgetTester tester) async {
      // Enable both Parcels and Food MVP for this test
      FeatureFlags.overrideForTests(const FeatureFlags(
        enableFoodMvpValue: true,
        enableParcelsMvpValue: true,
      ));

      await tester.pumpWidget(createTestWidget(
        locale: const Locale('ar'),
        overrides: [
          ...mapsOverrides,
        ],
      ));
      await tester.pump();

      // Check for Arabic title
      expect(find.text('إلى أين تريد الذهاب؟'), findsOneWidget);

      // Check for Arabic current location label
      expect(find.text('موقعك الحالي'), findsOneWidget);

      // Check for Arabic service chip labels
      expect(find.text('مشاوير'), findsOneWidget);
      expect(find.text('طرود'), findsOneWidget);
      expect(find.text('طلبات الطعام'), findsOneWidget);
    });

    // Ticket #188: Search bar tests
    testWidgets('HomeHubScreen displays search bar with English placeholder (Ticket #188)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Verify search bar is displayed
      expect(find.byKey(HomeHubScreen.homeHubSearchBarKey), findsOneWidget);
      // Verify English placeholder text
      expect(find.text('Where to?'), findsOneWidget);
    });

    testWidgets('HomeHubScreen displays Arabic search placeholder when locale is ar (Ticket #188)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('ar')));
      await tester.pump();

      // Verify search bar is displayed
      expect(find.byKey(HomeHubScreen.homeHubSearchBarKey), findsOneWidget);
      // Verify Arabic placeholder text
      expect(find.text('إلى أين؟'), findsOneWidget);
    });

    // Ticket #183: Active ride card tests
    testWidgets('shows active ride card when trip is active',
        (WidgetTester tester) async {
      const activeTrip = RideTripState(
        tripId: 'test-active-trip-123',
        phase: RideTripPhase.findingDriver,
      );

      await tester.pumpWidget(createTestWidget(
        overrides: [
          ...mapsOverrides,
          rideTripSessionProvider.overrideWith(
            (ref) => _FakeRideTripSessionController(
              initialState: const RideTripSessionUiState(activeTrip: activeTrip),
            ),
          ),
        ],
      ));
      await tester.pump();

      // Verify active ride card is displayed
      expect(find.byKey(HomeHubScreen.homeHubActiveRideCardKey), findsOneWidget);
      expect(find.text('Ride in progress'), findsOneWidget);
      expect(find.byKey(HomeHubScreen.homeHubActiveRideSubtitleKey), findsOneWidget);
    });

    testWidgets('does not show active ride card when no trip is active',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        overrides: [
          ...mapsOverrides,
          rideTripSessionProvider.overrideWith(
            (ref) => _FakeRideTripSessionController(
              initialState: const RideTripSessionUiState(),
            ),
          ),
        ],
      ));
      await tester.pump();

      // Verify active ride card is not displayed
      expect(find.byKey(HomeHubScreen.homeHubActiveRideCardKey), findsNothing);
    });

    testWidgets('taps on active ride card navigates to RideActiveTripScreen',
        (WidgetTester tester) async {
      const activeTrip = RideTripState(
        tripId: 'test-active-trip-456',
        phase: RideTripPhase.driverAccepted,
      );

      await tester.pumpWidget(createTestWidget(
        overrides: [
          ...mapsOverrides,
          rideTripSessionProvider.overrideWith(
            (ref) => _FakeRideTripSessionController(
              initialState: const RideTripSessionUiState(activeTrip: activeTrip),
            ),
          ),
        ],
        routes: {
          RoutePaths.rideDestination: (_) => const Scaffold(
            body: Center(child: Text('Ride Destination Screen')),
          ),
          RoutePaths.rideActive: (_) => const Scaffold(
            body: Center(child: Text('Ride Active Trip Screen')),
          ),
        },
      ));
      await tester.pump();

      // Tap the active ride card
      await tester.tap(find.byKey(HomeHubScreen.homeHubActiveRideCardKey));
      await tester.pumpAndSettle();

      // Verify navigation to active trip screen
      expect(find.text('Ride Active Trip Screen'), findsOneWidget);
    });

    testWidgets('taps Ride chip with active trip navigates to RideActiveTripScreen',
        (WidgetTester tester) async {
      const activeTrip = RideTripState(
        tripId: 'test-active-trip-789',
        phase: RideTripPhase.inProgress,
      );

      await tester.pumpWidget(createTestWidget(
        overrides: [
          ...mapsOverrides,
          rideTripSessionProvider.overrideWith(
            (ref) => _FakeRideTripSessionController(
              initialState: const RideTripSessionUiState(activeTrip: activeTrip),
            ),
          ),
        ],
        routes: {
          RoutePaths.rideDestination: (_) => const Scaffold(
            body: Center(child: Text('Ride Destination Screen')),
          ),
          RoutePaths.rideActive: (_) => const Scaffold(
            body: Center(child: Text('Ride Active Trip Screen')),
          ),
        },
      ));
      await tester.pump();

      // Tap the Ride service chip
      await tester.tap(find.byKey(HomeHubScreen.rideServiceKey));
      await tester.pumpAndSettle();

      // Verify navigation to active trip screen (not destination)
      expect(find.text('Ride Active Trip Screen'), findsOneWidget);
      expect(find.text('Ride Destination Screen'), findsNothing);
    });

    testWidgets('taps Ride chip without active trip navigates to RideDestinationScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        overrides: [
          ...mapsOverrides,
          rideTripSessionProvider.overrideWith(
            (ref) => _FakeRideTripSessionController(
              initialState: const RideTripSessionUiState(),
            ),
          ),
        ],
        routes: {
          RoutePaths.rideDestination: (_) => const Scaffold(
            body: Center(child: Text('Ride Destination Screen')),
          ),
          RoutePaths.rideActive: (_) => const Scaffold(
            body: Center(child: Text('Ride Active Trip Screen')),
          ),
        },
      ));
      await tester.pump();

      // Tap the Ride service chip
      await tester.tap(find.byKey(HomeHubScreen.rideServiceKey));
      await tester.pumpAndSettle();

      // Verify navigation to destination screen (not active trip)
      expect(find.text('Ride Destination Screen'), findsOneWidget);
      expect(find.text('Ride Active Trip Screen'), findsNothing);
    });

    testWidgets('HomeHubScreen tapping search bar without active trip navigates to RideDestinationScreen (Ticket #188)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        overrides: [
          ...mapsOverrides,
          rideTripSessionProvider.overrideWith(
            (ref) => _FakeRideTripSessionController(
              initialState: const RideTripSessionUiState(),
            ),
          ),
        ],
        routes: {
          RoutePaths.rideDestination: (_) => const Scaffold(
            body: Center(child: Text('Ride Destination Screen')),
          ),
          RoutePaths.rideActive: (_) => const Scaffold(
            body: Center(child: Text('Ride Active Trip Screen')),
          ),
        },
      ));
      await tester.pump();

      // Tap the search bar
      await tester.tap(find.byKey(HomeHubScreen.homeHubSearchBarKey));
      await tester.pumpAndSettle();

      // Verify navigation to destination screen (not active trip)
      expect(find.text('Ride Destination Screen'), findsOneWidget);
      expect(find.text('Ride Active Trip Screen'), findsNothing);
    });

    testWidgets('HomeHubScreen tapping search bar with active trip navigates to RideActiveTripScreen (Ticket #188)',
        (WidgetTester tester) async {
      const activeTrip = RideTripState(
        tripId: 'test-active-trip-188',
        phase: RideTripPhase.inProgress,
      );

      await tester.pumpWidget(createTestWidget(
        overrides: [
          ...mapsOverrides,
          rideTripSessionProvider.overrideWith(
            (ref) => _FakeRideTripSessionController(
              initialState: const RideTripSessionUiState(activeTrip: activeTrip),
            ),
          ),
        ],
        routes: {
          RoutePaths.rideDestination: (_) => const Scaffold(
            body: Center(child: Text('Ride Destination Screen')),
          ),
          RoutePaths.rideActive: (_) => const Scaffold(
            body: Center(child: Text('Ride Active Trip Screen')),
          ),
        },
      ));
      await tester.pump();

      // Tap the search bar
      await tester.tap(find.byKey(HomeHubScreen.homeHubSearchBarKey));
      await tester.pumpAndSettle();

      // Verify navigation to active trip screen (not destination)
      expect(find.text('Ride Active Trip Screen'), findsOneWidget);
      expect(find.text('Ride Destination Screen'), findsNothing);
    });

    // Ticket #184: Coming Soon SnackBar tests
    testWidgets('HomeHubScreen shows Parcels coming soon SnackBar when Parcels chip is tapped and Parcels MVP is enabled (Ticket #184)',
        (WidgetTester tester) async {
      // Parcels MVP is enabled by default in debug mode
      await tester.pumpWidget(createTestWidget(
        overrides: [
          ...mapsOverrides,
        ],
      ));
      await tester.pump();

      // Tap the Parcels service chip
      await tester.tap(find.byKey(HomeHubScreen.parcelsServiceKey));
      await tester.pumpAndSettle();

      // Verify SnackBar with coming soon message
      expect(find.text('Parcels service is coming soon to your city.'), findsOneWidget);
    });

    testWidgets('HomeHubScreen shows Food coming soon SnackBar when Food chip is tapped and Food MVP is enabled (Ticket #184)',
        (WidgetTester tester) async {
      // Enable Food MVP for this test
      FeatureFlags.overrideForTests(const FeatureFlags(
        enableFoodMvpValue: true,
        enableParcelsMvpValue: true,
      ));

      await tester.pumpWidget(createTestWidget(
        overrides: [
          ...mapsOverrides,
        ],
      ));
      await tester.pump();

      // Tap the Food service chip
      await tester.tap(find.byKey(HomeHubScreen.foodServiceKey));
      await tester.pumpAndSettle();

      // Verify SnackBar with coming soon message
      expect(find.text('Food ordering is coming soon to your city.'), findsOneWidget);
    });

    testWidgets('HomeHubScreen displays Arabic coming soon message for Parcels when locale is ar and Parcels MVP is enabled (Ticket #184)',
        (WidgetTester tester) async {
      // Parcels MVP is enabled by default in debug mode
      await tester.pumpWidget(createTestWidget(
        locale: const Locale('ar'),
        overrides: [
          ...mapsOverrides,
        ],
      ));
      await tester.pump();

      // Tap the Parcels service chip
      await tester.tap(find.byKey(HomeHubScreen.parcelsServiceKey));
      await tester.pumpAndSettle();

      // Verify Arabic SnackBar message
      expect(find.text('خدمة الطرود قادمة قريبًا إلى مدينتك.'), findsOneWidget);
    });

    // Ticket #187: Current Location Binding tests
    testWidgets('displays current location name when location is available (Ticket #187)',
        (WidgetTester tester) async {
      final testLocation = MobilityPlace.currentLocation(label: 'King Fahd Rd, Riyadh');

      await tester.pumpWidget(createTestWidget(
        overrides: [
          ...mapsOverrides,
          rideDraftProvider.overrideWith(
            (ref) => _FakeRideDraftController(
              initialState: RideDraftUiState(pickupPlace: testLocation),
            ),
          ),
        ],
      ));
      await tester.pump();

      // Verify the location label is displayed
      expect(find.text('Current location'), findsOneWidget);
      // Verify the actual location name is displayed
      expect(find.text('King Fahd Rd, Riyadh'), findsOneWidget);
    });

    testWidgets('displays location unavailable message when location is not available (Ticket #187)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        overrides: [
          ...mapsOverrides,
          rideDraftProvider.overrideWith(
            (ref) => _FakeRideDraftController(
              initialState: const RideDraftUiState(pickupPlace: null),
            ),
          ),
        ],
      ));
      await tester.pump();

      // Verify the location label is displayed
      expect(find.text('Current location'), findsOneWidget);
      // Verify the fallback message is displayed
      expect(find.text('Location not available'), findsOneWidget);
    });

    testWidgets('displays Arabic location unavailable message when locale is ar and location is not available (Ticket #187)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        locale: const Locale('ar'),
        overrides: [
          ...mapsOverrides,
          rideDraftProvider.overrideWith(
            (ref) => _FakeRideDraftController(
              initialState: const RideDraftUiState(pickupPlace: null),
            ),
          ),
        ],
      ));
      await tester.pump();

      // Verify Arabic fallback message is displayed
      expect(find.text('لا يمكن تحديد موقعك'), findsOneWidget);
    });

    // Ticket #189: HomeHub Ride Recent Destinations Shortcuts V1 tests
    testWidgets('HomeHubScreen displays recent destinations section when recent data is available (Ticket #189)',
        (WidgetTester tester) async {
      final recentLocations = [
        const RecentLocation(
          id: 'location1',
          title: 'King Fahd Road',
          type: MobilityPlaceType.recent,
        ),
        const RecentLocation(
          id: 'location2',
          title: 'Mall of Arabia',
          type: MobilityPlaceType.recent,
        ),
      ];

      await tester.pumpWidget(createTestWidget(
        overrides: [
          ...mapsOverrides,
          recentLocationsProvider.overrideWith(
            (ref) => Stream.value(recentLocations),
          ),
        ],
      ));
      await tester.pump();

      // Verify recent destinations section is displayed
      expect(find.byKey(HomeHubScreen.homeHubRecentDestinationsSectionKey), findsOneWidget);
      expect(find.byKey(HomeHubScreen.homeHubRecentDestinationItemKey(0)), findsOneWidget);
      expect(find.byKey(HomeHubScreen.homeHubRecentDestinationItemKey(1)), findsOneWidget);
      expect(find.text('Recent destinations'), findsOneWidget);
      expect(find.text('King Fahd Road'), findsOneWidget);
      expect(find.text('Mall of Arabia'), findsOneWidget);
    });

    testWidgets('HomeHubScreen does not show recent destinations section when there is no data (Ticket #189)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        overrides: [
          ...mapsOverrides,
          recentLocationsProvider.overrideWith(
            (ref) => Stream.value([]),
          ),
        ],
      ));
      await tester.pump();

      // Verify recent destinations section is not displayed
      expect(find.byKey(HomeHubScreen.homeHubRecentDestinationsSectionKey), findsNothing);
    });

    testWidgets('HomeHubScreen tapping recent destination without active trip updates rideDraft and navigates to RideConfirmationScreen (Ticket #189)',
        (WidgetTester tester) async {
      final recentLocations = [
        const RecentLocation(
          id: 'location1',
          title: 'King Fahd Road',
          type: MobilityPlaceType.recent,
        ),
      ];

      await tester.pumpWidget(createTestWidget(
        overrides: [
          ...mapsOverrides,
          recentLocationsProvider.overrideWith(
            (ref) => Stream.value(recentLocations),
          ),
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
        ],
        routes: {
          RoutePaths.rideDestination: (_) => const Scaffold(
            body: Center(child: Text('Ride Destination Screen')),
          ),
          RoutePaths.rideConfirmation: (_) => const Scaffold(
            body: Center(child: Text('Ride Confirmation Screen')),
          ),
        },
      ));
      await tester.pump();

      // Tap the first recent destination item
      await tester.tap(find.byKey(HomeHubScreen.homeHubRecentDestinationItemKey(0)));
      await tester.pumpAndSettle();

      // Verify navigation to ride confirmation screen
      expect(find.text('Ride Confirmation Screen'), findsOneWidget);
    });

    testWidgets('HomeHubScreen tapping recent destination with active trip navigates to RideActiveTripScreen (Ticket #189)',
        (WidgetTester tester) async {
      const activeTrip = RideTripState(
        tripId: 'test-active-trip-123',
        phase: RideTripPhase.findingDriver,
      );

      final recentLocations = [
        const RecentLocation(
          id: 'location1',
          title: 'King Fahd Road',
          type: MobilityPlaceType.recent,
        ),
      ];

      await tester.pumpWidget(createTestWidget(
        overrides: [
          ...mapsOverrides,
          recentLocationsProvider.overrideWith(
            (ref) => Stream.value(recentLocations),
          ),
          rideTripSessionProvider.overrideWith(
            (ref) => _FakeRideTripSessionController(
              initialState: const RideTripSessionUiState(activeTrip: activeTrip),
            ),
          ),
        ],
        routes: {
          RoutePaths.rideDestination: (_) => const Scaffold(
            body: Center(child: Text('Ride Destination Screen')),
          ),
          RoutePaths.rideActive: (_) => const Scaffold(
            body: Center(child: Text('Ride Active Trip Screen')),
          ),
        },
      ));
      await tester.pump();

      // Tap the first recent destination item
      await tester.tap(find.byKey(HomeHubScreen.homeHubRecentDestinationItemKey(0)));
      await tester.pumpAndSettle();

      // Verify navigation to active trip screen
      expect(find.text('Ride Active Trip Screen'), findsOneWidget);
    });

    // Ticket #194: HomeHub Recent Destinations "See all" CTA V1 tests
    testWidgets('HomeHubScreen does not show See all button when there are 3 or fewer recent destinations (Ticket #194)',
        (WidgetTester tester) async {
      final recentLocations = [
        const RecentLocation(
          id: 'location1',
          title: 'King Fahd Road',
          type: MobilityPlaceType.recent,
        ),
        const RecentLocation(
          id: 'location2',
          title: 'Mall of Arabia',
          type: MobilityPlaceType.recent,
        ),
        const RecentLocation(
          id: 'location3',
          title: 'Riyadh Airport',
          type: MobilityPlaceType.recent,
        ),
      ];

      await tester.pumpWidget(createTestWidget(
        overrides: [
          ...mapsOverrides,
          recentLocationsProvider.overrideWith(
            (ref) => Stream.value(recentLocations),
          ),
        ],
      ));
      await tester.pump();

      // Verify recent destinations section is displayed
      expect(find.byKey(HomeHubScreen.homeHubRecentDestinationsSectionKey), findsOneWidget);
      expect(find.text('Recent destinations'), findsOneWidget);

      // Verify "See all" button is not displayed (only 3 items)
      expect(find.byKey(HomeHubScreen.homeHubRecentDestinationsSeeAllKey), findsNothing);
    });

    testWidgets('HomeHubScreen shows See all button when there are more than 3 recent destinations (Ticket #194)',
        (WidgetTester tester) async {
      final recentLocations = [
        const RecentLocation(
          id: 'location1',
          title: 'King Fahd Road',
          type: MobilityPlaceType.recent,
        ),
        const RecentLocation(
          id: 'location2',
          title: 'Mall of Arabia',
          type: MobilityPlaceType.recent,
        ),
        const RecentLocation(
          id: 'location3',
          title: 'Riyadh Airport',
          type: MobilityPlaceType.recent,
        ),
        const RecentLocation(
          id: 'location4',
          title: 'Olaya Towers',
          type: MobilityPlaceType.recent,
        ),
      ];

      await tester.pumpWidget(createTestWidget(
        overrides: [
          ...mapsOverrides,
          recentLocationsProvider.overrideWith(
            (ref) => Stream.value(recentLocations),
          ),
        ],
      ));
      await tester.pump();

      // Verify recent destinations section is displayed
      expect(find.byKey(HomeHubScreen.homeHubRecentDestinationsSectionKey), findsOneWidget);
      expect(find.text('Recent destinations'), findsOneWidget);

      // Verify "See all" button is displayed (more than 3 items)
      expect(find.byKey(HomeHubScreen.homeHubRecentDestinationsSeeAllKey), findsOneWidget);
      expect(find.text('See all'), findsOneWidget);
    });

    testWidgets('HomeHubScreen tapping See all without active trip navigates to RideDestinationScreen (Ticket #194)',
        (WidgetTester tester) async {
      final recentLocations = [
        const RecentLocation(
          id: 'location1',
          title: 'King Fahd Road',
          type: MobilityPlaceType.recent,
        ),
        const RecentLocation(
          id: 'location2',
          title: 'Mall of Arabia',
          type: MobilityPlaceType.recent,
        ),
        const RecentLocation(
          id: 'location3',
          title: 'Riyadh Airport',
          type: MobilityPlaceType.recent,
        ),
        const RecentLocation(
          id: 'location4',
          title: 'Olaya Towers',
          type: MobilityPlaceType.recent,
        ),
      ];

      await tester.pumpWidget(createTestWidget(
        overrides: [
          ...mapsOverrides,
          recentLocationsProvider.overrideWith(
            (ref) => Stream.value(recentLocations),
          ),
          rideTripSessionProvider.overrideWith(
            (ref) => _FakeRideTripSessionController(
              initialState: const RideTripSessionUiState(),
            ),
          ),
        ],
        routes: {
          RoutePaths.rideDestination: (_) => const Scaffold(
            body: Center(child: Text('Ride Destination Screen')),
          ),
          RoutePaths.rideActive: (_) => const Scaffold(
            body: Center(child: Text('Ride Active Trip Screen')),
          ),
        },
      ));
      await tester.pump();

      // Tap the "See all" button
      await tester.tap(find.byKey(HomeHubScreen.homeHubRecentDestinationsSeeAllKey));
      await tester.pumpAndSettle();

      // Verify navigation to destination screen (not active trip)
      expect(find.text('Ride Destination Screen'), findsOneWidget);
      expect(find.text('Ride Active Trip Screen'), findsNothing);
    });


    testWidgets('HomeHubScreen shows Arabic See all label when locale is ar (Ticket #194)',
        (WidgetTester tester) async {
      final recentLocations = [
        const RecentLocation(
          id: 'location1',
          title: 'King Fahd Road',
          type: MobilityPlaceType.recent,
        ),
        const RecentLocation(
          id: 'location2',
          title: 'Mall of Arabia',
          type: MobilityPlaceType.recent,
        ),
        const RecentLocation(
          id: 'location3',
          title: 'Riyadh Airport',
          type: MobilityPlaceType.recent,
        ),
        const RecentLocation(
          id: 'location4',
          title: 'Olaya Towers',
          type: MobilityPlaceType.recent,
        ),
      ];

      await tester.pumpWidget(createTestWidget(
        locale: const Locale('ar'),
        overrides: [
          ...mapsOverrides,
          recentLocationsProvider.overrideWith(
            (ref) => Stream.value(recentLocations),
          ),
        ],
      ));
      await tester.pump();

      // Verify Arabic "See all" button text
      expect(find.text('عرض الكل'), findsOneWidget);
      expect(find.byKey(HomeHubScreen.homeHubRecentDestinationsSeeAllKey), findsOneWidget);
    });
  });
}

// Ticket #183: Fake controller for testing active trip state
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
}

// Fake ref for testing
class _FakeRef extends Fake implements Ref {}

// Ticket #187: Fake controller for testing ride draft state
class _FakeRideDraftController extends RideDraftController {
  _FakeRideDraftController({required RideDraftUiState initialState})
      : super() {
    state = initialState;
  }

  @override
  void updateDestination(String query) {}

  @override
  void updateSelectedOption(String optionId) {}

  @override
  void updatePickupLabel(String label) {}

  @override
  void updatePickupPlace(MobilityPlace place) {}

  @override
  void updateDestinationPlace(MobilityPlace place) {}

  @override
  void setPaymentMethodId(String? paymentMethodId) {}

  @override
  void clearPaymentMethodId() {}

  @override
  void clear() {}
}

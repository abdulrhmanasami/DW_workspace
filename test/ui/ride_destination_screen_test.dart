/// Ride Destination Screen Widget Tests - Track B Ticket #20, #93
/// Purpose: Test RideDestinationScreen UI components and behavior
/// Created by: Track B - Ticket #20
/// Updated by: Ticket #35 - Updated for DWTextField
/// Updated by: Ticket #93 - Updated for Location Picker enhancements
/// Last updated: 2025-11-30

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/screens/mobility/ride_destination_screen.dart';
import 'package:delivery_ways_clean/state/mobility/ride_draft_state.dart';
import 'package:design_system_shims/design_system_shims.dart';
import '../support/design_system_harness.dart';

void main() {
  setUpAll(() {
    ensureDesignSystemStubsForTests();
  });

  group('RideDestinationScreen Widget Tests', () {
    Widget createTestWidget({
      List<Override> overrides = const [],
      Locale locale = const Locale('en'),
    }) {
      return ProviderScope(
        overrides: overrides,
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
          home: const RideDestinationScreen(),
          routes: {
            '/ride/booking': (context) =>
                const Scaffold(body: Text('Ride Booking')),
          },
        ),
      );
    }

    testWidgets('displays pickup field with placeholder text (Ticket #93)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check that pickup placeholder text is displayed (Ticket #93 updated)
      expect(find.text('Where should we pick you up?'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays "Choose your trip" title (Ticket #93)', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for the title "Choose your trip" (Ticket #93 updated)
      expect(find.text('Choose your trip'), findsOneWidget);
    });

    testWidgets('displays destination input field with search icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for the search icon
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('displays "Recent locations" section',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for the recent locations section header
      expect(find.text('Recent locations'), findsOneWidget);
    });

    testWidgets('displays recent location cards (Home, Work)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for Home and Work cards
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
    });

    testWidgets('destination input updates rideDraftProvider',
        (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: const RideDestinationScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the destination text field (Ticket #35: now using DWTextField)
      final textFieldFinder = find.byType(DWTextField);
      expect(textFieldFinder, findsOneWidget);

      // Enter destination text
      await tester.enterText(textFieldFinder, 'Airport');
      await tester.pumpAndSettle();

      // Verify that rideDraftProvider was updated
      final rideDraft = container.read(rideDraftProvider);
      expect(rideDraft.destinationQuery, 'Airport');
    });

    testWidgets('shows continue button always but disabled until destination entered (Ticket #93)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Ticket #93: Button is always visible but disabled when no destination
      expect(find.byType(DWButton), findsOneWidget);
      
      // Verify it's disabled initially
      final dwButtonBefore = tester.widget<DWButton>(find.byType(DWButton));
      expect(dwButtonBefore.onPressed, isNull);

      // Enter a destination (Ticket #35: now using DWTextField)
      final textFieldFinder = find.byType(DWTextField);
      await tester.enterText(textFieldFinder, 'Mall');
      await tester.pumpAndSettle();

      // Now the button should be enabled (Ticket #93)
      final dwButtonAfter = tester.widget<DWButton>(find.byType(DWButton));
      expect(dwButtonAfter.onPressed, isNotNull);
    });

    testWidgets('displays Arabic translations when locale is ar (Ticket #93)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      // Check for Arabic text - "اختيار موقع الرحلة" is the Arabic for "Choose your trip" (Ticket #93)
      expect(find.text('اختيار موقع الرحلة'), findsOneWidget);

      // Check for Arabic "Recent locations" text
      expect(find.text('المواقع الأخيرة'), findsOneWidget);
    });

    testWidgets('displays pickup edit icon (tappable indicator - Ticket #93)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for the edit icon indicating tappable pickup field (Ticket #93)
      expect(find.byIcon(Icons.edit_location_outlined), findsOneWidget);
    });

    testWidgets('displays back button in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for the back arrow icon
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('tapping recent location card updates destination and navigates to confirmation',
        (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: const RideDestinationScreen(),
            routes: {
              '/ride/booking': (context) =>
                  const Scaffold(body: Text('Ride Booking')),
              '/ride/trip_confirmation': (context) =>
                  const Scaffold(body: Text('Trip Confirmation')),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on "Home" recent location card
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      // Verify navigation to Trip Confirmation (Track B - Ticket #21)
      expect(find.text('Trip Confirmation'), findsOneWidget);

      // Verify that rideDraftProvider was updated with Home destination
      final rideDraft = container.read(rideDraftProvider);
      expect(rideDraft.destinationPlace?.label, 'Home');
    });

    testWidgets('pickup place is initialized with current location type',
        (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: const RideDestinationScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify that pickup place was initialized as current location
      final rideDraft = container.read(rideDraftProvider);
      expect(rideDraft.pickupPlace?.isCurrentLocation, isTrue);
    });

    testWidgets('map widget is present in the background',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // The MapWidget from maps_shims should be present
      // Since it's a stub, it shows "Maps not available" text
      expect(find.text('Maps not available'), findsOneWidget);
    });
  });
}


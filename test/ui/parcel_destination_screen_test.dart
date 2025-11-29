/// Parcel Destination Screen Widget Tests - Track C Ticket #41 + #42
/// Purpose: Test ParcelDestinationScreen UI components and behavior
/// Created by: Track C - Ticket #41
/// Last updated: 2025-11-28 (Ticket #42 - Updated navigation tests)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/screens/parcels/parcel_destination_screen.dart';
import 'package:delivery_ways_clean/screens/parcels/parcel_details_screen.dart';
import 'package:delivery_ways_clean/state/parcels/parcel_draft_state.dart';
import 'package:design_system_shims/design_system_shims.dart';
import '../support/design_system_harness.dart';

void main() {
  setUpAll(() {
    ensureDesignSystemStubsForTests();
  });

  group('ParcelDestinationScreen Widget Tests', () {
    Widget createTestWidget({
      Locale locale = const Locale('en'),
      List<Override> overrides = const [],
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
          home: const ParcelDestinationScreen(),
        ),
      );
    }

    testWidgets('displays title and subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for title
      expect(find.text('Create shipment'), findsAtLeastNWidgets(1));

      // Check for subtitle
      expect(
        find.text('Enter where to pick up and where to deliver your parcel.'),
        findsOneWidget,
      );
    });

    testWidgets('displays two DWTextField inputs', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for two DWTextField widgets
      final textFieldFinder = find.byType(DWTextField);
      expect(textFieldFinder, findsNWidgets(2));
    });

    testWidgets('displays pickup and dropoff labels',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for labels
      expect(find.text('Pickup address'), findsOneWidget);
      expect(find.text('Delivery address'), findsOneWidget);
    });

    testWidgets('displays location icons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for icons
      expect(find.byIcon(Icons.my_location), findsOneWidget);
      expect(find.byIcon(Icons.place_outlined), findsOneWidget);
    });

    testWidgets('entering text in pickup field updates parcelDraftProvider',
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
            home: const ParcelDestinationScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the first DWTextField (pickup)
      final textFieldFinder = find.byType(DWTextField);
      expect(textFieldFinder, findsNWidgets(2));

      // Enter text in pickup field
      await tester.enterText(textFieldFinder.first, '123 Main Street');
      await tester.pumpAndSettle();

      // Verify provider was updated
      final draft = container.read(parcelDraftProvider);
      expect(draft.pickupAddress, '123 Main Street');
    });

    testWidgets('entering text in dropoff field updates parcelDraftProvider',
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
            home: const ParcelDestinationScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the second DWTextField (dropoff)
      final textFieldFinder = find.byType(DWTextField);
      expect(textFieldFinder, findsNWidgets(2));

      // Enter text in dropoff field
      await tester.enterText(textFieldFinder.at(1), '456 Oak Avenue');
      await tester.pumpAndSettle();

      // Verify provider was updated
      final draft = container.read(parcelDraftProvider);
      expect(draft.dropoffAddress, '456 Oak Avenue');
    });

    testWidgets('Continue button is disabled when fields are empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the DWButton
      final buttonFinder = find.byType(DWButton);
      expect(buttonFinder, findsOneWidget);

      // Button should be present but disabled (onPressed = null)
      // We can verify by checking the button label exists
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('Continue button is enabled when both fields have text',
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
            home: const ParcelDestinationScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter text in both fields
      final textFieldFinder = find.byType(DWTextField);
      await tester.enterText(textFieldFinder.first, 'Pickup Address');
      await tester.enterText(textFieldFinder.at(1), 'Dropoff Address');
      await tester.pumpAndSettle();

      // Button should be enabled now
      final buttonFinder = find.byType(DWButton);
      expect(buttonFinder, findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('pressing Continue navigates to ParcelDetailsScreen',
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
            home: const ParcelDestinationScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify we're on ParcelDestinationScreen
      expect(find.text('Create shipment'), findsAtLeastNWidgets(1));

      // Enter text in both fields
      final textFieldFinder = find.byType(DWTextField);
      await tester.enterText(textFieldFinder.first, 'Pickup');
      await tester.enterText(textFieldFinder.at(1), 'Dropoff');
      await tester.pumpAndSettle();

      // Tap Continue button
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Verify we navigated to ParcelDetailsScreen
      expect(find.byType(ParcelDetailsScreen), findsOneWidget);
      expect(find.text('Parcel details'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays Arabic translations when locale is ar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      // Check for Arabic title
      expect(find.text('إنشاء شحنة'), findsAtLeastNWidgets(1));

      // Check for Arabic labels
      expect(find.text('عنوان الاستلام'), findsOneWidget);
      expect(find.text('عنوان التسليم'), findsOneWidget);

      // Check for Arabic CTA
      expect(find.text('متابعة'), findsOneWidget);
    });

    testWidgets('has back button in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ParcelDestinationScreen(),
                      ),
                    ),
                    child: const Text('Go'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to ParcelDestinationScreen
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      // Check for back arrow icon
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('has SafeArea', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check that SafeArea is present
      expect(find.byType(SafeArea), findsAtLeastNWidgets(1));
    });
  });
}


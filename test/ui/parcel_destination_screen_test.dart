/// Parcel Destination Screen Widget Tests - Track C Ticket #41, #42, #75
/// Purpose: Test ParcelDestinationScreen UI components and behavior
/// Created by: Track C - Ticket #41
/// Last updated: 2025-11-29 (Ticket #75 - Form validation tests)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/screens/parcels/parcel_destination_screen.dart';
import 'package:delivery_ways_clean/screens/parcels/parcel_details_screen.dart';
import 'package:delivery_ways_clean/state/parcels/parcel_draft_state.dart';
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
            Locale('de'),
          ],
          home: const ParcelDestinationScreen(),
        ),
      );
    }

    // ========== Ticket #75: Section and CTA Tests ==========

    testWidgets('shows all main sections and CTA', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Track C - Ticket #75: Verify AppBar title uses parcelsCreateShipmentTitle
      // Note: L10n key parcelsCreateShipmentTitle = "New Shipment" (capital S)
      expect(find.text('New Shipment'), findsAtLeastNWidgets(1));

      // Verify section headers are present
      expect(find.text('Sender'), findsOneWidget);
      expect(find.text('Receiver'), findsOneWidget);

      // Verify field labels are present
      expect(find.text('Sender name'), findsOneWidget);
      expect(find.text('Pickup address'), findsOneWidget);
      expect(find.text('Receiver name'), findsOneWidget);
      expect(find.text('Delivery address'), findsOneWidget);

      // Verify CTA button uses parcelsCreateShipmentCtaGetEstimate
      expect(find.text('Get estimate'), findsOneWidget);
    });

    testWidgets('validation blocks navigation when required fields are empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Act: Tap "Get estimate" with empty fields
      await tester.tap(find.text('Get estimate'));
      await tester.pumpAndSettle();

      // Assert: Validation errors appear
      expect(find.text('This field is required'), findsAtLeastNWidgets(2));

      // Assert: Still on ParcelDestinationScreen (no navigation)
      expect(find.byType(ParcelDestinationScreen), findsOneWidget);
      expect(find.byType(ParcelDetailsScreen), findsNothing);
    });

    testWidgets('allows proceeding when form is valid',
        (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en')],
            home: ParcelDestinationScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find text fields and fill them
      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(4));

      // Fill in sender name
      await tester.enterText(textFields.at(0), 'John Doe');
      await tester.pumpAndSettle();

      // Fill in pickup address
      await tester.enterText(textFields.at(1), '123 Main Street');
      await tester.pumpAndSettle();

      // Fill in receiver name
      await tester.enterText(textFields.at(2), 'Jane Smith');
      await tester.pumpAndSettle();

      // Fill in delivery address
      await tester.enterText(textFields.at(3), '456 Oak Avenue');
      await tester.pumpAndSettle();

      // Tap "Get estimate"
      await tester.tap(find.text('Get estimate'));
      await tester.pumpAndSettle();

      // Assert: No validation errors visible
      expect(find.text('This field is required'), findsNothing);

      // Assert: Navigated to ParcelDetailsScreen
      expect(find.byType(ParcelDetailsScreen), findsOneWidget);
    });

    // ========== Ticket #75: L10n Tests for AR and DE ==========

    testWidgets('l10n_AR_title_renders_correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      // Check for Arabic title
      expect(find.text('شحنة جديدة'), findsAtLeastNWidgets(1));
    });

    testWidgets('l10n_DE_title_renders_correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('de')));
      await tester.pumpAndSettle();

      // Check for German title
      expect(find.text('Neue Sendung'), findsAtLeastNWidgets(1));
    });

    // ========== Original Tests (Updated) ==========

    testWidgets('displays four TextFormField inputs',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for four TextFormField widgets (sender name, pickup, receiver name, dropoff)
      final textFieldFinder = find.byType(TextFormField);
      expect(textFieldFinder, findsNWidgets(4));
    });

    testWidgets('displays location icons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for icons
      expect(find.byIcon(Icons.my_location), findsOneWidget);
      expect(find.byIcon(Icons.place_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsNWidgets(2));
    });

    testWidgets('entering text in pickup field updates parcelDraftProvider',
        (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en')],
            home: ParcelDestinationScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the pickup address field (second TextFormField)
      final textFieldFinder = find.byType(TextFormField);
      expect(textFieldFinder, findsNWidgets(4));

      // Enter text in pickup field (index 1)
      await tester.enterText(textFieldFinder.at(1), '123 Main Street');
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
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en')],
            home: ParcelDestinationScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the dropoff address field (fourth TextFormField)
      final textFieldFinder = find.byType(TextFormField);
      expect(textFieldFinder, findsNWidgets(4));

      // Enter text in dropoff field (index 3)
      await tester.enterText(textFieldFinder.at(3), '456 Oak Avenue');
      await tester.pumpAndSettle();

      // Verify provider was updated
      final draft = container.read(parcelDraftProvider);
      expect(draft.dropoffAddress, '456 Oak Avenue');
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

    testWidgets('displays Arabic section headers when locale is ar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      // Check for Arabic section headers
      expect(find.text('المرسل'), findsOneWidget);
      expect(find.text('المستلم'), findsOneWidget);
    });

    testWidgets('displays German labels when locale is de',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('de')));
      await tester.pumpAndSettle();

      // Check for German labels
      expect(find.text('Absender'), findsOneWidget);
      expect(find.text('Empfänger'), findsOneWidget);
    });

    testWidgets('validation error message is localized in Arabic',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      // Tap "Get estimate" with empty fields
      await tester.tap(find.text('احصل على التقدير'));
      await tester.pumpAndSettle();

      // Check for Arabic error message
      expect(find.text('هذا الحقل مطلوب'), findsAtLeastNWidgets(2));
    });

    testWidgets('validation error message is localized in German',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('de')));
      await tester.pumpAndSettle();

      // Tap "Get estimate" with empty fields
      await tester.tap(find.text('Kostenvoranschlag'));
      await tester.pumpAndSettle();

      // Check for German error message
      expect(find.text('Dieses Feld ist erforderlich'), findsAtLeastNWidgets(2));
    });
  });
}

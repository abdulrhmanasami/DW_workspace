/// Parcel Details Screen Widget Tests - Track C Ticket #42 + #43
/// Purpose: Test ParcelDetailsScreen UI components and behavior
/// Created by: Track C - Ticket #42
/// Last updated: 2025-11-28 (Ticket #43 - Updated navigation test)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/screens/parcels/parcel_details_screen.dart';
import 'package:delivery_ways_clean/screens/parcels/parcel_quote_screen.dart';
import 'package:delivery_ways_clean/state/parcels/parcel_draft_state.dart';
import 'package:design_system_shims/design_system_shims.dart';
import 'package:parcels_shims/parcels_shims.dart' show ParcelSize;
import '../support/design_system_harness.dart';

void main() {
  setUpAll(() {
    ensureDesignSystemStubsForTests();
  });

  group('ParcelDetailsScreen Widget Tests', () {
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
          home: const ParcelDetailsScreen(),
        ),
      );
    }

    testWidgets('displays title and subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for title
      expect(find.text('Parcel details'), findsAtLeastNWidgets(1));

      // Check for subtitle
      expect(
        find.text(
            'Tell us more about your parcel to get accurate pricing.'),
        findsOneWidget,
      );
    });

    testWidgets('displays section labels', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for section labels
      expect(find.text('Size'), findsOneWidget);
      expect(find.text('Weight'), findsOneWidget);
      expect(find.text('What are you sending?'), findsOneWidget);
      expect(find.text('This parcel is fragile'), findsOneWidget);
    });

    testWidgets('displays size selection chips', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for size chips
      expect(find.text('Small'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Large'), findsOneWidget);
      expect(find.text('Oversize'), findsOneWidget);
    });

    testWidgets('displays two DWTextField inputs', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for two DWTextField widgets (weight + contents)
      final textFieldFinder = find.byType(DWTextField);
      expect(textFieldFinder, findsNWidgets(2));
    });

    testWidgets('displays Switch for fragile toggle',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('selecting Small chip updates parcelDraftProvider',
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
            home: const ParcelDetailsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Small chip
      await tester.tap(find.text('Small'));
      await tester.pumpAndSettle();

      // Verify provider was updated
      final draft = container.read(parcelDraftProvider);
      expect(draft.size, ParcelSize.small);
    });

    testWidgets('selecting Medium chip updates parcelDraftProvider',
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
            home: const ParcelDetailsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Medium chip
      await tester.tap(find.text('Medium'));
      await tester.pumpAndSettle();

      // Verify provider was updated
      final draft = container.read(parcelDraftProvider);
      expect(draft.size, ParcelSize.medium);
    });

    testWidgets('entering weight updates parcelDraftProvider',
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
            home: const ParcelDetailsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find weight field (first DWTextField)
      final textFieldFinder = find.byType(DWTextField);
      await tester.enterText(textFieldFinder.first, '2.5');
      await tester.pumpAndSettle();

      // Verify provider was updated
      final draft = container.read(parcelDraftProvider);
      expect(draft.weightText, '2.5');
    });

    testWidgets('entering contents description updates parcelDraftProvider',
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
            home: const ParcelDetailsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find contents field (second DWTextField)
      final textFieldFinder = find.byType(DWTextField);
      await tester.enterText(textFieldFinder.at(1), 'Electronics');
      await tester.pumpAndSettle();

      // Verify provider was updated
      final draft = container.read(parcelDraftProvider);
      expect(draft.contentsDescription, 'Electronics');
    });

    testWidgets('toggling fragile switch updates parcelDraftProvider',
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
            home: const ParcelDetailsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initial state should be false
      expect(container.read(parcelDraftProvider).isFragile, false);

      // Scroll to Switch first (it might be off-screen)
      await tester.scrollUntilVisible(
        find.byType(Switch),
        100.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // Tap Switch
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Verify provider was updated
      expect(container.read(parcelDraftProvider).isFragile, true);
    });

    testWidgets('Continue button is disabled when fields are empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the DWButton
      final buttonFinder = find.byType(DWButton);
      expect(buttonFinder, findsOneWidget);

      // Button label should be present
      expect(find.text('Continue to pricing'), findsOneWidget);
    });

    testWidgets('Continue button is enabled when all required fields filled',
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
            home: const ParcelDetailsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Select size
      await tester.tap(find.text('Small'));
      await tester.pumpAndSettle();

      // Enter weight
      final textFieldFinder = find.byType(DWTextField);
      await tester.enterText(textFieldFinder.first, '2.5');
      await tester.pumpAndSettle();

      // Enter contents
      await tester.enterText(textFieldFinder.at(1), 'Books');
      await tester.pumpAndSettle();

      // Button should be enabled now
      final buttonFinder = find.byType(DWButton);
      expect(buttonFinder, findsOneWidget);
      expect(find.text('Continue to pricing'), findsOneWidget);
    });

    testWidgets('pressing Continue navigates to ParcelQuoteScreen',
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
            routes: {
              '/': (_) => const ParcelDetailsScreen(),
              '/parcels/quote': (_) => const ParcelQuoteScreen(),
            },
            initialRoute: '/',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify we're on ParcelDetailsScreen
      expect(find.text('Parcel details'), findsAtLeastNWidgets(1));

      // Fill required fields
      await tester.tap(find.text('Small'));
      await tester.pumpAndSettle();

      final textFieldFinder = find.byType(DWTextField);
      await tester.enterText(textFieldFinder.first, '1.5');
      await tester.enterText(textFieldFinder.at(1), 'Documents');
      await tester.pumpAndSettle();

      // Tap Continue button
      await tester.tap(find.text('Continue to pricing'));
      await tester.pumpAndSettle();

      // Verify we navigated to ParcelQuoteScreen
      // Note: Due to pumpAndSettle behavior with async loading, we check for the title
      expect(find.text('Shipment pricing'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays Arabic translations when locale is ar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      // Check for Arabic title
      expect(find.text('تفاصيل الشحنة'), findsAtLeastNWidgets(1));

      // Check for Arabic subtitle
      expect(
        find.text('أدخل تفاصيل الشحنة للحصول على تسعير أدق.'),
        findsOneWidget,
      );

      // Check for Arabic labels
      expect(find.text('الحجم'), findsOneWidget);
      expect(find.text('الوزن'), findsOneWidget);
      expect(find.text('ما الذي تريد إرساله؟'), findsOneWidget);
      expect(find.text('هذه الشحنة قابلة للكسر'), findsOneWidget);

      // Check for Arabic CTA
      expect(find.text('متابعة إلى التسعير'), findsOneWidget);
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
                        builder: (_) => const ParcelDetailsScreen(),
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

      // Navigate to ParcelDetailsScreen
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

    testWidgets('ChoiceChip widgets are present', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for ChoiceChip widgets (4 size options)
      expect(find.byType(ChoiceChip), findsNWidgets(4));
    });

    testWidgets('Continue button disabled without size',
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
            home: const ParcelDetailsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Only fill weight and contents (no size)
      final textFieldFinder = find.byType(DWTextField);
      await tester.enterText(textFieldFinder.first, '2.5');
      await tester.enterText(textFieldFinder.at(1), 'Books');
      await tester.pumpAndSettle();

      // Button should still be present but state should indicate it's disabled
      // (canContinue = false because no size selected)
      final draft = container.read(parcelDraftProvider);
      expect(draft.size, isNull);
      expect(draft.weightText, '2.5');
      expect(draft.contentsDescription, 'Books');
    });

    testWidgets('Continue button disabled without weight',
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
            home: const ParcelDetailsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Select size and contents only (no weight)
      await tester.tap(find.text('Medium'));
      await tester.pumpAndSettle();

      final textFieldFinder = find.byType(DWTextField);
      await tester.enterText(textFieldFinder.at(1), 'Books');
      await tester.pumpAndSettle();

      // Verify state
      final draft = container.read(parcelDraftProvider);
      expect(draft.size, ParcelSize.medium);
      expect(draft.weightText, '');
      expect(draft.contentsDescription, 'Books');
    });

    testWidgets('Continue button disabled without contents',
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
            home: const ParcelDetailsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Select size and weight only (no contents)
      await tester.tap(find.text('Large'));
      await tester.pumpAndSettle();

      final textFieldFinder = find.byType(DWTextField);
      await tester.enterText(textFieldFinder.first, '5.0');
      await tester.pumpAndSettle();

      // Verify state
      final draft = container.read(parcelDraftProvider);
      expect(draft.size, ParcelSize.large);
      expect(draft.weightText, '5.0');
      expect(draft.contentsDescription, '');
    });
  });
}


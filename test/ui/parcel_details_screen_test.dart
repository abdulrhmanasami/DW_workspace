/// Parcel Details Screen Widget Tests - Track C Ticket #42, #43, #76
/// Purpose: Test ParcelDetailsScreen UI components and behavior
/// Created by: Track C - Ticket #42
/// Last updated: 2025-11-29 (Ticket #76 - Form validation tests)

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
            Locale('de'),
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

      // Track C - Ticket #76: Check for section header
      // 'Parcel details' appears in AppBar title and section header
      expect(find.text('Parcel details'), findsAtLeastNWidgets(1));

      // Check for field labels
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

    // Track C - Ticket #76: CTA button label updated
    testWidgets('displays CTA button with Review price label',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Review price'), findsOneWidget);
    });

    testWidgets('selecting Small chip updates parcelDraftProvider',
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
            home: ParcelDetailsScreen(),
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
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en')],
            home: ParcelDetailsScreen(),
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
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en')],
            home: ParcelDetailsScreen(),
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
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en')],
            home: ParcelDetailsScreen(),
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
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en')],
            home: ParcelDetailsScreen(),
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

    // Track C - Ticket #76: Validation tests
    group('Form Validation Tests (Ticket #76)', () {
      testWidgets('shows size error when no size selected and CTA pressed',
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

        // Fill weight and contents but no size
        final textFieldFinder = find.byType(DWTextField);
        await tester.enterText(textFieldFinder.first, '2.5');
        await tester.enterText(textFieldFinder.at(1), 'Books');
        await tester.pumpAndSettle();

        // Scroll to and tap Continue button
        await tester.scrollUntilVisible(
          find.text('Review price'),
          100.0,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('Review price'));
        await tester.pumpAndSettle();

        // Should show size error
        expect(find.text('Please select a parcel size'), findsOneWidget);

        // Should NOT navigate (still on same screen)
        expect(find.text('Parcel details'), findsAtLeastNWidgets(1));
      });

      testWidgets('shows weight error when weight empty and CTA pressed',
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

        // Select size and contents but no weight
        await tester.tap(find.text('Small'));
        await tester.pumpAndSettle();

        final textFieldFinder = find.byType(DWTextField);
        await tester.enterText(textFieldFinder.at(1), 'Books');
        await tester.pumpAndSettle();

        // Scroll to and tap Continue button
        await tester.scrollUntilVisible(
          find.text('Review price'),
          100.0,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('Review price'));
        await tester.pumpAndSettle();

        // Should show weight error
        expect(find.text('Please enter the parcel weight'), findsOneWidget);

        // Should NOT navigate
        expect(find.text('Parcel details'), findsAtLeastNWidgets(1));
      });

      testWidgets('shows weight error for invalid number (zero)',
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

        // Select size
        await tester.tap(find.text('Small'));
        await tester.pumpAndSettle();

        // Enter invalid weight (0)
        final textFieldFinder = find.byType(DWTextField);
        await tester.enterText(textFieldFinder.first, '0');
        await tester.enterText(textFieldFinder.at(1), 'Books');
        await tester.pumpAndSettle();

        // Scroll to and tap Continue button
        await tester.scrollUntilVisible(
          find.text('Review price'),
          100.0,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('Review price'));
        await tester.pumpAndSettle();

        // Should show positive number error
        expect(find.text('Enter a valid positive number'), findsOneWidget);
      });

      testWidgets('shows contents error when contents empty and CTA pressed',
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

        // Select size and weight but no contents
        await tester.tap(find.text('Small'));
        await tester.pumpAndSettle();

        final textFieldFinder = find.byType(DWTextField);
        await tester.enterText(textFieldFinder.first, '2.5');
        await tester.pumpAndSettle();

        // Scroll to and tap Continue button
        await tester.scrollUntilVisible(
          find.text('Review price'),
          100.0,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('Review price'));
        await tester.pumpAndSettle();

        // Should show contents error
        expect(
            find.text('Please describe what you are sending'), findsOneWidget);
      });

      testWidgets('allows proceeding when all fields are valid',
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

        // Fill all required fields
        await tester.tap(find.text('Small'));
        await tester.pumpAndSettle();

        final textFieldFinder = find.byType(DWTextField);
        await tester.enterText(textFieldFinder.first, '1.5');
        await tester.enterText(textFieldFinder.at(1), 'Documents');
        await tester.pumpAndSettle();

        // Scroll to and tap Continue button
        await tester.scrollUntilVisible(
          find.text('Review price'),
          100.0,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('Review price'));
        await tester.pumpAndSettle();

        // Should NOT show any error messages
        expect(find.text('Please select a parcel size'), findsNothing);
        expect(find.text('Please enter the parcel weight'), findsNothing);
        expect(find.text('Please describe what you are sending'), findsNothing);

        // Should navigate to ParcelQuoteScreen
        expect(find.text('Shipment pricing'), findsAtLeastNWidgets(1));
      });

      testWidgets('clears size error when size is selected after error',
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
              home: ParcelDetailsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap Continue without filling anything
        await tester.scrollUntilVisible(
          find.text('Review price'),
          100.0,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('Review price'));
        await tester.pumpAndSettle();

        // Size error should be visible
        expect(find.text('Please select a parcel size'), findsOneWidget);

        // Now select a size
        await tester.tap(find.text('Medium'));
        await tester.pumpAndSettle();

        // Size error should be cleared
        expect(find.text('Please select a parcel size'), findsNothing);
      });
    });

    // Track C - Ticket #76: Localization tests
    group('Localization Tests (Ticket #76)', () {
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

        // Check for Arabic section header
        expect(find.text('تفاصيل الطرد'), findsOneWidget);

        // Check for Arabic labels
        expect(find.text('الحجم'), findsOneWidget);
        expect(find.text('الوزن'), findsOneWidget);
        expect(find.text('ما الذي تريد إرساله؟'), findsOneWidget);
        expect(find.text('هذه الشحنة قابلة للكسر'), findsOneWidget);

        // Check for Arabic CTA
        expect(find.text('مراجعة التسعيرة'), findsOneWidget);
      });

      testWidgets('displays German translations when locale is de',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(locale: const Locale('de')));
        await tester.pumpAndSettle();

        // Check for German title
        expect(find.text('Sendungsdetails'), findsAtLeastNWidgets(1));

        // Check for German section header
        expect(find.text('Paketdetails'), findsOneWidget);

        // Check for German labels
        expect(find.text('Größe'), findsOneWidget);
        expect(find.text('Gewicht'), findsOneWidget);
        expect(find.text('Was senden Sie?'), findsOneWidget);
        expect(find.text('Dieses Paket ist zerbrechlich'), findsOneWidget);

        // Check for German CTA
        expect(find.text('Preis prüfen'), findsOneWidget);
      });

      testWidgets('shows Arabic validation errors when locale is ar',
          (WidgetTester tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              locale: Locale('ar'),
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: [Locale('ar')],
              home: ParcelDetailsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap Continue without filling anything
        await tester.scrollUntilVisible(
          find.text('مراجعة التسعيرة'),
          100.0,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('مراجعة التسعيرة'));
        await tester.pumpAndSettle();

        // Check for Arabic error messages
        expect(find.text('يرجى اختيار حجم الطرد'), findsOneWidget);
        expect(find.text('يرجى إدخال وزن الطرد'), findsOneWidget);
        expect(find.text('يرجى وصف محتوى الشحنة'), findsOneWidget);
      });

      testWidgets('shows German validation errors when locale is de',
          (WidgetTester tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              locale: Locale('de'),
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: [Locale('de')],
              home: ParcelDetailsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap Continue without filling anything
        await tester.scrollUntilVisible(
          find.text('Preis prüfen'),
          100.0,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('Preis prüfen'));
        await tester.pumpAndSettle();

        // Check for German error messages
        expect(find.text('Bitte wählen Sie eine Paketgröße'), findsOneWidget);
        expect(find.text('Bitte geben Sie das Gewicht des Pakets ein'),
            findsOneWidget);
        expect(find.text('Bitte beschreiben Sie, was Sie versenden'),
            findsOneWidget);
      });
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
  });
}

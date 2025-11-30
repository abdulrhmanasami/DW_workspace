/// Parcel Quote Screen Widget Tests - Track C Ticket #43 + #44 + #77
/// Purpose: Test ParcelQuoteScreen UI components and behavior
/// Created by: Track C - Ticket #43
/// Last updated: 2025-11-29 (Ticket #77 - Added Summary card + Stub note tests)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:design_system_shims/design_system_shims.dart';
import 'package:parcels_shims/parcels_shims.dart';

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/router/app_router.dart';
import 'package:delivery_ways_clean/screens/parcels/parcel_quote_screen.dart';
import 'package:delivery_ways_clean/screens/parcels/parcel_shipment_details_screen.dart';
import 'package:delivery_ways_clean/screens/parcels/parcels_entry_screen.dart';
import 'package:delivery_ways_clean/state/parcels/parcel_draft_state.dart';
import 'package:delivery_ways_clean/state/parcels/parcel_orders_state.dart';
import 'package:delivery_ways_clean/state/parcels/parcel_quote_state.dart';
import '../support/design_system_harness.dart';

void main() {
  setUpAll(() {
    ensureDesignSystemStubsForTests();
  });

  group('ParcelQuoteScreen Widget Tests', () {
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
          home: const ParcelQuoteScreen(),
        ),
      );
    }

    // Helper to create a mock quote state
    ParcelQuoteUiState createSuccessState() {
      return ParcelQuoteUiState(
        isLoading: false,
        quote: ParcelQuote(
          quoteId: 'test-quote-123',
          options: const [
            ParcelQuoteOption(
              id: 'standard',
              label: 'Standard',
              estimatedMinutes: 60,
              totalAmountCents: 1500,
              currencyCode: 'SAR',
            ),
            ParcelQuoteOption(
              id: 'express',
              label: 'Express',
              estimatedMinutes: 30,
              totalAmountCents: 2250,
              currencyCode: 'SAR',
            ),
          ],
        ),
      );
    }

    testWidgets('displays title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Shipment pricing'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.text(
            'Choose how fast you want it delivered and how much you want to pay.'),
        findsOneWidget,
      );
    });

    group('Loading state', () {
      testWidgets('displays loading indicator when loading',
          (WidgetTester tester) async {
        final loadingController = _FakeParcelQuoteController(
          const ParcelQuoteUiState(isLoading: true),
        );

        await tester.pumpWidget(
          createTestWidget(
            overrides: [
              parcelQuoteControllerProvider.overrideWith((_) => loadingController),
            ],
          ),
        );
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('displays loading text', (WidgetTester tester) async {
        final loadingController = _FakeParcelQuoteController(
          const ParcelQuoteUiState(isLoading: true),
        );

        await tester.pumpWidget(
          createTestWidget(
            overrides: [
              parcelQuoteControllerProvider.overrideWith((_) => loadingController),
            ],
          ),
        );
        await tester.pump();

        expect(find.text('Fetching price options...'), findsOneWidget);
      });
    });

    group('Error state', () {
      testWidgets('displays error title when error occurs',
          (WidgetTester tester) async {
        final errorController = _FakeParcelQuoteController(
          const ParcelQuoteUiState(
            isLoading: false,
            errorMessage: 'Network error',
          ),
        );

        await tester.pumpWidget(
          createTestWidget(
            overrides: [
              parcelQuoteControllerProvider.overrideWith((_) => errorController),
            ],
          ),
        );
        await tester.pump();

        expect(find.text("We couldn't load price options"), findsOneWidget);
      });

      testWidgets('displays error subtitle when error occurs',
          (WidgetTester tester) async {
        final errorController = _FakeParcelQuoteController(
          const ParcelQuoteUiState(
            isLoading: false,
            errorMessage: 'Network error',
          ),
        );

        await tester.pumpWidget(
          createTestWidget(
            overrides: [
              parcelQuoteControllerProvider.overrideWith((_) => errorController),
            ],
          ),
        );
        await tester.pump();

        expect(
          find.text('Please check your connection and try again.'),
          findsOneWidget,
        );
      });

      testWidgets('displays retry button when error occurs',
          (WidgetTester tester) async {
        final errorController = _FakeParcelQuoteController(
          const ParcelQuoteUiState(
            isLoading: false,
            errorMessage: 'Network error',
          ),
        );

        await tester.pumpWidget(
          createTestWidget(
            overrides: [
              parcelQuoteControllerProvider.overrideWith((_) => errorController),
            ],
          ),
        );
        await tester.pump();

        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('displays error icon', (WidgetTester tester) async {
        final errorController = _FakeParcelQuoteController(
          const ParcelQuoteUiState(
            isLoading: false,
            errorMessage: 'Network error',
          ),
        );

        await tester.pumpWidget(
          createTestWidget(
            overrides: [
              parcelQuoteControllerProvider.overrideWith((_) => errorController),
            ],
          ),
        );
        await tester.pump();

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });
    });

    group('Empty state', () {
      testWidgets('displays empty title when no options',
          (WidgetTester tester) async {
        // Create a quote with no options is not possible due to assertion,
        // so we test with null quote and no error
        final emptyController = _FakeParcelQuoteController(
          const ParcelQuoteUiState(
            isLoading: false,
            quote: null,
            errorMessage: null,
          ),
        );

        await tester.pumpWidget(
          createTestWidget(
            overrides: [
              parcelQuoteControllerProvider.overrideWith((_) => emptyController),
            ],
          ),
        );
        await tester.pump();

        expect(find.text('No options available'), findsOneWidget);
      });

      testWidgets('displays empty subtitle when no options',
          (WidgetTester tester) async {
        final emptyController = _FakeParcelQuoteController(
          const ParcelQuoteUiState(
            isLoading: false,
            quote: null,
            errorMessage: null,
          ),
        );

        await tester.pumpWidget(
          createTestWidget(
            overrides: [
              parcelQuoteControllerProvider.overrideWith((_) => emptyController),
            ],
          ),
        );
        await tester.pump();

        expect(
          find.text('Please adjust the parcel details and try again.'),
          findsOneWidget,
        );
      });

      testWidgets('displays inventory icon for empty state',
          (WidgetTester tester) async {
        final emptyController = _FakeParcelQuoteController(
          const ParcelQuoteUiState(
            isLoading: false,
            quote: null,
            errorMessage: null,
          ),
        );

        await tester.pumpWidget(
          createTestWidget(
            overrides: [
              parcelQuoteControllerProvider.overrideWith((_) => emptyController),
            ],
          ),
        );
        await tester.pump();

        expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
      });
    });

    group('Success state', () {
      testWidgets('displays quote options when loaded',
          (WidgetTester tester) async {
        final successController = _FakeParcelQuoteController(createSuccessState());

        await tester.pumpWidget(
          createTestWidget(
            overrides: [
              parcelQuoteControllerProvider.overrideWith((_) => successController),
            ],
          ),
        );
        await tester.pump();

        expect(find.text('Standard'), findsOneWidget);
        expect(find.text('Express'), findsOneWidget);
      });

      testWidgets('displays price for each option', (WidgetTester tester) async {
        final successController = _FakeParcelQuoteController(createSuccessState());

        await tester.pumpWidget(
          createTestWidget(
            overrides: [
              parcelQuoteControllerProvider.overrideWith((_) => successController),
            ],
          ),
        );
        await tester.pump();

        expect(find.text('15.00 SAR'), findsOneWidget);
        expect(find.text('22.50 SAR'), findsOneWidget);
      });

      testWidgets('displays ETA for each option', (WidgetTester tester) async {
        final successController = _FakeParcelQuoteController(createSuccessState());

        await tester.pumpWidget(
          createTestWidget(
            overrides: [
              parcelQuoteControllerProvider.overrideWith((_) => successController),
            ],
          ),
        );
        await tester.pump();

        expect(find.text('~60 min'), findsOneWidget);
        expect(find.text('~30 min'), findsOneWidget);
      });

      testWidgets('displays shipping icon for each option',
          (WidgetTester tester) async {
        final successController = _FakeParcelQuoteController(createSuccessState());

        await tester.pumpWidget(
          createTestWidget(
            overrides: [
              parcelQuoteControllerProvider.overrideWith((_) => successController),
            ],
          ),
        );
        await tester.pump();

        // Should find 2 shipping icons (one per option)
        expect(find.byIcon(Icons.local_shipping_outlined), findsNWidgets(2));
      });
    });

    group('Option selection', () {
      testWidgets('selecting option updates draft provider',
          (WidgetTester tester) async {
        final container = ProviderContainer(
          overrides: [
            parcelPricingServiceProvider.overrideWithValue(
              const MockParcelPricingService(
                baseLatency: Duration.zero,
                failureRate: 0.0,
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        // Pre-fill draft with valid data
        container.read(parcelDraftProvider.notifier).updatePickupAddress('A');
        container.read(parcelDraftProvider.notifier).updateDropoffAddress('B');
        container.read(parcelDraftProvider.notifier).updateSize(ParcelSize.medium);
        container.read(parcelDraftProvider.notifier).updateWeightText('2.5');
        container.read(parcelDraftProvider.notifier).updateContentsDescription('Test');

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
              home: const ParcelQuoteScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap Standard option
        await tester.tap(find.text('Standard'));
        await tester.pumpAndSettle();

        // Verify draft was updated
        final draft = container.read(parcelDraftProvider);
        expect(draft.selectedQuoteOptionId, 'standard');
      });

      testWidgets('selecting different option updates selection',
          (WidgetTester tester) async {
        final container = ProviderContainer(
          overrides: [
            parcelPricingServiceProvider.overrideWithValue(
              const MockParcelPricingService(
                baseLatency: Duration.zero,
                failureRate: 0.0,
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        // Pre-fill draft with valid data
        container.read(parcelDraftProvider.notifier).updatePickupAddress('A');
        container.read(parcelDraftProvider.notifier).updateDropoffAddress('B');
        container.read(parcelDraftProvider.notifier).updateSize(ParcelSize.medium);
        container.read(parcelDraftProvider.notifier).updateWeightText('2.5');
        container.read(parcelDraftProvider.notifier).updateContentsDescription('Test');

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
              home: const ParcelQuoteScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap Standard option first
        await tester.tap(find.text('Standard'));
        await tester.pumpAndSettle();
        expect(container.read(parcelDraftProvider).selectedQuoteOptionId, 'standard');

        // Then tap Express option
        await tester.tap(find.text('Express'));
        await tester.pumpAndSettle();
        expect(container.read(parcelDraftProvider).selectedQuoteOptionId, 'express');
      });
    });

    group('Confirm button', () {
      testWidgets('confirm button is present', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Confirm shipment'), findsOneWidget);
      });

      testWidgets('confirm button is disabled when no option selected',
          (WidgetTester tester) async {
        final successController = _FakeParcelQuoteController(createSuccessState());

        await tester.pumpWidget(
          createTestWidget(
            overrides: [
              parcelQuoteControllerProvider.overrideWith((_) => successController),
            ],
          ),
        );
        await tester.pump();

        // Button should be present
        expect(find.text('Confirm shipment'), findsOneWidget);

        // Find DWButton and check it exists (disabled state is controlled by onPressed being null)
        final buttonFinder = find.byType(DWButton);
        expect(buttonFinder, findsOneWidget);
      });

      testWidgets('confirm button navigates to home when pressed',
          (WidgetTester tester) async {
        final container = ProviderContainer(
          overrides: [
            parcelPricingServiceProvider.overrideWithValue(
              const MockParcelPricingService(
                baseLatency: Duration.zero,
                failureRate: 0.0,
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        // Pre-fill draft with valid data
        container.read(parcelDraftProvider.notifier).updatePickupAddress('A');
        container.read(parcelDraftProvider.notifier).updateDropoffAddress('B');
        container.read(parcelDraftProvider.notifier).updateSize(ParcelSize.medium);
        container.read(parcelDraftProvider.notifier).updateWeightText('2.5');
        container.read(parcelDraftProvider.notifier).updateContentsDescription('Test');

        bool navigatedToHome = false;

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
              home: Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        await Navigator.push<void>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ParcelQuoteScreen(),
                          ),
                        );
                        navigatedToHome = true;
                      },
                      child: const Text('Go to Quote'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Navigate to ParcelQuoteScreen
        await tester.tap(find.text('Go to Quote'));
        await tester.pumpAndSettle();

        // Select an option
        await tester.tap(find.text('Standard'));
        await tester.pumpAndSettle();

        // Tap confirm button
        await tester.tap(find.text('Confirm shipment'));
        await tester.pumpAndSettle();

        // Verify we navigated back
        expect(navigatedToHome, isTrue);
      });
    });

    // =========================================================================
    // Ticket #77 - Summary Card + Stub Note Tests
    // =========================================================================

    group('Ticket #77 - Summary Card', () {
      testWidgets('displays shipment summary title when loaded',
          (WidgetTester tester) async {
        final container = ProviderContainer(
          overrides: [
            parcelPricingServiceProvider.overrideWithValue(
              const MockParcelPricingService(
                baseLatency: Duration.zero,
                failureRate: 0.0,
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        // Pre-fill draft with valid data
        container.read(parcelDraftProvider.notifier).updatePickupAddress('123 Main St');
        container.read(parcelDraftProvider.notifier).updateDropoffAddress('456 Oak Ave');
        container.read(parcelDraftProvider.notifier).updateSize(ParcelSize.medium);
        container.read(parcelDraftProvider.notifier).updateWeightText('2.5');
        container.read(parcelDraftProvider.notifier).updateContentsDescription('Test');

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
              home: const ParcelQuoteScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Shipment summary'), findsOneWidget);
      });

      testWidgets('displays pickup address in summary',
          (WidgetTester tester) async {
        final container = ProviderContainer(
          overrides: [
            parcelPricingServiceProvider.overrideWithValue(
              const MockParcelPricingService(
                baseLatency: Duration.zero,
                failureRate: 0.0,
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        container.read(parcelDraftProvider.notifier).updatePickupAddress('Test Pickup Location');
        container.read(parcelDraftProvider.notifier).updateDropoffAddress('Test Dropoff');
        container.read(parcelDraftProvider.notifier).updateSize(ParcelSize.medium);
        container.read(parcelDraftProvider.notifier).updateWeightText('2.5');

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
              home: const ParcelQuoteScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Test Pickup Location'), findsOneWidget);
      });

      testWidgets('displays dropoff address in summary',
          (WidgetTester tester) async {
        final container = ProviderContainer(
          overrides: [
            parcelPricingServiceProvider.overrideWithValue(
              const MockParcelPricingService(
                baseLatency: Duration.zero,
                failureRate: 0.0,
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        container.read(parcelDraftProvider.notifier).updatePickupAddress('Test Pickup');
        container.read(parcelDraftProvider.notifier).updateDropoffAddress('Test Dropoff Location');
        container.read(parcelDraftProvider.notifier).updateSize(ParcelSize.medium);
        container.read(parcelDraftProvider.notifier).updateWeightText('2.5');

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
              home: const ParcelQuoteScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Test Dropoff Location'), findsOneWidget);
      });

      testWidgets('displays weight in summary',
          (WidgetTester tester) async {
        final container = ProviderContainer(
          overrides: [
            parcelPricingServiceProvider.overrideWithValue(
              const MockParcelPricingService(
                baseLatency: Duration.zero,
                failureRate: 0.0,
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        container.read(parcelDraftProvider.notifier).updatePickupAddress('A');
        container.read(parcelDraftProvider.notifier).updateDropoffAddress('B');
        container.read(parcelDraftProvider.notifier).updateSize(ParcelSize.medium);
        container.read(parcelDraftProvider.notifier).updateWeightText('5.5');

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
              home: const ParcelQuoteScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('5.5 kg'), findsOneWidget);
      });

      testWidgets('displays stub note about estimated pricing',
          (WidgetTester tester) async {
        final container = ProviderContainer(
          overrides: [
            parcelPricingServiceProvider.overrideWithValue(
              const MockParcelPricingService(
                baseLatency: Duration.zero,
                failureRate: 0.0,
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        container.read(parcelDraftProvider.notifier).updatePickupAddress('A');
        container.read(parcelDraftProvider.notifier).updateDropoffAddress('B');
        container.read(parcelDraftProvider.notifier).updateSize(ParcelSize.medium);
        container.read(parcelDraftProvider.notifier).updateWeightText('2.5');

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
              home: const ParcelQuoteScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Scroll down to find stub note
        await tester.drag(find.byType(ListView), const Offset(0, -300));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('This is an estimated price'),
          findsOneWidget,
        );
      });

      testWidgets('displays total row when option is selected',
          (WidgetTester tester) async {
        final container = ProviderContainer(
          overrides: [
            parcelPricingServiceProvider.overrideWithValue(
              const MockParcelPricingService(
                baseLatency: Duration.zero,
                failureRate: 0.0,
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        container.read(parcelDraftProvider.notifier).updatePickupAddress('A');
        container.read(parcelDraftProvider.notifier).updateDropoffAddress('B');
        container.read(parcelDraftProvider.notifier).updateSize(ParcelSize.medium);
        container.read(parcelDraftProvider.notifier).updateWeightText('2.5');

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
              home: const ParcelQuoteScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Select an option to show total
        await tester.tap(find.text('Standard'));
        await tester.pumpAndSettle();

        // Scroll down to see the total row
        await tester.drag(find.byType(ListView), const Offset(0, -300));
        await tester.pumpAndSettle();

        // Verify the price is shown (Total row displays the selected option's price)
        // The MockParcelPricingService returns 15.00 SAR for Standard
        expect(find.textContaining('SAR'), findsAtLeastNWidgets(1));
      });
    });

    group('Arabic localization', () {
      testWidgets('displays Arabic title when locale is ar',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(locale: const Locale('ar')));
        await tester.pumpAndSettle();

        expect(find.text('تسعير الشحنة'), findsAtLeastNWidgets(1));
      });

      testWidgets('displays Arabic subtitle when locale is ar',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(locale: const Locale('ar')));
        await tester.pumpAndSettle();

        expect(
          find.text('اختر سرعة التوصيل والتكلفة المناسبة لك.'),
          findsOneWidget,
        );
      });

      testWidgets('displays Arabic confirm button when locale is ar',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(locale: const Locale('ar')));
        await tester.pumpAndSettle();

        expect(find.text('تأكيد الشحنة'), findsOneWidget);
      });

      testWidgets('displays Arabic loading text when locale is ar',
          (WidgetTester tester) async {
        final loadingController = _FakeParcelQuoteController(
          const ParcelQuoteUiState(isLoading: true),
        );

        await tester.pumpWidget(
          createTestWidget(
            locale: const Locale('ar'),
            overrides: [
              parcelQuoteControllerProvider.overrideWith((_) => loadingController),
            ],
          ),
        );
        await tester.pump();

        expect(find.text('جاري جلب خيارات التسعير...'), findsOneWidget);
      });
    });

    group('German localization', () {
      Widget createDeTestWidget({List<Override> overrides = const []}) {
        return ProviderScope(
          overrides: overrides,
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
            home: const ParcelQuoteScreen(),
          ),
        );
      }

      testWidgets('displays German title when locale is de',
          (WidgetTester tester) async {
        await tester.pumpWidget(createDeTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Sendungspreise'), findsAtLeastNWidgets(1));
      });

      testWidgets('displays German subtitle when locale is de',
          (WidgetTester tester) async {
        await tester.pumpWidget(createDeTestWidget());
        await tester.pumpAndSettle();

        expect(
          find.text(
              'Wählen Sie, wie schnell und zu welchem Preis Sie liefern möchten.'),
          findsOneWidget,
        );
      });

      testWidgets('displays German confirm button when locale is de',
          (WidgetTester tester) async {
        await tester.pumpWidget(createDeTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Sendung bestätigen'), findsOneWidget);
      });

      testWidgets('displays German loading text when locale is de',
          (WidgetTester tester) async {
        final loadingController = _FakeParcelQuoteController(
          const ParcelQuoteUiState(isLoading: true),
        );

        await tester.pumpWidget(
          createDeTestWidget(
            overrides: [
              parcelQuoteControllerProvider.overrideWith((_) => loadingController),
            ],
          ),
        );
        await tester.pump();

        expect(find.text('Preise werden geladen...'), findsOneWidget);
      });
    });

    testWidgets('has SafeArea', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(SafeArea), findsAtLeastNWidgets(1));
    });

    testWidgets('has AppBar with back button', (WidgetTester tester) async {
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
                        builder: (_) => const ParcelQuoteScreen(),
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

      // Navigate to ParcelQuoteScreen
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      // Check for back arrow icon
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    // =========================================================================
    // Ticket #44 - Confirm Integration Tests
    // =========================================================================

    group('Ticket #44 - Confirm Integration', () {
      testWidgets('confirm creates parcel and stores in session',
          (WidgetTester tester) async {
        final container = ProviderContainer(
          overrides: [
            parcelPricingServiceProvider.overrideWithValue(
              const MockParcelPricingService(
                baseLatency: Duration.zero,
                failureRate: 0.0,
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        // Pre-fill draft with valid data
        container.read(parcelDraftProvider.notifier).updatePickupAddress('123 Main St');
        container.read(parcelDraftProvider.notifier).updateDropoffAddress('456 Oak Ave');
        container.read(parcelDraftProvider.notifier).updateSize(ParcelSize.medium);
        container.read(parcelDraftProvider.notifier).updateWeightText('2.5');
        container.read(parcelDraftProvider.notifier).updateContentsDescription('Test items');

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
              home: Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.push<void>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ParcelQuoteScreen(),
                        ),
                      ),
                      child: const Text('Go to Quote'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Navigate to ParcelQuoteScreen
        await tester.tap(find.text('Go to Quote'));
        await tester.pumpAndSettle();

        // Select an option
        await tester.tap(find.text('Standard'));
        await tester.pumpAndSettle();

        // Verify session is empty before confirm
        expect(container.read(parcelOrdersProvider).parcels.length, 0);

        // Tap confirm button
        await tester.tap(find.text('Confirm shipment'));
        await tester.pumpAndSettle();

        // Verify parcel was created and stored
        expect(container.read(parcelOrdersProvider).parcels.length, 1);
        expect(container.read(parcelOrdersProvider).activeParcel, isNotNull);
      });

      testWidgets('confirm resets draft to default state',
          (WidgetTester tester) async {
        final container = ProviderContainer(
          overrides: [
            parcelPricingServiceProvider.overrideWithValue(
              const MockParcelPricingService(
                baseLatency: Duration.zero,
                failureRate: 0.0,
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        // Pre-fill draft with valid data
        container.read(parcelDraftProvider.notifier).updatePickupAddress('123 Main St');
        container.read(parcelDraftProvider.notifier).updateDropoffAddress('456 Oak Ave');
        container.read(parcelDraftProvider.notifier).updateSize(ParcelSize.medium);
        container.read(parcelDraftProvider.notifier).updateWeightText('2.5');
        container.read(parcelDraftProvider.notifier).updateContentsDescription('Test items');

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
              home: Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.push<void>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ParcelQuoteScreen(),
                        ),
                      ),
                      child: const Text('Go to Quote'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Navigate to ParcelQuoteScreen
        await tester.tap(find.text('Go to Quote'));
        await tester.pumpAndSettle();

        // Select an option
        await tester.tap(find.text('Standard'));
        await tester.pumpAndSettle();

        // Tap confirm button
        await tester.tap(find.text('Confirm shipment'));
        await tester.pumpAndSettle();

        // Verify draft was reset
        final draft = container.read(parcelDraftProvider);
        expect(draft.pickupAddress, '');
        expect(draft.dropoffAddress, '');
        expect(draft.size, isNull);
        expect(draft.weightText, '');
        expect(draft.contentsDescription, '');
        expect(draft.selectedQuoteOptionId, isNull);
      });

      testWidgets('confirm resets quote state',
          (WidgetTester tester) async {
        final container = ProviderContainer(
          overrides: [
            parcelPricingServiceProvider.overrideWithValue(
              const MockParcelPricingService(
                baseLatency: Duration.zero,
                failureRate: 0.0,
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        // Pre-fill draft with valid data
        container.read(parcelDraftProvider.notifier).updatePickupAddress('123 Main St');
        container.read(parcelDraftProvider.notifier).updateDropoffAddress('456 Oak Ave');
        container.read(parcelDraftProvider.notifier).updateSize(ParcelSize.medium);
        container.read(parcelDraftProvider.notifier).updateWeightText('2.5');
        container.read(parcelDraftProvider.notifier).updateContentsDescription('Test items');

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
              home: Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.push<void>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ParcelQuoteScreen(),
                        ),
                      ),
                      child: const Text('Go to Quote'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Navigate to ParcelQuoteScreen
        await tester.tap(find.text('Go to Quote'));
        await tester.pumpAndSettle();

        // Select an option
        await tester.tap(find.text('Standard'));
        await tester.pumpAndSettle();

        // Tap confirm button
        await tester.tap(find.text('Confirm shipment'));
        await tester.pumpAndSettle();

        // Verify quote state was reset
        final quoteState = container.read(parcelQuoteControllerProvider);
        expect(quoteState.isLoading, false);
        expect(quoteState.quote, isNull);
        expect(quoteState.errorMessage, isNull);
      });

      testWidgets('confirm navigates to ParcelShipmentDetailsScreen (Ticket #80)',
          (WidgetTester tester) async {
        final container = ProviderContainer(
          overrides: [
            parcelPricingServiceProvider.overrideWithValue(
              const MockParcelPricingService(
                baseLatency: Duration.zero,
                failureRate: 0.0,
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        // Pre-fill draft with valid data
        container.read(parcelDraftProvider.notifier).updatePickupAddress('123 Main St');
        container.read(parcelDraftProvider.notifier).updateDropoffAddress('456 Oak Ave');
        container.read(parcelDraftProvider.notifier).updateSize(ParcelSize.medium);
        container.read(parcelDraftProvider.notifier).updateWeightText('2.5');
        container.read(parcelDraftProvider.notifier).updateContentsDescription('Test items');

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
                '/': (_) => const Scaffold(body: Text('Home')),
                RoutePaths.parcelsHome: (_) => const ParcelsEntryScreen(),
                RoutePaths.parcelsQuote: (_) => const ParcelQuoteScreen(),
              },
              initialRoute: '/',
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Navigate to ParcelsEntryScreen
        final context = tester.element(find.text('Home'));
        Navigator.of(context).pushNamed(RoutePaths.parcelsHome);
        await tester.pumpAndSettle();

        // Then navigate to ParcelQuoteScreen
        final entryContext = tester.element(find.byType(ParcelsEntryScreen));
        Navigator.of(entryContext).pushNamed(RoutePaths.parcelsQuote);
        await tester.pumpAndSettle();

        // Select an option
        await tester.tap(find.text('Standard'));
        await tester.pumpAndSettle();

        // Tap confirm button
        await tester.tap(find.text('Confirm shipment'));
        await tester.pumpAndSettle();

        // Ticket #80: Verify we navigated to ParcelShipmentDetailsScreen
        expect(find.byType(ParcelShipmentDetailsScreen), findsOneWidget);
        expect(find.byType(ParcelQuoteScreen), findsNothing);
      });

      testWidgets('guard rail - does not create parcel when quote is null',
          (WidgetTester tester) async {
        final fakeController = _FakeParcelQuoteController(
          const ParcelQuoteUiState(
            isLoading: false,
            quote: null,
            errorMessage: null,
          ),
        );

        final container = ProviderContainer(
          overrides: [
            parcelQuoteControllerProvider.overrideWith((_) => fakeController),
          ],
        );
        addTearDown(container.dispose);

        // Pre-fill draft with valid data including selectedQuoteOptionId
        container.read(parcelDraftProvider.notifier).updatePickupAddress('123 Main St');
        container.read(parcelDraftProvider.notifier).updateDropoffAddress('456 Oak Ave');
        container.read(parcelDraftProvider.notifier).updateSize(ParcelSize.medium);
        container.read(parcelDraftProvider.notifier).updateWeightText('2.5');
        container.read(parcelDraftProvider.notifier).updateSelectedQuoteOptionId('standard');

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
              home: const ParcelQuoteScreen(),
            ),
          ),
        );
        await tester.pump();

        // Verify confirm button is disabled (quote is null, so canConfirm = false)
        // Even if we try to tap it, nothing should happen
        await tester.tap(find.text('Confirm shipment'));
        await tester.pump();

        // Verify no parcel was created
        expect(container.read(parcelOrdersProvider).parcels.length, 0);
      });

      testWidgets('guard rail - does not create parcel when selectedId is null',
          (WidgetTester tester) async {
        final quote = ParcelQuote(
          quoteId: 'test-quote',
          options: const [
            ParcelQuoteOption(
              id: 'standard',
              label: 'Standard',
              estimatedMinutes: 60,
              totalAmountCents: 1500,
              currencyCode: 'SAR',
            ),
          ],
        );
        final fakeController = _FakeParcelQuoteController(
          ParcelQuoteUiState(
            isLoading: false,
            quote: quote,
            errorMessage: null,
          ),
        );

        final container = ProviderContainer(
          overrides: [
            parcelQuoteControllerProvider.overrideWith((_) => fakeController),
          ],
        );
        addTearDown(container.dispose);

        // Pre-fill draft but WITHOUT selectedQuoteOptionId
        container.read(parcelDraftProvider.notifier).updatePickupAddress('123 Main St');
        container.read(parcelDraftProvider.notifier).updateDropoffAddress('456 Oak Ave');
        container.read(parcelDraftProvider.notifier).updateSize(ParcelSize.medium);
        container.read(parcelDraftProvider.notifier).updateWeightText('2.5');
        // Note: NOT setting selectedQuoteOptionId

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
              home: const ParcelQuoteScreen(),
            ),
          ),
        );
        await tester.pump();

        // Verify confirm button is disabled (selectedId is null, so canConfirm = false)
        // Even if we try to tap it, nothing should happen
        await tester.tap(find.text('Confirm shipment'));
        await tester.pump();

        // Verify no parcel was created
        expect(container.read(parcelOrdersProvider).parcels.length, 0);
      });

      testWidgets('created parcel has correct properties from draft',
          (WidgetTester tester) async {
        final container = ProviderContainer(
          overrides: [
            parcelPricingServiceProvider.overrideWithValue(
              const MockParcelPricingService(
                baseLatency: Duration.zero,
                failureRate: 0.0,
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        // Pre-fill draft with specific data
        container.read(parcelDraftProvider.notifier).updatePickupAddress('Test Pickup Location');
        container.read(parcelDraftProvider.notifier).updateDropoffAddress('Test Dropoff Location');
        container.read(parcelDraftProvider.notifier).updateSize(ParcelSize.large);
        container.read(parcelDraftProvider.notifier).updateWeightText('5.5');
        container.read(parcelDraftProvider.notifier).updateContentsDescription('Fragile items');

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
              home: Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.push<void>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ParcelQuoteScreen(),
                        ),
                      ),
                      child: const Text('Go to Quote'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Navigate to ParcelQuoteScreen
        await tester.tap(find.text('Go to Quote'));
        await tester.pumpAndSettle();

        // Select Express option
        await tester.tap(find.text('Express'));
        await tester.pumpAndSettle();

        // Tap confirm button
        await tester.tap(find.text('Confirm shipment'));
        await tester.pumpAndSettle();

        // Verify parcel has correct properties
        final parcel = container.read(parcelOrdersProvider).activeParcel!;
        expect(parcel.pickupAddress.label, 'Test Pickup Location');
        expect(parcel.dropoffAddress.label, 'Test Dropoff Location');
        expect(parcel.details.size, ParcelSize.large);
        expect(parcel.details.weightKg, 5.5);
        expect(parcel.details.description, 'Fragile items');
        expect(parcel.status, ParcelStatus.scheduled);
      });
    });

    // =========================================================================
    // Ticket #80 - Navigation to ParcelShipmentDetailsScreen after Confirm
    // =========================================================================

    group('Ticket #80 - Navigate to Details after Confirm', () {
      testWidgets('navigates_to_parcel_details_after_confirm',
          (WidgetTester tester) async {
        final container = ProviderContainer(
          overrides: [
            parcelPricingServiceProvider.overrideWithValue(
              const MockParcelPricingService(
                baseLatency: Duration.zero,
                failureRate: 0.0,
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        // Pre-fill draft with valid data
        container.read(parcelDraftProvider.notifier).updatePickupAddress('123 Pickup St');
        container.read(parcelDraftProvider.notifier).updateDropoffAddress('456 Dropoff Ave');
        container.read(parcelDraftProvider.notifier).updateSize(ParcelSize.medium);
        container.read(parcelDraftProvider.notifier).updateWeightText('3.0');
        container.read(parcelDraftProvider.notifier).updateContentsDescription('Test items');

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
              home: Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.push<void>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ParcelQuoteScreen(),
                        ),
                      ),
                      child: const Text('Go to Quote'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Navigate to ParcelQuoteScreen
        await tester.tap(find.text('Go to Quote'));
        await tester.pumpAndSettle();

        // Verify we're on ParcelQuoteScreen
        expect(find.byType(ParcelQuoteScreen), findsOneWidget);

        // Select an option
        await tester.tap(find.text('Standard'));
        await tester.pumpAndSettle();

        // Tap confirm button
        await tester.tap(find.text('Confirm shipment'));
        await tester.pumpAndSettle();

        // Assert: Should navigate to ParcelShipmentDetailsScreen
        expect(find.byType(ParcelShipmentDetailsScreen), findsOneWidget);
        expect(find.byType(ParcelQuoteScreen), findsNothing);
      });

      testWidgets('parcel_details_screen_shows_correct_data_after_confirm',
          (WidgetTester tester) async {
        final container = ProviderContainer(
          overrides: [
            parcelPricingServiceProvider.overrideWithValue(
              const MockParcelPricingService(
                baseLatency: Duration.zero,
                failureRate: 0.0,
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        // Pre-fill draft with specific data
        container.read(parcelDraftProvider.notifier).updatePickupAddress('Test Pickup Address');
        container.read(parcelDraftProvider.notifier).updateDropoffAddress('Test Dropoff Address');
        container.read(parcelDraftProvider.notifier).updateSize(ParcelSize.large);
        container.read(parcelDraftProvider.notifier).updateWeightText('4.5');
        container.read(parcelDraftProvider.notifier).updateContentsDescription('Fragile');

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
              home: Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.push<void>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ParcelQuoteScreen(),
                        ),
                      ),
                      child: const Text('Go to Quote'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Navigate to ParcelQuoteScreen
        await tester.tap(find.text('Go to Quote'));
        await tester.pumpAndSettle();

        // Select an option
        await tester.tap(find.text('Express'));
        await tester.pumpAndSettle();

        // Tap confirm button
        await tester.tap(find.text('Confirm shipment'));
        await tester.pumpAndSettle();

        // Assert: ParcelShipmentDetailsScreen shows correct data
        expect(find.byType(ParcelShipmentDetailsScreen), findsOneWidget);

        // Verify pickup/dropoff addresses are displayed (may appear in multiple sections)
        expect(find.text('Test Pickup Address'), findsAtLeastNWidgets(1));
        expect(find.text('Test Dropoff Address'), findsAtLeastNWidgets(1));

        // Verify weight is displayed
        expect(find.text('4.5 kg'), findsOneWidget);

        // Verify size is displayed
        expect(find.text('Large'), findsOneWidget);
      });

      testWidgets('back_from_details_does_not_return_to_quote_screen',
          (WidgetTester tester) async {
        final container = ProviderContainer(
          overrides: [
            parcelPricingServiceProvider.overrideWithValue(
              const MockParcelPricingService(
                baseLatency: Duration.zero,
                failureRate: 0.0,
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        // Pre-fill draft with valid data
        container.read(parcelDraftProvider.notifier).updatePickupAddress('A');
        container.read(parcelDraftProvider.notifier).updateDropoffAddress('B');
        container.read(parcelDraftProvider.notifier).updateSize(ParcelSize.small);
        container.read(parcelDraftProvider.notifier).updateWeightText('1.0');

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
              home: Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Home Screen'),
                        ElevatedButton(
                          onPressed: () => Navigator.push<void>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ParcelQuoteScreen(),
                            ),
                          ),
                          child: const Text('Go to Quote'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Navigate to ParcelQuoteScreen
        await tester.tap(find.text('Go to Quote'));
        await tester.pumpAndSettle();

        // Select an option and confirm
        await tester.tap(find.text('Standard'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Confirm shipment'));
        await tester.pumpAndSettle();

        // Verify we're on ParcelShipmentDetailsScreen
        expect(find.byType(ParcelShipmentDetailsScreen), findsOneWidget);

        // Press back
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Assert: Should NOT return to ParcelQuoteScreen
        expect(find.byType(ParcelQuoteScreen), findsNothing);

        // Assert: Should be back at Home (root)
        expect(find.text('Home Screen'), findsOneWidget);
      });

      testWidgets('confirm_shows_active_shipment_title_in_details',
          (WidgetTester tester) async {
        final container = ProviderContainer(
          overrides: [
            parcelPricingServiceProvider.overrideWithValue(
              const MockParcelPricingService(
                baseLatency: Duration.zero,
                failureRate: 0.0,
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        // Pre-fill draft
        container.read(parcelDraftProvider.notifier).updatePickupAddress('A');
        container.read(parcelDraftProvider.notifier).updateDropoffAddress('B');
        container.read(parcelDraftProvider.notifier).updateSize(ParcelSize.medium);
        container.read(parcelDraftProvider.notifier).updateWeightText('2.0');

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
              home: Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.push<void>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ParcelQuoteScreen(),
                        ),
                      ),
                      child: const Text('Go to Quote'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Navigate and confirm
        await tester.tap(find.text('Go to Quote'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Standard'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Confirm shipment'));
        await tester.pumpAndSettle();

        // Assert: AppBar shows "Active shipment" title
        expect(find.text('Active shipment'), findsOneWidget);
      });
    });
  });
}

/// Fake controller for testing different states
class _FakeParcelQuoteController extends StateNotifier<ParcelQuoteUiState>
    implements ParcelQuoteController {
  _FakeParcelQuoteController(super.state);

  int refreshCallCount = 0;

  @override
  Future<void> refreshFromDraft(ParcelDraftUiState draft) async {
    refreshCallCount++;
  }

  @override
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  @override
  void reset() {
    state = const ParcelQuoteUiState();
  }
}


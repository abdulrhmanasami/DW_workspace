/// Parcels Entry Screen Widget Tests - Track C Ticket #40
/// Purpose: Test ParcelsEntryScreen UI components and behavior
/// Created by: Track C - Ticket #40
/// Updated by: Track C - Ticket #41 (Create shipment navigation)
/// Updated by: Track C - Ticket #45 (My Shipments list + filtering tests)
/// Updated by: Track C - Ticket #49 (ParcelsRepository Port integration)
/// Updated by: Track C - Ticket #50 (Parcels Pricing Integration tests)
/// Last updated: 2025-11-28

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/screens/parcels/parcel_create_shipment_screen.dart';
import 'package:delivery_ways_clean/screens/parcels/parcels_entry_screen.dart';
import 'package:delivery_ways_clean/state/parcels/app_parcels_repository.dart';
import 'package:delivery_ways_clean/state/parcels/parcel_orders_state.dart';
import 'package:design_system_shims/design_system_shims.dart';
import 'package:parcels_shims/parcels_shims.dart';
import '../support/design_system_harness.dart';

void main() {
  setUpAll(() {
    ensureDesignSystemStubsForTests();
  });

  group('ParcelsEntryScreen Widget Tests', () {
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
          home: const ParcelsEntryScreen(),
        ),
      );
    }

    testWidgets('displays title and CTA buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check that "Parcels" title is displayed (both in AppBar and body)
      expect(find.text('Parcels'), findsAtLeastNWidgets(1));

      // Check for "Create shipment" CTA
      expect(find.text('Create shipment'), findsOneWidget);
    });

    testWidgets('displays subtitle text', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for subtitle
      expect(
        find.text('Ship and track your parcels in one place.'),
        findsOneWidget,
      );
    });

    testWidgets('displays footer note', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for footer note
      expect(
        find.text('Parcels MVP is under active development.'),
        findsOneWidget,
      );
    });

    testWidgets('displays shipping icon', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for the shipping icon
      expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);
    });

    testWidgets('tapping Create shipment navigates to ParcelCreateShipmentScreen',
        (WidgetTester tester) async {
      // Track C - Ticket #46: Create shipment now navigates to ParcelCreateShipmentScreen
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find DWButton widgets
      final buttonsFinder = find.byType(DWButton);
      expect(buttonsFinder, findsAtLeastNWidgets(1));

      // Tap the "Create shipment" button (first DWButton)
      await tester.tap(buttonsFinder.first);
      await tester.pumpAndSettle();

      // Verify navigation to ParcelCreateShipmentScreen
      expect(find.byType(ParcelCreateShipmentScreen), findsOneWidget);
      // Verify the screen shows expected sections
      expect(find.text('Sender'), findsOneWidget);
      expect(find.text('Receiver'), findsOneWidget);
    });

    testWidgets('displays Arabic translations when locale is ar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      // Check for Arabic title "الطرود"
      expect(find.text('الطرود'), findsAtLeastNWidgets(1));

      // Check for Arabic subtitle
      expect(
        find.text('اشحن وتابع طرودك من مكان واحد.'),
        findsOneWidget,
      );

      // Check for Arabic CTA
      expect(find.text('إنشاء شحنة'), findsOneWidget);
    });

    testWidgets('can navigate back when pushed onto stack',
        (WidgetTester tester) async {
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
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const ParcelsEntryScreen(),
                      ),
                    ),
                    child: const Text('Go to Parcels'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to ParcelsEntryScreen
      await tester.tap(find.text('Go to Parcels'));
      await tester.pumpAndSettle();

      // Verify we're on ParcelsEntryScreen
      expect(find.text('Parcels'), findsAtLeastNWidgets(1));

      // Back button should exist now
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Go back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify we're back
      expect(find.text('Go to Parcels'), findsOneWidget);
    });

    testWidgets('has safe area padding', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check that SafeArea is present (at least one)
      expect(find.byType(SafeArea), findsAtLeastNWidgets(1));
    });

    testWidgets('uses primary DWButton variant',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify we have DWButton widgets
      final buttonsFinder = find.byType(DWButton);
      expect(buttonsFinder, findsAtLeastNWidgets(1));
    });
  });

  // =========================================================================
  // Ticket #45 - My Shipments List Tests
  // =========================================================================

  group('Ticket #45 - Empty State Tests', () {
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
          home: const ParcelsEntryScreen(),
        ),
      );
    }

    testWidgets('displays empty state when no parcels exist',
        (WidgetTester tester) async {
      // Default state has empty parcels list
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check empty state title
      expect(find.text('No shipments yet'), findsOneWidget);

      // Check empty state subtitle
      expect(
        find.text('When you create a shipment, it will appear here.'),
        findsOneWidget,
      );

      // Check for inventory icon in empty state
      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    });

    testWidgets('empty state shows no parcel cards',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should not find any Card widgets with parcel info
      expect(find.byType(Card), findsNothing);

      // Should not find "My shipments" section title when empty
      expect(find.text('My shipments'), findsNothing);
    });

    testWidgets('empty state does not show filter bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should not find filter chips when no parcels
      expect(find.byType(FilterChip), findsNothing);
    });

    testWidgets('displays Arabic empty state when locale is ar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      // Check Arabic empty state title
      expect(find.text('لا توجد شحنات حتى الآن'), findsOneWidget);

      // Check Arabic empty state subtitle
      expect(
        find.text('عند إنشاء شحنة جديدة ستظهر هنا.'),
        findsOneWidget,
      );
    });
  });

  group('Ticket #45 - Non-Empty State Tests', () {
    // Helper to create test parcels
    // Track C - Ticket #50: Updated to include price
    List<Parcel> createTestParcels() {
      return [
        Parcel(
          id: 'parcel-123456',
          createdAt: DateTime(2024, 1, 15, 10, 30),
          pickupAddress: const ParcelAddress(label: 'Home'),
          dropoffAddress: const ParcelAddress(label: 'Office'),
          details: const ParcelDetails(size: ParcelSize.small, weightKg: 1.0),
          status: ParcelStatus.scheduled,
          price: const ParcelPrice(totalAmountCents: 1500, currencyCode: 'SAR'),
        ),
        Parcel(
          id: 'parcel-789012',
          createdAt: DateTime(2024, 1, 16, 14, 0),
          pickupAddress: const ParcelAddress(label: 'Warehouse'),
          dropoffAddress: const ParcelAddress(label: 'Store'),
          details: const ParcelDetails(size: ParcelSize.medium, weightKg: 3.5),
          status: ParcelStatus.delivered,
          price: const ParcelPrice(totalAmountCents: 2500, currencyCode: 'SAR'),
        ),
        Parcel(
          id: 'parcel-345678',
          createdAt: DateTime(2024, 1, 17, 9, 15),
          pickupAddress: const ParcelAddress(label: 'Factory'),
          dropoffAddress: const ParcelAddress(label: 'Customer'),
          details: const ParcelDetails(size: ParcelSize.large, weightKg: 10.0),
          status: ParcelStatus.cancelled,
          price: const ParcelPrice(totalAmountCents: 3500, currencyCode: 'SAR'),
        ),
      ];
    }

    Widget createTestWidgetWithParcels({
      Locale locale = const Locale('en'),
      required List<Parcel> parcels,
    }) {
      return ProviderScope(
        overrides: [
          parcelOrdersProvider.overrideWith(
            (ref) => ParcelOrdersController(repository: AppParcelsRepository())
              ..state = ParcelOrdersState(
                activeParcel: parcels.isNotEmpty ? parcels.first : null,
                parcels: parcels,
              ),
          ),
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
          home: const ParcelsEntryScreen(),
        ),
      );
    }

    testWidgets('displays section title when parcels exist',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidgetWithParcels(parcels: createTestParcels()),
      );
      await tester.pumpAndSettle();

      // Should show section title
      expect(find.text('My shipments'), findsOneWidget);
    });

    testWidgets('does not show empty state when parcels exist',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidgetWithParcels(parcels: createTestParcels()),
      );
      await tester.pumpAndSettle();

      // Should NOT show inventory icon (used in empty state)
      // Note: inventory_2_outlined is used in empty state
      expect(find.byIcon(Icons.inventory_2_outlined), findsNothing);
    });

    testWidgets('displays parcel cards with correct info',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidgetWithParcels(parcels: createTestParcels()),
      );
      await tester.pumpAndSettle();

      // Check for Card widgets
      expect(find.byType(Card), findsNWidgets(3));

      // Check for shortened IDs (last 6 chars)
      expect(find.text('#123456'), findsOneWidget);
      expect(find.text('#789012'), findsOneWidget);
      expect(find.text('#345678'), findsOneWidget);

      // Check for pickup → dropoff routes
      expect(find.text('Home → Office'), findsOneWidget);
      expect(find.text('Warehouse → Store'), findsOneWidget);
      expect(find.text('Factory → Customer'), findsOneWidget);

      // Check for status labels
      expect(find.text('• Scheduled'), findsOneWidget);
      expect(find.text('• Delivered'), findsOneWidget);
      expect(find.text('• Cancelled'), findsOneWidget);

      // Check for timestamps
      expect(find.text('2024-01-15 10:30'), findsOneWidget);
      expect(find.text('2024-01-16 14:00'), findsOneWidget);
      expect(find.text('2024-01-17 09:15'), findsOneWidget);
    });

    // Track C - Ticket #50: Price display tests
    testWidgets('displays parcel prices in cards',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidgetWithParcels(parcels: createTestParcels()),
      );
      await tester.pumpAndSettle();

      // Check for price display (formatted as XX.XX CURRENCY)
      expect(find.text('15.00 SAR'), findsOneWidget);
      expect(find.text('25.00 SAR'), findsOneWidget);
      expect(find.text('35.00 SAR'), findsOneWidget);
    });

    testWidgets('displays filter bar with all filter options',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidgetWithParcels(parcels: createTestParcels()),
      );
      await tester.pumpAndSettle();

      // Check for filter chips
      expect(find.byType(FilterChip), findsNWidgets(4));

      // Check for filter labels
      expect(find.text('All'), findsOneWidget);
      expect(find.text('In progress'), findsOneWidget);
      expect(find.text('Delivered'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);
    });

    testWidgets('displays Arabic section title when locale is ar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidgetWithParcels(
          parcels: createTestParcels(),
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();

      // Check Arabic section title
      expect(find.text('شحناتي'), findsOneWidget);
    });

    testWidgets('displays Arabic filter labels when locale is ar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidgetWithParcels(
          parcels: createTestParcels(),
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();

      // Check Arabic filter labels
      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('قيد التنفيذ'), findsOneWidget);
      expect(find.text('تم التسليم'), findsOneWidget);
      expect(find.text('ملغاة'), findsOneWidget);
    });

    testWidgets('displays Arabic status labels when locale is ar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidgetWithParcels(
          parcels: createTestParcels(),
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();

      // Check Arabic status labels
      expect(find.text('• مجدولة'), findsOneWidget);
      expect(find.text('• تم التسليم'), findsOneWidget);
      expect(find.text('• ملغاة'), findsOneWidget);
    });
  });

  group('Ticket #45 - Filtering Tests', () {
    List<Parcel> createMixedStatusParcels() {
      return [
        // In progress: scheduled
        Parcel(
          id: 'parcel-scheduled',
          createdAt: DateTime(2024, 1, 1),
          pickupAddress: const ParcelAddress(label: 'A'),
          dropoffAddress: const ParcelAddress(label: 'B'),
          details: const ParcelDetails(size: ParcelSize.small, weightKg: 1.0),
          status: ParcelStatus.scheduled,
        ),
        // In progress: pickupPending
        Parcel(
          id: 'parcel-pickup-pending',
          createdAt: DateTime(2024, 1, 2),
          pickupAddress: const ParcelAddress(label: 'C'),
          dropoffAddress: const ParcelAddress(label: 'D'),
          details: const ParcelDetails(size: ParcelSize.small, weightKg: 1.0),
          status: ParcelStatus.pickupPending,
        ),
        // In progress: inTransit
        Parcel(
          id: 'parcel-intransit',
          createdAt: DateTime(2024, 1, 3),
          pickupAddress: const ParcelAddress(label: 'E'),
          dropoffAddress: const ParcelAddress(label: 'F'),
          details: const ParcelDetails(size: ParcelSize.small, weightKg: 1.0),
          status: ParcelStatus.inTransit,
        ),
        // Delivered
        Parcel(
          id: 'parcel-delivered',
          createdAt: DateTime(2024, 1, 4),
          pickupAddress: const ParcelAddress(label: 'G'),
          dropoffAddress: const ParcelAddress(label: 'H'),
          details: const ParcelDetails(size: ParcelSize.small, weightKg: 1.0),
          status: ParcelStatus.delivered,
        ),
        // Cancelled
        Parcel(
          id: 'parcel-cancelled',
          createdAt: DateTime(2024, 1, 5),
          pickupAddress: const ParcelAddress(label: 'I'),
          dropoffAddress: const ParcelAddress(label: 'J'),
          details: const ParcelDetails(size: ParcelSize.small, weightKg: 1.0),
          status: ParcelStatus.cancelled,
        ),
        // Failed (also shows in Cancelled filter)
        Parcel(
          id: 'parcel-failed01',
          createdAt: DateTime(2024, 1, 6),
          pickupAddress: const ParcelAddress(label: 'K'),
          dropoffAddress: const ParcelAddress(label: 'L'),
          details: const ParcelDetails(size: ParcelSize.small, weightKg: 1.0),
          status: ParcelStatus.failed,
        ),
      ];
    }

    Widget createTestWidgetWithParcels({
      required List<Parcel> parcels,
    }) {
      return ProviderScope(
        overrides: [
          parcelOrdersProvider.overrideWith(
            (ref) => ParcelOrdersController(repository: AppParcelsRepository())
              ..state = ParcelOrdersState(
                activeParcel: parcels.isNotEmpty ? parcels.first : null,
                parcels: parcels,
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
          home: const ParcelsEntryScreen(),
        ),
      );
    }

    testWidgets('All filter shows all parcels by default',
        (WidgetTester tester) async {
      final parcels = createMixedStatusParcels();
      await tester.pumpWidget(createTestWidgetWithParcels(parcels: parcels));
      await tester.pumpAndSettle();

      // All 6 parcels should be visible
      expect(find.byType(Card), findsNWidgets(6));

      // "All" filter should be selected by default
      final allChip = tester.widget<FilterChip>(
        find.ancestor(
          of: find.text('All'),
          matching: find.byType(FilterChip),
        ),
      );
      expect(allChip.selected, isTrue);
    });

    testWidgets('In progress filter shows only in-progress parcels',
        (WidgetTester tester) async {
      final parcels = createMixedStatusParcels();
      await tester.pumpWidget(createTestWidgetWithParcels(parcels: parcels));
      await tester.pumpAndSettle();

      // Tap "In progress" filter
      await tester.tap(find.text('In progress'));
      await tester.pumpAndSettle();

      // Should show 3 in-progress parcels: scheduled, pickupPending, inTransit
      expect(find.byType(Card), findsNWidgets(3));

      // Check that correct parcels are shown (last 6 chars of ID)
      expect(find.text('#eduled'), findsOneWidget); // 'parcel-scheduled' -> 'eduled'
      expect(find.text('#ending'), findsOneWidget); // 'parcel-pickup-pending' -> 'ending'
      expect(find.text('#ransit'), findsOneWidget); // 'parcel-intransit' -> 'ransit'

      // Delivered and cancelled should not be visible
      expect(find.text('#ivered'), findsNothing); // 'parcel-delivered' -> 'ivered'
      expect(find.text('#celled'), findsNothing); // 'parcel-cancelled' -> 'celled'
    });

    testWidgets('Delivered filter shows only delivered parcels',
        (WidgetTester tester) async {
      final parcels = createMixedStatusParcels();
      await tester.pumpWidget(createTestWidgetWithParcels(parcels: parcels));
      await tester.pumpAndSettle();

      // Tap "Delivered" filter
      await tester.tap(find.text('Delivered'));
      await tester.pumpAndSettle();

      // Should show only 1 delivered parcel
      expect(find.byType(Card), findsNWidgets(1));

      // Check that correct parcel is shown
      expect(find.text('#ivered'), findsOneWidget); // last 6 of 'parcel-delivered'
    });

    testWidgets('Cancelled filter shows cancelled and failed parcels',
        (WidgetTester tester) async {
      final parcels = createMixedStatusParcels();
      await tester.pumpWidget(createTestWidgetWithParcels(parcels: parcels));
      await tester.pumpAndSettle();

      // Tap "Cancelled" filter
      await tester.tap(find.text('Cancelled'));
      await tester.pumpAndSettle();

      // Should show 2 parcels: cancelled + failed
      expect(find.byType(Card), findsNWidgets(2));

      // Check that correct parcels are shown
      expect(find.text('#celled'), findsOneWidget); // last 6 of 'parcel-cancelled'
      expect(find.text('#iled01'), findsOneWidget); // last 6 of 'parcel-failed01'
    });

    testWidgets('switching back to All shows all parcels again',
        (WidgetTester tester) async {
      final parcels = createMixedStatusParcels();
      await tester.pumpWidget(createTestWidgetWithParcels(parcels: parcels));
      await tester.pumpAndSettle();

      // Initially all 6 shown
      expect(find.byType(Card), findsNWidgets(6));

      // Tap "Delivered" filter
      await tester.tap(find.text('Delivered'));
      await tester.pumpAndSettle();
      expect(find.byType(Card), findsNWidgets(1));

      // Tap "All" filter again
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      // All 6 should be visible again
      expect(find.byType(Card), findsNWidgets(6));
    });

    testWidgets('filter selection updates chip visual state',
        (WidgetTester tester) async {
      final parcels = createMixedStatusParcels();
      await tester.pumpWidget(createTestWidgetWithParcels(parcels: parcels));
      await tester.pumpAndSettle();

      // Initially "All" is selected
      FilterChip allChip = tester.widget<FilterChip>(
        find.ancestor(
          of: find.text('All'),
          matching: find.byType(FilterChip),
        ),
      );
      expect(allChip.selected, isTrue);

      FilterChip deliveredChip = tester.widget<FilterChip>(
        find.ancestor(
          of: find.text('Delivered'),
          matching: find.byType(FilterChip),
        ),
      );
      expect(deliveredChip.selected, isFalse);

      // Tap "Delivered" filter
      await tester.tap(find.text('Delivered'));
      await tester.pumpAndSettle();

      // Now "Delivered" should be selected
      allChip = tester.widget<FilterChip>(
        find.ancestor(
          of: find.text('All'),
          matching: find.byType(FilterChip),
        ),
      );
      expect(allChip.selected, isFalse);

      deliveredChip = tester.widget<FilterChip>(
        find.ancestor(
          of: find.text('Delivered'),
          matching: find.byType(FilterChip),
        ),
      );
      expect(deliveredChip.selected, isTrue);
    });

    testWidgets('pickedUp status appears in In progress filter',
        (WidgetTester tester) async {
      final parcels = [
        Parcel(
          id: 'parcel-pickedup',
          createdAt: DateTime(2024, 1, 1),
          pickupAddress: const ParcelAddress(label: 'Pickup'),
          dropoffAddress: const ParcelAddress(label: 'Dropoff'),
          details: const ParcelDetails(size: ParcelSize.small, weightKg: 1.0),
          status: ParcelStatus.pickedUp,
        ),
      ];
      await tester.pumpWidget(createTestWidgetWithParcels(parcels: parcels));
      await tester.pumpAndSettle();

      // Tap "In progress" filter
      await tester.tap(find.text('In progress'));
      await tester.pumpAndSettle();

      // pickedUp parcel should be visible
      expect(find.byType(Card), findsNWidgets(1));
      expect(find.text('• Picked up'), findsOneWidget);
    });
  });

  group('Ticket #45 - Status Label Mapping Tests', () {
    Widget createTestWidgetWithSingleParcel({
      required ParcelStatus status,
      Locale locale = const Locale('en'),
    }) {
      final parcel = Parcel(
        id: 'parcel-test01',
        createdAt: DateTime(2024, 1, 1),
        pickupAddress: const ParcelAddress(label: 'From'),
        dropoffAddress: const ParcelAddress(label: 'To'),
        details: const ParcelDetails(size: ParcelSize.small, weightKg: 1.0),
        status: status,
      );

      return ProviderScope(
        overrides: [
          parcelOrdersProvider.overrideWith(
            (ref) => ParcelOrdersController(repository: AppParcelsRepository())
              ..state = ParcelOrdersState(
                activeParcel: parcel,
                parcels: [parcel],
              ),
          ),
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
          home: const ParcelsEntryScreen(),
        ),
      );
    }

    testWidgets('scheduled status displays correct label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidgetWithSingleParcel(status: ParcelStatus.scheduled),
      );
      await tester.pumpAndSettle();

      expect(find.text('• Scheduled'), findsOneWidget);
    });

    testWidgets('pickupPending status displays correct label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidgetWithSingleParcel(status: ParcelStatus.pickupPending),
      );
      await tester.pumpAndSettle();

      expect(find.text('• Pickup pending'), findsOneWidget);
    });

    testWidgets('pickedUp status displays correct label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidgetWithSingleParcel(status: ParcelStatus.pickedUp),
      );
      await tester.pumpAndSettle();

      expect(find.text('• Picked up'), findsOneWidget);
    });

    testWidgets('inTransit status displays correct label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidgetWithSingleParcel(status: ParcelStatus.inTransit),
      );
      await tester.pumpAndSettle();

      expect(find.text('• In transit'), findsOneWidget);
    });

    testWidgets('delivered status displays correct label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidgetWithSingleParcel(status: ParcelStatus.delivered),
      );
      await tester.pumpAndSettle();

      expect(find.text('• Delivered'), findsOneWidget);
    });

    testWidgets('cancelled status displays correct label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidgetWithSingleParcel(status: ParcelStatus.cancelled),
      );
      await tester.pumpAndSettle();

      expect(find.text('• Cancelled'), findsOneWidget);
    });

    testWidgets('failed status displays correct label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidgetWithSingleParcel(status: ParcelStatus.failed),
      );
      await tester.pumpAndSettle();

      expect(find.text('• Failed'), findsOneWidget);
    });

    // Arabic status label tests
    testWidgets('scheduled status displays correct Arabic label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidgetWithSingleParcel(
          status: ParcelStatus.scheduled,
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('• مجدولة'), findsOneWidget);
    });

    testWidgets('pickupPending status displays correct Arabic label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidgetWithSingleParcel(
          status: ParcelStatus.pickupPending,
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('• في انتظار الاستلام'), findsOneWidget);
    });

    testWidgets('inTransit status displays correct Arabic label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidgetWithSingleParcel(
          status: ParcelStatus.inTransit,
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('• في الطريق'), findsOneWidget);
    });

    testWidgets('delivered status displays correct Arabic label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidgetWithSingleParcel(
          status: ParcelStatus.delivered,
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('• تم التسليم'), findsOneWidget);
    });

    testWidgets('failed status displays correct Arabic label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidgetWithSingleParcel(
          status: ParcelStatus.failed,
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('• فشل في التسليم'), findsOneWidget);
    });
  });
}

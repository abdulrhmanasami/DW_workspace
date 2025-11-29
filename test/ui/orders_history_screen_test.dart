/// Orders History Screen Widget Tests - Track C Ticket #51
/// Purpose: Test OrdersHistoryScreen UI components and behavior
/// Created by: Track C - Ticket #51
/// Last updated: 2025-11-29

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/screens/orders/orders_history_screen.dart';
import 'package:delivery_ways_clean/screens/parcels/parcel_shipment_details_screen.dart';
import 'package:delivery_ways_clean/screens/parcels/widgets/parcel_order_card.dart';
import 'package:delivery_ways_clean/state/parcels/app_parcels_repository.dart';
import 'package:delivery_ways_clean/state/parcels/parcel_orders_state.dart';
import 'package:parcels_shims/parcels_shims.dart';
import '../support/design_system_harness.dart';

void main() {
  setUpAll(() {
    ensureDesignSystemStubsForTests();
  });

  group('OrdersHistoryScreen - Basic UI Tests', () {
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
          home: const OrdersHistoryScreen(),
        ),
      );
    }

    testWidgets('displays AppBar with correct title in English',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for AppBar title
      expect(find.text('My Orders'), findsOneWidget);
    });

    testWidgets('displays AppBar with correct title in Arabic',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      // Check for Arabic AppBar title
      expect(find.text('طلباتي'), findsOneWidget);
    });

    testWidgets('displays AppBar with correct title in German',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('de')));
      await tester.pumpAndSettle();

      // Check for German AppBar title
      expect(find.text('Meine Bestellungen'), findsOneWidget);
    });

    testWidgets('displays filter chips', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for filter chips
      expect(find.byType(ChoiceChip), findsNWidgets(2));
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Parcels'), findsOneWidget);
    });

    testWidgets('displays Arabic filter labels when locale is ar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      // Check for Arabic filter labels
      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('الطرود'), findsOneWidget);
    });

    testWidgets('displays German filter labels when locale is de',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('de')));
      await tester.pumpAndSettle();

      // Check for German filter labels
      expect(find.text('Alle'), findsOneWidget);
      expect(find.text('Pakete'), findsOneWidget);
    });

    testWidgets('All filter is selected by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find All chip and check if selected
      final allChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('All'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(allChip.selected, isTrue);

      // Parcels chip should not be selected
      final parcelsChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('Parcels'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(parcelsChip.selected, isFalse);
    });
  });

  group('OrdersHistoryScreen - Empty State Tests', () {
    Widget createTestWidget({
      Locale locale = const Locale('en'),
    }) {
      return ProviderScope(
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
          home: const OrdersHistoryScreen(),
        ),
      );
    }

    testWidgets('displays empty state when no orders exist',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check empty state icon
      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);

      // Check empty state title
      expect(find.text('No orders yet'), findsOneWidget);
    });

    testWidgets('displays empty state subtitle',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check empty state subtitle
      expect(
        find.text(
          "You don't have any orders yet. Start by creating a new shipment.",
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays Arabic empty state when locale is ar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      // Check Arabic empty state title
      expect(find.text('لا توجد طلبات بعد'), findsOneWidget);

      // Check Arabic empty state subtitle
      expect(
        find.text('لا يوجد لديك أي طلبات حتى الآن. ابدأ بإنشاء شحنة جديدة.'),
        findsOneWidget,
      );
    });

    testWidgets('displays German empty state when locale is de',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('de')));
      await tester.pumpAndSettle();

      // Check German empty state title
      expect(find.text('Noch keine Bestellungen'), findsOneWidget);

      // Check German empty state subtitle
      expect(
        find.text(
          'Sie haben noch keine Bestellungen. Erstellen Sie zuerst eine neue Sendung.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('does not show any parcel cards when empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should not find any ParcelOrderCard widgets
      expect(find.byType(ParcelOrderCard), findsNothing);
      expect(find.byType(Card), findsNothing);
    });
  });

  group('OrdersHistoryScreen - Non-Empty State Tests', () {
    List<Parcel> createTestParcels() {
      return [
        Parcel(
          id: 'parcel-abc123',
          createdAt: DateTime(2024, 1, 15, 10, 30),
          pickupAddress: const ParcelAddress(label: 'Home'),
          dropoffAddress: const ParcelAddress(label: 'Office'),
          details: const ParcelDetails(size: ParcelSize.small, weightKg: 1.0),
          status: ParcelStatus.scheduled,
          price: const ParcelPrice(totalAmountCents: 1500, currencyCode: 'USD'),
        ),
        Parcel(
          id: 'parcel-def456',
          createdAt: DateTime(2024, 1, 16, 14, 0),
          pickupAddress: const ParcelAddress(label: 'Warehouse'),
          dropoffAddress: const ParcelAddress(label: 'Store'),
          details: const ParcelDetails(size: ParcelSize.medium, weightKg: 3.5),
          status: ParcelStatus.delivered,
          price: const ParcelPrice(totalAmountCents: 2500, currencyCode: 'USD'),
        ),
        Parcel(
          id: 'parcel-ghi789',
          createdAt: DateTime(2024, 1, 17, 9, 15),
          pickupAddress: const ParcelAddress(label: 'Factory'),
          dropoffAddress: const ParcelAddress(label: 'Customer'),
          details: const ParcelDetails(size: ParcelSize.large, weightKg: 10.0),
          status: ParcelStatus.inTransit,
          price: const ParcelPrice(totalAmountCents: 3500, currencyCode: 'USD'),
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
            Locale('de'),
          ],
          home: const OrdersHistoryScreen(),
        ),
      );
    }

    testWidgets('displays parcel cards when parcels exist',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidgetWithParcels(parcels: createTestParcels()),
      );
      await tester.pumpAndSettle();

      // Should find ParcelOrderCard widgets
      expect(find.byType(ParcelOrderCard), findsNWidgets(3));
    });

    testWidgets('does not show empty state when parcels exist',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidgetWithParcels(parcels: createTestParcels()),
      );
      await tester.pumpAndSettle();

      // Empty state title should not be visible
      expect(find.text('No orders yet'), findsNothing);
    });

    testWidgets('displays parcel IDs correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidgetWithParcels(parcels: createTestParcels()),
      );
      await tester.pumpAndSettle();

      // Check for shortened IDs (last 6 chars)
      expect(find.text('#abc123'), findsOneWidget);
      expect(find.text('#def456'), findsOneWidget);
      expect(find.text('#ghi789'), findsOneWidget);
    });

    testWidgets('displays parcel routes correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidgetWithParcels(parcels: createTestParcels()),
      );
      await tester.pumpAndSettle();

      // Check for routes
      expect(find.text('Home → Office'), findsOneWidget);
      expect(find.text('Warehouse → Store'), findsOneWidget);
      expect(find.text('Factory → Customer'), findsOneWidget);
    });

    testWidgets('displays parcel prices correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidgetWithParcels(parcels: createTestParcels()),
      );
      await tester.pumpAndSettle();

      // Check for prices
      expect(find.text('15.00 USD'), findsOneWidget);
      expect(find.text('25.00 USD'), findsOneWidget);
      expect(find.text('35.00 USD'), findsOneWidget);
    });

    testWidgets('displays parcel status labels correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidgetWithParcels(parcels: createTestParcels()),
      );
      await tester.pumpAndSettle();

      // Check for status labels
      expect(find.text('• Scheduled'), findsOneWidget);
      expect(find.text('• Delivered'), findsOneWidget);
      expect(find.text('• In transit'), findsOneWidget);
    });

    testWidgets('displays parcel timestamps correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidgetWithParcels(parcels: createTestParcels()),
      );
      await tester.pumpAndSettle();

      // Check for timestamps
      expect(find.text('2024-01-15 10:30'), findsOneWidget);
      expect(find.text('2024-01-16 14:00'), findsOneWidget);
      expect(find.text('2024-01-17 09:15'), findsOneWidget);
    });

    testWidgets('tapping parcel card navigates to details screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidgetWithParcels(parcels: createTestParcels()),
      );
      await tester.pumpAndSettle();

      // Tap first parcel card
      await tester.tap(find.text('#abc123'));
      await tester.pumpAndSettle();

      // Should navigate to ParcelShipmentDetailsScreen
      expect(find.byType(ParcelShipmentDetailsScreen), findsOneWidget);
    });
  });

  group('OrdersHistoryScreen - Filter Interaction Tests', () {
    List<Parcel> createTestParcels() {
      return [
        Parcel(
          id: 'parcel-filter1',
          createdAt: DateTime(2024, 1, 15),
          pickupAddress: const ParcelAddress(label: 'A'),
          dropoffAddress: const ParcelAddress(label: 'B'),
          details: const ParcelDetails(size: ParcelSize.small, weightKg: 1.0),
          status: ParcelStatus.scheduled,
        ),
        Parcel(
          id: 'parcel-filter2',
          createdAt: DateTime(2024, 1, 16),
          pickupAddress: const ParcelAddress(label: 'C'),
          dropoffAddress: const ParcelAddress(label: 'D'),
          details: const ParcelDetails(size: ParcelSize.small, weightKg: 1.0),
          status: ParcelStatus.delivered,
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
          home: const OrdersHistoryScreen(),
        ),
      );
    }

    testWidgets('tapping Parcels filter updates selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidgetWithParcels(parcels: createTestParcels()),
      );
      await tester.pumpAndSettle();

      // Initially All is selected
      ChoiceChip allChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('All'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(allChip.selected, isTrue);

      // Tap Parcels filter
      await tester.tap(find.text('Parcels'));
      await tester.pumpAndSettle();

      // Now Parcels should be selected
      final parcelsChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('Parcels'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(parcelsChip.selected, isTrue);

      // All should no longer be selected
      allChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('All'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(allChip.selected, isFalse);
    });

    testWidgets('switching back to All filter works',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidgetWithParcels(parcels: createTestParcels()),
      );
      await tester.pumpAndSettle();

      // Tap Parcels filter
      await tester.tap(find.text('Parcels'));
      await tester.pumpAndSettle();

      // Tap All filter
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      // All should be selected again
      final allChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('All'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(allChip.selected, isTrue);
    });

    testWidgets('both filters show same parcels in MVP',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidgetWithParcels(parcels: createTestParcels()),
      );
      await tester.pumpAndSettle();

      // Initially 2 parcels shown
      expect(find.byType(ParcelOrderCard), findsNWidgets(2));

      // Tap Parcels filter
      await tester.tap(find.text('Parcels'));
      await tester.pumpAndSettle();

      // Still 2 parcels (MVP: All == Parcels)
      expect(find.byType(ParcelOrderCard), findsNWidgets(2));
    });
  });

  group('OrdersHistoryScreen - SafeArea Tests', () {
    testWidgets('has safe area wrapper', (WidgetTester tester) async {
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
            home: const OrdersHistoryScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check for SafeArea
      expect(find.byType(SafeArea), findsAtLeastNWidgets(1));
    });
  });
}


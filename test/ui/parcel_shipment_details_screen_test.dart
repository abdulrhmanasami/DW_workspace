/// Parcel Shipment Details Screen Widget Tests - Track C Ticket #47
/// Purpose: Test ParcelShipmentDetailsScreen UI components and behavior
/// Created by: Track C - Ticket #47
/// Updated by: Track C - Ticket #49 (ParcelsRepository Port integration)
/// Updated by: Track C - Ticket #50 (Parcels Pricing Integration tests)
/// Last updated: 2025-11-28

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/screens/parcels/parcel_shipment_details_screen.dart';
import 'package:delivery_ways_clean/screens/parcels/parcels_entry_screen.dart';
import 'package:delivery_ways_clean/state/parcels/app_parcels_repository.dart';
import 'package:delivery_ways_clean/state/parcels/parcel_orders_state.dart';
import 'package:parcels_shims/parcels_shims.dart';
import '../support/design_system_harness.dart';

void main() {
  setUpAll(() {
    ensureDesignSystemStubsForTests();
  });

  // Helper to create a test Parcel
  // Track C - Ticket #50: Updated to include price
  Parcel createTestParcel({
    String id = 'parcel-test123456',
    DateTime? createdAt,
    String pickupLabel = 'Home Address',
    String dropoffLabel = 'Office Building',
    ParcelSize size = ParcelSize.medium,
    double? weightKg = 2.5,
    String? description = 'Test parcel contents',
    ParcelStatus status = ParcelStatus.scheduled,
    ParcelPrice? price = const ParcelPrice(totalAmountCents: 2500, currencyCode: 'SAR'),
  }) {
    return Parcel(
      id: id,
      createdAt: createdAt ?? DateTime(2024, 1, 15, 10, 30),
      pickupAddress: ParcelAddress(
        label: pickupLabel,
        streetLine1: pickupLabel,
      ),
      dropoffAddress: ParcelAddress(
        label: dropoffLabel,
        streetLine1: dropoffLabel,
      ),
      details: ParcelDetails(
        size: size,
        weightKg: weightKg,
        description: description,
      ),
      status: status,
      price: price,
    );
  }

  Widget createTestWidget({
    required Parcel parcel,
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
        home: ParcelShipmentDetailsScreen(parcel: parcel),
      ),
    );
  }

  group('ParcelShipmentDetailsScreen - Summary Section Tests', () {
    testWidgets('displays screen title in AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(parcel: createTestParcel()));
      await tester.pumpAndSettle();

      // Check AppBar title
      expect(find.text('Shipment details'), findsOneWidget);
    });

    testWidgets('displays shortened parcel ID', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(parcel: createTestParcel(id: 'parcel-ABCDEF123456')),
      );
      await tester.pumpAndSettle();

      // ID should show last 6 characters prefixed with #
      expect(find.text('#123456'), findsOneWidget);
    });

    testWidgets('displays status chip', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(parcel: createTestParcel(status: ParcelStatus.inTransit)),
      );
      await tester.pumpAndSettle();

      // Should show localized status label
      expect(find.text('In transit'), findsOneWidget);
    });

    testWidgets('displays creation date', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          parcel: createTestParcel(createdAt: DateTime(2024, 3, 20, 14, 45)),
        ),
      );
      await tester.pumpAndSettle();

      // Should show formatted date
      expect(find.text('Created on 2024-03-20 14:45'), findsOneWidget);
    });

    testWidgets('displays all status types correctly', (WidgetTester tester) async {
      final statuses = {
        ParcelStatus.scheduled: 'Scheduled',
        ParcelStatus.pickupPending: 'Pickup pending',
        ParcelStatus.pickedUp: 'Picked up',
        ParcelStatus.inTransit: 'In transit',
        ParcelStatus.delivered: 'Delivered',
        ParcelStatus.cancelled: 'Cancelled',
        ParcelStatus.failed: 'Failed',
      };

      for (final entry in statuses.entries) {
        await tester.pumpWidget(
          createTestWidget(parcel: createTestParcel(status: entry.key)),
        );
        await tester.pumpAndSettle();

        expect(find.text(entry.value), findsOneWidget,
            reason: 'Status ${entry.key} should display "${entry.value}"');
      }
    });
  });

  group('ParcelShipmentDetailsScreen - Route Section Tests', () {
    testWidgets('displays route section title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(parcel: createTestParcel()));
      await tester.pumpAndSettle();

      expect(find.text('Route'), findsOneWidget);
    });

    testWidgets('displays pickup and dropoff labels', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(parcel: createTestParcel()));
      await tester.pumpAndSettle();

      expect(find.text('Pickup'), findsOneWidget);
      expect(find.text('Drop-off'), findsOneWidget);
    });

    testWidgets('displays pickup and dropoff addresses', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          parcel: createTestParcel(
            pickupLabel: 'My Home',
            dropoffLabel: 'The Office',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Addresses appear in both Route and Address sections
      expect(find.text('My Home'), findsAtLeastNWidgets(1));
      expect(find.text('The Office'), findsAtLeastNWidgets(1));
    });
  });

  group('ParcelShipmentDetailsScreen - Address Section Tests', () {
    testWidgets('displays addresses section title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(parcel: createTestParcel()));
      await tester.pumpAndSettle();

      expect(find.text('Addresses'), findsOneWidget);
    });

    testWidgets('displays sender and receiver labels', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(parcel: createTestParcel()));
      await tester.pumpAndSettle();

      expect(find.text('From (Sender)'), findsOneWidget);
      expect(find.text('To (Receiver)'), findsOneWidget);
    });
  });

  group('ParcelShipmentDetailsScreen - Meta Section Tests', () {
    testWidgets('displays parcel details section title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(parcel: createTestParcel()));
      await tester.pumpAndSettle();

      expect(find.text('Parcel details'), findsOneWidget);
    });

    testWidgets('displays weight label and value', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(parcel: createTestParcel(weightKg: 3.5)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Weight'), findsOneWidget);
      expect(find.text('3.5 kg'), findsOneWidget);
    });

    testWidgets('displays size label and value', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(parcel: createTestParcel(size: ParcelSize.large)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Size'), findsOneWidget);
      expect(find.text('Large'), findsOneWidget);
    });

    testWidgets('displays all size types correctly', (WidgetTester tester) async {
      final sizes = {
        ParcelSize.small: 'Small',
        ParcelSize.medium: 'Medium',
        ParcelSize.large: 'Large',
        ParcelSize.oversize: 'Oversize',
      };

      for (final entry in sizes.entries) {
        await tester.pumpWidget(
          createTestWidget(parcel: createTestParcel(size: entry.key)),
        );
        await tester.pumpAndSettle();

        expect(find.text(entry.value), findsOneWidget,
            reason: 'Size ${entry.key} should display "${entry.value}"');
      }
    });

    testWidgets('displays notes when present', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          parcel: createTestParcel(description: 'Handle with care'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('Handle with care'), findsOneWidget);
    });

    testWidgets('hides notes section when notes are empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          parcel: createTestParcel(description: ''),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notes'), findsNothing);
    });

    testWidgets('hides notes section when notes are null', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          parcel: createTestParcel(description: null),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notes'), findsNothing);
    });

    testWidgets('displays N/A when weight is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(parcel: createTestParcel(weightKg: null)),
      );
      await tester.pumpAndSettle();

      expect(find.text('N/A'), findsOneWidget);
    });
  });

  group('ParcelShipmentDetailsScreen - Arabic Translations Tests', () {
    testWidgets('displays Arabic screen title', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          parcel: createTestParcel(),
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('تفاصيل الشحنة'), findsOneWidget);
    });

    testWidgets('displays Arabic section titles', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          parcel: createTestParcel(),
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('المسار'), findsOneWidget);
      expect(find.text('العناوين'), findsOneWidget);
      expect(find.text('تفاصيل الطرد'), findsOneWidget);
    });

    testWidgets('displays Arabic labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          parcel: createTestParcel(),
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('الاستلام'), findsOneWidget);
      expect(find.text('التسليم'), findsOneWidget);
      expect(find.text('من (المرسل)'), findsOneWidget);
      expect(find.text('إلى (المستلم)'), findsOneWidget);
      expect(find.text('الوزن'), findsOneWidget);
      expect(find.text('الحجم'), findsOneWidget);
    });

    testWidgets('displays Arabic status labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          parcel: createTestParcel(status: ParcelStatus.inTransit),
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('في الطريق'), findsOneWidget);
    });

    testWidgets('displays Arabic size labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          parcel: createTestParcel(size: ParcelSize.large),
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('كبير'), findsOneWidget);
    });
  });

  group('ParcelShipmentDetailsScreen - German Translations Tests', () {
    testWidgets('displays German screen title', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          parcel: createTestParcel(),
          locale: const Locale('de'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sendungsdetails'), findsOneWidget);
    });

    testWidgets('displays German section titles', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          parcel: createTestParcel(),
          locale: const Locale('de'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Route'), findsOneWidget);
      expect(find.text('Adressen'), findsOneWidget);
      expect(find.text('Paketdetails'), findsOneWidget);
    });
  });

  // Track C - Ticket #50: Price Display Tests
  group('ParcelShipmentDetailsScreen - Price Display Tests', () {
    testWidgets('displays price label when price is available',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          parcel: createTestParcel(
            price: const ParcelPrice(totalAmountCents: 2500, currencyCode: 'SAR'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Price'), findsOneWidget);
    });

    testWidgets('displays formatted price value', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          parcel: createTestParcel(
            price: const ParcelPrice(totalAmountCents: 2500, currencyCode: 'SAR'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('25.00 SAR'), findsOneWidget);
    });

    testWidgets('hides price section when price is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          parcel: createTestParcel(price: null),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Price'), findsNothing);
    });

    testWidgets('displays Arabic price label when locale is ar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          parcel: createTestParcel(
            price: const ParcelPrice(totalAmountCents: 1500, currencyCode: 'SAR'),
          ),
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('السعر'), findsOneWidget);
      expect(find.text('15.00 SAR'), findsOneWidget);
    });

    testWidgets('displays German price label when locale is de',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          parcel: createTestParcel(
            price: const ParcelPrice(totalAmountCents: 3500, currencyCode: 'SAR'),
          ),
          locale: const Locale('de'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Preis'), findsOneWidget);
      expect(find.text('35.00 SAR'), findsOneWidget);
    });

    testWidgets('displays different currency codes correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          parcel: createTestParcel(
            price: const ParcelPrice(totalAmountCents: 4999, currencyCode: 'USD'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('49.99 USD'), findsOneWidget);
    });
  });

  group('ParcelShipmentDetailsScreen - Navigation Tests', () {
    testWidgets('navigates to details screen when parcel card is tapped',
        (WidgetTester tester) async {
      // Create test parcel
      final testParcel = createTestParcel();

      // Create widget with ParcelsEntryScreen that has parcels
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            parcelOrdersProvider.overrideWith(
              // Track C - Ticket #49: Now requires repository
              (ref) => ParcelOrdersController(repository: AppParcelsRepository())
                ..state = ParcelOrdersState(
                  activeParcel: testParcel,
                  parcels: [testParcel],
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
        ),
      );
      await tester.pumpAndSettle();

      // Verify we're on ParcelsEntryScreen and can see the parcel card
      expect(find.text('My shipments'), findsOneWidget);

      // Find and tap the parcel card
      final cardFinder = find.byType(Card);
      expect(cardFinder, findsOneWidget);
      await tester.tap(cardFinder);
      await tester.pumpAndSettle();

      // Verify navigation to ParcelShipmentDetailsScreen
      expect(find.byType(ParcelShipmentDetailsScreen), findsOneWidget);
      expect(find.text('Shipment details'), findsOneWidget);
    });

    testWidgets('can navigate back from details screen',
        (WidgetTester tester) async {
      final testParcel = createTestParcel();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            parcelOrdersProvider.overrideWith(
              // Track C - Ticket #49: Now requires repository
              (ref) => ParcelOrdersController(repository: AppParcelsRepository())
                ..state = ParcelOrdersState(
                  activeParcel: testParcel,
                  parcels: [testParcel],
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
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to details
      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      // Verify we're on details screen
      expect(find.text('Shipment details'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify we're back on entry screen
      expect(find.text('My shipments'), findsOneWidget);
    });
  });

  group('ParcelShipmentDetailsScreen - UI Structure Tests', () {
    testWidgets('has SafeArea', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(parcel: createTestParcel()));
      await tester.pumpAndSettle();

      expect(find.byType(SafeArea), findsAtLeastNWidgets(1));
    });

    testWidgets('has SingleChildScrollView for scrolling', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(parcel: createTestParcel()));
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('displays 4 Card widgets for sections', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(parcel: createTestParcel()));
      await tester.pumpAndSettle();

      // Summary, Route, Address, Meta sections all use Card
      expect(find.byType(Card), findsNWidgets(4));
    });

    testWidgets('displays route icons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(parcel: createTestParcel()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
      expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
    });
  });
}


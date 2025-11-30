/// Parcels List Screen Tests - Track C Ticket #72
/// Purpose: Test ParcelsListScreen list display, empty state, and L10n
/// Created by: Track C - Ticket #72
/// Last updated: 2025-11-29

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:parcels_shims/parcels_shims.dart';

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/router/app_router.dart';
import 'package:delivery_ways_clean/screens/parcels/parcels_list_screen.dart';
import 'package:delivery_ways_clean/state/parcels/parcel_orders_state.dart';
import '../support/design_system_harness.dart';

void main() {
  setUpAll(() {
    ensureDesignSystemStubsForTests();
  });

  /// Creates a stub Parcel with given parameters.
  Parcel createStubParcel({
    required String id,
    required ParcelStatus status,
    String dropoffLabel = 'Riyadh - King Fahd Road',
    DateTime? createdAt,
  }) {
    return Parcel(
      id: id,
      createdAt: createdAt ?? DateTime.now(),
      pickupAddress: const ParcelAddress(label: 'Test Pickup Address'),
      dropoffAddress: ParcelAddress(label: dropoffLabel),
      details: const ParcelDetails(
        size: ParcelSize.medium,
        weightKg: 2.5,
      ),
      status: status,
    );
  }

  /// Creates a test widget with ParcelsListScreen and given parcels.
  Widget createParcelsListTestApp({
    required List<Parcel> parcels,
    Locale locale = const Locale('en'),
  }) {
    return ProviderScope(
      overrides: [
        parcelOrdersProvider.overrideWith(
          (ref) {
            final controller = ParcelOrdersController(
              repository: _StubParcelsRepository(),
            );
            if (parcels.isNotEmpty) {
              controller.state = ParcelOrdersState(
                activeParcel: parcels.first,
                parcels: parcels,
              );
            }
            return controller;
          },
        ),
      ],
      child: MaterialApp(
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
        locale: locale,
        home: const ParcelsListScreen(),
        routes: {
          RoutePaths.parcelsDetails: (context) => const Scaffold(
                body: Center(child: Text('Parcel Details')),
              ),
          // Track C - Ticket #73: Add destination route for CTA navigation test
          RoutePaths.parcelsDestination: (context) => const Scaffold(
                body: Center(child: Text('Create Shipment')),
              ),
        },
      ),
    );
  }

  group('Parcels List Screen Tests (Ticket #72)', () {
    testWidgets('shows list when parcels exist',
        (WidgetTester tester) async {
      final parcels = [
        createStubParcel(
          id: 'parcel-001',
          status: ParcelStatus.inTransit,
          dropoffLabel: 'Location A',
        ),
        createStubParcel(
          id: 'parcel-002',
          status: ParcelStatus.scheduled,
          dropoffLabel: 'Location B',
        ),
        createStubParcel(
          id: 'parcel-003',
          status: ParcelStatus.delivered,
          dropoffLabel: 'Location C',
        ),
      ];

      await tester.pumpWidget(
        createParcelsListTestApp(parcels: parcels),
      );
      await tester.pumpAndSettle();

      // Verify list items exist (shipping icons for each parcel)
      expect(find.byIcon(Icons.local_shipping_outlined), findsNWidgets(3));

      // Verify status labels are visible
      expect(find.text('In transit'), findsOneWidget);
      expect(find.text('Pickup scheduled'), findsOneWidget);
      expect(find.text('Delivered'), findsOneWidget);

      // Verify destination labels are visible
      expect(find.text('Location A'), findsOneWidget);
      expect(find.text('Location B'), findsOneWidget);
      expect(find.text('Location C'), findsOneWidget);
    });

    testWidgets('shows empty state when no parcels exist',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createParcelsListTestApp(parcels: []),
      );
      await tester.pumpAndSettle();

      // Verify empty state icon is visible
      expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);

      // Verify empty state texts are visible
      expect(find.text('No shipments yet'), findsOneWidget);
      expect(
        find.text('When you create a shipment, it will appear here.'),
        findsOneWidget,
      );

      // Verify no list items
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('L10n title uses parcelsListTitle (EN)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createParcelsListTestApp(parcels: []),
      );
      await tester.pumpAndSettle();

      // Verify AppBar title
      expect(find.text('Your shipments'), findsOneWidget);
    });

    testWidgets('L10n AR: Shows correct Arabic translations',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createParcelsListTestApp(parcels: [], locale: const Locale('ar')),
      );
      await tester.pumpAndSettle();

      // Verify Arabic title
      expect(find.text('شحناتك'), findsOneWidget);

      // Verify Arabic empty state
      expect(find.text('لا توجد شحنات حتى الآن'), findsOneWidget);
    });

    testWidgets('L10n DE: Shows correct German translations',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createParcelsListTestApp(parcels: [], locale: const Locale('de')),
      );
      await tester.pumpAndSettle();

      // Verify German title
      expect(find.text('Deine Sendungen'), findsOneWidget);

      // Verify German empty state
      expect(find.text('Noch keine Sendungen'), findsOneWidget);
    });

    testWidgets('shows shipment ID for each parcel',
        (WidgetTester tester) async {
      final parcels = [
        createStubParcel(
          id: 'SHIP-12345',
          status: ParcelStatus.pickedUp,
          dropoffLabel: 'Test Location',
        ),
      ];

      await tester.pumpWidget(
        createParcelsListTestApp(parcels: parcels),
      );
      await tester.pumpAndSettle();

      // Verify shipment ID is displayed
      expect(find.textContaining('SHIP-12345'), findsOneWidget);
    });

    testWidgets('RoutePaths.parcelsList has correct path value',
        (WidgetTester tester) async {
      expect(RoutePaths.parcelsList, equals('/parcels/list'));
    });

    testWidgets('displays status labels correctly for different statuses',
        (WidgetTester tester) async {
      final parcels = [
        createStubParcel(
          id: 'preparing',
          status: ParcelStatus.draft,
          dropoffLabel: 'Draft Location',
        ),
        createStubParcel(
          id: 'waiting',
          status: ParcelStatus.pickupPending,
          dropoffLabel: 'Waiting Location',
        ),
      ];

      await tester.pumpWidget(
        createParcelsListTestApp(parcels: parcels),
      );
      await tester.pumpAndSettle();

      // Verify draft status maps to "Preparing your shipment..."
      expect(find.text('Preparing your shipment...'), findsOneWidget);

      // Verify pickupPending status maps to "Waiting for pickup"
      expect(find.text('Waiting for pickup'), findsOneWidget);
    });

    // Track C - Ticket #73: New tests for design alignment

    testWidgets('appBar has new shipment action button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createParcelsListTestApp(parcels: []),
      );
      await tester.pumpAndSettle();

      // Verify IconButton with add icon exists in AppBar
      expect(find.byIcon(Icons.add), findsOneWidget);

      // Verify it's an IconButton
      final iconButton = find.ancestor(
        of: find.byIcon(Icons.add),
        matching: find.byType(IconButton),
      );
      expect(iconButton, findsOneWidget);
    });

    testWidgets('empty state shows create first shipment CTA',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createParcelsListTestApp(parcels: []),
      );
      await tester.pumpAndSettle();

      // Verify CTA button text is visible
      expect(find.text('Create first shipment'), findsOneWidget);

      // Verify it's a FilledButton
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('empty state CTA navigates to parcels destination',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createParcelsListTestApp(parcels: []),
      );
      await tester.pumpAndSettle();

      // Tap the CTA button
      await tester.tap(find.text('Create first shipment'));
      await tester.pumpAndSettle();

      // Verify navigation to Create Shipment screen
      expect(find.text('Create Shipment'), findsOneWidget);
    });

    testWidgets('list item shows status chip and created at date',
        (WidgetTester tester) async {
      final testDate = DateTime(2025, 11, 15);
      final parcels = [
        createStubParcel(
          id: 'parcel-test',
          status: ParcelStatus.inTransit,
          dropoffLabel: 'Test Destination',
          createdAt: testDate,
        ),
      ];

      await tester.pumpWidget(
        createParcelsListTestApp(parcels: parcels),
      );
      await tester.pumpAndSettle();

      // Verify destination label is shown as title
      expect(find.text('Test Destination'), findsOneWidget);

      // Verify created at date is shown
      expect(find.text('Created on 2025-11-15'), findsOneWidget);

      // Verify status label is shown (In transit)
      expect(find.text('In transit'), findsOneWidget);

      // Verify chevron indicator exists
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('list item shows unknown destination when dropoff is empty',
        (WidgetTester tester) async {
      final parcels = [
        createStubParcel(
          id: 'parcel-empty-dest',
          status: ParcelStatus.scheduled,
          dropoffLabel: '',
        ),
      ];

      await tester.pumpWidget(
        createParcelsListTestApp(parcels: parcels),
      );
      await tester.pumpAndSettle();

      // Verify fallback destination label is shown
      expect(find.text('Unknown destination'), findsOneWidget);
    });

    testWidgets('appBar new shipment action navigates to parcels destination',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createParcelsListTestApp(parcels: []),
      );
      await tester.pumpAndSettle();

      // Tap the add icon button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Verify navigation to Create Shipment screen
      expect(find.text('Create Shipment'), findsOneWidget);
    });
  });
}

/// Stub ParcelsRepository for testing.
class _StubParcelsRepository implements ParcelsRepository {
  final List<Parcel> _parcels = [];

  @override
  Future<Parcel> createShipment(ParcelCreateRequest request) async {
    final parcel = Parcel(
      id: 'stub-parcel-${DateTime.now().microsecondsSinceEpoch}',
      createdAt: DateTime.now(),
      pickupAddress: ParcelAddress(label: request.senderAddress),
      dropoffAddress: ParcelAddress(label: request.receiverAddress),
      details: ParcelDetails(
        size: request.size,
        weightKg: double.tryParse(request.weightText) ?? 1.0,
      ),
      status: ParcelStatus.scheduled,
    );
    _parcels.add(parcel);
    return parcel;
  }

  @override
  Future<List<Parcel>> listParcels() async {
    return List.unmodifiable(_parcels);
  }

  @override
  Future<Parcel?> getParcelById(String id) async {
    try {
      return _parcels.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}


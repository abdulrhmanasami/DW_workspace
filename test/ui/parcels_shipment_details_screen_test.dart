import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:parcels_shims/parcels_shims.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/screens/parcels/parcels_shipment_details_screen.dart';
import 'package:delivery_ways_clean/screens/parcels/parcels_shipments_list_screen.dart';
import 'package:delivery_ways_clean/state/parcels/parcel_shipments_providers.dart';
import 'package:delivery_ways_clean/router/app_router.dart';
import '../support/design_system_harness.dart';

void main() {
  setUpAll(() {
    ensureDesignSystemStubsForTests();
  });

  group('ParcelsShipmentDetailsScreen Widget Tests (Track C - Ticket #151)', () {
    Widget createTestWidget({
      Widget? child,
      List<Override> overrides = const [],
      Locale locale = const Locale('en'),
      NavigatorObserver? observer,
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
          navigatorObservers: observer != null ? [observer] : [],
          home: child,
          onGenerateRoute: (settings) {
            if (settings.name == RoutePaths.parcelsShipmentDetails) {
              final shipment = settings.arguments as ParcelShipment;
              return MaterialPageRoute(
                builder: (context) => ParcelsShipmentDetailsScreen(
                  shipment: shipment,
                ),
                settings: settings,
              );
            }
            return null;
          },
        ),
      );
    }

    ParcelShipment createTestShipment({
      String? id,
      ParcelShipmentStatus? status,
      String? serviceType,
      double? weight,
      String? notes,
    }) {
      return ParcelShipment(
        id: id ?? 'shp_test_123456',
        sender: const ParcelContact(
          name: 'John Doe',
          phone: '1234567890',
        ),
        receiver: const ParcelContact(
          name: 'Jane Smith',
          phone: '0987654321',
        ),
        pickupAddress: const ParcelAddress(
          label: '123 Main Street',
        ),
        dropoffAddress: const ParcelAddress(
          label: '456 Oak Avenue',
        ),
        status: status ?? ParcelShipmentStatus.created,
        createdAt: DateTime(2024, 12, 1, 10, 30),
        weightKg: weight,
        sizeLabel: 'Medium Box',
        notes: notes,
        serviceType: serviceType,
        estimatedPrice: 25.99,
        currencyCode: 'SAR',
      );
    }

    testWidgets('displays all shipment details correctly', (tester) async {
      final shipment = createTestShipment(
        serviceType: 'express',
        weight: 2.5,
        notes: 'Handle with care',
      );

      await tester.pumpWidget(
        createTestWidget(
          child: ParcelsShipmentDetailsScreen(shipment: shipment),
        ),
      );

      // Check title
      expect(find.text('Shipment details'), findsOneWidget);

      // Check sections
      expect(find.text('Route'), findsOneWidget);
      expect(find.text('Contacts'), findsOneWidget);
      expect(find.text('Parcel details'), findsOneWidget);

      // Check shipment ID (last 6 characters)
      expect(find.text('Shipment #123456'), findsOneWidget);

      // Check status
      expect(find.text('Created'), findsOneWidget);

      // Check addresses
      expect(find.text('123 Main Street'), findsOneWidget);
      expect(find.text('456 Oak Avenue'), findsOneWidget);

      // Check contacts
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('1234567890'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);
      expect(find.text('0987654321'), findsOneWidget);

      // Check details
      expect(find.text('Express'), findsOneWidget);
      expect(find.text('2.5 kg'), findsOneWidget);
      expect(find.text('Medium Box'), findsOneWidget);
      expect(find.text('Handle with care'), findsOneWidget);

      // Check price
      expect(find.text('25.99 SAR'), findsOneWidget);
    });

    testWidgets('shows correct status chip for different statuses', (tester) async {
      // Test In Transit status
      final inTransitShipment = createTestShipment(
        status: ParcelShipmentStatus.inTransit,
      );

      await tester.pumpWidget(
        createTestWidget(
          child: ParcelsShipmentDetailsScreen(shipment: inTransitShipment),
        ),
      );

      expect(find.text('In Transit'), findsOneWidget);

      // Test Delivered status
      final deliveredShipment = createTestShipment(
        status: ParcelShipmentStatus.delivered,
      );

      await tester.pumpWidget(
        createTestWidget(
          child: ParcelsShipmentDetailsScreen(shipment: deliveredShipment),
        ),
      );

      expect(find.text('Delivered'), findsOneWidget);
    });

    testWidgets('handles optional fields gracefully', (tester) async {
      final minimalShipment = createTestShipment(
        weight: null,
        notes: null,
        serviceType: null,
      );

      await tester.pumpWidget(
        createTestWidget(
          child: ParcelsShipmentDetailsScreen(shipment: minimalShipment),
        ),
      );

      // Should still show required fields
      expect(find.text('Shipment details'), findsOneWidget);
      expect(find.text('Route'), findsOneWidget);
      expect(find.text('Contacts'), findsOneWidget);

      // Should not show optional fields
      expect(find.text('Weight'), findsNothing);
      expect(find.text('Notes'), findsNothing);
      expect(find.text('Service type'), findsNothing);
    });

    testWidgets('navigates from list to details screen', (tester) async {
      final testShipment = createTestShipment();
      final fakeRepo = _FakeParcelShipmentsRepository([testShipment]);
      final observer = _TestNavigatorObserver();

      await tester.pumpWidget(
        createTestWidget(
          child: const ParcelsShipmentsListScreen(),
          overrides: [
            parcelShipmentsRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          observer: observer,
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap on the shipment card
      final shipmentCard = find.byType(Card).first;
      await tester.tap(shipmentCard);
      await tester.pumpAndSettle();

      // Verify navigation occurred
      expect(observer.pushedRoutes.length, equals(1));
      expect(observer.pushedRoutes.first.settings.name, 
        equals(RoutePaths.parcelsShipmentDetails));
      expect(observer.pushedRoutes.first.settings.arguments, 
        equals(testShipment));

      // Verify details screen is shown
      expect(find.byType(ParcelsShipmentDetailsScreen), findsOneWidget);
      expect(find.text('Shipment details'), findsOneWidget);
    });

    testWidgets('displays pickup and dropoff labels correctly', (tester) async {
      final shipment = createTestShipment();

      await tester.pumpWidget(
        createTestWidget(
          child: ParcelsShipmentDetailsScreen(shipment: shipment),
        ),
      );

      // Check labels
      expect(find.text('Pickup'), findsOneWidget);
      expect(find.text('Dropoff'), findsOneWidget);

      // Check icons
      expect(find.byIcon(Icons.location_on), findsOneWidget);
      expect(find.byIcon(Icons.flag), findsOneWidget);
    });

    testWidgets('displays sender and receiver with correct icons', (tester) async {
      final shipment = createTestShipment();

      await tester.pumpWidget(
        createTestWidget(
          child: ParcelsShipmentDetailsScreen(shipment: shipment),
        ),
      );

      // Check labels
      expect(find.text('Sender'), findsOneWidget);
      expect(find.text('Receiver'), findsOneWidget);

      // Check icons
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('maps service type correctly', (tester) async {
      // Test standard service
      final standardShipment = createTestShipment(serviceType: 'standard');

      await tester.pumpWidget(
        createTestWidget(
          child: ParcelsShipmentDetailsScreen(shipment: standardShipment),
        ),
      );

      expect(find.text('Standard'), findsOneWidget);
    });

    testWidgets('formats short ID correctly', (tester) async {
      final shortIdShipment = createTestShipment(id: '123');

      await tester.pumpWidget(
        createTestWidget(
          child: ParcelsShipmentDetailsScreen(shipment: shortIdShipment),
        ),
      );

      // Should show the full ID if it's shorter than 6 characters
      expect(find.text('Shipment #123'), findsOneWidget);
    });
  });
}

// Fake repository for testing
class _FakeParcelShipmentsRepository implements ParcelShipmentsRepository {
  _FakeParcelShipmentsRepository(this._shipments);

  final List<ParcelShipment> _shipments;

  @override
  Stream<List<ParcelShipment>> watchShipments() {
    return Stream.value(_shipments);
  }

  @override
  Future<ParcelShipment?> getShipmentById(String id) async {
    try {
      return _shipments.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<ParcelShipment> createShipment(ParcelShipment shipment) async {
    return shipment;
  }

  @override
  Future<void> updateShipmentStatus(
      String id, ParcelShipmentStatus status) async {}

  @override
  Future<void> clearAll() async {}

  void dispose() {}
}

// Test navigator observer
class _TestNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
  }
}

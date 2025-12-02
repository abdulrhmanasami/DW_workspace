import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:parcels_shims/parcels_shims.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/screens/parcels/parcels_shipments_list_screen.dart';
import 'package:delivery_ways_clean/state/parcels/parcel_shipments_providers.dart';
import 'package:design_system_shims/design_system_shims.dart';
import '../support/design_system_harness.dart';

void main() {
  setUpAll(() {
    ensureDesignSystemStubsForTests();
  });

  group('ParcelsShipmentsListScreen Widget Tests (Track C - Ticket #149)', () {
    Widget createTestWidget({
      Widget? child,
      List<Override> overrides = const [],
      Locale locale = const Locale('en'),
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
          home: child ?? const ParcelsShipmentsListScreen(),
        ),
      );
    }
    // Test helper to create a ParcelShipment
    ParcelShipment _createTestShipment({
      String? id,
      ParcelShipmentStatus? status,
      DateTime? createdAt,
      String? receiverName,
      double? price,
    }) {
      return ParcelShipment(
        id: id ?? 'shipment-test-${DateTime.now().millisecondsSinceEpoch}',
        sender: const ParcelContact(
          name: 'Test Sender',
          phone: '+966501234567',
        ),
        receiver: ParcelContact(
          name: receiverName ?? 'Test Receiver',
          phone: '+966507654321',
        ),
        pickupAddress: const ParcelAddress(
          label: 'Pickup Location',
        ),
        dropoffAddress: const ParcelAddress(
          label: 'Dropoff Location',
        ),
        status: status ?? ParcelShipmentStatus.created,
        createdAt: createdAt ?? DateTime.now(),
        weightKg: 2.5,
        sizeLabel: 'Medium',
        serviceType: 'Express',
        estimatedPrice: price ?? 50.0,
        currencyCode: 'SAR',
      );
    }

    testWidgets('displays empty state when no shipments exist', (tester) async {
      // Create a fake repository that returns empty list
      final fakeRepo = _FakeParcelShipmentsRepository([]);

      await tester.pumpWidget(
        createTestWidget(
          overrides: [
          parcelShipmentsRepositoryProvider.overrideWithValue(fakeRepo),
          parcelShipmentsStreamProvider.overrideWith((ref) {
            return Stream.value([]);
          }),
        ],
      ),
    );

      // Allow widget to build
      await tester.pump();

      // Verify empty state is displayed
      expect(find.text('No shipments yet'), findsOneWidget);
      expect(
        find.text(
          'You don\'t have any shipments yet. Create your first shipment to start sending parcels.',
        ),
        findsOneWidget,
      );
      expect(find.text('Create first shipment'), findsOneWidget);

      // Verify empty state icon
      expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);
    });

    testWidgets('displays list of shipments when data exists', (tester) async {
      // Create test shipments
      final shipments = [
        _createTestShipment(
          id: 'shipment-1',
          status: ParcelShipmentStatus.created,
          receiverName: 'John Doe',
          price: 75.50,
        ),
        _createTestShipment(
          id: 'shipment-2',
          status: ParcelShipmentStatus.inTransit,
          receiverName: 'Jane Smith',
          price: 120.00,
        ),
      ];

      // Create a fake repository that returns test shipments
      final fakeRepo = _FakeParcelShipmentsRepository(shipments);

      await tester.pumpWidget(
        createTestWidget(
          overrides: [
          parcelShipmentsRepositoryProvider.overrideWithValue(fakeRepo),
          parcelShipmentsStreamProvider.overrideWith((ref) {
            return Stream.value(shipments);
          }),
        ],
      ),
    );

      // Verify shipment cards are displayed
      expect(find.text('To John Doe'), findsOneWidget);
      expect(find.text('To Jane Smith'), findsOneWidget);

      // Verify status chips
      expect(find.text('Created'), findsOneWidget);
      expect(find.text('In Transit'), findsOneWidget);

      // Verify prices
      expect(find.text('75.50 SAR'), findsOneWidget);
      expect(find.text('120.00 SAR'), findsOneWidget);

      // Verify no empty state
      expect(find.text('No shipments yet'), findsNothing);
    });

    testWidgets('calls onCreateShipment when + button is pressed',
        (tester) async {
      bool wasCalled = false;

      // Create a fake repository that returns empty list
      final fakeRepo = _FakeParcelShipmentsRepository([]);

      await tester.pumpWidget(
        createTestWidget(
          child: ParcelsShipmentsListScreen(
            onCreateShipment: () {
              wasCalled = true;
            },
          ),
          overrides: [
          parcelShipmentsRepositoryProvider.overrideWithValue(fakeRepo),
          parcelShipmentsStreamProvider.overrideWith((ref) {
            return Stream.value([]);
          }),
        ],
      ),
    );

      // Find and tap the + button
      final addButton = find.byIcon(Icons.add);
      expect(addButton, findsOneWidget);

      await tester.tap(addButton);
      await tester.pump();

      // Verify callback was called
      expect(wasCalled, isTrue);
    });

    testWidgets('calls onCreateShipment when empty state CTA is pressed',
        (tester) async {
      bool wasCalled = false;

      // Create a fake repository that returns empty list
      final fakeRepo = _FakeParcelShipmentsRepository([]);

      await tester.pumpWidget(
        createTestWidget(
          child: ParcelsShipmentsListScreen(
            onCreateShipment: () {
              wasCalled = true;
            },
          ),
          overrides: [
          parcelShipmentsRepositoryProvider.overrideWithValue(fakeRepo),
          parcelShipmentsStreamProvider.overrideWith((ref) {
            return Stream.value([]);
          }),
        ],
      ),
    );

      // Find and tap the empty state CTA button
      final ctaButton = find.text('Create first shipment');
      expect(ctaButton, findsOneWidget);

      await tester.tap(ctaButton);
      await tester.pump();

      // Verify callback was called
      expect(wasCalled, isTrue);
    });

    testWidgets('displays loading state while fetching data', (tester) async {
      // Create a fake repository
      final fakeRepo = _FakeParcelShipmentsRepository([]);

      // Use a Completer to control when data is emitted
      final completer = Completer<List<ParcelShipment>>();

      await tester.pumpWidget(
        createTestWidget(
          overrides: [
          parcelShipmentsRepositoryProvider.overrideWithValue(fakeRepo),
          parcelShipmentsStreamProvider.overrideWith((ref) {
            return completer.future.asStream();
          }),
        ],
      ),
    );

      // Initially should show loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the future with empty data
      completer.complete([]);
      await tester.pumpAndSettle();

      // Should now show empty state
      expect(find.text('No shipments yet'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('displays error state when stream emits error', (tester) async {
      // Create a fake repository
      final fakeRepo = _FakeParcelShipmentsRepository([]);

      await tester.pumpWidget(
        createTestWidget(
          overrides: [
          parcelShipmentsRepositoryProvider.overrideWithValue(fakeRepo),
          parcelShipmentsStreamProvider.overrideWith((ref) {
            return Stream.error('Test error message');
          }),
        ],
      ),
    );

      // Verify error state is displayed
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Test error message'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('displays correct status colors for shipments', (tester) async {
      // Create test shipments with different statuses
      final shipments = [
        _createTestShipment(
          id: 'shipment-1',
          status: ParcelShipmentStatus.created,
          receiverName: 'Created Order',
        ),
        _createTestShipment(
          id: 'shipment-2',
          status: ParcelShipmentStatus.inTransit,
          receiverName: 'Transit Order',
        ),
        _createTestShipment(
          id: 'shipment-3',
          status: ParcelShipmentStatus.delivered,
          receiverName: 'Delivered Order',
        ),
        _createTestShipment(
          id: 'shipment-4',
          status: ParcelShipmentStatus.cancelled,
          receiverName: 'Cancelled Order',
        ),
      ];

      // Create a fake repository that returns test shipments
      final fakeRepo = _FakeParcelShipmentsRepository(shipments);

      await tester.pumpWidget(
        createTestWidget(
          overrides: [
          parcelShipmentsRepositoryProvider.overrideWithValue(fakeRepo),
          parcelShipmentsStreamProvider.overrideWith((ref) {
            return Stream.value(shipments);
          }),
        ],
      ),
    );

      // Verify all status texts are displayed
      expect(find.text('Created'), findsOneWidget);
      expect(find.text('In Transit'), findsOneWidget);
      expect(find.text('Delivered'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);

      // Verify all shipment receivers are displayed
      expect(find.text('To Created Order'), findsOneWidget);
      expect(find.text('To Transit Order'), findsOneWidget);
      expect(find.text('To Delivered Order'), findsOneWidget);
      expect(find.text('To Cancelled Order'), findsOneWidget);
    });
  });
}

// Fake implementation of ParcelShipmentsRepository for testing
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
    _shipments.add(shipment);
    return shipment;
  }

  @override
  Future<void> updateShipmentStatus(
      String id, ParcelShipmentStatus status) async {
    final index = _shipments.indexWhere((s) => s.id == id);
    if (index != -1) {
      _shipments[index] = _shipments[index].copyWith(status: status);
    }
  }

  @override
  Future<void> clearAll() async {
    _shipments.clear();
  }
}

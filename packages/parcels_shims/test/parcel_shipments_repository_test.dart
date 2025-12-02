import 'package:test/test.dart';
import 'package:parcels_shims/parcels_shims.dart';

void main() {
  group('InMemoryParcelShipmentsRepository', () {
    late InMemoryParcelShipmentsRepository repository;

    setUp(() {
      repository = InMemoryParcelShipmentsRepository();
    });

    tearDown(() {
      repository.dispose();
    });

    ParcelShipment _createTestShipment({
      String? id,
      ParcelShipmentStatus? status,
      DateTime? createdAt,
    }) {
      return ParcelShipment(
        id: id ?? 'test-shipment-${DateTime.now().millisecondsSinceEpoch}',
        sender: const ParcelContact(
          name: 'John Sender',
          phone: '+966501234567',
        ),
        receiver: const ParcelContact(
          name: 'Jane Receiver',
          phone: '+966507654321',
        ),
        pickupAddress: const ParcelAddress(
          label: 'Home',
          streetLine1: '123 Pickup St',
          city: 'Riyadh',
          countryCode: 'SA',
        ),
        dropoffAddress: const ParcelAddress(
          label: 'Office',
          streetLine1: '456 Dropoff Ave',
          city: 'Jeddah',
          countryCode: 'SA',
        ),
        status: status ?? ParcelShipmentStatus.created,
        createdAt: createdAt ?? DateTime.now(),
        weightKg: 2.5,
        sizeLabel: 'Medium',
        notes: 'Handle with care',
        serviceType: 'Express',
        estimatedPrice: 50.0,
        currencyCode: 'SAR',
      );
    }

    test('should start with empty shipments', () async {
      // Create the repository and immediately check the stream
      final shipments = await repository.watchShipments().first;
      expect(shipments, isEmpty);
    });

    test('should create and watch shipment', () async {
      // Create a shipment
      final testShipment = _createTestShipment(id: 'shipment-1');
      final created = await repository.createShipment(testShipment);
      
      // Verify the created shipment
      expect(created.id, equals('shipment-1'));
      expect(created.status, equals(ParcelShipmentStatus.created));
      
      // Verify stream emits the new shipment
      final shipments = await repository.watchShipments().first;
      expect(shipments.length, equals(1));
      expect(shipments.first.id, equals('shipment-1'));
    });

    test('should order shipments by createdAt desc', () async {
      // Create shipments with different timestamps
      final now = DateTime.now();
      final older = _createTestShipment(
        id: 'older',
        createdAt: now.subtract(const Duration(days: 2)),
      );
      final newer = _createTestShipment(
        id: 'newer',
        createdAt: now.subtract(const Duration(days: 1)),
      );
      final newest = _createTestShipment(
        id: 'newest',
        createdAt: now,
      );
      
      // Add them out of order
      await repository.createShipment(older);
      await repository.createShipment(newest);
      await repository.createShipment(newer);
      
      // Verify they are sorted newest first
      final shipments = await repository.watchShipments().first;
      expect(shipments.length, equals(3));
      expect(shipments[0].id, equals('newest'));
      expect(shipments[1].id, equals('newer'));
      expect(shipments[2].id, equals('older'));
    });

    test('should get shipment by id', () async {
      final testShipment = _createTestShipment(id: 'test-123');
      await repository.createShipment(testShipment);
      
      final retrieved = await repository.getShipmentById('test-123');
      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals('test-123'));
      expect(retrieved.sender.name, equals('John Sender'));
      
      // Non-existent shipment
      final notFound = await repository.getShipmentById('non-existent');
      expect(notFound, isNull);
    });

    test('should update shipment status', () async {
      final testShipment = _createTestShipment(
        id: 'status-test',
        status: ParcelShipmentStatus.created,
      );
      await repository.createShipment(testShipment);
      
      // Update status to inTransit
      await repository.updateShipmentStatus(
        'status-test',
        ParcelShipmentStatus.inTransit,
      );
      
      // Verify the status was updated
      final updated = await repository.getShipmentById('status-test');
      expect(updated, isNotNull);
      expect(updated!.status, equals(ParcelShipmentStatus.inTransit));
      expect(updated.updatedAt, isNotNull);
      
      // Verify stream emits the updated shipment
      final shipments = await repository.watchShipments().first;
      expect(shipments.first.status, equals(ParcelShipmentStatus.inTransit));
    });

    test('should handle updating non-existent shipment gracefully', () async {
      // Should not throw when updating non-existent shipment
      await expectLater(
        repository.updateShipmentStatus(
          'non-existent',
          ParcelShipmentStatus.delivered,
        ),
        completes,
      );
    });

    test('should clear all shipments', () async {
      // Create multiple shipments
      await repository.createShipment(_createTestShipment(id: 'ship-1'));
      await repository.createShipment(_createTestShipment(id: 'ship-2'));
      await repository.createShipment(_createTestShipment(id: 'ship-3'));
      
      // Verify they exist
      var shipments = await repository.watchShipments().first;
      expect(shipments.length, equals(3));
      
      // Clear all
      await repository.clearAll();
      
      // Verify they are cleared
      shipments = await repository.watchShipments().first;
      expect(shipments, isEmpty);
    });

    test('should emit unmodifiable list', () async {
      await repository.createShipment(_createTestShipment(id: 'test-1'));
      
      final shipments = await repository.watchShipments().first;
      
      // Should throw when trying to modify the list
      expect(
        () => shipments.add(_createTestShipment(id: 'test-2')),
        throwsUnsupportedError,
      );
    });

    test('should handle concurrent operations correctly', () async {
      // Create multiple shipments concurrently
      final futures = List.generate(
        5,
        (i) => repository.createShipment(
          _createTestShipment(id: 'concurrent-$i'),
        ),
      );
      
      await Future.wait(futures);
      
      // All shipments should be created
      final shipments = await repository.watchShipments().first;
      expect(shipments.length, equals(5));
      
      // All IDs should be present
      final ids = shipments.map((s) => s.id).toSet();
      for (int i = 0; i < 5; i++) {
        expect(ids.contains('concurrent-$i'), isTrue);
      }
    });

    test('should maintain shipment immutability', () async {
      final original = _createTestShipment(
        id: 'immutable-test',
        status: ParcelShipmentStatus.created,
      );
      await repository.createShipment(original);
      
      // Update status
      await repository.updateShipmentStatus(
        'immutable-test',
        ParcelShipmentStatus.delivered,
      );
      
      // Original should not be modified
      expect(original.status, equals(ParcelShipmentStatus.created));
      expect(original.updatedAt, isNull);
      
      // Repository should have the updated version
      final updated = await repository.getShipmentById('immutable-test');
      expect(updated!.status, equals(ParcelShipmentStatus.delivered));
      expect(updated.updatedAt, isNotNull);
    });
  });
}

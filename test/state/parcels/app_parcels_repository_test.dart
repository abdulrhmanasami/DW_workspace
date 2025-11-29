/// AppParcelsRepository Unit Tests - Track C Ticket #49
/// Purpose: Safety net tests for AppParcelsRepository (Adapter for ParcelsRepository Port)
/// Created by: Track C - Ticket #49
/// Updated by: Track C - Ticket #50 (Parcels Pricing Integration tests)
/// Last updated: 2025-11-28

import 'package:flutter_test/flutter_test.dart';
import 'package:parcels_shims/parcels_shims.dart';

import 'package:delivery_ways_clean/state/parcels/app_parcels_repository.dart';

void main() {
  group('AppParcelsRepository', () {
    late AppParcelsRepository repository;

    setUp(() {
      repository = AppParcelsRepository();
    });

    group('listParcels', () {
      test('returns empty list initially', () async {
        final parcels = await repository.listParcels();

        expect(parcels, isEmpty);
      });

      test('returns initial parcels if provided', () async {
        final initialParcels = [
          _createTestParcel('test-1'),
          _createTestParcel('test-2'),
        ];
        final repo = AppParcelsRepository(initialParcels: initialParcels);

        final parcels = await repo.listParcels();

        expect(parcels.length, 2);
        expect(parcels[0].id, 'test-1');
        expect(parcels[1].id, 'test-2');
      });

      test('returns unmodifiable list', () async {
        await repository.createShipment(_createTestRequest());

        final parcels = await repository.listParcels();

        expect(() => parcels.add(_createTestParcel('test-new')), throwsUnsupportedError);
      });
    });

    group('getParcelById', () {
      test('returns null for non-existent ID', () async {
        final result = await repository.getParcelById('non-existent');

        expect(result, isNull);
      });

      test('returns parcel for existing ID', () async {
        final created = await repository.createShipment(_createTestRequest());

        final result = await repository.getParcelById(created.id);

        expect(result, isNotNull);
        expect(result!.id, created.id);
      });
    });

    group('createShipment', () {
      test('creates parcel with generated ID', () async {
        final request = _createTestRequest();

        final parcel = await repository.createShipment(request);

        expect(parcel.id, isNotEmpty);
        expect(parcel.id, startsWith('parcel-'));
      });

      test('creates parcel with correct pickup address', () async {
        final request = ParcelCreateRequest(
          senderName: 'John Doe',
          senderPhone: '+1234567890',
          senderAddress: '123 Main Street',
          receiverName: 'Jane Smith',
          receiverPhone: '+0987654321',
          receiverAddress: '456 Oak Avenue',
          weightText: '2.5',
          size: ParcelSize.medium,
          notes: null,
          serviceType: ParcelServiceType.standard,
        );

        final parcel = await repository.createShipment(request);

        expect(parcel.pickupAddress.label, '123 Main Street');
        expect(parcel.pickupAddress.streetLine1, '123 Main Street');
      });

      test('creates parcel with correct dropoff address', () async {
        final request = ParcelCreateRequest(
          senderName: 'John Doe',
          senderPhone: '+1234567890',
          senderAddress: '123 Main Street',
          receiverName: 'Jane Smith',
          receiverPhone: '+0987654321',
          receiverAddress: '456 Oak Avenue',
          weightText: '2.5',
          size: ParcelSize.medium,
          notes: null,
          serviceType: ParcelServiceType.standard,
        );

        final parcel = await repository.createShipment(request);

        expect(parcel.dropoffAddress.label, '456 Oak Avenue');
        expect(parcel.dropoffAddress.streetLine1, '456 Oak Avenue');
      });

      test('creates parcel with correct size', () async {
        final request = ParcelCreateRequest(
          senderName: 'John Doe',
          senderPhone: '+1234567890',
          senderAddress: '123 Main Street',
          receiverName: 'Jane Smith',
          receiverPhone: '+0987654321',
          receiverAddress: '456 Oak Avenue',
          weightText: '2.5',
          size: ParcelSize.large,
          notes: null,
          serviceType: ParcelServiceType.standard,
        );

        final parcel = await repository.createShipment(request);

        expect(parcel.details.size, ParcelSize.large);
      });

      test('parses weight correctly', () async {
        final request = ParcelCreateRequest(
          senderName: 'John Doe',
          senderPhone: '+1234567890',
          senderAddress: '123 Main Street',
          receiverName: 'Jane Smith',
          receiverPhone: '+0987654321',
          receiverAddress: '456 Oak Avenue',
          weightText: '3.5',
          size: ParcelSize.medium,
          notes: null,
          serviceType: ParcelServiceType.standard,
        );

        final parcel = await repository.createShipment(request);

        expect(parcel.details.weightKg, 3.5);
      });

      test('handles comma as decimal separator in weight', () async {
        final request = ParcelCreateRequest(
          senderName: 'John Doe',
          senderPhone: '+1234567890',
          senderAddress: '123 Main Street',
          receiverName: 'Jane Smith',
          receiverPhone: '+0987654321',
          receiverAddress: '456 Oak Avenue',
          weightText: '2,5',
          size: ParcelSize.medium,
          notes: null,
          serviceType: ParcelServiceType.standard,
        );

        final parcel = await repository.createShipment(request);

        expect(parcel.details.weightKg, 2.5);
      });

      test('defaults to 1.0 kg for invalid weight', () async {
        final request = ParcelCreateRequest(
          senderName: 'John Doe',
          senderPhone: '+1234567890',
          senderAddress: '123 Main Street',
          receiverName: 'Jane Smith',
          receiverPhone: '+0987654321',
          receiverAddress: '456 Oak Avenue',
          weightText: 'invalid',
          size: ParcelSize.medium,
          notes: null,
          serviceType: ParcelServiceType.standard,
        );

        final parcel = await repository.createShipment(request);

        expect(parcel.details.weightKg, 1.0);
      });

      test('sets notes as description', () async {
        final request = ParcelCreateRequest(
          senderName: 'John Doe',
          senderPhone: '+1234567890',
          senderAddress: '123 Main Street',
          receiverName: 'Jane Smith',
          receiverPhone: '+0987654321',
          receiverAddress: '456 Oak Avenue',
          weightText: '2.5',
          size: ParcelSize.medium,
          notes: 'Handle with care',
          serviceType: ParcelServiceType.standard,
        );

        final parcel = await repository.createShipment(request);

        expect(parcel.details.description, 'Handle with care');
      });

      test('sets null description when notes is null', () async {
        final request = _createTestRequest();

        final parcel = await repository.createShipment(request);

        expect(parcel.details.description, isNull);
      });

      test('sets status to scheduled', () async {
        final request = _createTestRequest();

        final parcel = await repository.createShipment(request);

        expect(parcel.status, ParcelStatus.scheduled);
      });

      test('sets createdAt to approximately now', () async {
        final before = DateTime.now();
        final request = _createTestRequest();

        final parcel = await repository.createShipment(request);

        final after = DateTime.now();
        expect(parcel.createdAt.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
        expect(parcel.createdAt.isBefore(after.add(const Duration(seconds: 1))), isTrue);
      });

      test('adds parcel to internal list (newest first)', () async {
        final request1 = _createTestRequest();
        final request2 = _createTestRequest();

        final parcel1 = await repository.createShipment(request1);
        final parcel2 = await repository.createShipment(request2);

        final parcels = await repository.listParcels();
        expect(parcels.length, 2);
        expect(parcels[0].id, parcel2.id); // newest first
        expect(parcels[1].id, parcel1.id);
      });

      test('generates unique IDs for each shipment', () async {
        final request = _createTestRequest();

        final parcel1 = await repository.createShipment(request);
        final parcel2 = await repository.createShipment(request);

        expect(parcel1.id, isNot(equals(parcel2.id)));
      });

      // Track C - Ticket #50: Pricing Integration Tests
      group('pricing integration', () {
        test('creates parcel with non-null price', () async {
          final request = _createTestRequest();

          final parcel = await repository.createShipment(request);

          expect(parcel.price, isNotNull);
        });

        test('creates parcel with positive total amount', () async {
          final request = _createTestRequest();

          final parcel = await repository.createShipment(request);

          expect(parcel.price!.totalAmountCents, greaterThan(0));
        });

        test('creates parcel with valid currency code', () async {
          final request = _createTestRequest();

          final parcel = await repository.createShipment(request);

          expect(parcel.price!.currencyCode, isNotEmpty);
          expect(parcel.price!.currencyCode, equals('SAR'));
        });

        test('price varies by parcel size - small', () async {
          final request = ParcelCreateRequest(
            senderName: 'Test Sender',
            senderPhone: '+1234567890',
            senderAddress: '123 Test Street',
            receiverName: 'Test Receiver',
            receiverPhone: '+0987654321',
            receiverAddress: '456 Test Avenue',
            weightText: '1.0',
            size: ParcelSize.small,
            notes: null,
            serviceType: ParcelServiceType.standard,
          );

          final parcel = await repository.createShipment(request);

          // Small size with standard service = 1500 cents = 15.00 SAR
          expect(parcel.price!.totalAmountCents, equals(1500));
        });

        test('price varies by parcel size - large', () async {
          final request = ParcelCreateRequest(
            senderName: 'Test Sender',
            senderPhone: '+1234567890',
            senderAddress: '123 Test Street',
            receiverName: 'Test Receiver',
            receiverPhone: '+0987654321',
            receiverAddress: '456 Test Avenue',
            weightText: '5.0',
            size: ParcelSize.large,
            notes: null,
            serviceType: ParcelServiceType.standard,
          );

          final parcel = await repository.createShipment(request);

          // Large size with standard service = 3500 cents = 35.00 SAR
          expect(parcel.price!.totalAmountCents, equals(3500));
        });

        test('express service costs more than standard', () async {
          final standardRequest = ParcelCreateRequest(
            senderName: 'Test Sender',
            senderPhone: '+1234567890',
            senderAddress: '123 Test Street',
            receiverName: 'Test Receiver',
            receiverPhone: '+0987654321',
            receiverAddress: '456 Test Avenue',
            weightText: '2.0',
            size: ParcelSize.medium,
            notes: null,
            serviceType: ParcelServiceType.standard,
          );

          final expressRequest = ParcelCreateRequest(
            senderName: 'Test Sender',
            senderPhone: '+1234567890',
            senderAddress: '123 Test Street',
            receiverName: 'Test Receiver',
            receiverPhone: '+0987654321',
            receiverAddress: '456 Test Avenue',
            weightText: '2.0',
            size: ParcelSize.medium,
            notes: null,
            serviceType: ParcelServiceType.express,
          );

          final standardParcel = await repository.createShipment(standardRequest);
          final expressParcel = await repository.createShipment(expressRequest);

          expect(
            expressParcel.price!.totalAmountCents,
            greaterThan(standardParcel.price!.totalAmountCents),
          );
        });

        test('handles comma decimal separator in weight for pricing', () async {
          final request = ParcelCreateRequest(
            senderName: 'Test Sender',
            senderPhone: '+1234567890',
            senderAddress: '123 Test Street',
            receiverName: 'Test Receiver',
            receiverPhone: '+0987654321',
            receiverAddress: '456 Test Avenue',
            weightText: '2,5',
            size: ParcelSize.medium,
            notes: null,
            serviceType: ParcelServiceType.standard,
          );

          final parcel = await repository.createShipment(request);

          // Should successfully create parcel with price
          expect(parcel.price, isNotNull);
          expect(parcel.price!.totalAmountCents, greaterThan(0));
        });
      });
    });
  });
}

/// Helper to create a test Parcel.
Parcel _createTestParcel(String id) {
  return Parcel(
    id: id,
    createdAt: DateTime.now(),
    pickupAddress: const ParcelAddress(label: 'Test Pickup'),
    dropoffAddress: const ParcelAddress(label: 'Test Dropoff'),
    details: const ParcelDetails(
      size: ParcelSize.medium,
      weightKg: 2.5,
      description: 'Test contents',
    ),
    status: ParcelStatus.scheduled,
  );
}

/// Helper to create a test ParcelCreateRequest.
ParcelCreateRequest _createTestRequest() {
  return const ParcelCreateRequest(
    senderName: 'Test Sender',
    senderPhone: '+1234567890',
    senderAddress: '123 Test Street',
    receiverName: 'Test Receiver',
    receiverPhone: '+0987654321',
    receiverAddress: '456 Test Avenue',
    weightText: '2.5',
    size: ParcelSize.medium,
    notes: null,
    serviceType: ParcelServiceType.standard,
  );
}


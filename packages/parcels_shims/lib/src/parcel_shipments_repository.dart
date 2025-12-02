import 'dart:async';

import 'parcel_shipment.dart';

/// Track C - Parcels Shim (Ticket #148)
/// Domain-facing API for managing parcel shipments.
///
/// Pure Dart interface (no Flutter, no HTTP).
abstract class ParcelShipmentsRepository {
  /// Stream of all shipments, ordered by createdAt desc.
  Stream<List<ParcelShipment>> watchShipments();

  /// Get a single shipment by id.
  Future<ParcelShipment?> getShipmentById(String id);

  /// Create a new shipment (returns created instance).
  Future<ParcelShipment> createShipment(ParcelShipment shipment);

  /// Update the status of an existing shipment.
  Future<void> updateShipmentStatus(String id, ParcelShipmentStatus status);

  /// Clear all shipments (useful for tests / reset).
  Future<void> clearAll();
}

/// In-memory implementation of ParcelShipmentsRepository.
/// 
/// Track C - Ticket #148: Parcels Shims
class InMemoryParcelShipmentsRepository implements ParcelShipmentsRepository {
  InMemoryParcelShipmentsRepository() {
    // Emit initial empty state
    _emit();
  }

  final _controller = StreamController<List<ParcelShipment>>.broadcast();
  final List<ParcelShipment> _items = [];
  List<ParcelShipment> _lastEmittedValue = [];

  @override
  Stream<List<ParcelShipment>> watchShipments() {
    // Return a stream that immediately emits the last known value
    // then listens to future updates
    return Stream.multi((controller) {
      controller.add(_lastEmittedValue);
      _controller.stream.listen(
        controller.add,
        onError: controller.addError,
        onDone: controller.close,
      );
    });
  }

  @override
  Future<ParcelShipment?> getShipmentById(String id) async {
    try {
      return _items.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<ParcelShipment> createShipment(ParcelShipment shipment) async {
    _items.add(shipment);
    _emit();
    return shipment;
  }

  @override
  Future<void> updateShipmentStatus(
      String id, ParcelShipmentStatus status) async {
    final index = _items.indexWhere((s) => s.id == id);
    if (index == -1) return;

    final current = _items[index];
    _items[index] = current.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );
    _emit();
  }

  @override
  Future<void> clearAll() async {
    _items.clear();
    _emit();
  }

  void _emit() {
    // Newest first
    final sorted = [..._items]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _lastEmittedValue = List.unmodifiable(sorted);
    _controller.add(_lastEmittedValue);
  }

  void dispose() {
    _controller.close();
  }
}

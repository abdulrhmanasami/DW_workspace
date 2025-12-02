import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parcels_shims/parcels_shims.dart';

/// Track C - Ticket #149:
/// App-level providers for Parcels Shipments, backed by parcels_shims.

final parcelShipmentsRepositoryProvider =
    Provider<ParcelShipmentsRepository>((ref) {
  // Simple in-memory implementation for now.
  final repo = InMemoryParcelShipmentsRepository();

  ref.onDispose(() {
    // Dispose the repository when provider is disposed
    repo.dispose();
  });

  return repo;
});

/// Stream provider exposing shipments list to the UI.
///
/// Sorted from most recent to oldest (handled by repository).
final parcelShipmentsStreamProvider =
    StreamProvider.autoDispose<List<ParcelShipment>>((ref) {
  final repo = ref.watch(parcelShipmentsRepositoryProvider);
  return repo.watchShipments();
});

/// Future provider to create a new shipment.
///
/// Returns a FutureProvider.family for creating shipments with different parameters.
final createShipmentProvider =
    FutureProvider.family<ParcelShipment, ParcelShipment>((ref, shipment) async {
  final repo = ref.read(parcelShipmentsRepositoryProvider);
  return await repo.createShipment(shipment);
});

/// Track C - Ticket #150:
/// Helper provider exposing a function to create a new ParcelShipment.
final createParcelShipmentProvider =
    Provider<Future<ParcelShipment> Function(ParcelShipment)>((ref) {
  final repo = ref.watch(parcelShipmentsRepositoryProvider);

  return (ParcelShipment shipment) {
    return repo.createShipment(shipment);
  };
});

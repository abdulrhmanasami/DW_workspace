import 'package:meta/meta.dart';

import 'parcel_models.dart';
import 'parcel_pricing_service.dart';

/// DTO for creating a new parcel shipment.
///
/// Contains all fields from the Create Shipment form.
/// Track C - Ticket #49
@immutable
class ParcelCreateRequest {
  const ParcelCreateRequest({
    required this.senderName,
    required this.senderPhone,
    required this.senderAddress,
    required this.receiverName,
    required this.receiverPhone,
    required this.receiverAddress,
    required this.weightText,
    required this.size,
    this.notes,
    required this.serviceType,
  });

  final String senderName;
  final String senderPhone;
  final String senderAddress;
  final String receiverName;
  final String receiverPhone;
  final String receiverAddress;
  final String weightText;
  final ParcelSize size;
  final String? notes;
  final ParcelServiceType serviceType;
}

/// Port (abstract interface) for managing parcel shipments.
///
/// This is the Ports/Adapters pattern - the Port defines the contract,
/// and concrete Adapters implement it (in-memory, backend, etc.)
///
/// Track C - Ticket #49
abstract class ParcelsRepository {
  /// Returns all parcels in the current session/storage.
  Future<List<Parcel>> listParcels();

  /// Creates a new shipment from the given request.
  ///
  /// Returns the created [Parcel] with generated ID and timestamp.
  Future<Parcel> createShipment(ParcelCreateRequest request);

  /// Gets a parcel by its ID.
  ///
  /// Returns `null` if not found.
  Future<Parcel?> getParcelById(String id);
}


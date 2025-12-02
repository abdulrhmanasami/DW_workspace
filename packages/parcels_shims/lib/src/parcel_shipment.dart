import 'package:meta/meta.dart';

import 'parcel_contact.dart';
import 'parcel_models.dart';

/// Status of a parcel shipment.
/// 
/// Track C - Ticket #148: Parcels Domain Models
enum ParcelShipmentStatus {
  created,
  inTransit,
  delivered,
  cancelled,
}

/// Extended parcel shipment model with sender/receiver contacts.
/// 
/// Track C - Ticket #148: Parcels Domain Models
@immutable
class ParcelShipment {
  const ParcelShipment({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.weightKg,
    this.sizeLabel,
    this.notes,
    this.serviceType, // e.g. "Express" / "Standard"
    this.estimatedPrice,
    this.currencyCode,
  });

  final String id;
  final ParcelContact sender;
  final ParcelContact receiver;
  final ParcelAddress pickupAddress;
  final ParcelAddress dropoffAddress;
  
  final ParcelShipmentStatus status;
  
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  /// Optional fields (details section in Screen 11)
  final double? weightKg;
  final String? sizeLabel;
  final String? notes;
  
  /// Service type (Screen 11 chips: Express / Standard)
  final String? serviceType;
  
  /// Estimated/final price for Orders/History screens.
  final double? estimatedPrice;
  final String? currencyCode;

  ParcelShipment copyWith({
    ParcelShipmentStatus? status,
    DateTime? updatedAt,
    double? estimatedPrice,
    String? currencyCode,
  }) {
    return ParcelShipment(
      id: id,
      sender: sender,
      receiver: receiver,
      pickupAddress: pickupAddress,
      dropoffAddress: dropoffAddress,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      weightKg: weightKg,
      sizeLabel: sizeLabel,
      notes: notes,
      serviceType: serviceType,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParcelShipment &&
        other.id == id &&
        other.sender == sender &&
        other.receiver == receiver &&
        other.pickupAddress == pickupAddress &&
        other.dropoffAddress == dropoffAddress &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.weightKg == weightKg &&
        other.sizeLabel == sizeLabel &&
        other.notes == notes &&
        other.serviceType == serviceType &&
        other.estimatedPrice == estimatedPrice &&
        other.currencyCode == currencyCode;
  }

  @override
  int get hashCode => Object.hash(
        id,
        sender,
        receiver,
        pickupAddress,
        dropoffAddress,
        status,
        createdAt,
        updatedAt,
        weightKg,
        sizeLabel,
        notes,
        serviceType,
        estimatedPrice,
        currencyCode,
      );

  @override
  String toString() {
    return 'ParcelShipment(id: $id, sender: $sender, receiver: $receiver, '
        'pickupAddress: $pickupAddress, dropoffAddress: $dropoffAddress, '
        'status: $status, createdAt: $createdAt, updatedAt: $updatedAt, '
        'weightKg: $weightKg, sizeLabel: $sizeLabel, notes: $notes, '
        'serviceType: $serviceType, estimatedPrice: $estimatedPrice, '
        'currencyCode: $currencyCode)';
  }
}

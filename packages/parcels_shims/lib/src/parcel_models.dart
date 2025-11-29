import 'package:meta/meta.dart';

/// Unique identifier for a parcel shipment.
typedef ParcelId = String;

/// Domain type representing a parcel price.
///
/// Track C - Ticket #50: Parcels Pricing Integration
@immutable
class ParcelPrice {
  const ParcelPrice({
    required this.totalAmountCents,
    required this.currencyCode,
  });

  /// Total price in cents (smallest currency unit).
  final int totalAmountCents;

  /// ISO 4217 currency code (e.g., "SAR", "USD", "EUR").
  final String currencyCode;

  /// Convenience getter for total in major currency unit (e.g., SAR not halalas).
  double get totalAmount => totalAmountCents / 100.0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParcelPrice &&
        other.totalAmountCents == totalAmountCents &&
        other.currencyCode == currencyCode;
  }

  @override
  int get hashCode => Object.hash(totalAmountCents, currencyCode);

  @override
  String toString() =>
      'ParcelPrice(totalAmountCents: $totalAmountCents, currencyCode: $currencyCode)';
}

/// Parcel size category for pricing and logistics.
enum ParcelSize {
  small,
  medium,
  large,
  oversize,
}

/// High-level status of a parcel shipment.
///
/// This is the "business status" visible to UI / customer.
/// The internal FSM (ParcelPhase) may be more detailed.
enum ParcelStatus {
  draft,
  quoting,
  scheduled,
  pickupPending,
  pickedUp,
  inTransit,
  delivered,
  cancelled,
  failed,
}

/// Basic address model for Parcels.
///
/// ⚠️ Can be replaced/merged with Address from Orders API later.
@immutable
class ParcelAddress {
  const ParcelAddress({
    required this.label,
    this.streetLine1,
    this.streetLine2,
    this.city,
    this.region,
    this.countryCode,
    this.postalCode,
  });

  final String label;
  final String? streetLine1;
  final String? streetLine2;
  final String? city;
  final String? region;
  final String? countryCode;
  final String? postalCode;
}

/// Basic parcel details used for quoting and tracking.
///
/// Can be extended later to include Orders API fields (contentType, declaredValue, ...).
@immutable
class ParcelDetails {
  const ParcelDetails({
    required this.size,
    this.weightKg,
    this.description,
  });

  final ParcelSize size;
  final double? weightKg;
  final String? description;
}

/// Core Parcel shipment model.
///
/// This is not a full Order, but represents the shipment as needed in the app.
@immutable
class Parcel {
  const Parcel({
    required this.id,
    required this.createdAt,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.details,
    required this.status,
    this.price,
  });

  final ParcelId id;
  final DateTime createdAt;
  final ParcelAddress pickupAddress;
  final ParcelAddress dropoffAddress;
  final ParcelDetails details;
  final ParcelStatus status;

  /// The calculated price for this parcel shipment.
  /// Track C - Ticket #50: Parcels Pricing Integration
  final ParcelPrice? price;

  Parcel copyWith({
    ParcelStatus? status,
    ParcelPrice? price,
  }) {
    return Parcel(
      id: id,
      createdAt: createdAt,
      pickupAddress: pickupAddress,
      dropoffAddress: dropoffAddress,
      details: details,
      status: status ?? this.status,
      price: price ?? this.price,
    );
  }
}

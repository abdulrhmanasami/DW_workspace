import 'package:meta/meta.dart';

/// Contact information for sender or receiver in parcel shipments.
/// 
/// Track C - Ticket #148: Parcels Domain Models
@immutable
class ParcelContact {
  const ParcelContact({
    required this.name,
    required this.phone,
  });

  final String name;
  final String phone;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParcelContact &&
        other.name == name &&
        other.phone == phone;
  }

  @override
  int get hashCode => Object.hash(name, phone);

  @override
  String toString() => 'ParcelContact(name: $name, phone: $phone)';
}

/// Mobility Place Models - Track B Ticket #20
/// Purpose: Domain models for location/place representation
/// Created by: Track B - Ticket #20
/// Last updated: 2025-11-28
///
/// These models represent places/locations for the ride booking flow.
/// They are domain models that can be used across the app via shims.

import 'package:meta/meta.dart';
import 'package:mobility_shims/location/models.dart';

/// Represents a named location/place for ride booking.
/// Used for pickup and destination points in the ride flow.
@immutable
class MobilityPlace {
  /// Unique identifier for this place (can be address ID, POI ID, etc.)
  final String? id;

  /// Human-readable display name (e.g., "Home", "Work", "Airport")
  final String label;

  /// Full address string for display
  final String? address;

  /// Geographic coordinates (optional - may be resolved later)
  final LocationPoint? location;

  /// Place type for categorization
  final MobilityPlaceType type;

  const MobilityPlace({
    this.id,
    required this.label,
    this.address,
    this.location,
    this.type = MobilityPlaceType.other,
  });

  /// Factory for current location placeholder
  factory MobilityPlace.currentLocation({String? label}) {
    return MobilityPlace(
      id: '__current_location__',
      label: label ?? 'Current location',
      type: MobilityPlaceType.currentLocation,
    );
  }

  /// Factory for a recent/saved place
  factory MobilityPlace.saved({
    required String id,
    required String label,
    String? address,
    LocationPoint? location,
    MobilityPlaceType type = MobilityPlaceType.saved,
  }) {
    return MobilityPlace(
      id: id,
      label: label,
      address: address,
      location: location,
      type: type,
    );
  }

  /// Check if this is the current location placeholder
  bool get isCurrentLocation => type == MobilityPlaceType.currentLocation;

  /// Check if this place has resolved coordinates
  bool get hasCoordinates => location != null;

  MobilityPlace copyWith({
    String? id,
    String? label,
    String? address,
    LocationPoint? location,
    MobilityPlaceType? type,
  }) {
    return MobilityPlace(
      id: id ?? this.id,
      label: label ?? this.label,
      address: address ?? this.address,
      location: location ?? this.location,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MobilityPlace &&
        other.id == id &&
        other.label == label &&
        other.address == address &&
        other.type == type;
  }

  @override
  int get hashCode => Object.hash(id, label, address, type);

  @override
  String toString() =>
      'MobilityPlace(id: $id, label: $label, address: $address, type: $type)';
}

/// Type classification for mobility places
enum MobilityPlaceType {
  /// User's current GPS location
  currentLocation,

  /// Saved/favorite place (home, work, etc.)
  saved,

  /// Recently visited place
  recent,

  /// Search result / POI
  searchResult,

  /// Other/generic place
  other,
}

/// Recent location item for display in the UI
@immutable
class RecentLocation {
  final String id;
  final String title;
  final String? subtitle;
  final MobilityPlaceType type;
  final LocationPoint? location;

  const RecentLocation({
    required this.id,
    required this.title,
    this.subtitle,
    this.type = MobilityPlaceType.recent,
    this.location,
  });

  MobilityPlace toMobilityPlace() {
    return MobilityPlace(
      id: id,
      label: title,
      address: subtitle,
      location: location,
      type: type,
    );
  }
}


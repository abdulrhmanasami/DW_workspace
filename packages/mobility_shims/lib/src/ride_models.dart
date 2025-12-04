/// Ride Domain Models - Track B Ticket #241
/// Purpose: Core domain models for ride booking
/// Created by: Track B - Ticket #241
/// Last updated: 2025-12-04
///
/// Contains the essential domain models for ride booking.
/// Uses existing MobilityPlace model to avoid duplication.

import 'package:meta/meta.dart';

import 'place_models.dart';
import 'ride_status.dart';

/// Core domain model representing a ride booking request.
///
/// This model tracks the complete lifecycle of a ride from draft
/// through completion or failure. It contains all necessary information
/// for booking, tracking, and completing a ride.
///
/// IMPORTANT: This is a domain model, not a persistence or API model.
/// Storage/backends should map to/from this model as needed.
@immutable
class RideRequest {
  /// Creates a new ride request with the specified parameters.
  const RideRequest({
    this.id,
    required this.status,
    this.pickup,
    this.destination,
    required this.createdAt,
    this.updatedAt,
    this.estimatedDurationSeconds,
    this.estimatedPrice,
    this.currencyCode,
  });

  /// Unique identifier for this ride request.
  /// May be null for draft requests that haven't been submitted yet.
  final String? id;

  /// Current status in the ride booking lifecycle.
  final RideStatus status;

  /// Pickup location for the ride.
  /// May be null if not yet selected.
  final MobilityPlace? pickup;

  /// Destination location for the ride.
  /// May be null if not yet selected.
  final MobilityPlace? destination;

  /// Timestamp when this request was created.
  final DateTime createdAt;

  /// Timestamp when this request was last updated.
  /// Should be updated on every status change.
  final DateTime? updatedAt;

  /// Estimated trip duration in seconds.
  /// Populated after quote is received.
  final int? estimatedDurationSeconds;

  /// Estimated trip price in minor units (e.g., 1850 = 18.50 SAR).
  /// Populated after quote is received.
  final int? estimatedPrice;

  /// ISO-4217 currency code for pricing (e.g., 'SAR', 'USD').
  /// Defaults to SAR if not specified.
  final String? currencyCode;

  /// Creates a copy of this RideRequest with the given fields replaced.
  RideRequest copyWith({
    String? id,
    RideStatus? status,
    MobilityPlace? pickup,
    MobilityPlace? destination,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? estimatedDurationSeconds,
    int? estimatedPrice,
    String? currencyCode,
  }) {
    return RideRequest(
      id: id ?? this.id,
      status: status ?? this.status,
      pickup: pickup ?? this.pickup,
      destination: destination ?? this.destination,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      estimatedDurationSeconds: estimatedDurationSeconds ?? this.estimatedDurationSeconds,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }

  /// Returns true if both pickup and destination are set.
  bool get hasValidLocations => pickup != null && destination != null;

  /// Returns true if pricing information is available.
  bool get hasPricing => estimatedPrice != null && currencyCode != null;

  /// Formats the estimated price for display (e.g., "18.50").
  /// Returns null if pricing is not available.
  String? get formattedEstimatedPrice {
    if (estimatedPrice == null) return null;
    final major = estimatedPrice! ~/ 100;
    final minor = estimatedPrice! % 100;
    return '$major.${minor.toString().padLeft(2, '0')}';
  }

  /// Returns the estimated duration formatted as minutes.
  /// Returns null if duration is not available.
  String? get formattedEstimatedDuration {
    if (estimatedDurationSeconds == null) return null;
    final minutes = estimatedDurationSeconds! ~/ 60;
    return '$minutes min';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RideRequest &&
        other.id == id &&
        other.status == status &&
        other.pickup == pickup &&
        other.destination == destination &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.estimatedDurationSeconds == estimatedDurationSeconds &&
        other.estimatedPrice == estimatedPrice &&
        other.currencyCode == currencyCode;
  }

  @override
  int get hashCode => Object.hash(
        id,
        status,
        pickup,
        destination,
        createdAt,
        updatedAt,
        estimatedDurationSeconds,
        estimatedPrice,
        currencyCode,
      );

  @override
  String toString() {
    return 'RideRequest('
        'id: $id, '
        'status: $status, '
        'pickup: ${pickup?.label}, '
        'destination: ${destination?.label}, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'hasPricing: $hasPricing'
        ')';
  }
}

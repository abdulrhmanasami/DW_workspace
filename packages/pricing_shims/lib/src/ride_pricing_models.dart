/// Ride Pricing Domain Models
/// Ticket #210 – Track B: Mock Ride Pricing Service + Domain Interface
/// Purpose: Define canonical ride pricing data models

import 'package:meta/meta.dart';
import 'package:payments/models.dart';
import 'package:maps_shims/maps_shims.dart';

/// Request for a ride price quote.
@immutable
class RideQuoteRequest {
  /// Creates a ride quote request.
  const RideQuoteRequest({
    required this.pickup,
    required this.dropoff,
    required this.requestedAt,
    this.serviceTierCode,
    this.debugScenario, // For testing different surge scenarios
    this.forceNetworkError = false, // For testing error handling
  });

  /// Pickup location.
  final GeoPoint pickup;

  /// Dropoff location.
  final GeoPoint dropoff;

  /// When the ride is requested.
  final DateTime requestedAt;

  /// Service tier code (e.g., "standard", "premium").
  final String? serviceTierCode;

  /// Debug scenario for testing (normal, moderate_surge, high_surge, network_error).
  final String? debugScenario;

  /// Force network error for testing purposes.
  final bool forceNetworkError;

  @override
  String toString() => 'RideQuoteRequest(pickup: $pickup, dropoff: $dropoff, serviceTierCode: $serviceTierCode)';

  @override
  bool operator ==(Object other) {
    return other is RideQuoteRequest &&
        other.pickup == pickup &&
        other.dropoff == dropoff &&
        other.requestedAt == requestedAt &&
        other.serviceTierCode == serviceTierCode;
  }

  @override
  int get hashCode => Object.hash(pickup, dropoff, requestedAt, serviceTierCode);
}

/// A price quote for a ride.
@immutable
class RideQuote {
  /// Creates a ride quote.
  const RideQuote({
    required this.id,
    required this.price,
    required this.estimatedDuration,
    required this.distanceMeters,
    required this.surgeMultiplier,
  });

  /// Unique quote identifier.
  final String id;

  /// The quoted price using the payments Amount model.
  final Amount price;

  /// Estimated duration in minutes.
  final Duration estimatedDuration;

  /// Distance in meters.
  final int distanceMeters;

  /// Surge multiplier (1.0 = no surge, 1.5 = moderate, 2.0 = high).
  final double surgeMultiplier;

  @override
  String toString() => 'RideQuote(id: $id, price: $price, duration: $estimatedDuration, distance: $distanceMeters, surge: $surgeMultiplier)';

  @override
  bool operator ==(Object other) {
    return other is RideQuote &&
        other.id == id &&
        other.price.value == price.value &&
        other.price.currency == price.currency &&
        other.estimatedDuration == estimatedDuration &&
        other.distanceMeters == distanceMeters &&
        other.surgeMultiplier == surgeMultiplier;
  }

  @override
  int get hashCode => Object.hash(id, price, estimatedDuration, distanceMeters, surgeMultiplier);
}

/// Reasons why a ride quote request might fail.
enum RideQuoteFailureReason {
  /// Network error occurred.
  networkError,

  /// Invalid request parameters.
  invalidRequest,

  /// Service is currently unavailable.
  serviceUnavailable,

  /// Surge pricing is too high.
  surgeTooHigh,
}

/// Result of a ride quote request (success or failure).
@immutable
class RideQuoteResult {
  /// Creates a successful result.
  const RideQuoteResult.success(this.quote)
      : failure = null,
        assert(quote != null);

  /// Creates a failure result.
  const RideQuoteResult.failure(this.failure)
      : quote = null,
        assert(failure != null);

  /// The successful quote, null if failed.
  final RideQuote? quote;

  /// The failure reason, null if successful.
  final RideQuoteFailureReason? failure;

  /// Whether the result is successful.
  bool get isSuccess => quote != null;

  /// Whether the result is a failure.
  bool get isFailure => failure != null;

  @override
  String toString() => isSuccess
      ? 'RideQuoteResult.success($quote)'
      : 'RideQuoteResult.failure($failure)';

  @override
  bool operator ==(Object other) {
    return other is RideQuoteResult &&
        other.quote == quote &&
        other.failure == failure;
  }

  @override
  int get hashCode => Object.hash(quote, failure);
}

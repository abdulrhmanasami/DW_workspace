/// Ride Pricing Service Interface - Track B Ticket #27, #115
/// Purpose: Abstract contract for ride pricing & quoting with MobilityPlace support
/// Created by: Track B - Ticket #27
/// Reviewed by: Track B - Ticket #115 (MockPricingService architecture validation)
/// Last updated: 2025-11-30
///
/// This interface provides:
/// - Pricing computation based on MobilityPlace (domain models)
/// - Support for different service types (Economy, XL, Premium)
/// - Abstraction layer for backend pricing engine simulation
///
/// IMPORTANT:
/// - Implementations may simulate network latency and failures
/// - This is part of the MockPricingService Stub for RideQuote

import '../place_models.dart';
import '../ride_quote_models.dart';

/// Service type for ride pricing.
///
/// Maps to vehicle categories but used specifically for pricing requests.
/// This allows flexibility in pricing different service levels.
enum RideServiceType {
  /// Standard affordable option
  economy,

  /// Larger vehicle for more passengers or luggage
  xl,

  /// Luxury/premium vehicle option
  premium,

  /// Generic ride - returns all available options
  ride,
}

/// Abstract contract for ride pricing & quoting.
///
/// Track B - Ticket #27: MockPricingService Stub for RideQuote.
///
/// Implementations can:
/// - Simulate network latency
/// - Simulate random failures (for chaos testing)
/// - Compute pricing based on distance/time heuristics
abstract class RidePricingService {
  /// Computes a [RideQuote] for the given pickup and destination.
  ///
  /// Parameters:
  /// - [pickup]: The pickup location as a [MobilityPlace]
  /// - [destination]: The destination location as a [MobilityPlace]
  /// - [serviceType]: The type of service requested (affects options returned)
  ///
  /// Returns a [RideQuote] with available options.
  ///
  /// Throws [RidePricingException] on pricing failures.
  Future<RideQuote> quoteRide({
    required MobilityPlace pickup,
    required MobilityPlace destination,
    required RideServiceType serviceType,
  });
}

/// Exception thrown when ride pricing fails.
///
/// This can be used to simulate backend failures or network errors
/// in mock implementations.
class RidePricingException implements Exception {
  /// Creates a new pricing exception with the given [message].
  const RidePricingException(this.message);

  /// Human-readable error message.
  final String message;

  @override
  String toString() => 'RidePricingException: $message';
}


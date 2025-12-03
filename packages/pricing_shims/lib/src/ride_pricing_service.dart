/// Ride Pricing Service Interface
/// Ticket #210 – Track B: Mock Ride Pricing Service + Domain Interface
/// Purpose: Define the contract for ride pricing services

import 'ride_pricing_models.dart';

/// Service for requesting ride price quotes.
///
/// This interface defines the contract for pricing services,
/// allowing different implementations (mock, real backend, etc.).
abstract class RidePricingService {
  /// Requests a price quote for a ride.
  ///
  /// Returns a [RideQuoteResult] containing either a successful
  /// [RideQuote] or a failure reason.
  Future<RideQuoteResult> requestQuote(RideQuoteRequest request);
}

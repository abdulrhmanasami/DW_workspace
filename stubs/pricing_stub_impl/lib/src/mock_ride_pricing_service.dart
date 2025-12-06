/// Mock Ride Pricing Service Implementation
/// Ticket #210 – Track B: Mock Ride Pricing Service + Domain Interface
/// Purpose: Pure Dart mock implementation of ride pricing with surge support

import 'dart:math' as math;
import 'package:pricing_shims/pricing_shims.dart';
import 'package:payments/models.dart';
import 'package:maps_shims/maps_shims.dart';

/// Mock implementation of ride pricing service for testing and development.
///
/// This service provides deterministic pricing calculations with support for:
/// - Normal pricing (surge = 1.0)
/// - Moderate surge (surge = 1.5)
/// - High surge (surge = 2.0)
/// - Network error simulation
class MockRidePricingService implements RidePricingService {
  /// Creates a mock ride pricing service.
  const MockRidePricingService({
    this.baseFare = 800, // 8.00 SAR in minor units
    this.perKmRate = 150, // 1.50 SAR per km in minor units
    this.perMinuteRate = 40, // 0.40 SAR per minute in minor units
    this.avgSpeedKmh = 30, // Average speed in km/h for duration calculation
  });

  /// Base fare in minor units (e.g., 800 = 8.00 SAR).
  final int baseFare;

  /// Rate per kilometer in minor units (e.g., 150 = 1.50 SAR/km).
  final int perKmRate;

  /// Rate per minute in minor units (e.g., 40 = 0.40 SAR/min).
  final int perMinuteRate;

  /// Average speed in km/h for estimating duration.
  final int avgSpeedKmh;

  static const String _currency = 'SAR';

  @override
  Future<RideQuoteResult> requestQuote(RideQuoteRequest request) async {
    // Simulate network delay (50-200ms)
    await Future<void>.delayed(Duration(milliseconds: 50 + math.Random().nextInt(150)));

    // Check for forced network error
    if (request.forceNetworkError) {
      return const RideQuoteResult.failure(RideQuoteFailureReason.networkError);
    }

    // Validate request
    if (!_isValidRequest(request)) {
      return const RideQuoteResult.failure(RideQuoteFailureReason.invalidRequest);
    }

    // Determine surge multiplier based on debug scenario
    final surgeMultiplier = _getSurgeMultiplier(request.debugScenario);

    // Calculate distance and duration
    final distanceKm = _calculateDistanceKm(request.pickup, request.dropoff);
    final distanceMeters = (distanceKm * 1000).round();
    final estimatedDuration = Duration(minutes: (distanceKm / avgSpeedKmh * 60).round());

    // Calculate price
    final priceMinorUnits = _calculatePrice(
      distanceKm: distanceKm,
      durationMinutes: estimatedDuration.inMinutes,
      surgeMultiplier: surgeMultiplier,
    );

    // Create quote
    final quoteId = 'mock-${DateTime.now().millisecondsSinceEpoch}';
    final quote = RideQuote(
      id: quoteId,
      price: Amount(priceMinorUnits, _currency),
      estimatedDuration: estimatedDuration,
      distanceMeters: distanceMeters,
      surgeMultiplier: surgeMultiplier,
    );

    return RideQuoteResult.success(quote);
  }

  /// Validates the quote request.
  bool _isValidRequest(RideQuoteRequest request) {
    // Basic validation - pickup and dropoff should be different
    return request.pickup != request.dropoff;
  }

  /// Determines surge multiplier based on debug scenario.
  double _getSurgeMultiplier(String? scenario) {
    switch (scenario) {
      case 'moderate_surge':
        return 1.5;
      case 'high_surge':
        return 2.0;
      case 'network_error':
        throw UnsupportedError('Use forceNetworkError flag instead');
      case 'normal':
      default:
        return 1.0;
    }
  }

  /// Calculates approximate distance between two points using Haversine formula.
  ///
  /// Returns distance in kilometers.
  double _calculateDistanceKm(GeoPoint pickup, GeoPoint dropoff) {
    const double earthRadiusKm = 6371;

    final lat1Rad = pickup.latitude * math.pi / 180;
    final lat2Rad = dropoff.latitude * math.pi / 180;
    final deltaLatRad = (dropoff.latitude - pickup.latitude) * math.pi / 180;
    final deltaLngRad = (dropoff.longitude - pickup.longitude) * math.pi / 180;

    final a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) *
        math.sin(deltaLngRad / 2) * math.sin(deltaLngRad / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusKm * c;
  }

  /// Calculates total price in minor units.
  int _calculatePrice({
    required double distanceKm,
    required int durationMinutes,
    required double surgeMultiplier,
  }) {
    final distanceCost = (distanceKm * perKmRate).round();
    final timeCost = (durationMinutes * perMinuteRate).round();
    final baseCost = baseFare;

    final subtotal = baseCost + distanceCost + timeCost;
    final total = (subtotal * surgeMultiplier).round();

    return total;
  }
}

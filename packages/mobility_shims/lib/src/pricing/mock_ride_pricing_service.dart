/// Mock Ride Pricing Service - Track B Ticket #27
/// Purpose: Simulated backend pricing engine for development and testing
/// Created by: Track B - Ticket #27
/// Last updated: 2025-11-28
///
/// This implementation simulates a backend pricing engine:
/// - Configurable network latency
/// - Configurable failure rate for chaos testing
/// - Distance-based pricing calculation
/// - Multiple vehicle options (Economy, XL, Premium)
///
/// IMPORTANT:
/// - This is NOT a production pricing engine
/// - Use for development, testing, and UI prototyping only
/// - Swap with real backend adapter in production

import 'dart:math';

import 'package:meta/meta.dart';

import '../../location/models.dart';
import '../place_models.dart';
import '../ride_quote_models.dart';
import 'ride_pricing_service.dart';

/// Mock implementation of [RidePricingService].
///
/// Simulates a backend pricing engine with:
/// - Configurable latency to simulate network delay
/// - Configurable failure rate for testing error handling
/// - Distance-based pricing with realistic fare calculation
///
/// Example usage:
/// ```dart
/// // Default configuration
/// const service = MockRidePricingService();
///
/// // Custom latency for slower network simulation
/// const slowService = MockRidePricingService(
///   baseLatency: Duration(milliseconds: 1500),
/// );
///
/// // Always fails (for error testing)
/// const failingService = MockRidePricingService(
///   failureRate: 1.0,
/// );
/// ```
@immutable
class MockRidePricingService implements RidePricingService {
  /// Creates a mock pricing service with configurable behavior.
  ///
  /// Parameters:
  /// - [baseLatency]: Simulated network delay (default: 600ms)
  /// - [failureRate]: Probability of failure (0.0 to 1.0, default: 0.0)
  /// - [random]: Optional random instance for deterministic testing
  const MockRidePricingService({
    this.baseLatency = const Duration(milliseconds: 600),
    this.failureRate = 0.0,
    Random? random,
  }) : _random = random;

  /// Simulated network latency before returning results.
  final Duration baseLatency;

  /// Probability of throwing [RidePricingException] (0.0 = never, 1.0 = always).
  final double failureRate;

  /// Random instance for failure simulation (injectable for testing).
  final Random? _random;

  // Pricing constants (SAR)
  static const _baseFareEconomy = 5.0;
  static const _baseFareXl = 8.0;
  static const _baseFarePremium = 12.0;

  static const _perKmEconomy = 2.0;
  static const _perKmXl = 3.5;
  static const _perKmPremium = 5.0;

  // ETA constants (km/h average speed assumptions)
  static const _avgSpeedEconomy = 25.0;
  static const _avgSpeedXl = 22.0;
  static const _avgSpeedPremium = 28.0;

  // Default distance when coordinates are missing
  static const _defaultDistanceKm = 5.0;

  @override
  Future<RideQuote> quoteRide({
    required MobilityPlace pickup,
    required MobilityPlace destination,
    required RideServiceType serviceType,
  }) async {
    // 1) Simulate network latency
    await Future.delayed(baseLatency);

    // 2) Check for simulated failure
    if (_shouldFail()) {
      throw const RidePricingException('Mock pricing service failure');
    }

    // 3) Calculate distance between pickup and destination
    final distanceKm = _estimateDistanceKm(
      pickup.location,
      destination.location,
    );

    // 4) Build options based on service type
    final options = _buildOptions(
      distanceKm: distanceKm,
      serviceType: serviceType,
    );

    // 5) Create the quote request for backward compatibility
    final request = _buildRequest(pickup, destination);

    return RideQuote(
      quoteId: 'mock-${DateTime.now().microsecondsSinceEpoch}',
      request: request,
      options: options,
    );
  }

  /// Determines if this request should fail based on [failureRate].
  bool _shouldFail() {
    if (failureRate <= 0.0) return false;
    if (failureRate >= 1.0) return true;

    final random = _random ?? Random();
    return random.nextDouble() < failureRate;
  }

  /// Estimates distance in kilometers between two points.
  ///
  /// Uses equirectangular approximation (good enough for city distances).
  /// Falls back to [_defaultDistanceKm] if coordinates are missing.
  double _estimateDistanceKm(LocationPoint? a, LocationPoint? b) {
    if (a == null || b == null) return _defaultDistanceKm;

    // Equirectangular approximation
    // ~111 km per degree at the equator
    final dx = (a.latitude - b.latitude).abs();
    final dy = (a.longitude - b.longitude).abs();

    // Rough scaling for latitude correction (approximate for Saudi Arabia ~24°N)
    final avgLat = (a.latitude + b.latitude) / 2;
    final lonCorrection = cos(avgLat * pi / 180);

    final distance = sqrt(dx * dx + (dy * lonCorrection) * (dy * lonCorrection)) * 111;

    // Clamp to reasonable city trip range
    return distance.clamp(1.0, 50.0);
  }

  /// Builds ride options based on distance and requested service type.
  List<RideQuoteOption> _buildOptions({
    required double distanceKm,
    required RideServiceType serviceType,
  }) {
    final options = <RideQuoteOption>[];

    // Helper to convert SAR to minor units (halalas)
    int toMinor(double amount) => (amount * 100).round();

    // Calculate fares
    final economyFare = toMinor(_baseFareEconomy + _perKmEconomy * distanceKm);
    final xlFare = toMinor(_baseFareXl + _perKmXl * distanceKm);
    final premiumFare = toMinor(_baseFarePremium + _perKmPremium * distanceKm);

    // Calculate ETAs (distance / speed * 60 = minutes)
    final economyEta = (distanceKm / _avgSpeedEconomy * 60).round().clamp(2, 15);
    final xlEta = (distanceKm / _avgSpeedXl * 60).round().clamp(3, 18);
    final premiumEta = (distanceKm / _avgSpeedPremium * 60).round().clamp(2, 12);

    // Build options based on service type
    final shouldIncludeEconomy = serviceType == RideServiceType.ride ||
        serviceType == RideServiceType.economy;
    final shouldIncludeXl = serviceType == RideServiceType.ride ||
        serviceType == RideServiceType.xl;
    final shouldIncludePremium = serviceType == RideServiceType.ride ||
        serviceType == RideServiceType.premium;

    if (shouldIncludeEconomy) {
      options.add(RideQuoteOption(
        id: 'economy',
        category: RideVehicleCategory.economy,
        displayName: 'Economy',
        etaMinutes: economyEta,
        priceMinorUnits: economyFare,
        currencyCode: 'SAR',
        isRecommended: serviceType == RideServiceType.ride,
      ));
    }

    if (shouldIncludeXl) {
      options.add(RideQuoteOption(
        id: 'xl',
        category: RideVehicleCategory.xl,
        displayName: 'XL',
        etaMinutes: xlEta,
        priceMinorUnits: xlFare,
        currencyCode: 'SAR',
        isRecommended: serviceType == RideServiceType.xl,
      ));
    }

    if (shouldIncludePremium) {
      options.add(RideQuoteOption(
        id: 'premium',
        category: RideVehicleCategory.premium,
        displayName: 'Premium',
        etaMinutes: premiumEta,
        priceMinorUnits: premiumFare,
        currencyCode: 'SAR',
        isRecommended: serviceType == RideServiceType.premium,
      ));
    }

    return options;
  }

  /// Builds a [RideQuoteRequest] from [MobilityPlace] objects.
  ///
  /// Used for backward compatibility with existing quote structure.
  RideQuoteRequest _buildRequest(MobilityPlace pickup, MobilityPlace destination) {
    final now = DateTime.now();

    // Create LocationPoints from MobilityPlace, using defaults if missing
    final pickupPoint = pickup.location ??
        LocationPoint(
          latitude: 24.7136, // Riyadh default
          longitude: 46.6753,
          accuracyMeters: 100,
          timestamp: now,
        );

    final destinationPoint = destination.location ??
        LocationPoint(
          latitude: 24.7236, // Slight offset from pickup
          longitude: 46.6853,
          accuracyMeters: 100,
          timestamp: now,
        );

    return RideQuoteRequest(
      pickup: pickupPoint,
      dropoff: destinationPoint,
      currencyCode: 'SAR',
    );
  }
}


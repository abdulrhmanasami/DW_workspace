/// Mock Ride Pricing Service - Track B Ticket #27, #63, #115, #121
/// Purpose: Simulated backend pricing engine for development and testing
/// Created by: Track B - Ticket #27
/// Updated by: Track B - Ticket #63 (RidePriceBreakdown integration)
/// Reviewed by: Track B - Ticket #115 (MockPricingService architecture validation)
/// Updated by: Track B - Ticket #121 (returnEmptyOptions for testing empty quote scenarios)
/// Last updated: 2025-12-01
///
/// This implementation simulates a backend pricing engine:
/// - Configurable network latency
/// - Configurable failure rate for chaos testing
/// - Configurable empty options for empty state testing
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
/// - Configurable empty options for testing no-options scenarios
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
///
/// // Track B - Ticket #121: Returns empty options (for empty state testing)
/// const emptyService = MockRidePricingService(
///   returnEmptyOptions: true,
/// );
/// ```
@immutable
class MockRidePricingService implements RidePricingService {
  /// Creates a mock pricing service with configurable behavior.
  ///
  /// Parameters:
  /// - [baseLatency]: Simulated network delay (default: 600ms)
  /// - [failureRate]: Probability of failure (0.0 to 1.0, default: 0.0)
  /// - [returnEmptyOptions]: If true, returns a quote with empty options (default: false)
  /// - [random]: Optional random instance for deterministic testing
  const MockRidePricingService({
    this.baseLatency = const Duration(milliseconds: 600),
    this.failureRate = 0.0,
    this.returnEmptyOptions = false,
    Random? random,
  }) : _random = random;

  /// Simulated network latency before returning results.
  final Duration baseLatency;

  /// Probability of throwing [RidePricingException] (0.0 = never, 1.0 = always).
  final double failureRate;

  /// Track B - Ticket #121: If true, returns a quote with empty options.
  ///
  /// Use this to test the "no options available" UI state.
  final bool returnEmptyOptions;

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

    // 3) Create the quote request for backward compatibility
    final request = _buildRequest(pickup, destination);

    // Track B - Ticket #139: Throw exception for empty options scenario
    // (RideQuote now enforces non-empty options)
    if (returnEmptyOptions) {
      throw const RidePricingException(
        'No vehicles available for this route',
      );
    }

    // 4) Calculate distance between pickup and destination
    final distanceKm = _estimateDistanceKm(
      pickup.location,
      destination.location,
    );

    // 5) Estimate trip duration (assume average speed of 25 km/h for city driving)
    final durationMinutes = (distanceKm / 25.0 * 60).round().clamp(5, 45);

    // 6) Build options based on service type (includes price breakdown)
    final options = _buildOptions(
      distanceKm: distanceKm,
      durationMinutes: durationMinutes,
      serviceType: serviceType,
    );

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
  ///
  /// Track B - Ticket #63: Now includes [RidePriceBreakdown] for each option.
  List<RideQuoteOption> _buildOptions({
    required double distanceKm,
    required int durationMinutes,
    required RideServiceType serviceType,
  }) {
    final options = <RideQuoteOption>[];

    // Build options based on service type
    final shouldIncludeEconomy = serviceType == RideServiceType.ride ||
        serviceType == RideServiceType.economy;
    final shouldIncludeXl = serviceType == RideServiceType.ride ||
        serviceType == RideServiceType.xl;
    final shouldIncludePremium = serviceType == RideServiceType.ride ||
        serviceType == RideServiceType.premium;

    if (shouldIncludeEconomy) {
      final breakdown = _buildBreakdownForCategory(
        category: RideVehicleCategory.economy,
        distanceKm: distanceKm,
        durationMinutes: durationMinutes,
      );
      final eta = (distanceKm / _avgSpeedEconomy * 60).round().clamp(2, 15);
      
      options.add(RideQuoteOption(
        id: 'economy',
        category: RideVehicleCategory.economy,
        displayName: 'Economy',
        etaMinutes: eta,
        priceMinorUnits: breakdown.totalMinorUnits,
        currencyCode: 'SAR',
        isRecommended: serviceType == RideServiceType.ride,
        priceBreakdown: breakdown,
      ));
    }

    if (shouldIncludeXl) {
      final breakdown = _buildBreakdownForCategory(
        category: RideVehicleCategory.xl,
        distanceKm: distanceKm,
        durationMinutes: durationMinutes,
      );
      final eta = (distanceKm / _avgSpeedXl * 60).round().clamp(3, 18);
      
      options.add(RideQuoteOption(
        id: 'xl',
        category: RideVehicleCategory.xl,
        displayName: 'XL',
        etaMinutes: eta,
        priceMinorUnits: breakdown.totalMinorUnits,
        currencyCode: 'SAR',
        isRecommended: serviceType == RideServiceType.xl,
        priceBreakdown: breakdown,
      ));
    }

    if (shouldIncludePremium) {
      final breakdown = _buildBreakdownForCategory(
        category: RideVehicleCategory.premium,
        distanceKm: distanceKm,
        durationMinutes: durationMinutes,
      );
      final eta = (distanceKm / _avgSpeedPremium * 60).round().clamp(2, 12);
      
      options.add(RideQuoteOption(
        id: 'premium',
        category: RideVehicleCategory.premium,
        displayName: 'Premium',
        etaMinutes: eta,
        priceMinorUnits: breakdown.totalMinorUnits,
        currencyCode: 'SAR',
        isRecommended: serviceType == RideServiceType.premium,
        priceBreakdown: breakdown,
      ));
    }

    return options;
  }

  /// Builds a detailed price breakdown for a vehicle category.
  ///
  /// Track B - Ticket #63: Deterministic pricing based on distance and time.
  RidePriceBreakdown _buildBreakdownForCategory({
    required RideVehicleCategory category,
    required double distanceKm,
    required int durationMinutes,
  }) {
    // Helper to convert SAR to minor units (halalas)
    int toMinor(double amount) => (amount * 100).round();

    late final double baseFare;
    late final double perKm;
    late final double perMinute;
    late final double fees;

    switch (category) {
      case RideVehicleCategory.economy:
        baseFare = _baseFareEconomy;
        perKm = _perKmEconomy;
        perMinute = 0.50; // 0.50 SAR per minute
        fees = 3.0;       // 3.00 SAR fees
      case RideVehicleCategory.xl:
        baseFare = _baseFareXl;
        perKm = _perKmXl;
        perMinute = 0.70; // 0.70 SAR per minute
        fees = 4.0;       // 4.00 SAR fees
      case RideVehicleCategory.premium:
        baseFare = _baseFarePremium;
        perKm = _perKmPremium;
        perMinute = 0.90; // 0.90 SAR per minute
        fees = 6.0;       // 6.00 SAR fees
    }

    final distanceComponent = distanceKm * perKm;
    final timeComponent = durationMinutes * perMinute;

    return RidePriceBreakdown(
      currencyCode: 'SAR',
      baseFareMinorUnits: toMinor(baseFare),
      distanceComponentMinorUnits: toMinor(distanceComponent),
      timeComponentMinorUnits: toMinor(timeComponent),
      feesMinorUnits: toMinor(fees),
    );
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


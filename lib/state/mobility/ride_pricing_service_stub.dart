/// Stub Ride Pricing Service - Ticket #196
/// Purpose: Clean injectable pricing stub for Ride flow with resilience & audit
/// Created by: Ticket #196
/// Last updated: 2025-12-03
///
/// This implementation provides:
/// - Clean abstraction for pricing (compatible with mobility_shims interface)
/// - Deterministic pricing for testing and development
/// - Configurable failure simulation for chaos testing
/// - Simple, understandable pricing logic
///
/// IMPORTANT:
/// - UI widgets do NOT calculate prices themselves
/// - All pricing goes through this service abstraction
/// - Easy to swap with real backend implementation
/// - Compatible with existing RideQuoteController and UI code

import 'dart:math';

import 'package:mobility_shims/mobility_shims.dart';

/// Stub implementation of ride pricing service.
///
/// This provides deterministic pricing based on distance and service type,
/// with configurable simulation of network delays and failures.
///
/// Features:
/// - Deterministic pricing (same inputs = same results)
/// - Configurable network delay simulation
/// - Configurable failure rate for chaos testing
/// - Compatible with existing RideQuoteController and UI
/// - Simple, understandable pricing logic
class StubRidePricingService implements RidePricingService {
  /// Creates a stub pricing service with configurable behavior.
  ///
  /// Parameters:
  /// - [simulatedDelay]: Network delay to simulate (default: 400ms)
  /// - [failureRate]: Probability of failure (0.0-1.0, default: 0.0)
  /// - [random]: Random instance for deterministic testing
  StubRidePricingService({
    this.simulatedDelay = const Duration(milliseconds: 400),
    this.failureRate = 0.0,
    Random? random,
  }) : _random = random;

  /// Simulated network delay.
  final Duration simulatedDelay;

  /// Probability of simulated failure (0.0 = never, 1.0 = always).
  final double failureRate;

  /// Random instance for failure simulation (injectable for testing).
  final Random? _random;

  // Pricing constants (SAR) - deterministic and clear
  static const double _baseFareEconomy = 5.0;
  static const double _baseFareXl = 8.0;
  static const double _baseFarePremium = 12.0;

  static const double _perKmEconomy = 2.0;
  static const double _perKmXl = 3.5;
  static const double _perKmPremium = 5.0;

  static const double _perMinuteEconomy = 0.50;
  static const double _perMinuteXl = 0.70;
  static const double _perMinutePremium = 0.90;

  static const double _feesEconomy = 3.0;
  static const double _feesXl = 4.0;
  static const double _feesPremium = 6.0;

  @override
  Future<RideQuote> quoteRide({
    required MobilityPlace pickup,
    required MobilityPlace destination,
    required RideServiceType serviceType,
  }) async {
    // Simulate network delay
    await Future<void>.delayed(simulatedDelay);

    // Simulate random failures
    if (_shouldSimulateFailure()) {
      throw const RidePricingException('Network request failed');
    }

    // Validate inputs
    if (pickup.location == null || destination.location == null) {
      throw const RidePricingException('Invalid location data');
    }

    // Calculate deterministic pricing
    final pricing = _calculatePricing(
      pickup: pickup,
      destination: destination,
      serviceType: serviceType,
    );

    // Create quote with pricing breakdown
    final quote = _buildQuote(
      pickup: pickup,
      destination: destination,
      pricing: pricing,
    );

    return quote;
  }

  /// Determines if this request should simulate a failure.
  bool _shouldSimulateFailure() {
    if (failureRate <= 0.0) return false;
    if (failureRate >= 1.0) return true;

    final random = _random ?? Random();
    return random.nextDouble() < failureRate;
  }

  /// Calculates pricing breakdown for the given route and service type.
  ///
  /// Returns pricing data that can be used to build the quote.
  _PricingData _calculatePricing({
    required MobilityPlace pickup,
    required MobilityPlace destination,
    required RideServiceType serviceType,
  }) {
    // Calculate distance (simplified - same logic as MockRidePricingService)
    final distanceKm = _calculateDistanceKm(
      pickup.location!,
      destination.location!,
    );

    // Estimate duration (25 km/h average city speed)
    final durationMinutes = (distanceKm / 25.0 * 60).round().clamp(5, 45);

    // Get pricing constants for service type
    final constants = _getPricingConstants(serviceType);

    // Calculate components
    final distanceComponent = distanceKm * constants.perKm;
    final timeComponent = durationMinutes * constants.perMinute;
    final total = constants.baseFare + distanceComponent + timeComponent + constants.fees;

    return _PricingData(
      distanceKm: distanceKm,
      durationMinutes: durationMinutes,
      baseFare: constants.baseFare,
      distanceComponent: distanceComponent,
      timeComponent: timeComponent,
      fees: constants.fees,
      total: total,
      serviceType: serviceType,
      pickupLocation: pickup.location!,
      destinationLocation: destination.location!,
    );
  }

  /// Gets pricing constants for a service type.
  _PricingConstants _getPricingConstants(RideServiceType serviceType) {
    switch (serviceType) {
      case RideServiceType.economy:
        return const _PricingConstants(
          baseFare: _baseFareEconomy,
          perKm: _perKmEconomy,
          perMinute: _perMinuteEconomy,
          fees: _feesEconomy,
        );
      case RideServiceType.xl:
        return const _PricingConstants(
          baseFare: _baseFareXl,
          perKm: _perKmXl,
          perMinute: _perMinuteXl,
          fees: _feesXl,
        );
      case RideServiceType.premium:
        return const _PricingConstants(
          baseFare: _baseFarePremium,
          perKm: _perKmPremium,
          perMinute: _perMinutePremium,
          fees: _feesPremium,
        );
      case RideServiceType.ride:
        // For generic ride requests, default to economy pricing
        // (this could be enhanced to return multiple options)
        return const _PricingConstants(
          baseFare: _baseFareEconomy,
          perKm: _perKmEconomy,
          perMinute: _perMinuteEconomy,
          fees: _feesEconomy,
        );
    }
  }

  /// Calculates distance in kilometers between two points.
  ///
  /// Uses equirectangular approximation for simplicity.
  double _calculateDistanceKm(LocationPoint a, LocationPoint b) {
    final dx = (a.latitude - b.latitude).abs();
    final dy = (a.longitude - b.longitude).abs();

    // Rough latitude correction for Saudi Arabia (~24°N)
    final avgLat = (a.latitude + b.latitude) / 2;
    final lonCorrection = cos(avgLat * pi / 180);

    final distance = sqrt(dx * dx + (dy * lonCorrection) * (dy * lonCorrection)) * 111;

    // Clamp to reasonable city trip range
    return distance.clamp(1.0, 50.0);
  }

  /// Builds a RideQuote from pricing data.
  RideQuote _buildQuote({
    required MobilityPlace pickup,
    required MobilityPlace destination,
    required _PricingData pricing,
  }) {
    // Create request for compatibility
    final request = RideQuoteRequest(
      pickup: pickup.location!,
      dropoff: destination.location!,
      currencyCode: 'SAR',
    );

    // Build price breakdown
    final breakdown = RidePriceBreakdown(
      currencyCode: 'SAR',
      baseFareMinorUnits: (pricing.baseFare * 100).round(),
      distanceComponentMinorUnits: (pricing.distanceComponent * 100).round(),
      timeComponentMinorUnits: (pricing.timeComponent * 100).round(),
      feesMinorUnits: (pricing.fees * 100).round(),
    );

    // Build options based on service type
    final options = _buildOptions(
      pricing: pricing,
      breakdown: breakdown,
    );

    return RideQuote(
      quoteId: 'stub-${DateTime.now().millisecondsSinceEpoch}',
      request: request,
      options: options,
    );
  }

  /// Builds ride options based on service type.
  List<RideQuoteOption> _buildOptions({
    required _PricingData pricing,
    required RidePriceBreakdown breakdown,
  }) {
    final options = <RideQuoteOption>[];

    // For specific service types, return single option
    if (pricing.serviceType != RideServiceType.ride) {
      options.add(_buildOptionForServiceType(
        pricing.serviceType,
        pricing,
        breakdown,
        isRecommended: true,
      ));
    } else {
      // For generic "ride" requests, return all options
      for (final currentServiceType in [RideServiceType.economy, RideServiceType.xl, RideServiceType.premium]) {
        final servicePricing = _calculatePricing(
          pickup: MobilityPlace(label: '', location: pricing.pickupLocation),
          destination: MobilityPlace(label: '', location: pricing.destinationLocation),
          serviceType: currentServiceType,
        );
        final serviceBreakdown = RidePriceBreakdown(
          currencyCode: 'SAR',
          baseFareMinorUnits: (servicePricing.baseFare * 100).round(),
          distanceComponentMinorUnits: (servicePricing.distanceComponent * 100).round(),
          timeComponentMinorUnits: (servicePricing.timeComponent * 100).round(),
          feesMinorUnits: (servicePricing.fees * 100).round(),
        );

        options.add(_buildOptionForServiceType(
          currentServiceType,
          servicePricing,
          serviceBreakdown,
          isRecommended: currentServiceType == RideServiceType.economy, // Default to economy as recommended
        ));
      }
    }

    return options;
  }

  /// Builds a single option for the given service type.
  RideQuoteOption _buildOptionForServiceType(
    RideServiceType serviceType,
    _PricingData pricing,
    RidePriceBreakdown breakdown, {
    required bool isRecommended,
  }) {
    return RideQuoteOption(
      id: serviceType.name,
      category: _mapServiceTypeToCategory(serviceType),
      displayName: _getDisplayName(serviceType),
      etaMinutes: (pricing.distanceKm / 25.0 * 60).round().clamp(2, 15),
      priceMinorUnits: (pricing.total * 100).round(),
      currencyCode: 'SAR',
      isRecommended: isRecommended,
      priceBreakdown: breakdown,
    );
  }

  /// Maps RideServiceType to RideVehicleCategory.
  RideVehicleCategory _mapServiceTypeToCategory(RideServiceType serviceType) {
    switch (serviceType) {
      case RideServiceType.economy:
        return RideVehicleCategory.economy;
      case RideServiceType.xl:
        return RideVehicleCategory.xl;
      case RideServiceType.premium:
        return RideVehicleCategory.premium;
      case RideServiceType.ride:
        return RideVehicleCategory.economy; // Default fallback
    }
  }

  /// Gets display name for service type.
  String _getDisplayName(RideServiceType serviceType) {
    switch (serviceType) {
      case RideServiceType.economy:
        return 'Economy';
      case RideServiceType.xl:
        return 'XL';
      case RideServiceType.premium:
        return 'Premium';
      case RideServiceType.ride:
        return 'Ride';
    }
  }
}

/// Internal data structure for pricing calculations.
class _PricingData {
  const _PricingData({
    required this.distanceKm,
    required this.durationMinutes,
    required this.baseFare,
    required this.distanceComponent,
    required this.timeComponent,
    required this.fees,
    required this.total,
    required this.serviceType,
    required this.pickupLocation,
    required this.destinationLocation,
  });

  final double distanceKm;
  final int durationMinutes;
  final double baseFare;
  final double distanceComponent;
  final double timeComponent;
  final double fees;
  final double total;
  final RideServiceType serviceType;
  final LocationPoint pickupLocation;
  final LocationPoint destinationLocation;
}

/// Internal data structure for pricing constants.
class _PricingConstants {
  const _PricingConstants({
    required this.baseFare,
    required this.perKm,
    required this.perMinute,
    required this.fees,
  });

  final double baseFare;
  final double perKm;
  final double perMinute;
  final double fees;
}

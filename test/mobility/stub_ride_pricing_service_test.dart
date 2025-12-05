/// Tests for StubRidePricingService - Ticket #196
/// Purpose: Test deterministic pricing, failure simulation, and integration
/// Created by: Ticket #196
/// Last updated: 2025-12-03

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobility_shims/mobility_shims.dart';

import 'package:delivery_ways_clean/state/mobility/ride_pricing_service_stub.dart';

void main() {
  group('StubRidePricingService', () {
    late StubRidePricingService service;
    late MobilityPlace pickup;
    late MobilityPlace destination;

    setUp(() {
      service = StubRidePricingService();
      pickup = MobilityPlace(
        label: 'Pickup',
        location: LocationPoint(
          latitude: 24.7136,
          longitude: 46.6753,
          accuracyMeters: 10,
          timestamp: DateTime.now(),
        ),
      );
      destination = MobilityPlace(
        label: 'Destination',
        location: LocationPoint(
          latitude: 24.7236,
          longitude: 46.6853,
          accuracyMeters: 10,
          timestamp: DateTime.now(),
        ),
      );
    });

    test('deterministic pricing - same inputs produce same results', () async {
      // Arrange
      const serviceType = RideServiceType.economy;

      // Act
      final quote1 = await service.quoteRide(
        pickup: pickup,
        destination: destination,
        serviceType: serviceType,
      );
      final quote2 = await service.quoteRide(
        pickup: pickup,
        destination: destination,
        serviceType: serviceType,
      );

      // Assert
      expect(quote1.quoteId, isNot(equals(quote2.quoteId))); // IDs should be unique
      expect(quote1.options.length, equals(quote2.options.length));
      expect(quote1.options.first.priceMinorUnits,
          equals(quote2.options.first.priceMinorUnits));
      expect(quote1.options.first.etaMinutes, equals(quote2.options.first.etaMinutes));
    });

    test('economy service type returns single option with correct pricing', () async {
      // Act
      final quote = await service.quoteRide(
        pickup: pickup,
        destination: destination,
        serviceType: RideServiceType.economy,
      );

      // Assert
      expect(quote.options.length, equals(1));
      final option = quote.options.first;
      expect(option.category, equals(RideVehicleCategory.economy));
      expect(option.displayName, equals('Economy'));
      expect(option.isRecommended, isTrue);
      expect(option.priceMinorUnits, greaterThan(0));
      expect(option.currencyCode, equals('SAR'));
      expect(option.priceBreakdown, isNotNull);
    });

    test('xl service type returns single option with correct pricing', () async {
      // Act
      final quote = await service.quoteRide(
        pickup: pickup,
        destination: destination,
        serviceType: RideServiceType.xl,
      );

      // Assert
      expect(quote.options.length, equals(1));
      final option = quote.options.first;
      expect(option.category, equals(RideVehicleCategory.xl));
      expect(option.displayName, equals('XL'));
      expect(option.isRecommended, isTrue);
      expect(option.priceMinorUnits, greaterThan(0));
      expect(option.currencyCode, equals('SAR'));
    });

    test('premium service type returns single option with correct pricing', () async {
      // Act
      final quote = await service.quoteRide(
        pickup: pickup,
        destination: destination,
        serviceType: RideServiceType.premium,
      );

      // Assert
      expect(quote.options.length, equals(1));
      final option = quote.options.first;
      expect(option.category, equals(RideVehicleCategory.premium));
      expect(option.displayName, equals('Premium'));
      expect(option.isRecommended, isTrue);
      expect(option.priceMinorUnits, greaterThan(0));
      expect(option.currencyCode, equals('SAR'));
    });

    test('ride service type returns all options', () async {
      // Act
      final quote = await service.quoteRide(
        pickup: pickup,
        destination: destination,
        serviceType: RideServiceType.ride,
      );

      // Assert
      expect(quote.options.length, equals(3)); // Economy, XL, Premium

      // Check that economy is recommended by default
      final economyOption = quote.options.firstWhere(
        (opt) => opt.category == RideVehicleCategory.economy,
      );
      expect(economyOption.isRecommended, isTrue);

      // Check that others are not recommended
      final xlOption = quote.options.firstWhere(
        (opt) => opt.category == RideVehicleCategory.xl,
      );
      final premiumOption = quote.options.firstWhere(
        (opt) => opt.category == RideVehicleCategory.premium,
      );
      expect(xlOption.isRecommended, isFalse);
      expect(premiumOption.isRecommended, isFalse);
    });

    test('simulated delay is respected', () async {
      // Arrange
      const delay = Duration(milliseconds: 100);
      final fastService = StubRidePricingService(simulatedDelay: Duration.zero);
      final slowService = StubRidePricingService(simulatedDelay: delay);

      // Act & Assert
      final start = DateTime.now();
      await fastService.quoteRide(
        pickup: pickup,
        destination: destination,
        serviceType: RideServiceType.economy,
      );
      final fastDuration = DateTime.now().difference(start);

      final start2 = DateTime.now();
      await slowService.quoteRide(
        pickup: pickup,
        destination: destination,
        serviceType: RideServiceType.economy,
      );
      final slowDuration = DateTime.now().difference(start2);

      // Fast service should be much quicker
      expect(fastDuration, lessThan(delay));
      expect(slowDuration, greaterThanOrEqualTo(delay));
    });

    test('failure rate simulation works', () async {
      // Arrange
      final failingService = StubRidePricingService(
        failureRate: 1.0, // Always fail
        random: Random(42), // Deterministic random for testing
      );

      // Act & Assert
      expect(
        () => failingService.quoteRide(
          pickup: pickup,
          destination: destination,
          serviceType: RideServiceType.economy,
        ),
        throwsA(isA<RidePricingException>()),
      );
    });

    test('no failure when failure rate is zero', () async {
      // Arrange
      final reliableService = StubRidePricingService(
        failureRate: 0.0, // Never fail
      );

      // Act & Assert
      expect(
        () => reliableService.quoteRide(
          pickup: pickup,
          destination: destination,
          serviceType: RideServiceType.economy,
        ),
        returnsNormally,
      );
    });

    test('throws exception for invalid location data', () async {
      // Arrange
      const invalidPickup = MobilityPlace(
        label: 'Invalid Pickup',
        location: null, // No location data
      );

      // Act & Assert
      expect(
        () => service.quoteRide(
          pickup: invalidPickup,
          destination: destination,
          serviceType: RideServiceType.economy,
        ),
        throwsA(isA<RidePricingException>()),
      );
    });

    test('price breakdown is correctly calculated', () async {
      // Act
      final quote = await service.quoteRide(
        pickup: pickup,
        destination: destination,
        serviceType: RideServiceType.economy,
      );

      // Assert
      final breakdown = quote.options.first.priceBreakdown!;
      expect(breakdown.currencyCode, equals('SAR'));
      expect(breakdown.baseFareMinorUnits, greaterThan(0));
      expect(breakdown.distanceComponentMinorUnits, greaterThan(0));
      expect(breakdown.timeComponentMinorUnits, greaterThan(0));
      expect(breakdown.feesMinorUnits, greaterThan(0));

      // Total should equal sum of components
      final expectedTotal = breakdown.baseFareMinorUnits +
          breakdown.distanceComponentMinorUnits +
          breakdown.timeComponentMinorUnits +
          breakdown.feesMinorUnits;
      expect(breakdown.totalMinorUnits, equals(expectedTotal));
    });

    test('pricing scales with distance', () async {
      // Arrange
      final closeDestination = MobilityPlace(
        label: 'Close',
        location: LocationPoint(
          latitude: 24.7146, // Very close
          longitude: 46.6763,
          accuracyMeters: 10,
          timestamp: DateTime.now(),
        ),
      );

      final farDestination = MobilityPlace(
        label: 'Far',
        location: LocationPoint(
          latitude: 24.8136, // Much farther
          longitude: 46.7753,
          accuracyMeters: 10,
          timestamp: DateTime.now(),
        ),
      );

      // Act
      final closeQuote = await service.quoteRide(
        pickup: pickup,
        destination: closeDestination,
        serviceType: RideServiceType.economy,
      );
      final farQuote = await service.quoteRide(
        pickup: pickup,
        destination: farDestination,
        serviceType: RideServiceType.economy,
      );

      // Assert
      final closePrice = closeQuote.options.first.priceMinorUnits;
      final farPrice = farQuote.options.first.priceMinorUnits;
      expect(farPrice, greaterThan(closePrice));
    });
  });
}

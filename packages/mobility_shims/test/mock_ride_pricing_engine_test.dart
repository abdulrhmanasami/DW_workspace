/// Mock Ride Pricing Engine Tests - Ticket #155
/// Purpose: Test MockRidePricingService pricing logic and behavior
/// Created by: Ticket #155
/// Last updated: 2025-12-03

import 'package:flutter_test/flutter_test.dart';
import 'package:mobility_shims/mobility_shims.dart';

void main() {
  group('MockRidePricingService Tests', () {
    late MockRidePricingService service;
    late MobilityPlace pickup;
    late MobilityPlace destination;

    setUp(() {
      service = const MockRidePricingService(
        baseLatency: Duration.zero, // No delay for tests
      );

      // Setup test locations
      pickup = const MobilityPlace(
        label: 'Pickup Location',
        type: MobilityPlaceType.currentLocation,
        location: LocationPoint(
          latitude: 24.7136,
          longitude: 46.6753,
          accuracyMeters: 10,
        ),
      );

      destination = const MobilityPlace(
        label: 'Destination',
        type: MobilityPlaceType.searchResult,
        location: LocationPoint(
          latitude: 24.9576,
          longitude: 46.6988,
          accuracyMeters: 10,
        ),
      );
    });

    test('getQuote returns valid RideQuote', () async {
      final quote = await service.quoteRide(
        pickup: pickup,
        destination: destination,
        serviceType: RideServiceType.ride,
      );

      expect(quote, isNotNull);
      expect(quote.options, isNotEmpty);
    });

    test('quote contains at least 3 vehicle options', () async {
      final quote = await service.quoteRide(
        pickup: pickup,
        destination: destination,
        serviceType: RideServiceType.ride,
      );

      expect(quote.options.length, greaterThanOrEqualTo(3));
      
      // Check for all three categories
      final hasEconomy = quote.options.any((opt) => opt.category == RideVehicleCategory.economy);
      final hasXl = quote.options.any((opt) => opt.category == RideVehicleCategory.xl);
      final hasPremium = quote.options.any((opt) => opt.category == RideVehicleCategory.premium);

      expect(hasEconomy, isTrue, reason: 'Should have Economy option');
      expect(hasXl, isTrue, reason: 'Should have XL option');
      expect(hasPremium, isTrue, reason: 'Should have Premium option');
    });

    test('prices are monotonic (economy <= xl <= premium)', () async {
      final quote = await service.quoteRide(
        pickup: pickup,
        destination: destination,
        serviceType: RideServiceType.ride,
      );

      // Sort options by price
      final sortedOptions = List.from(quote.options)
        ..sort((a, b) => a.priceMinorUnits.compareTo(b.priceMinorUnits));

      // Economy should be cheapest
      expect(sortedOptions.first.category, equals(RideVehicleCategory.economy));
      
      // Premium should be most expensive
      expect(sortedOptions.last.category, equals(RideVehicleCategory.premium));

      // Check monotonic pricing
      for (int i = 1; i < sortedOptions.length; i++) {
        expect(
          sortedOptions[i].priceMinorUnits,
          greaterThanOrEqualTo(sortedOptions[i - 1].priceMinorUnits),
          reason: 'Prices should be monotonically increasing',
        );
      }
    });

    test('all options have positive ETAs', () async {
      final quote = await service.quoteRide(
        pickup: pickup,
        destination: destination,
        serviceType: RideServiceType.ride,
      );

      for (final option in quote.options) {
        expect(option.etaMinutes, greaterThan(0));
        expect(option.etaMinutes, lessThanOrEqualTo(20)); // Reasonable upper bound
      }
    });

    test('all options have price breakdowns', () async {
      final quote = await service.quoteRide(
        pickup: pickup,
        destination: destination,
        serviceType: RideServiceType.ride,
      );

      for (final option in quote.options) {
        expect(option.priceBreakdown, isNotNull);
        
        final breakdown = option.priceBreakdown!;
        expect(breakdown.baseFareMinorUnits, greaterThan(0));
        expect(breakdown.distanceComponentMinorUnits, greaterThanOrEqualTo(0));
        expect(breakdown.timeComponentMinorUnits, greaterThanOrEqualTo(0));
        expect(breakdown.feesMinorUnits, greaterThanOrEqualTo(0));
        expect(breakdown.totalMinorUnits, equals(option.priceMinorUnits));
      }
    });

    test('service respects failure rate configuration', () async {
      const failingService = MockRidePricingService(
        baseLatency: Duration.zero,
        failureRate: 1.0, // Always fail
      );

      expect(
        () => failingService.quoteRide(
          pickup: pickup,
          destination: destination,
          serviceType: RideServiceType.ride,
        ),
        throwsA(isA<RidePricingException>()),
      );
    });

    test('service returns empty options error when configured', () async {
      const emptyService = MockRidePricingService(
        baseLatency: Duration.zero,
        returnEmptyOptions: true,
      );

      expect(
        () => emptyService.quoteRide(
          pickup: pickup,
          destination: destination,
          serviceType: RideServiceType.ride,
        ),
        throwsA(
          isA<RidePricingException>().having(
            (e) => e.message,
            'message',
            contains('No vehicles available'),
          ),
        ),
      );
    });

    test('single service type returns only one option', () async {
      final economyQuote = await service.quoteRide(
        pickup: pickup,
        destination: destination,
        serviceType: RideServiceType.economy,
      );

      expect(economyQuote.options.length, equals(1));
      expect(economyQuote.options.first.category, equals(RideVehicleCategory.economy));

      final xlQuote = await service.quoteRide(
        pickup: pickup,
        destination: destination,
        serviceType: RideServiceType.xl,
      );

      expect(xlQuote.options.length, equals(1));
      expect(xlQuote.options.first.category, equals(RideVehicleCategory.xl));
    });

    test('quote has unique ID', () async {
      final quote1 = await service.quoteRide(
        pickup: pickup,
        destination: destination,
        serviceType: RideServiceType.ride,
      );

      final quote2 = await service.quoteRide(
        pickup: pickup,
        destination: destination,
        serviceType: RideServiceType.ride,
      );

      expect(quote1.quoteId, isNotNull);
      expect(quote2.quoteId, isNotNull);
      expect(quote1.quoteId, isNot(equals(quote2.quoteId)));
    });

    test('handles missing location coordinates gracefully', () async {
      const pickupNoCoords = MobilityPlace(
        label: 'Pickup',
        type: MobilityPlaceType.currentLocation,
        // No location specified
      );

      const destinationNoCoords = MobilityPlace(
        label: 'Destination',
        type: MobilityPlaceType.searchResult,
        // No location specified
      );

      final quote = await service.quoteRide(
        pickup: pickupNoCoords,
        destination: destinationNoCoords,
        serviceType: RideServiceType.ride,
      );

      expect(quote, isNotNull);
      expect(quote.options, isNotEmpty);
      
      // Should use default distance
      for (final option in quote.options) {
        expect(option.priceMinorUnits, greaterThan(0));
      }
    });
  });
}

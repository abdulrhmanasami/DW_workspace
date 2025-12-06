/// MockRidePricingService Unit Tests - Track B Ticket #27, #63
/// Purpose: Test the mock pricing service for ride quotes
/// Created by: Track B - Ticket #27
/// Updated by: Track B - Ticket #63 (RidePriceBreakdown tests)
/// Last updated: 2025-11-29

import 'package:flutter_test/flutter_test.dart';
import 'package:mobility_shims/mobility_shims.dart';

void main() {
  group('MockRidePricingService', () {
    // Helper to create MobilityPlace with coordinates
    MobilityPlace placeWithLocation({
      required String label,
      required double lat,
      required double lng,
    }) {
      return MobilityPlace(
        label: label,
        location: LocationPoint(
          latitude: lat,
          longitude: lng,
          accuracyMeters: 10,
          timestamp: DateTime.now(),
        ),
      );
    }

    // Helper to create MobilityPlace without coordinates
    MobilityPlace placeWithoutLocation({required String label}) {
      return MobilityPlace(label: label);
    }

    group('basic quote success', () {
      test('returns non-empty options list', () async {
        const service = MockRidePricingService();

        final pickup = placeWithLocation(
          label: 'Home',
          lat: 24.7136,
          lng: 46.6753,
        );
        final destination = placeWithLocation(
          label: 'Airport',
          lat: 24.7743,
          lng: 46.7386,
        );

        final quote = await service.quoteRide(
          pickup: pickup,
          destination: destination,
          serviceType: RideServiceType.ride,
        );

        expect(quote.options, isNotEmpty);
      });

      test('returns exactly 3 options for RideServiceType.ride', () async {
        const service = MockRidePricingService();

        final pickup = placeWithLocation(
          label: 'Home',
          lat: 24.7136,
          lng: 46.6753,
        );
        final destination = placeWithLocation(
          label: 'Office',
          lat: 24.7200,
          lng: 46.6800,
        );

        final quote = await service.quoteRide(
          pickup: pickup,
          destination: destination,
          serviceType: RideServiceType.ride,
        );

        expect(quote.options.length, equals(3));
        expect(
          quote.options.map((o) => o.id).toList(),
          containsAll(['economy', 'xl', 'premium']),
        );
      });

      test('all options have positive prices', () async {
        const service = MockRidePricingService();

        final pickup = placeWithLocation(
          label: 'A',
          lat: 24.7136,
          lng: 46.6753,
        );
        final destination = placeWithLocation(
          label: 'B',
          lat: 24.7500,
          lng: 46.7000,
        );

        final quote = await service.quoteRide(
          pickup: pickup,
          destination: destination,
          serviceType: RideServiceType.ride,
        );

        for (final option in quote.options) {
          expect(option.priceMinorUnits, greaterThan(0));
        }
      });

      test('all options have reasonable ETA', () async {
        const service = MockRidePricingService();

        final pickup = placeWithLocation(
          label: 'Start',
          lat: 24.7136,
          lng: 46.6753,
        );
        final destination = placeWithLocation(
          label: 'End',
          lat: 24.8000,
          lng: 46.8000,
        );

        final quote = await service.quoteRide(
          pickup: pickup,
          destination: destination,
          serviceType: RideServiceType.ride,
        );

        for (final option in quote.options) {
          expect(option.etaMinutes, greaterThanOrEqualTo(2));
          expect(option.etaMinutes, lessThanOrEqualTo(18));
        }
      });

      test('economy is recommended for generic ride service type', () async {
        const service = MockRidePricingService();

        final pickup = placeWithLocation(
          label: 'A',
          lat: 24.7136,
          lng: 46.6753,
        );
        final destination = placeWithLocation(
          label: 'B',
          lat: 24.7200,
          lng: 46.6800,
        );

        final quote = await service.quoteRide(
          pickup: pickup,
          destination: destination,
          serviceType: RideServiceType.ride,
        );

        final economy = quote.options.firstWhere((o) => o.id == 'economy');
        expect(economy.isRecommended, isTrue);
      });
    });

    group('service type filtering', () {
      test('RideServiceType.economy returns only economy option', () async {
        const service = MockRidePricingService();

        final pickup = placeWithLocation(
          label: 'A',
          lat: 24.7136,
          lng: 46.6753,
        );
        final destination = placeWithLocation(
          label: 'B',
          lat: 24.7200,
          lng: 46.6800,
        );

        final quote = await service.quoteRide(
          pickup: pickup,
          destination: destination,
          serviceType: RideServiceType.economy,
        );

        expect(quote.options.length, equals(1));
        expect(quote.options.first.id, equals('economy'));
      });

      test('RideServiceType.xl returns only xl option', () async {
        const service = MockRidePricingService();

        final pickup = placeWithLocation(
          label: 'A',
          lat: 24.7136,
          lng: 46.6753,
        );
        final destination = placeWithLocation(
          label: 'B',
          lat: 24.7200,
          lng: 46.6800,
        );

        final quote = await service.quoteRide(
          pickup: pickup,
          destination: destination,
          serviceType: RideServiceType.xl,
        );

        expect(quote.options.length, equals(1));
        expect(quote.options.first.id, equals('xl'));
        expect(quote.options.first.isRecommended, isTrue);
      });

      test('RideServiceType.premium returns only premium option', () async {
        const service = MockRidePricingService();

        final pickup = placeWithLocation(
          label: 'A',
          lat: 24.7136,
          lng: 46.6753,
        );
        final destination = placeWithLocation(
          label: 'B',
          lat: 24.7200,
          lng: 46.6800,
        );

        final quote = await service.quoteRide(
          pickup: pickup,
          destination: destination,
          serviceType: RideServiceType.premium,
        );

        expect(quote.options.length, equals(1));
        expect(quote.options.first.id, equals('premium'));
        expect(quote.options.first.isRecommended, isTrue);
      });
    });

    group('fallback behavior (no coordinates)', () {
      test('handles pickup without location', () async {
        const service = MockRidePricingService();

        final pickup = placeWithoutLocation(label: 'Unknown Pickup');
        final destination = placeWithLocation(
          label: 'Destination',
          lat: 24.7200,
          lng: 46.6800,
        );

        final quote = await service.quoteRide(
          pickup: pickup,
          destination: destination,
          serviceType: RideServiceType.ride,
        );

        expect(quote.options, isNotEmpty);
        for (final option in quote.options) {
          expect(option.priceMinorUnits, greaterThan(0));
        }
      });

      test('handles destination without location', () async {
        const service = MockRidePricingService();

        final pickup = placeWithLocation(
          label: 'Pickup',
          lat: 24.7136,
          lng: 46.6753,
        );
        final destination = placeWithoutLocation(label: 'Unknown Destination');

        final quote = await service.quoteRide(
          pickup: pickup,
          destination: destination,
          serviceType: RideServiceType.ride,
        );

        expect(quote.options, isNotEmpty);
        for (final option in quote.options) {
          expect(option.priceMinorUnits, greaterThan(0));
        }
      });

      test('handles both without location (uses default distance)', () async {
        const service = MockRidePricingService();

        final pickup = placeWithoutLocation(label: 'Unknown A');
        final destination = placeWithoutLocation(label: 'Unknown B');

        final quote = await service.quoteRide(
          pickup: pickup,
          destination: destination,
          serviceType: RideServiceType.ride,
        );

        expect(quote.options, isNotEmpty);
        // Default distance is 5km, so prices should be reasonable
        final economy = quote.options.firstWhere((o) => o.id == 'economy');
        // Price includes base fare + distance + time + fees
        // Should be a reasonable amount for a 5km trip
        expect(economy.priceMinorUnits, greaterThan(1000)); // > 10 SAR
        expect(economy.priceMinorUnits, lessThan(5000));    // < 50 SAR
      });
    });

    group('pricing consistency', () {
      test('longer distance produces higher prices', () async {
        const service = MockRidePricingService();

        final pickup = placeWithLocation(
          label: 'Start',
          lat: 24.7136,
          lng: 46.6753,
        );

        final shortDestination = placeWithLocation(
          label: 'Near',
          lat: 24.7200,
          lng: 46.6800,
        );

        final longDestination = placeWithLocation(
          label: 'Far',
          lat: 24.9000,
          lng: 46.9000,
        );

        final shortQuote = await service.quoteRide(
          pickup: pickup,
          destination: shortDestination,
          serviceType: RideServiceType.ride,
        );

        final longQuote = await service.quoteRide(
          pickup: pickup,
          destination: longDestination,
          serviceType: RideServiceType.ride,
        );

        final shortEconomy = shortQuote.options.firstWhere((o) => o.id == 'economy');
        final longEconomy = longQuote.options.firstWhere((o) => o.id == 'economy');

        expect(
          longEconomy.priceMinorUnits,
          greaterThan(shortEconomy.priceMinorUnits),
        );
      });

      test('prices increase from economy to premium', () async {
        const service = MockRidePricingService();

        final pickup = placeWithLocation(
          label: 'A',
          lat: 24.7136,
          lng: 46.6753,
        );
        final destination = placeWithLocation(
          label: 'B',
          lat: 24.7500,
          lng: 46.7000,
        );

        final quote = await service.quoteRide(
          pickup: pickup,
          destination: destination,
          serviceType: RideServiceType.ride,
        );

        final economy = quote.options.firstWhere((o) => o.id == 'economy');
        final xl = quote.options.firstWhere((o) => o.id == 'xl');
        final premium = quote.options.firstWhere((o) => o.id == 'premium');

        expect(economy.priceMinorUnits, lessThan(xl.priceMinorUnits));
        expect(xl.priceMinorUnits, lessThan(premium.priceMinorUnits));
      });
    });

    group('latency simulation', () {
      test('respects baseLatency duration', () async {
        const service = MockRidePricingService(
          baseLatency: Duration(milliseconds: 100),
        );

        final pickup = placeWithLocation(
          label: 'A',
          lat: 24.7136,
          lng: 46.6753,
        );
        final destination = placeWithLocation(
          label: 'B',
          lat: 24.7200,
          lng: 46.6800,
        );

        final stopwatch = Stopwatch()..start();
        await service.quoteRide(
          pickup: pickup,
          destination: destination,
          serviceType: RideServiceType.ride,
        );
        stopwatch.stop();

        // Should take at least 100ms (with some tolerance)
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(90));
      });
    });

    group('failure simulation', () {
      test('failureRate 1.0 always throws RidePricingException', () async {
        const service = MockRidePricingService(
          failureRate: 1.0,
          baseLatency: Duration.zero,
        );

        final pickup = placeWithLocation(
          label: 'A',
          lat: 24.7136,
          lng: 46.6753,
        );
        final destination = placeWithLocation(
          label: 'B',
          lat: 24.7200,
          lng: 46.6800,
        );

        expect(
          () => service.quoteRide(
            pickup: pickup,
            destination: destination,
            serviceType: RideServiceType.ride,
          ),
          throwsA(isA<RidePricingException>()),
        );
      });

      test('failureRate 0.0 never throws', () async {
        const service = MockRidePricingService(
          failureRate: 0.0,
          baseLatency: Duration.zero,
        );

        final pickup = placeWithLocation(
          label: 'A',
          lat: 24.7136,
          lng: 46.6753,
        );
        final destination = placeWithLocation(
          label: 'B',
          lat: 24.7200,
          lng: 46.6800,
        );

        // Run multiple times to ensure no failures
        for (var i = 0; i < 10; i++) {
          final quote = await service.quoteRide(
            pickup: pickup,
            destination: destination,
            serviceType: RideServiceType.ride,
          );
          expect(quote.options, isNotEmpty);
        }
      });

      test('RidePricingException has correct message', () {
        const exception = RidePricingException('Test error');

        expect(exception.message, equals('Test error'));
        expect(exception.toString(), contains('Test error'));
      });
    });

    group('quote structure', () {
      test('quote has unique id', () async {
        const service = MockRidePricingService(baseLatency: Duration.zero);

        final pickup = placeWithLocation(
          label: 'A',
          lat: 24.7136,
          lng: 46.6753,
        );
        final destination = placeWithLocation(
          label: 'B',
          lat: 24.7200,
          lng: 46.6800,
        );

        final quote1 = await service.quoteRide(
          pickup: pickup,
          destination: destination,
          serviceType: RideServiceType.ride,
        );

        // Small delay to ensure different timestamp
        await Future<void>.delayed(const Duration(milliseconds: 1));

        final quote2 = await service.quoteRide(
          pickup: pickup,
          destination: destination,
          serviceType: RideServiceType.ride,
        );

        expect(quote1.quoteId, isNot(equals(quote2.quoteId)));
      });

      test('quote contains request with correct pickup/dropoff', () async {
        const service = MockRidePricingService(baseLatency: Duration.zero);

        final pickup = placeWithLocation(
          label: 'A',
          lat: 24.7136,
          lng: 46.6753,
        );
        final destination = placeWithLocation(
          label: 'B',
          lat: 24.7200,
          lng: 46.6800,
        );

        final quote = await service.quoteRide(
          pickup: pickup,
          destination: destination,
          serviceType: RideServiceType.ride,
        );

        expect(quote.request.pickup.latitude, closeTo(24.7136, 0.01));
        expect(quote.request.pickup.longitude, closeTo(46.6753, 0.01));
        expect(quote.request.dropoff.latitude, closeTo(24.7200, 0.01));
        expect(quote.request.dropoff.longitude, closeTo(46.6800, 0.01));
      });

      test('quote uses SAR currency', () async {
        const service = MockRidePricingService(baseLatency: Duration.zero);

        final pickup = placeWithLocation(
          label: 'A',
          lat: 24.7136,
          lng: 46.6753,
        );
        final destination = placeWithLocation(
          label: 'B',
          lat: 24.7200,
          lng: 46.6800,
        );

        final quote = await service.quoteRide(
          pickup: pickup,
          destination: destination,
          serviceType: RideServiceType.ride,
        );

        for (final option in quote.options) {
          expect(option.currencyCode, equals('SAR'));
        }
      });
    });
  });

  group('RideServiceType', () {
    test('has all expected values', () {
      expect(RideServiceType.values, contains(RideServiceType.economy));
      expect(RideServiceType.values, contains(RideServiceType.xl));
      expect(RideServiceType.values, contains(RideServiceType.premium));
      expect(RideServiceType.values, contains(RideServiceType.ride));
    });
  });

  group('RidePricingException', () {
    test('message is stored correctly', () {
      const exception = RidePricingException('Custom error');
      expect(exception.message, equals('Custom error'));
    });

    test('toString includes message', () {
      const exception = RidePricingException('My error');
      expect(exception.toString(), contains('My error'));
      expect(exception.toString(), contains('RidePricingException'));
    });
  });

  // ============================================================================
  // Track B - Ticket #63: RidePriceBreakdown Tests
  // ============================================================================
  
  group('RidePriceBreakdown - Ticket #63', () {
    test('calculates totalMinorUnits correctly', () {
      const breakdown = RidePriceBreakdown(
        currencyCode: 'SAR',
        baseFareMinorUnits: 500,          // 5.00
        distanceComponentMinorUnits: 800, // 8.00
        timeComponentMinorUnits: 200,     // 2.00
        feesMinorUnits: 300,              // 3.00
      );

      // Total = 500 + 800 + 200 + 300 = 1800
      expect(breakdown.totalMinorUnits, equals(1800));
    });

    test('calculates fareSubtotalMinorUnits correctly', () {
      const breakdown = RidePriceBreakdown(
        currencyCode: 'SAR',
        baseFareMinorUnits: 500,
        distanceComponentMinorUnits: 800,
        timeComponentMinorUnits: 200,
        feesMinorUnits: 300,
      );

      // Fare subtotal = 500 + 800 + 200 = 1500 (without fees)
      expect(breakdown.fareSubtotalMinorUnits, equals(1500));
    });

    test('formattedTotal formats correctly', () {
      const breakdown = RidePriceBreakdown(
        currencyCode: 'SAR',
        baseFareMinorUnits: 500,
        distanceComponentMinorUnits: 800,
        timeComponentMinorUnits: 200,
        feesMinorUnits: 300,
      );

      expect(breakdown.formattedTotal, equals('18.00'));
    });

    test('formatted values handle single-digit minor units', () {
      const breakdown = RidePriceBreakdown(
        currencyCode: 'SAR',
        baseFareMinorUnits: 505, // 5.05
        distanceComponentMinorUnits: 0,
        timeComponentMinorUnits: 0,
        feesMinorUnits: 0,
      );

      expect(breakdown.formattedBaseFare, equals('5.05'));
    });

    test('equality works correctly', () {
      const a = RidePriceBreakdown(
        currencyCode: 'SAR',
        baseFareMinorUnits: 500,
        distanceComponentMinorUnits: 800,
        timeComponentMinorUnits: 200,
        feesMinorUnits: 300,
      );

      const b = RidePriceBreakdown(
        currencyCode: 'SAR',
        baseFareMinorUnits: 500,
        distanceComponentMinorUnits: 800,
        timeComponentMinorUnits: 200,
        feesMinorUnits: 300,
      );

      const c = RidePriceBreakdown(
        currencyCode: 'USD',
        baseFareMinorUnits: 500,
        distanceComponentMinorUnits: 800,
        timeComponentMinorUnits: 200,
        feesMinorUnits: 300,
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('toString contains all components', () {
      const breakdown = RidePriceBreakdown(
        currencyCode: 'SAR',
        baseFareMinorUnits: 500,
        distanceComponentMinorUnits: 800,
        timeComponentMinorUnits: 200,
        feesMinorUnits: 300,
      );

      final str = breakdown.toString();
      expect(str, contains('SAR'));
      expect(str, contains('5.00'));
      expect(str, contains('8.00'));
      expect(str, contains('2.00'));
      expect(str, contains('3.00'));
      expect(str, contains('18.00'));
    });
  });

  group('MockRidePricingService priceBreakdown - Ticket #63', () {
    MobilityPlace placeWithLocation({
      required String label,
      required double lat,
      required double lng,
    }) {
      return MobilityPlace(
        label: label,
        location: LocationPoint(
          latitude: lat,
          longitude: lng,
          accuracyMeters: 10,
          timestamp: DateTime.now(),
        ),
      );
    }

    test('options include priceBreakdown', () async {
      const service = MockRidePricingService(baseLatency: Duration.zero);

      final pickup = placeWithLocation(
        label: 'A',
        lat: 24.7136,
        lng: 46.6753,
      );
      final destination = placeWithLocation(
        label: 'B',
        lat: 24.7200,
        lng: 46.6800,
      );

      final quote = await service.quoteRide(
        pickup: pickup,
        destination: destination,
        serviceType: RideServiceType.ride,
      );

      for (final option in quote.options) {
        expect(option.priceBreakdown, isNotNull);
      }
    });

    test('priceBreakdown totalMinorUnits matches priceMinorUnits', () async {
      const service = MockRidePricingService(baseLatency: Duration.zero);

      final pickup = placeWithLocation(
        label: 'A',
        lat: 24.7136,
        lng: 46.6753,
      );
      final destination = placeWithLocation(
        label: 'B',
        lat: 24.7200,
        lng: 46.6800,
      );

      final quote = await service.quoteRide(
        pickup: pickup,
        destination: destination,
        serviceType: RideServiceType.ride,
      );

      for (final option in quote.options) {
        expect(
          option.priceBreakdown!.totalMinorUnits,
          equals(option.priceMinorUnits),
          reason: '${option.id} breakdown total should match priceMinorUnits',
        );
      }
    });

    test('priceBreakdown has positive components', () async {
      const service = MockRidePricingService(baseLatency: Duration.zero);

      final pickup = placeWithLocation(
        label: 'A',
        lat: 24.7136,
        lng: 46.6753,
      );
      final destination = placeWithLocation(
        label: 'B',
        lat: 24.7500,
        lng: 46.7000,
      );

      final quote = await service.quoteRide(
        pickup: pickup,
        destination: destination,
        serviceType: RideServiceType.ride,
      );

      for (final option in quote.options) {
        final breakdown = option.priceBreakdown!;
        expect(breakdown.baseFareMinorUnits, greaterThan(0),
            reason: '${option.id} should have positive base fare');
        expect(breakdown.distanceComponentMinorUnits, greaterThanOrEqualTo(0),
            reason: '${option.id} should have non-negative distance component');
        expect(breakdown.timeComponentMinorUnits, greaterThanOrEqualTo(0),
            reason: '${option.id} should have non-negative time component');
        expect(breakdown.feesMinorUnits, greaterThan(0),
            reason: '${option.id} should have positive fees');
      }
    });

    test('priceBreakdown uses SAR currency', () async {
      const service = MockRidePricingService(baseLatency: Duration.zero);

      final pickup = placeWithLocation(
        label: 'A',
        lat: 24.7136,
        lng: 46.6753,
      );
      final destination = placeWithLocation(
        label: 'B',
        lat: 24.7200,
        lng: 46.6800,
      );

      final quote = await service.quoteRide(
        pickup: pickup,
        destination: destination,
        serviceType: RideServiceType.ride,
      );

      for (final option in quote.options) {
        expect(option.priceBreakdown!.currencyCode, equals('SAR'));
      }
    });

    test('priceBreakdown is deterministic for same inputs', () async {
      const service = MockRidePricingService(baseLatency: Duration.zero);

      final pickup = placeWithLocation(
        label: 'A',
        lat: 24.7136,
        lng: 46.6753,
      );
      final destination = placeWithLocation(
        label: 'B',
        lat: 24.7200,
        lng: 46.6800,
      );

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

      // Compare breakdowns for each option type
      for (var i = 0; i < quote1.options.length; i++) {
        final breakdown1 = quote1.options[i].priceBreakdown!;
        final breakdown2 = quote2.options[i].priceBreakdown!;

        expect(breakdown1.baseFareMinorUnits, equals(breakdown2.baseFareMinorUnits));
        expect(breakdown1.distanceComponentMinorUnits,
            equals(breakdown2.distanceComponentMinorUnits));
        expect(breakdown1.timeComponentMinorUnits,
            equals(breakdown2.timeComponentMinorUnits));
        expect(breakdown1.feesMinorUnits, equals(breakdown2.feesMinorUnits));
        expect(breakdown1.totalMinorUnits, equals(breakdown2.totalMinorUnits));
      }
    });

    test('premium breakdown has higher fees than economy', () async {
      const service = MockRidePricingService(baseLatency: Duration.zero);

      final pickup = placeWithLocation(
        label: 'A',
        lat: 24.7136,
        lng: 46.6753,
      );
      final destination = placeWithLocation(
        label: 'B',
        lat: 24.7500,
        lng: 46.7000,
      );

      final quote = await service.quoteRide(
        pickup: pickup,
        destination: destination,
        serviceType: RideServiceType.ride,
      );

      final economy = quote.options.firstWhere((o) => o.id == 'economy');
      final premium = quote.options.firstWhere((o) => o.id == 'premium');

      expect(
        premium.priceBreakdown!.feesMinorUnits,
        greaterThan(economy.priceBreakdown!.feesMinorUnits),
      );
    });
  });
}


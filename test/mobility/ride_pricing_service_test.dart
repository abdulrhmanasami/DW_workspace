/// Tests for MockRidePricingService - Ticket #210
/// Purpose: Test pricing calculations, surge scenarios, and error handling
/// Created by: Ticket #210
/// Last updated: 2025-12-03

import 'package:flutter_test/flutter_test.dart';
import 'package:maps_shims/maps_shims.dart';
import 'package:pricing_shims/pricing_shims.dart';
import 'package:pricing_stub_impl/pricing_stub_impl.dart';

void main() {
  group('MockRidePricingService', () {
    late MockRidePricingService service;
    late GeoPoint pickup;
    late GeoPoint dropoff;

    setUp(() {
      service = const MockRidePricingService();
      pickup = const GeoPoint(24.7136, 46.6753); // Riyadh coordinates
      dropoff = const GeoPoint(24.7236, 46.6853); // Nearby location
    });

    test('normal quote - returns successful result with correct pricing', () async {
      // Arrange
      final request = RideQuoteRequest(
        pickup: pickup,
        dropoff: dropoff,
        requestedAt: DateTime.now(),
      );

      // Act
      final result = await service.requestQuote(request);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.quote, isNotNull);
      expect(result.failure, isNull);

      final quote = result.quote!;
      expect(quote.id, startsWith('mock-'));
      expect(quote.price.value, greaterThan(0));
      expect(quote.price.currency, equals('SAR'));
      expect(quote.estimatedDuration.inMinutes, greaterThan(0));
      expect(quote.distanceMeters, greaterThan(0));
      expect(quote.surgeMultiplier, equals(1.0));
    });

    test('moderate surge scenario - returns higher price with surge multiplier', () async {
      // Arrange
      final request = RideQuoteRequest(
        pickup: pickup,
        dropoff: dropoff,
        requestedAt: DateTime.now(),
        debugScenario: 'moderate_surge',
      );

      // Act
      final result = await service.requestQuote(request);

      // Assert
      expect(result.isSuccess, isTrue);
      final quote = result.quote!;
      expect(quote.surgeMultiplier, equals(1.5));
      expect(quote.price.value, greaterThan(0));
    });

    test('high surge scenario - returns significantly higher price', () async {
      // Arrange
      final request = RideQuoteRequest(
        pickup: pickup,
        dropoff: dropoff,
        requestedAt: DateTime.now(),
        debugScenario: 'high_surge',
      );

      // Act
      final result = await service.requestQuote(request);

      // Assert
      expect(result.isSuccess, isTrue);
      final quote = result.quote!;
      expect(quote.surgeMultiplier, equals(2.0));
      expect(quote.price.value, greaterThan(0));
    });

    test('network error scenario - returns failure result', () async {
      // Arrange
      final request = RideQuoteRequest(
        pickup: pickup,
        dropoff: dropoff,
        requestedAt: DateTime.now(),
        forceNetworkError: true,
      );

      // Act
      final result = await service.requestQuote(request);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.quote, isNull);
      expect(result.failure, equals(RideQuoteFailureReason.networkError));
    });

    test('invalid request - same pickup and dropoff returns failure', () async {
      // Arrange
      final request = RideQuoteRequest(
        pickup: pickup,
        dropoff: pickup, // Same location
        requestedAt: DateTime.now(),
      );

      // Act
      final result = await service.requestQuote(request);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.quote, isNull);
      expect(result.failure, equals(RideQuoteFailureReason.invalidRequest));
    });

    test('deterministic pricing - same inputs produce consistent results', () async {
      // Arrange
      final request = RideQuoteRequest(
        pickup: pickup,
        dropoff: dropoff,
        requestedAt: DateTime.now(),
      );

      // Act
      final result1 = await service.requestQuote(request);
      final result2 = await service.requestQuote(request);

      // Assert
      expect(result1.isSuccess, isTrue);
      expect(result2.isSuccess, isTrue);

      final quote1 = result1.quote!;
      final quote2 = result2.quote!;

      expect(quote1.id, isNot(equals(quote2.id))); // IDs should be unique
      expect(quote1.price.value, equals(quote2.price.value));
      expect(quote1.estimatedDuration, equals(quote2.estimatedDuration));
      expect(quote1.distanceMeters, equals(quote2.distanceMeters));
      expect(quote1.surgeMultiplier, equals(quote2.surgeMultiplier));
    });

    test('pricing scales with distance', () async {
      // Arrange
      final closeDropoff = const GeoPoint(24.7146, 46.6763); // Very close
      final farDropoff = const GeoPoint(24.8136, 46.7753); // Much farther

      final closeRequest = RideQuoteRequest(
        pickup: pickup,
        dropoff: closeDropoff,
        requestedAt: DateTime.now(),
      );

      final farRequest = RideQuoteRequest(
        pickup: pickup,
        dropoff: farDropoff,
        requestedAt: DateTime.now(),
      );

      // Act
      final closeResult = await service.requestQuote(closeRequest);
      final farResult = await service.requestQuote(farRequest);

      // Assert
      expect(closeResult.isSuccess, isTrue);
      expect(farResult.isSuccess, isTrue);

      final closePrice = closeResult.quote!.price.value;
      final farPrice = farResult.quote!.price.value;

      expect(farPrice, greaterThan(closePrice));
      expect(farResult.quote!.distanceMeters, greaterThan(closeResult.quote!.distanceMeters));
    });

    test('surge pricing increases total cost proportionally', () async {
      // Arrange
      final baseRequest = RideQuoteRequest(
        pickup: pickup,
        dropoff: dropoff,
        requestedAt: DateTime.now(),
        debugScenario: 'normal',
      );

      final surgeRequest = RideQuoteRequest(
        pickup: pickup,
        dropoff: dropoff,
        requestedAt: DateTime.now(),
        debugScenario: 'moderate_surge',
      );

      // Act
      final baseResult = await service.requestQuote(baseRequest);
      final surgeResult = await service.requestQuote(surgeRequest);

      // Assert
      expect(baseResult.isSuccess, isTrue);
      expect(surgeResult.isSuccess, isTrue);

      final basePrice = baseResult.quote!.price.value;
      final surgePrice = surgeResult.quote!.price.value;

      // Surge price should be approximately 1.5x base price
      final expectedSurgePrice = (basePrice * 1.5).round();
      expect(surgePrice, closeTo(expectedSurgePrice, 100)); // Allow some rounding tolerance
    });

    test('service includes network delay simulation', () async {
      // Arrange
      final request = RideQuoteRequest(
        pickup: pickup,
        dropoff: dropoff,
        requestedAt: DateTime.now(),
      );

      // Act
      final startTime = DateTime.now();
      await service.requestQuote(request);
      final duration = DateTime.now().difference(startTime);

      // Assert
      // Should take at least some time for network simulation (50-200ms)
      expect(duration.inMilliseconds, greaterThan(40));
      expect(duration.inMilliseconds, lessThan(300));
    });

    test('quote includes realistic duration estimate', () async {
      // Arrange
      final request = RideQuoteRequest(
        pickup: pickup,
        dropoff: dropoff,
        requestedAt: DateTime.now(),
      );

      // Act
      final result = await service.requestQuote(request);

      // Assert
      expect(result.isSuccess, isTrue);
      final duration = result.quote!.estimatedDuration;

      // For ~1km distance at 30km/h, should be around 2 minutes
      expect(duration.inMinutes, greaterThanOrEqualTo(1));
      expect(duration.inMinutes, lessThanOrEqualTo(10));
    });

    test('price calculation uses correct currency and minor units', () async {
      // Arrange
      final request = RideQuoteRequest(
        pickup: pickup,
        dropoff: dropoff,
        requestedAt: DateTime.now(),
      );

      // Act
      final result = await service.requestQuote(request);

      // Assert
      expect(result.isSuccess, isTrue);
      final price = result.quote!.price;

      expect(price.currency, equals('SAR'));
      // Price should be reasonable (greater than base fare of 8 SAR = 800 minor units)
      expect(price.value, greaterThan(800));
      // But not ridiculously high
      expect(price.value, lessThan(50000)); // 500 SAR max
    });

    test('unique quote IDs are generated', () async {
      // Arrange
      final request = RideQuoteRequest(
        pickup: pickup,
        dropoff: dropoff,
        requestedAt: DateTime.now(),
      );

      // Act
      final result1 = await service.requestQuote(request);
      final result2 = await service.requestQuote(request);

      // Assert
      expect(result1.isSuccess, isTrue);
      expect(result2.isSuccess, isTrue);
      expect(result1.quote!.id, isNot(equals(result2.quote!.id)));
      expect(result1.quote!.id, startsWith('mock-'));
      expect(result2.quote!.id, startsWith('mock-'));
    });
  });
}

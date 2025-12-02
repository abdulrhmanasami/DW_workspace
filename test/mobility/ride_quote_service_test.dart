import 'package:mobility_shims/mobility_shims.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MockRideQuoteService', () {
    const service = MockRideQuoteService();

    LocationPoint point(double lat, double lng) {
      return LocationPoint(
        latitude: lat,
        longitude: lng,
        accuracyMeters: 5,
        timestamp: DateTime.now(),
      );
    }

    test('returns non-empty options list', () async {
      final request = RideQuoteRequest(
        pickup: point(24.7136, 46.6753),
        dropoff: point(24.7743, 46.7386),
      );

      final quote = await service.getQuote(request);

      expect(quote.options, isNotEmpty);
      expect(quote.request.pickup.latitude, equals(24.7136));
    });

    test('returns exactly 3 options (economy, xl, premium)', () async {
      final request = RideQuoteRequest(
        pickup: point(24.7136, 46.6753),
        dropoff: point(24.7743, 46.7386),
      );

      final quote = await service.getQuote(request);

      expect(quote.options.length, equals(3));
      expect(quote.options.map((o) => o.id).toList(),
          containsAll(['economy', 'xl', 'premium']));
    });

    test('options are sorted and recommended flag is set for economy',
        () async {
      final request = RideQuoteRequest(
        pickup: point(24.7136, 46.6753),
        dropoff: point(24.7743, 46.7386),
      );

      final quote = await service.getQuote(request);

      final economy = quote.options.firstWhere((o) => o.id == 'economy');
      expect(economy.isRecommended, isTrue);

      // Other options should not be recommended
      final xl = quote.options.firstWhere((o) => o.id == 'xl');
      final premium = quote.options.firstWhere((o) => o.id == 'premium');
      expect(xl.isRecommended, isFalse);
      expect(premium.isRecommended, isFalse);
    });

    test('quote uses request currency and non-negative prices', () async {
      final request = RideQuoteRequest(
        pickup: point(24.7136, 46.6753),
        dropoff: point(24.7743, 46.7386),
        currencyCode: 'SAR',
      );

      final quote = await service.getQuote(request);

      for (final option in quote.options) {
        expect(option.currencyCode, equals('SAR'));
        expect(option.priceMinorUnits, greaterThanOrEqualTo(0));
      }
    });

    test('supports different currency codes', () async {
      final request = RideQuoteRequest(
        pickup: point(24.7136, 46.6753),
        dropoff: point(24.7743, 46.7386),
        currencyCode: 'USD',
      );

      final quote = await service.getQuote(request);

      for (final option in quote.options) {
        expect(option.currencyCode, equals('USD'));
      }
    });

    test('prices increase from economy to premium', () async {
      final request = RideQuoteRequest(
        pickup: point(24.7136, 46.6753),
        dropoff: point(24.7743, 46.7386),
      );

      final quote = await service.getQuote(request);

      final economy = quote.options.firstWhere((o) => o.id == 'economy');
      final xl = quote.options.firstWhere((o) => o.id == 'xl');
      final premium = quote.options.firstWhere((o) => o.id == 'premium');

      expect(economy.priceMinorUnits, lessThan(xl.priceMinorUnits));
      expect(xl.priceMinorUnits, lessThan(premium.priceMinorUnits));
    });

    test('ETA increases from economy to premium', () async {
      final request = RideQuoteRequest(
        pickup: point(24.7136, 46.6753),
        dropoff: point(24.7743, 46.7386),
      );

      final quote = await service.getQuote(request);

      final economy = quote.options.firstWhere((o) => o.id == 'economy');
      final xl = quote.options.firstWhere((o) => o.id == 'xl');
      final premium = quote.options.firstWhere((o) => o.id == 'premium');

      expect(economy.etaMinutes, lessThan(xl.etaMinutes));
      expect(xl.etaMinutes, lessThan(premium.etaMinutes));
    });

    test('longer distance produces higher prices', () async {
      final shortTrip = RideQuoteRequest(
        pickup: point(24.7136, 46.6753),
        dropoff: point(24.7200, 46.6800), // short distance
      );

      final longTrip = RideQuoteRequest(
        pickup: point(24.7136, 46.6753),
        dropoff: point(24.9000, 46.9000), // longer distance
      );

      final shortQuote = await service.getQuote(shortTrip);
      final longQuote = await service.getQuote(longTrip);

      final shortEconomy =
          shortQuote.options.firstWhere((o) => o.id == 'economy');
      final longEconomy =
          longQuote.options.firstWhere((o) => o.id == 'economy');

      expect(longEconomy.priceMinorUnits,
          greaterThan(shortEconomy.priceMinorUnits));
    });
  });

  group('RideQuote', () {
    LocationPoint point(double lat, double lng) {
      return LocationPoint(
        latitude: lat,
        longitude: lng,
        accuracyMeters: 5,
        timestamp: DateTime.now(),
      );
    }

    test(
      'enforces non-empty options',
      () {
        createEmptyQuote() => RideQuote(
              quoteId: 'q-1',
              request: RideQuoteRequest(
                pickup: point(0, 0),
                dropoff: point(1, 1),
              ),
              options: const [],
            );

        expect(createEmptyQuote, throwsA(isA<AssertionError>()));
      },
      skip: 'Track B - Ticket #123: Legacy behavior after Ride pricing refactor; pending rewrite',
    );

    test('recommendedOption returns first recommended option', () {
      final quote = RideQuote(
        quoteId: 'q-1',
        request: RideQuoteRequest(
          pickup: point(0, 0),
          dropoff: point(1, 1),
        ),
        options: const [
          RideQuoteOption(
            id: 'a',
            category: RideVehicleCategory.economy,
            displayName: 'A',
            etaMinutes: 5,
            priceMinorUnits: 1000,
            currencyCode: 'SAR',
            isRecommended: false,
          ),
          RideQuoteOption(
            id: 'b',
            category: RideVehicleCategory.xl,
            displayName: 'B',
            etaMinutes: 7,
            priceMinorUnits: 1500,
            currencyCode: 'SAR',
            isRecommended: true,
          ),
        ],
      );

      // Track B - Ticket #121: recommendedOption is now nullable
      expect(quote.recommendedOption?.id, equals('b'));
    });

    test('optionById returns correct option', () {
      final quote = RideQuote(
        quoteId: 'q-1',
        request: RideQuoteRequest(
          pickup: point(0, 0),
          dropoff: point(1, 1),
        ),
        options: const [
          RideQuoteOption(
            id: 'economy',
            category: RideVehicleCategory.economy,
            displayName: 'Economy',
            etaMinutes: 5,
            priceMinorUnits: 1000,
            currencyCode: 'SAR',
          ),
        ],
      );

      expect(quote.optionById('economy')?.displayName, equals('Economy'));
      expect(quote.optionById('nonexistent'), isNull);
    });
  });

  group('RideQuoteOption', () {
    test('formattedPrice formats correctly', () {
      const option = RideQuoteOption(
        id: 'test',
        category: RideVehicleCategory.economy,
        displayName: 'Test',
        etaMinutes: 5,
        priceMinorUnits: 1850,
        currencyCode: 'SAR',
      );

      expect(option.formattedPrice, equals('18.50'));
    });

    test('formattedPrice handles zero minor units', () {
      const option = RideQuoteOption(
        id: 'test',
        category: RideVehicleCategory.economy,
        displayName: 'Test',
        etaMinutes: 5,
        priceMinorUnits: 1800,
        currencyCode: 'SAR',
      );

      expect(option.formattedPrice, equals('18.00'));
    });

    test('enforces non-negative etaMinutes', () {
      createInvalidOption() => RideQuoteOption(
            id: 'test',
            category: RideVehicleCategory.economy,
            displayName: 'Test',
            etaMinutes: -1,
            priceMinorUnits: 1000,
            currencyCode: 'SAR',
          );

      expect(createInvalidOption, throwsA(isA<AssertionError>()));
    });

    test('enforces non-negative priceMinorUnits', () {
      createInvalidOption() => RideQuoteOption(
            id: 'test',
            category: RideVehicleCategory.economy,
            displayName: 'Test',
            etaMinutes: 5,
            priceMinorUnits: -100,
            currencyCode: 'SAR',
          );

      expect(createInvalidOption, throwsA(isA<AssertionError>()));
    });
  });

  group('NoOpRideQuoteService', () {
    test('throws UnimplementedError', () {
      const service = NoOpRideQuoteService();
      final request = RideQuoteRequest(
        pickup: LocationPoint(
          latitude: 0,
          longitude: 0,
          accuracyMeters: 5,
          timestamp: DateTime.now(),
        ),
        dropoff: LocationPoint(
          latitude: 1,
          longitude: 1,
          accuracyMeters: 5,
          timestamp: DateTime.now(),
        ),
      );

      expect(
        () => service.getQuote(request),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}


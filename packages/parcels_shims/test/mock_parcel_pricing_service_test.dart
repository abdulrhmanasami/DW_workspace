/// MockParcelPricingService Unit Tests - Ticket #39
/// Purpose: Tests for the mock parcel pricing service
/// Created by: Ticket #39

import 'package:parcels_shims/parcels_shims.dart';
import 'package:test/test.dart';

void main() {
  group('MockParcelPricingService', () {
    test('returns non-empty options list', () async {
      const service = MockParcelPricingService(baseLatency: Duration.zero);

      const pickup = ParcelAddress(label: 'Pickup');
      const dropoff = ParcelAddress(label: 'Dropoff');
      const details = ParcelDetails(size: ParcelSize.small);

      final quote = await service.quoteParcel(
        pickup: pickup,
        dropoff: dropoff,
        details: details,
        serviceType: ParcelServiceType.standard,
      );

      expect(quote.options, isNotEmpty);
    });

    test('returns standard and express options', () async {
      const service = MockParcelPricingService(baseLatency: Duration.zero);

      const pickup = ParcelAddress(label: 'Pickup');
      const dropoff = ParcelAddress(label: 'Dropoff');
      const details = ParcelDetails(size: ParcelSize.medium);

      final quote = await service.quoteParcel(
        pickup: pickup,
        dropoff: dropoff,
        details: details,
        serviceType: ParcelServiceType.standard,
      );

      final ids = quote.options.map((o) => o.id).toList();
      expect(ids, containsAll(['standard', 'express']));
    });

    test('throws ParcelPricingException when failureRate is 1.0', () async {
      const service = MockParcelPricingService(
        baseLatency: Duration.zero,
        failureRate: 1.0,
      );

      const pickup = ParcelAddress(label: 'Pickup');
      const dropoff = ParcelAddress(label: 'Dropoff');
      const details = ParcelDetails(size: ParcelSize.large);

      expect(
        () => service.quoteParcel(
          pickup: pickup,
          dropoff: dropoff,
          details: details,
          serviceType: ParcelServiceType.express,
        ),
        throwsA(isA<ParcelPricingException>()),
      );
    });

    test('returns two options', () async {
      const service = MockParcelPricingService(baseLatency: Duration.zero);

      const pickup = ParcelAddress(label: 'Pickup');
      const dropoff = ParcelAddress(label: 'Dropoff');
      const details = ParcelDetails(size: ParcelSize.oversize);

      final quote = await service.quoteParcel(
        pickup: pickup,
        dropoff: dropoff,
        details: details,
        serviceType: ParcelServiceType.standard,
      );

      expect(quote.options.length, 2);
    });

    test('express option is more expensive than standard', () async {
      const service = MockParcelPricingService(baseLatency: Duration.zero);

      const pickup = ParcelAddress(label: 'Pickup');
      const dropoff = ParcelAddress(label: 'Dropoff');
      const details = ParcelDetails(size: ParcelSize.medium);

      final quote = await service.quoteParcel(
        pickup: pickup,
        dropoff: dropoff,
        details: details,
        serviceType: ParcelServiceType.standard,
      );

      final standardOption =
          quote.options.firstWhere((o) => o.id == 'standard');
      final expressOption = quote.options.firstWhere((o) => o.id == 'express');

      expect(expressOption.totalAmountCents,
          greaterThan(standardOption.totalAmountCents));
    });

    test('express option has shorter estimated time', () async {
      const service = MockParcelPricingService(baseLatency: Duration.zero);

      const pickup = ParcelAddress(label: 'Pickup');
      const dropoff = ParcelAddress(label: 'Dropoff');
      const details = ParcelDetails(size: ParcelSize.small);

      final quote = await service.quoteParcel(
        pickup: pickup,
        dropoff: dropoff,
        details: details,
        serviceType: ParcelServiceType.standard,
      );

      final standardOption =
          quote.options.firstWhere((o) => o.id == 'standard');
      final expressOption = quote.options.firstWhere((o) => o.id == 'express');

      expect(expressOption.estimatedMinutes,
          lessThan(standardOption.estimatedMinutes));
    });

    test('quote has unique quoteId', () async {
      const service = MockParcelPricingService(baseLatency: Duration.zero);

      const pickup = ParcelAddress(label: 'Pickup');
      const dropoff = ParcelAddress(label: 'Dropoff');
      const details = ParcelDetails(size: ParcelSize.small);

      final quote1 = await service.quoteParcel(
        pickup: pickup,
        dropoff: dropoff,
        details: details,
        serviceType: ParcelServiceType.standard,
      );

      final quote2 = await service.quoteParcel(
        pickup: pickup,
        dropoff: dropoff,
        details: details,
        serviceType: ParcelServiceType.standard,
      );

      expect(quote1.quoteId, isNot(equals(quote2.quoteId)));
    });

    test('options have SAR currency code', () async {
      const service = MockParcelPricingService(baseLatency: Duration.zero);

      const pickup = ParcelAddress(label: 'Pickup');
      const dropoff = ParcelAddress(label: 'Dropoff');
      const details = ParcelDetails(size: ParcelSize.small);

      final quote = await service.quoteParcel(
        pickup: pickup,
        dropoff: dropoff,
        details: details,
        serviceType: ParcelServiceType.standard,
      );

      for (final option in quote.options) {
        expect(option.currencyCode, 'SAR');
      }
    });

    group('pricing by size', () {
      test('small parcel has lowest base price', () async {
        const service = MockParcelPricingService(baseLatency: Duration.zero);

        const pickup = ParcelAddress(label: 'Pickup');
        const dropoff = ParcelAddress(label: 'Dropoff');

        final smallQuote = await service.quoteParcel(
          pickup: pickup,
          dropoff: dropoff,
          details: const ParcelDetails(size: ParcelSize.small),
          serviceType: ParcelServiceType.standard,
        );

        final mediumQuote = await service.quoteParcel(
          pickup: pickup,
          dropoff: dropoff,
          details: const ParcelDetails(size: ParcelSize.medium),
          serviceType: ParcelServiceType.standard,
        );

        final smallStandard =
            smallQuote.options.firstWhere((o) => o.id == 'standard');
        final mediumStandard =
            mediumQuote.options.firstWhere((o) => o.id == 'standard');

        expect(smallStandard.totalAmountCents,
            lessThan(mediumStandard.totalAmountCents));
      });

      test('oversize parcel has highest base price', () async {
        const service = MockParcelPricingService(baseLatency: Duration.zero);

        const pickup = ParcelAddress(label: 'Pickup');
        const dropoff = ParcelAddress(label: 'Dropoff');

        final largeQuote = await service.quoteParcel(
          pickup: pickup,
          dropoff: dropoff,
          details: const ParcelDetails(size: ParcelSize.large),
          serviceType: ParcelServiceType.standard,
        );

        final oversizeQuote = await service.quoteParcel(
          pickup: pickup,
          dropoff: dropoff,
          details: const ParcelDetails(size: ParcelSize.oversize),
          serviceType: ParcelServiceType.standard,
        );

        final largeStandard =
            largeQuote.options.firstWhere((o) => o.id == 'standard');
        final oversizeStandard =
            oversizeQuote.options.firstWhere((o) => o.id == 'standard');

        expect(oversizeStandard.totalAmountCents,
            greaterThan(largeStandard.totalAmountCents));
      });
    });

    test('does not fail when failureRate is 0', () async {
      const service = MockParcelPricingService(
        baseLatency: Duration.zero,
        failureRate: 0.0,
      );

      const pickup = ParcelAddress(label: 'Pickup');
      const dropoff = ParcelAddress(label: 'Dropoff');
      const details = ParcelDetails(size: ParcelSize.small);

      // Run multiple times to verify it never fails
      for (var i = 0; i < 10; i++) {
        final quote = await service.quoteParcel(
          pickup: pickup,
          dropoff: dropoff,
          details: details,
          serviceType: ParcelServiceType.standard,
        );
        expect(quote.options, isNotEmpty);
      }
    });
  });

  group('ParcelQuoteOption', () {
    test('has correct field values', () {
      const option = ParcelQuoteOption(
        id: 'test-id',
        label: 'Test Label',
        estimatedMinutes: 45,
        totalAmountCents: 2000,
        currencyCode: 'SAR',
      );

      expect(option.id, 'test-id');
      expect(option.label, 'Test Label');
      expect(option.estimatedMinutes, 45);
      expect(option.totalAmountCents, 2000);
      expect(option.currencyCode, 'SAR');
    });
  });

  group('ParcelQuote', () {
    test('has quoteId and options', () {
      const option = ParcelQuoteOption(
        id: 'standard',
        label: 'Standard',
        estimatedMinutes: 60,
        totalAmountCents: 1500,
        currencyCode: 'SAR',
      );

      final quote = ParcelQuote(
        quoteId: 'quote-123',
        options: [option],
      );

      expect(quote.quoteId, 'quote-123');
      expect(quote.options.length, 1);
    });
  });

  group('ParcelPricingException', () {
    test('toString contains message', () {
      const exception = ParcelPricingException('Test error message');

      expect(exception.toString(), contains('Test error message'));
      expect(exception.toString(), contains('ParcelPricingException'));
    });

    test('message field is accessible', () {
      const exception = ParcelPricingException('My message');

      expect(exception.message, 'My message');
    });
  });

  group('ParcelServiceType', () {
    test('has standard and express values', () {
      expect(ParcelServiceType.values, contains(ParcelServiceType.standard));
      expect(ParcelServiceType.values, contains(ParcelServiceType.express));
    });
  });
}


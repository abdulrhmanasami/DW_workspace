import 'dart:math';

import 'package:meta/meta.dart';

import 'parcel_models.dart';

/// Service type for parcel shipments.
enum ParcelServiceType {
  standard,
  express,
}

/// Option returned by pricing service.
@immutable
class ParcelQuoteOption {
  const ParcelQuoteOption({
    required this.id,
    required this.label,
    required this.estimatedMinutes,
    required this.totalAmountCents,
    required this.currencyCode,
  });

  final String id;
  final String label;
  final int estimatedMinutes;
  final int totalAmountCents;
  final String currencyCode;
}

/// Quote result for a parcel shipment.
@immutable
class ParcelQuote {
  const ParcelQuote({
    required this.quoteId,
    required this.options,
  }) : assert(options.length > 0, 'ParcelQuote.options must not be empty');

  final String quoteId;
  final List<ParcelQuoteOption> options;
}

/// Abstract pricing service for parcel shipments.
abstract class ParcelPricingService {
  Future<ParcelQuote> quoteParcel({
    required ParcelAddress pickup,
    required ParcelAddress dropoff,
    required ParcelDetails details,
    required ParcelServiceType serviceType,
  });
}

/// Exception thrown when pricing fails.
class ParcelPricingException implements Exception {
  const ParcelPricingException(this.message);

  final String message;

  @override
  String toString() => 'ParcelPricingException: $message';
}

/// Mock implementation for local development and tests.
class MockParcelPricingService implements ParcelPricingService {
  const MockParcelPricingService({
    this.baseLatency = const Duration(milliseconds: 300),
    this.failureRate = 0.0,
    this.random,
  });

  final Duration baseLatency;
  final double failureRate;
  final Random? random;

  bool _shouldFail() {
    if (failureRate <= 0) return false;
    final rng = random ?? Random();
    return rng.nextDouble() < failureRate;
  }

  @override
  Future<ParcelQuote> quoteParcel({
    required ParcelAddress pickup,
    required ParcelAddress dropoff,
    required ParcelDetails details,
    required ParcelServiceType serviceType,
  }) async {
    // 1) Simulate network latency
    await Future.delayed(baseLatency);

    // 2) Possible failure
    if (_shouldFail()) {
      throw const ParcelPricingException('Mock parcel pricing failure');
    }

    // 3) Mock price logic: base on size + service type
    final basePrice = switch (details.size) {
      ParcelSize.small => 1500, // 15 SAR
      ParcelSize.medium => 2500,
      ParcelSize.large => 3500,
      ParcelSize.oversize => 5000,
    };

    final standardAmount = (basePrice * 1.0).round();
    final expressAmount = (basePrice * 1.5).round();

    final options = <ParcelQuoteOption>[
      ParcelQuoteOption(
        id: 'standard',
        label: 'Standard',
        estimatedMinutes: 60,
        totalAmountCents: standardAmount,
        currencyCode: 'SAR',
      ),
      ParcelQuoteOption(
        id: 'express',
        label: 'Express',
        estimatedMinutes: 30,
        totalAmountCents: expressAmount,
        currencyCode: 'SAR',
      ),
    ];

    return ParcelQuote(
      quoteId: 'mock-${DateTime.now().microsecondsSinceEpoch}',
      options: options,
    );
  }
}


/// Ride Quote Service - Track B Ticket #13
/// Purpose: Abstract service interface + Mock implementation for ride quotes
/// Created by: Track B - Ticket #13
/// Last updated: 2025-11-28
///
/// This file provides:
/// - [RideQuoteService] - abstract interface for quote providers
/// - [MockRideQuoteService] - deterministic mock for dev/tests
///
/// IMPORTANT:
/// - [MockRideQuoteService] is NOT a production pricing engine.
/// - Real implementations should live in adapter packages.

import 'dart:math';

import 'package:meta/meta.dart';

import 'ride_quote_models.dart';

/// Abstraction for a ride quote service.
///
/// Implementations may talk to:
/// - A real backend (production),
/// - A local mock (development),
/// - Or a fake in-memory calculator (tests).
abstract class RideQuoteService {
  /// Fetches a quote for the given [request].
  ///
  /// Returns a [RideQuote] with available options.
  /// May throw exceptions for network/backend errors in real implementations.
  Future<RideQuote> getQuote(RideQuoteRequest request);
}

/// Simple in-memory mock implementation of [RideQuoteService].
///
/// This implementation is:
/// - Deterministic (no randomness),
/// - SDK/backend agnostic,
/// - Intended for early development and tests.
///
/// IMPORTANT:
/// - This must NOT be shipped as a production pricing engine.
/// - A real implementation should live in an adapter package or the app.
@immutable
class MockRideQuoteService implements RideQuoteService {
  const MockRideQuoteService();

  /// Base price per kilometer for each vehicle category (fake SAR values).
  static const _basePerKmEconomy = 1.8;
  static const _basePerKmXl = 2.6;
  static const _basePerKmPremium = 3.5;

  /// Minimum fare in SAR (before minor unit conversion).
  static const _minimumFare = 5.0;

  @override
  Future<RideQuote> getQuote(RideQuoteRequest request) async {
    // Simple heuristic: approximate "distance" using lat/lng difference.
    // This uses the equirectangular approximation (good enough for mock).
    final dx = request.pickup.latitude - request.dropoff.latitude;
    final dy = request.pickup.longitude - request.dropoff.longitude;

    // ~111 km per degree at the equator (rough approximation)
    final approxDistanceKm = max(1.0, sqrt(dx * dx + dy * dy) * 111);

    // Calculate prices
    int toMinor(double amount) => (amount * 100).round();

    final economyPrice = toMinor(
      max(_minimumFare, _basePerKmEconomy * approxDistanceKm),
    );
    final xlPrice = toMinor(
      max(_minimumFare * 1.4, _basePerKmXl * approxDistanceKm),
    );
    final premiumPrice = toMinor(
      max(_minimumFare * 2, _basePerKmPremium * approxDistanceKm),
    );

    // Very rough ETA heuristic (assumes ~30 km/h average in city).
    final baseEta = max(3, (approxDistanceKm * 2).round());

    final options = <RideQuoteOption>[
      RideQuoteOption(
        id: 'economy',
        category: RideVehicleCategory.economy,
        displayName: 'Economy',
        etaMinutes: baseEta,
        priceMinorUnits: economyPrice,
        currencyCode: request.currencyCode,
        isRecommended: true,
      ),
      RideQuoteOption(
        id: 'xl',
        category: RideVehicleCategory.xl,
        displayName: 'XL',
        etaMinutes: baseEta + 2,
        priceMinorUnits: xlPrice,
        currencyCode: request.currencyCode,
        isRecommended: false,
      ),
      RideQuoteOption(
        id: 'premium',
        category: RideVehicleCategory.premium,
        displayName: 'Premium',
        etaMinutes: baseEta + 4,
        priceMinorUnits: premiumPrice,
        currencyCode: request.currencyCode,
        isRecommended: false,
      ),
    ];

    return RideQuote(
      quoteId: 'local-quote-${DateTime.now().microsecondsSinceEpoch}',
      request: request,
      options: options,
    );
  }
}

/// A no-op quote service that always throws.
///
/// Useful as a placeholder when no real service is configured.
class NoOpRideQuoteService implements RideQuoteService {
  const NoOpRideQuoteService();

  @override
  Future<RideQuote> getQuote(RideQuoteRequest request) {
    throw UnimplementedError(
      'NoOpRideQuoteService: No real quote service configured.',
    );
  }
}


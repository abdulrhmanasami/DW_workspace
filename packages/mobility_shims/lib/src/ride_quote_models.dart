/// Ride Quote Domain Models - Track B Ticket #13
/// Purpose: Canonical domain models for ride pricing/quotes
/// Created by: Track B - Ticket #13
/// Last updated: 2025-11-28
///
/// These models are the single source of truth for ride pricing.
/// They are SDK/backend agnostic and should be used by:
/// - App UI layer (via providers)
/// - Backend adapters (mapping to/from API responses)
/// - Tests and mocks
///
/// IMPORTANT:
/// - Do NOT duplicate these models in app/lib.
/// - Prices are in minor units (e.g. 1800 = 18.00 SAR).

import 'package:meta/meta.dart';

import '../location/models.dart' show LocationPoint;

/// Vehicle categories supported by the ride platform.
///
/// This is intentionally generic and should map to the product catalog
/// (e.g. Economy, XL, Premium).
enum RideVehicleCategory {
  /// Standard affordable option.
  economy,

  /// Larger vehicle for more passengers or luggage.
  xl,

  /// Luxury/premium vehicle option.
  premium,
}

/// Client-side request model for a ride quote.
///
/// This is SDK/backend agnostic and uses [LocationPoint] from mobility_shims.
@immutable
class RideQuoteRequest {
  const RideQuoteRequest({
    required this.pickup,
    required this.dropoff,
    this.currencyCode = 'SAR',
  });

  /// Pickup location (where the trip should start).
  final LocationPoint pickup;

  /// Dropoff location (where the trip should end).
  final LocationPoint dropoff;

  /// ISO-4217 currency code used for pricing (e.g. 'SAR', 'USD').
  final String currencyCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RideQuoteRequest &&
        other.pickup.latitude == pickup.latitude &&
        other.pickup.longitude == pickup.longitude &&
        other.dropoff.latitude == dropoff.latitude &&
        other.dropoff.longitude == dropoff.longitude &&
        other.currencyCode == currencyCode;
  }

  @override
  int get hashCode =>
      pickup.latitude.hashCode ^
      pickup.longitude.hashCode ^
      dropoff.latitude.hashCode ^
      dropoff.longitude.hashCode ^
      currencyCode.hashCode;
}

/// A single option returned in a ride quote (e.g. Economy / XL / Premium).
@immutable
class RideQuoteOption {
  const RideQuoteOption({
    required this.id,
    required this.category,
    required this.displayName,
    required this.etaMinutes,
    required this.priceMinorUnits,
    required this.currencyCode,
    this.isRecommended = false,
  })  : assert(etaMinutes >= 0, 'etaMinutes must be non-negative'),
        assert(priceMinorUnits >= 0, 'priceMinorUnits must be non-negative');

  /// Stable option id (e.g. 'economy', 'xl', 'premium').
  final String id;

  /// Logical category for this option.
  final RideVehicleCategory category;

  /// Human-readable name to display in the UI (e.g. "Economy").
  final String displayName;

  /// Estimated time of arrival (minutes).
  final int etaMinutes;

  /// Estimated price in minor units (e.g. 1800 = 18.00 SAR).
  final int priceMinorUnits;

  /// Currency code (ISO-4217).
  final String currencyCode;

  /// Whether this option is recommended to the user.
  final bool isRecommended;

  /// Formats the price for display (e.g. "18.00").
  String get formattedPrice {
    final major = priceMinorUnits ~/ 100;
    final minor = priceMinorUnits % 100;
    return '$major.${minor.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RideQuoteOption &&
        other.id == id &&
        other.category == category &&
        other.priceMinorUnits == priceMinorUnits &&
        other.currencyCode == currencyCode;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      category.hashCode ^
      priceMinorUnits.hashCode ^
      currencyCode.hashCode;
}

/// Result of a quote request.
///
/// Contains the original request and the available options.
@immutable
class RideQuote {
  const RideQuote({
    required this.quoteId,
    required this.request,
    required this.options,
  }) : assert(options.length > 0, 'RideQuote.options must not be empty');

  /// Client-side identifier for this quote.
  final String quoteId;

  /// Request that produced this quote.
  final RideQuoteRequest request;

  /// Available ride options (sorted from "best" to "worst" for display).
  final List<RideQuoteOption> options;

  /// Returns the recommended option, or the first option if none is recommended.
  RideQuoteOption get recommendedOption {
    return options.firstWhere(
      (o) => o.isRecommended,
      orElse: () => options.first,
    );
  }

  /// Returns an option by id, or null if not found.
  RideQuoteOption? optionById(String id) {
    for (final option in options) {
      if (option.id == id) return option;
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RideQuote && other.quoteId == quoteId;
  }

  @override
  int get hashCode => quoteId.hashCode;
}


/// Ride Quote Domain Models - Track B Ticket #13, #63
/// Purpose: Canonical domain models for ride pricing/quotes
/// Created by: Track B - Ticket #13
/// Updated by: Track B - Ticket #63 (RidePriceBreakdown)
/// Last updated: 2025-11-29
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

// ============================================================================
// Price Breakdown Model - Track B Ticket #63
// ============================================================================

/// Detailed breakdown of a ride price.
///
/// This model provides granular pricing components that can be displayed
/// in the trip summary/receipt screen (Screen 10).
///
/// All amounts are in minor units (e.g. 1800 = 18.00 SAR).
///
/// Example:
/// ```dart
/// const breakdown = RidePriceBreakdown(
///   currencyCode: 'SAR',
///   baseFareMinorUnits: 500,       // 5.00 SAR
///   distanceComponentMinorUnits: 800, // 8.00 SAR
///   timeComponentMinorUnits: 200,     // 2.00 SAR
///   feesMinorUnits: 300,              // 3.00 SAR
/// );
/// print(breakdown.totalMinorUnits); // 1800 (18.00 SAR)
/// ```
@immutable
class RidePriceBreakdown {
  /// Creates a price breakdown with all components.
  const RidePriceBreakdown({
    required this.currencyCode,
    required this.baseFareMinorUnits,
    required this.distanceComponentMinorUnits,
    required this.timeComponentMinorUnits,
    required this.feesMinorUnits,
  })  : assert(baseFareMinorUnits >= 0, 'baseFareMinorUnits must be non-negative'),
        assert(distanceComponentMinorUnits >= 0, 'distanceComponentMinorUnits must be non-negative'),
        assert(timeComponentMinorUnits >= 0, 'timeComponentMinorUnits must be non-negative'),
        assert(feesMinorUnits >= 0, 'feesMinorUnits must be non-negative');

  /// ISO-4217 currency code (e.g. 'SAR', 'USD').
  final String currencyCode;

  /// Base fare in minor units (charged regardless of distance/time).
  final int baseFareMinorUnits;

  /// Distance-based charge in minor units.
  final int distanceComponentMinorUnits;

  /// Time-based charge in minor units.
  final int timeComponentMinorUnits;

  /// Fees and surcharges in minor units.
  final int feesMinorUnits;

  /// Total price in minor units (sum of all components).
  int get totalMinorUnits =>
      baseFareMinorUnits + distanceComponentMinorUnits + timeComponentMinorUnits + feesMinorUnits;

  /// Fare subtotal (base + distance + time) without fees.
  int get fareSubtotalMinorUnits =>
      baseFareMinorUnits + distanceComponentMinorUnits + timeComponentMinorUnits;

  /// Formats a minor unit value as display string (e.g. 1850 -> "18.50").
  String _formatMinorUnits(int minorUnits) {
    final major = minorUnits ~/ 100;
    final minor = minorUnits % 100;
    return '$major.${minor.toString().padLeft(2, '0')}';
  }

  /// Formatted base fare (e.g. "5.00").
  String get formattedBaseFare => _formatMinorUnits(baseFareMinorUnits);

  /// Formatted distance component (e.g. "8.00").
  String get formattedDistanceComponent => _formatMinorUnits(distanceComponentMinorUnits);

  /// Formatted time component (e.g. "2.00").
  String get formattedTimeComponent => _formatMinorUnits(timeComponentMinorUnits);

  /// Formatted fees (e.g. "3.00").
  String get formattedFees => _formatMinorUnits(feesMinorUnits);

  /// Formatted total (e.g. "18.00").
  String get formattedTotal => _formatMinorUnits(totalMinorUnits);

  /// Formatted fare subtotal (e.g. "15.00").
  String get formattedFareSubtotal => _formatMinorUnits(fareSubtotalMinorUnits);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RidePriceBreakdown &&
        other.currencyCode == currencyCode &&
        other.baseFareMinorUnits == baseFareMinorUnits &&
        other.distanceComponentMinorUnits == distanceComponentMinorUnits &&
        other.timeComponentMinorUnits == timeComponentMinorUnits &&
        other.feesMinorUnits == feesMinorUnits;
  }

  @override
  int get hashCode => Object.hash(
        currencyCode,
        baseFareMinorUnits,
        distanceComponentMinorUnits,
        timeComponentMinorUnits,
        feesMinorUnits,
      );

  @override
  String toString() =>
      'RidePriceBreakdown(currency: $currencyCode, base: $formattedBaseFare, distance: $formattedDistanceComponent, time: $formattedTimeComponent, fees: $formattedFees, total: $formattedTotal)';
}

// ============================================================================
// Vehicle Category Enum
// ============================================================================

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
    this.priceBreakdown,
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

  /// Detailed price breakdown (Track B - Ticket #63).
  ///
  /// When available, use this for displaying receipt/fare summary.
  /// If null, UI should fall back to [priceMinorUnits] for total.
  final RidePriceBreakdown? priceBreakdown;

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
///
/// Track B - Ticket #121: Now allows empty options to represent "no vehicles
/// available" scenarios. The UI should check `options.isEmpty` and display
/// an appropriate empty state.
@immutable
class RideQuote {
  const RideQuote({
    required this.quoteId,
    required this.request,
    required this.options,
  });

  /// Client-side identifier for this quote.
  final String quoteId;

  /// Request that produced this quote.
  final RideQuoteRequest request;

  /// Available ride options (sorted from "best" to "worst" for display).
  ///
  /// Track B - Ticket #121: May be empty if no vehicles are available.
  final List<RideQuoteOption> options;

  /// Whether any options are available.
  bool get hasOptions => options.isNotEmpty;

  /// Returns the recommended option, or the first option if none is recommended.
  ///
  /// Track B - Ticket #121: Returns null if options is empty.
  RideQuoteOption? get recommendedOption {
    if (options.isEmpty) return null;
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


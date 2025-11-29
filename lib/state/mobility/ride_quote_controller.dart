/// Ride Quote Controller - Track B Ticket #14, #27
/// Purpose: Bridge between UI and RidePricingService from mobility_shims
/// Created by: Track B - Ticket #14
/// Updated by: Track B - Ticket #27 (MockPricingService integration)
/// Last updated: 2025-11-28
///
/// This controller manages the quote fetching lifecycle:
/// - Loading state while fetching
/// - Quote data when successful
/// - Error state when failed
///
/// IMPORTANT:
/// - Uses MockRidePricingService for now (no real backend).
/// - Later, swap ridePricingServiceProvider with real implementation.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// From mobility_shims package (canonical domain models):
import 'package:mobility_shims/mobility_shims.dart';

// From app:
import 'package:delivery_ways_clean/state/mobility/ride_draft_state.dart';

/// UI state for ride quote fetching.
@immutable
class RideQuoteUiState {
  const RideQuoteUiState({
    this.isLoading = false,
    this.quote,
    this.errorMessage,
  });

  /// Whether a quote request is in progress.
  final bool isLoading;

  /// The fetched quote, or null if not yet fetched or failed.
  final RideQuote? quote;

  /// Error message if the last fetch failed.
  final String? errorMessage;

  /// Whether we have a valid quote.
  bool get hasQuote => quote != null;

  /// Whether there's an error with no quote.
  bool get hasError => errorMessage != null && quote == null;

  RideQuoteUiState copyWith({
    bool? isLoading,
    RideQuote? quote,
    String? errorMessage,
    bool clearError = false,
    bool clearQuote = false,
  }) {
    return RideQuoteUiState(
      isLoading: isLoading ?? this.isLoading,
      quote: clearQuote ? null : (quote ?? this.quote),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RideQuoteUiState &&
        other.isLoading == isLoading &&
        other.quote?.quoteId == quote?.quoteId &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode =>
      isLoading.hashCode ^ (quote?.quoteId.hashCode ?? 0) ^ errorMessage.hashCode;

  @override
  String toString() =>
      'RideQuoteUiState(isLoading: $isLoading, hasQuote: $hasQuote, error: $errorMessage)';
}

/// Provides the current implementation of [RidePricingService].
///
/// Track B - Ticket #27: Using MockRidePricingService for pricing.
/// In production, this can be swapped with a real backend-backed implementation.
final ridePricingServiceProvider = Provider<RidePricingService>((ref) {
  return const MockRidePricingService();
});

/// Legacy provider for backward compatibility.
/// @deprecated Use [ridePricingServiceProvider] instead.
final rideQuoteServiceProvider = Provider<RideQuoteService>((ref) {
  return const MockRideQuoteService();
});

/// Controller for managing ride quote fetching.
///
/// Uses [RidePricingService] to fetch quotes based on [RideDraftUiState].
/// Track B - Ticket #27: Now uses MockRidePricingService for pricing logic.
class RideQuoteController extends StateNotifier<RideQuoteUiState> {
  /// Creates a controller with the new [RidePricingService].
  RideQuoteController({
    required RidePricingService pricingService,
  })  : _pricingService = pricingService,
        _legacyService = null,
        super(const RideQuoteUiState());

  /// Legacy constructor for backward compatibility with existing tests.
  /// @deprecated Use the default constructor with [RidePricingService] instead.
  RideQuoteController.legacy(RideQuoteService service)
      : _legacyService = service,
        _pricingService = null,
        super(const RideQuoteUiState());

  final RidePricingService? _pricingService;
  final RideQuoteService? _legacyService;

  /// Fetches a new quote based on the current draft.
  ///
  /// Uses [RidePricingService.quoteRide] when [pickupPlace] and [destinationPlace]
  /// are available (Ticket #27 flow).
  ///
  /// Falls back to legacy behavior if domain places are not set.
  Future<void> refreshFromDraft(RideDraftUiState draft) async {
    // Check if we have MobilityPlace data (Ticket #27 flow)
    final pickup = draft.pickupPlace;
    final destination = draft.destinationPlace;

    if (_pricingService != null && pickup != null && destination != null) {
      // New flow: use RidePricingService with MobilityPlace
      await _refreshWithPricingService(pickup, destination);
    } else if (_legacyService != null) {
      // Legacy flow: use RideQuoteService with destination query
      await _refreshWithLegacyService(draft);
    } else {
      // Fallback: try to use pricing service with synthesized places
      await _refreshWithSynthesizedPlaces(draft);
    }
  }

  /// New pricing flow using [RidePricingService] and [MobilityPlace].
  Future<void> _refreshWithPricingService(
    MobilityPlace pickup,
    MobilityPlace destination,
  ) async {
    state = const RideQuoteUiState(isLoading: true);

    try {
      final quote = await _pricingService!.quoteRide(
        pickup: pickup,
        destination: destination,
        serviceType: RideServiceType.ride, // Return all options
      );

      state = RideQuoteUiState(
        isLoading: false,
        quote: quote,
      );
    } on RidePricingException catch (e) {
      state = RideQuoteUiState(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (e) {
      state = RideQuoteUiState(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Fallback flow: synthesize [MobilityPlace] from draft query.
  ///
  /// This is used when:
  /// - We have [RidePricingService] but no [MobilityPlace] in draft
  /// - Maintains backward compatibility with existing UI
  Future<void> _refreshWithSynthesizedPlaces(RideDraftUiState draft) async {
    final destinationQuery = draft.destinationQuery.trim();

    if (destinationQuery.isEmpty) {
      state = const RideQuoteUiState(
        isLoading: false,
        errorMessage: 'Destination is empty',
      );
      return;
    }

    state = const RideQuoteUiState(isLoading: true);

    try {
      // Synthesize MobilityPlace objects
      final now = DateTime.now();

      // Default pickup (Riyadh)
      final pickupPlace = draft.pickupPlace ??
          MobilityPlace(
            label: draft.pickupLabel,
            location: LocationPoint(
              latitude: 24.7136,
              longitude: 46.6753,
              accuracyMeters: 10,
              timestamp: now,
            ),
          );

      // Synthesize destination based on query length
      final length = destinationQuery.length.clamp(1, 50);
      final delta = length * 0.001;

      final destinationPlace = MobilityPlace(
        label: destinationQuery,
        location: LocationPoint(
          latitude: 24.7136 + delta,
          longitude: 46.6753 + delta,
          accuracyMeters: 10,
          timestamp: now,
        ),
      );

      if (_pricingService != null) {
        final quote = await _pricingService.quoteRide(
          pickup: pickupPlace,
          destination: destinationPlace,
          serviceType: RideServiceType.ride,
        );

        state = RideQuoteUiState(
          isLoading: false,
          quote: quote,
        );
      } else {
        throw const RidePricingException('No pricing service available');
      }
    } on RidePricingException catch (e) {
      state = RideQuoteUiState(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (e) {
      state = RideQuoteUiState(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Legacy flow using [RideQuoteService].
  ///
  /// Maintained for backward compatibility with existing tests.
  Future<void> _refreshWithLegacyService(RideDraftUiState draft) async {
    final destination = draft.destinationQuery.trim();

    if (destination.isEmpty) {
      state = const RideQuoteUiState(
        isLoading: false,
        errorMessage: 'Destination is empty',
      );
      return;
    }

    final request = _buildRequestFromDraft(draft);

    state = const RideQuoteUiState(isLoading: true);

    try {
      final quote = await _legacyService!.getQuote(request);
      state = RideQuoteUiState(
        isLoading: false,
        quote: quote,
      );
    } catch (e) {
      state = RideQuoteUiState(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Clears the current quote state.
  void clear() {
    state = const RideQuoteUiState();
  }

  /// Builds a [RideQuoteRequest] from the UI draft state.
  ///
  /// For legacy service: uses fixed coordinates as pickup and calculates dropoff
  /// based on destination string length.
  RideQuoteRequest _buildRequestFromDraft(RideDraftUiState draft) {
    const baseLat = 24.7136;
    const baseLng = 46.6753;

    final length = draft.destinationQuery.trim().length.clamp(1, 50);
    final delta = length * 0.001;

    final now = DateTime.now();

    final pickup = LocationPoint(
      latitude: baseLat,
      longitude: baseLng,
      accuracyMeters: 10,
      timestamp: now,
    );

    final dropoff = LocationPoint(
      latitude: baseLat + delta,
      longitude: baseLng + delta,
      accuracyMeters: 10,
      timestamp: now,
    );

    return RideQuoteRequest(
      pickup: pickup,
      dropoff: dropoff,
      currencyCode: 'SAR',
    );
  }
}

/// Global provider for ride quote controller.
///
/// Track B - Ticket #27: Uses [RidePricingService] instead of legacy service.
final rideQuoteControllerProvider =
    StateNotifierProvider<RideQuoteController, RideQuoteUiState>((ref) {
  final pricingService = ref.watch(ridePricingServiceProvider);
  return RideQuoteController(pricingService: pricingService);
});

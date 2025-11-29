/// Parcel Quote State + Controller
/// Created by: Track C - Ticket #43
/// Purpose: Manage pricing quote state for parcel shipments
/// Last updated: 2025-11-28

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parcels_shims/parcels_shims.dart';

import 'parcel_draft_state.dart';

/// UI State for parcel pricing quotes.
@immutable
class ParcelQuoteUiState {
  const ParcelQuoteUiState({
    this.isLoading = false,
    this.quote,
    this.errorMessage,
  });

  final bool isLoading;
  final ParcelQuote? quote;
  final String? errorMessage;

  bool get hasQuote => quote != null;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  ParcelQuoteUiState copyWith({
    bool? isLoading,
    ParcelQuote? quote,
    String? errorMessage,
    bool clearError = false,
    bool clearQuote = false,
  }) {
    return ParcelQuoteUiState(
      isLoading: isLoading ?? this.isLoading,
      quote: clearQuote ? null : (quote ?? this.quote),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParcelQuoteUiState &&
        other.isLoading == isLoading &&
        other.quote == quote &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(isLoading, quote, errorMessage);

  @override
  String toString() => 'ParcelQuoteUiState('
      'isLoading: $isLoading, hasQuote: $hasQuote, hasError: $hasError)';
}

/// Provides the pricing service implementation (Mock for now).
/// Track C - Ticket #43: Mock only (no backend integration yet)
final parcelPricingServiceProvider = Provider<ParcelPricingService>((ref) {
  return const MockParcelPricingService(
    baseLatency: Duration(milliseconds: 300),
    failureRate: 0.0,
  );
});

/// Controller for managing parcel quote state.
class ParcelQuoteController extends StateNotifier<ParcelQuoteUiState> {
  ParcelQuoteController({
    required ParcelPricingService pricingService,
  })  : _pricingService = pricingService,
        super(const ParcelQuoteUiState());

  final ParcelPricingService _pricingService;

  /// Refresh quote based on current parcel draft.
  ///
  /// Ticket #43: Uses MockParcelPricingService only (no backend).
  Future<void> refreshFromDraft(ParcelDraftUiState draft) async {
    // Basic validation - missing required fields
    if (draft.size == null ||
        draft.weightText.trim().isEmpty ||
        draft.pickupAddress.trim().isEmpty ||
        draft.dropoffAddress.trim().isEmpty) {
      state = const ParcelQuoteUiState(
        isLoading: false,
        errorMessage: 'Missing required fields for pricing',
      );
      return;
    }

    state = const ParcelQuoteUiState(isLoading: true);

    try {
      // Convert weight to numeric (kg)
      final rawWeight = draft.weightText.trim().replaceAll(',', '.');
      final weightKg = double.tryParse(rawWeight) ?? 1.0;

      // Build domain models for the pricing service
      final pickupAddress = ParcelAddress(label: draft.pickupAddress);
      final dropoffAddress = ParcelAddress(label: draft.dropoffAddress);
      final details = ParcelDetails(
        size: draft.size!,
        weightKg: weightKg,
        description: draft.contentsDescription.isNotEmpty
            ? draft.contentsDescription
            : null,
      );

      final quote = await _pricingService.quoteParcel(
        pickup: pickupAddress,
        dropoff: dropoffAddress,
        details: details,
        serviceType: ParcelServiceType.standard,
      );

      state = ParcelQuoteUiState(
        isLoading: false,
        quote: quote,
      );
    } on ParcelPricingException catch (e) {
      state = ParcelQuoteUiState(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (_) {
      state = const ParcelQuoteUiState(
        isLoading: false,
        errorMessage: 'Unknown pricing error',
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void reset() {
    state = const ParcelQuoteUiState();
  }
}

/// Provider for ParcelQuoteController.
final parcelQuoteControllerProvider =
    StateNotifierProvider<ParcelQuoteController, ParcelQuoteUiState>((ref) {
  final service = ref.watch(parcelPricingServiceProvider);
  return ParcelQuoteController(pricingService: service);
});


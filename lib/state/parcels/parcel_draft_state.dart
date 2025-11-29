/// Parcel Draft UI State
/// Created by: Track C - Ticket #41
/// Purpose: Hold draft data for creating a new parcel shipment
/// Last updated: 2025-11-28 (Ticket #43 - Added selectedQuoteOptionId)

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parcels_shims/parcels_shims.dart' show ParcelSize;

@immutable
class ParcelDraftUiState {
  const ParcelDraftUiState({
    this.pickupAddress = '',
    this.dropoffAddress = '',
    this.size,
    this.weightText = '',
    this.contentsDescription = '',
    this.isFragile = false,
    this.selectedQuoteOptionId, // Track C - Ticket #43
  });

  /// Free-form pickup address text entered by the user.
  final String pickupAddress;

  /// Free-form dropoff/destination address text entered by the user.
  final String dropoffAddress;

  /// Selected parcel size (small / medium / large / oversize).
  final ParcelSize? size;

  /// Free-form weight text entered by the user (e.g. "2.5", "3").
  /// Conversion to numeric types will be handled in a later ticket.
  final String weightText;

  /// Short description of parcel contents.
  final String contentsDescription;

  /// Whether the parcel is fragile (e.g. electronics, glass, etc.).
  final bool isFragile;

  /// Selected pricing option id (e.g. "standard" / "express").
  /// Track C - Ticket #43
  final String? selectedQuoteOptionId;

  ParcelDraftUiState copyWith({
    String? pickupAddress,
    String? dropoffAddress,
    ParcelSize? size,
    bool clearSize = false,
    String? weightText,
    String? contentsDescription,
    bool? isFragile,
    String? selectedQuoteOptionId,
    bool clearSelectedQuoteOptionId = false,
  }) {
    return ParcelDraftUiState(
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      size: clearSize ? null : (size ?? this.size),
      weightText: weightText ?? this.weightText,
      contentsDescription: contentsDescription ?? this.contentsDescription,
      isFragile: isFragile ?? this.isFragile,
      selectedQuoteOptionId: clearSelectedQuoteOptionId
          ? null
          : (selectedQuoteOptionId ?? this.selectedQuoteOptionId),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParcelDraftUiState &&
        other.pickupAddress == pickupAddress &&
        other.dropoffAddress == dropoffAddress &&
        other.size == size &&
        other.weightText == weightText &&
        other.contentsDescription == contentsDescription &&
        other.isFragile == isFragile &&
        other.selectedQuoteOptionId == selectedQuoteOptionId;
  }

  @override
  int get hashCode => Object.hash(
        pickupAddress,
        dropoffAddress,
        size,
        weightText,
        contentsDescription,
        isFragile,
        selectedQuoteOptionId,
      );

  @override
  String toString() => 'ParcelDraftUiState('
      'pickupAddress: $pickupAddress, '
      'dropoffAddress: $dropoffAddress, '
      'size: $size, '
      'weightText: $weightText, '
      'contentsDescription: $contentsDescription, '
      'isFragile: $isFragile, '
      'selectedQuoteOptionId: $selectedQuoteOptionId)';
}

/// Controller for managing parcel draft state.
///
/// Note: This is UI-level only and does not yet map to parcels_shims domain models.
///       Domain mapping will be added in a future ticket.
class ParcelDraftController extends StateNotifier<ParcelDraftUiState> {
  ParcelDraftController() : super(const ParcelDraftUiState());

  void updatePickupAddress(String value) {
    state = state.copyWith(pickupAddress: value);
  }

  void updateDropoffAddress(String value) {
    state = state.copyWith(dropoffAddress: value);
  }

  void updateSize(ParcelSize size) {
    state = state.copyWith(size: size);
  }

  void clearSize() {
    state = state.copyWith(clearSize: true);
  }

  void updateWeightText(String value) {
    state = state.copyWith(weightText: value);
  }

  void updateContentsDescription(String value) {
    state = state.copyWith(contentsDescription: value);
  }

  void toggleFragile() {
    state = state.copyWith(isFragile: !state.isFragile);
  }

  /// Update selected quote option id (or clear when null).
  /// Track C - Ticket #43
  void updateSelectedQuoteOptionId(String? optionId) {
    if (optionId == null) {
      state = state.copyWith(clearSelectedQuoteOptionId: true);
    } else {
      state = state.copyWith(selectedQuoteOptionId: optionId);
    }
  }

  /// Reset draft to initial empty state.
  void reset() {
    state = const ParcelDraftUiState();
  }
}

/// Global provider for ParcelDraftUiState.
final parcelDraftProvider =
    StateNotifierProvider<ParcelDraftController, ParcelDraftUiState>((ref) {
  return ParcelDraftController();
});

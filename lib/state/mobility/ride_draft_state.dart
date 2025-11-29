/// Ride Draft UI State - Track B Ticket #9
/// Purpose: Shared state between RideBookingScreen and RideConfirmationScreen
/// Created by: Track B - Ticket #9
/// Updated by: Track B - Ticket #20 (MobilityPlace integration)
/// Last updated: 2025-11-28
///
/// This state is UI-only and synchronizes user input across the ride booking flow.
///
/// IMPORTANT:
/// - Do NOT use this as a backend/domain model.
/// - Later, this will be mapped to mobility_shims quote / FSM models.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobility_shims/mobility_shims.dart';

/// UI-only state for the current ride draft (not a domain model).
/// This state is used to synchronize RideBookingScreen, RideDestinationScreen,
/// and RideConfirmationScreen.
///
/// IMPORTANT:
/// - Do NOT use this as a backend/domain model.
/// - Later, this will be mapped to mobility_shims quote / FSM models.
@immutable
class RideDraftUiState {
  const RideDraftUiState({
    this.pickupLabel = 'Current location', // purely UI label
    this.destinationQuery = '',
    this.selectedOptionId,
    this.pickupPlace,
    this.destinationPlace,
  });

  /// Human-readable pickup label (e.g. "Current location").
  final String pickupLabel;

  /// Free-text destination query entered by the user.
  final String destinationQuery;

  /// Id of the selected ride option (e.g. 'economy', 'xl', 'premium').
  final String? selectedOptionId;

  /// Domain model for pickup location (Track B - Ticket #20)
  final MobilityPlace? pickupPlace;

  /// Domain model for destination/dropoff location (Track B - Ticket #20)
  final MobilityPlace? destinationPlace;

  RideDraftUiState copyWith({
    String? pickupLabel,
    String? destinationQuery,
    String? selectedOptionId,
    MobilityPlace? pickupPlace,
    MobilityPlace? destinationPlace,
    bool clearPickupPlace = false,
    bool clearDestinationPlace = false,
  }) {
    return RideDraftUiState(
      pickupLabel: pickupLabel ?? this.pickupLabel,
      destinationQuery: destinationQuery ?? this.destinationQuery,
      selectedOptionId: selectedOptionId ?? this.selectedOptionId,
      pickupPlace: clearPickupPlace ? null : (pickupPlace ?? this.pickupPlace),
      destinationPlace: clearDestinationPlace
          ? null
          : (destinationPlace ?? this.destinationPlace),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RideDraftUiState &&
        other.pickupLabel == pickupLabel &&
        other.destinationQuery == destinationQuery &&
        other.selectedOptionId == selectedOptionId &&
        other.pickupPlace == pickupPlace &&
        other.destinationPlace == destinationPlace;
  }

  @override
  int get hashCode => Object.hash(
        pickupLabel,
        destinationQuery,
        selectedOptionId,
        pickupPlace,
        destinationPlace,
      );

  @override
  String toString() =>
      'RideDraftUiState(pickupLabel: $pickupLabel, destinationQuery: $destinationQuery, selectedOptionId: $selectedOptionId, pickupPlace: $pickupPlace, destinationPlace: $destinationPlace)';
}

/// Simple Riverpod StateNotifier for the ride draft.
class RideDraftController extends StateNotifier<RideDraftUiState> {
  RideDraftController() : super(const RideDraftUiState());

  void updateDestination(String query) {
    state = state.copyWith(destinationQuery: query);
  }

  void updateSelectedOption(String optionId) {
    state = state.copyWith(selectedOptionId: optionId);
  }

  void updatePickupLabel(String label) {
    state = state.copyWith(pickupLabel: label);
  }

  /// Update pickup place with domain model (Track B - Ticket #20)
  void updatePickupPlace(MobilityPlace place) {
    state = state.copyWith(
      pickupPlace: place,
      pickupLabel: place.label,
    );
  }

  /// Update destination place with domain model (Track B - Ticket #20)
  void updateDestinationPlace(MobilityPlace place) {
    state = state.copyWith(
      destinationPlace: place,
      destinationQuery: place.label,
    );
  }

  /// Can be used later after a trip is successfully created.
  void clear() {
    state = const RideDraftUiState();
  }
}

/// Global provider for ride draft state.
final rideDraftProvider =
    StateNotifierProvider<RideDraftController, RideDraftUiState>((ref) {
  return RideDraftController();
});


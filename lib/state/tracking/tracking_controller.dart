// Component: Trip Tracking Controller
// Created by: Cursor B-central
// Purpose: Controller for trip tracking with Sale-Only availability awareness
// Last updated: 2025-11-25 (CENT-MOB-TRACKING-001)

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobility_shims/mobility.dart';

import 'package:delivery_ways_clean/state/infra/mobility_availability.dart';
import 'package:delivery_ways_clean/state/infra/mobility_providers.dart';
import 'tracking_state.dart';

/// Controller for managing trip tracking state
class TripTrackingController extends StateNotifier<TrackingState> {
  final TripRecorder _recorder;
  final MobilityAvailabilityService _availabilityService;
  StreamSubscription<LocationPoint>? _locationSub;

  TripTrackingController({
    required TripRecorder recorder,
    required MobilityAvailabilityService availabilityService,
  })  : _recorder = recorder,
        _availabilityService = availabilityService,
        super(const TrackingState.initial()) {
    _initializeAvailability();
  }

  /// Initialize by checking availability status
  Future<void> _initializeAvailability() async {
    try {
      final availability = await _availabilityService.getAvailability();
      state = state.copyWith(
        availabilityStatus: availability.trackingStatus,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        availabilityStatus: TrackingAvailabilityStatus.unavailable,
        errorMessage: 'Failed to check tracking availability',
        isLoading: false,
      );
    }
  }

  /// Begin a new trip
  /// 
  /// Returns early without starting if tracking is not available (Sale-Only).
  Future<void> begin(String tripId) async {
    // Sale-Only: Don't start tracking if not available
    if (!state.isAvailable) {
      state = state.copyWith(
        errorMessage: 'Realtime tracking is not available',
      );
      return;
    }

    if (state.hasActiveTrip) {
      state = state.copyWith(
        errorMessage: 'A trip is already in progress',
      );
      return;
    }

    state = state.copyWith(
      activeTripId: tripId,
      isLoading: true,
      clearErrorMessage: true,
    );

    try {
      await _recorder.beginTrip(tripId);
      _locationSub = _recorder.points.listen(
        _onLocationUpdate,
        onError: _onLocationError,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        clearActiveTripId: true,
        isLoading: false,
        errorMessage: 'Failed to start trip: $e',
      );
    }
  }

  void _onLocationUpdate(LocationPoint location) {
    state = state.copyWith(lastPoint: location);
  }

  void _onLocationError(Object error) {
    state = state.copyWith(
      errorMessage: 'Location error: $error',
    );
  }

  /// End the current trip
  Future<void> end() async {
    await _locationSub?.cancel();
    _locationSub = null;

    try {
      await _recorder.endTrip();
    } finally {
      state = state.copyWith(
        clearActiveTripId: true,
        clearLastPoint: true,
        clearErrorMessage: true,
      );
    }
  }

  /// Refresh availability status
  Future<void> refreshAvailability() async {
    await _initializeAvailability();
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    super.dispose();
  }
}

/// Provider for TripTrackingController
final tripTrackingProvider =
    StateNotifierProvider<TripTrackingController, TrackingState>((ref) {
  final recorder = ref.watch(tripRecorderProvider);
  final availabilityService = ref.watch(mobilityAvailabilityServiceProvider);

  return TripTrackingController(
    recorder: recorder,
    availabilityService: availabilityService,
  );
});

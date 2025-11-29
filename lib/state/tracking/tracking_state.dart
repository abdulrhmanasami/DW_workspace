// Component: Tracking State
// Created by: Cursor B-central
// Purpose: State model for trip tracking with availability awareness
// Last updated: 2025-11-25 (CENT-MOB-TRACKING-001)

import 'package:mobility_shims/mobility.dart';
import '../infra/mobility_availability.dart';

/// State for trip tracking with Sale-Only availability awareness
class TrackingState {
  /// Current availability status for realtime tracking
  final TrackingAvailabilityStatus availabilityStatus;

  /// Active trip ID if a trip is in progress
  final String? activeTripId;

  /// Last known location point
  final LocationPoint? lastPoint;

  /// Error message if tracking failed
  final String? errorMessage;

  /// Whether tracking is currently loading/initializing
  final bool isLoading;

  const TrackingState({
    this.availabilityStatus = TrackingAvailabilityStatus.unknown,
    this.activeTripId,
    this.lastPoint,
    this.errorMessage,
    this.isLoading = false,
  });

  /// Initial state
  const TrackingState.initial()
      : availabilityStatus = TrackingAvailabilityStatus.unknown,
        activeTripId = null,
        lastPoint = null,
        errorMessage = null,
        isLoading = true;

  /// Unavailable state (Sale-Only: no fake data)
  const TrackingState.unavailable()
      : availabilityStatus = TrackingAvailabilityStatus.unavailable,
        activeTripId = null,
        lastPoint = null,
        errorMessage = null,
        isLoading = false;

  /// Check if tracking is available
  bool get isAvailable =>
      availabilityStatus == TrackingAvailabilityStatus.available;

  /// Check if a trip is currently active
  bool get hasActiveTrip => activeTripId != null;

  /// Check if tracking can be started
  bool get canStartTracking => isAvailable && !hasActiveTrip && !isLoading;

  TrackingState copyWith({
    TrackingAvailabilityStatus? availabilityStatus,
    String? activeTripId,
    LocationPoint? lastPoint,
    String? errorMessage,
    bool? isLoading,
    bool clearActiveTripId = false,
    bool clearLastPoint = false,
    bool clearErrorMessage = false,
  }) =>
      TrackingState(
        availabilityStatus: availabilityStatus ?? this.availabilityStatus,
        activeTripId: clearActiveTripId ? null : (activeTripId ?? this.activeTripId),
        lastPoint: clearLastPoint ? null : (lastPoint ?? this.lastPoint),
        errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
        isLoading: isLoading ?? this.isLoading,
      );
}

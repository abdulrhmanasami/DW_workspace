// Component: Mobility Providers
// Created by: Cursor B-mobility
// Purpose: Central Riverpod providers for mobility and maps implementations
// Last updated: 2025-11-25 (CENT-MOB-TRACKING-001)

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Canonical shims (interfaces + no-op fallbacks)
import 'package:mobility_shims/mobility_shims.dart' as shim;
import 'package:maps_shims/maps.dart' as mshim;

// Uplink implementation for data transmission
import 'package:mobility_uplink_impl/mobility_uplink_impl.dart' as uplink;

// Availability service
import 'mobility_availability.dart';

// ============================================================================
// Feature Flags
// ============================================================================

/// Feature flags — can switch to Noop at runtime without code changes.
const _useNoopMobility = bool.fromEnvironment(
  'USE_NOOP_MOBILITY',
  defaultValue: true,
); // Default to NoOp for now
const _useNoopMaps = bool.fromEnvironment(
  'USE_NOOP_MAPS',
  defaultValue: true,
); // Default to NoOp for now

// ============================================================================
// Core Mobility Providers
// ============================================================================

/// Background tracking controller - canonical interface
final backgroundTrackingControllerProvider =
    Provider<shim.BackgroundTrackingController>((ref) {
  if (_useNoopMobility) {
    return const shim.NoOpBackgroundTrackingController();
  }
  // return geo.BackgroundTrackingControllerImpl(); // When real impl is ready
  return const shim.NoOpBackgroundTrackingController(); // Stub for now
});

/// Geofence manager - canonical interface
final geofenceManagerProvider = Provider<shim.GeofenceManager>((ref) {
  if (_useNoopMobility) return const shim.NoOpGeofenceManager();
  // return geo.GeofenceManagerImpl(); // When real impl is ready
  return const shim.NoOpGeofenceManager(); // Stub for now
});

/// Trip recorder - canonical interface
final tripRecorderProvider = Provider<shim.TripRecorder>((ref) {
  if (_useNoopMobility) return const shim.NoOpTripRecorder();
  // return geo.TripRecorderImpl(); // When real impl is ready
  return const shim.NoOpTripRecorder(); // Stub for now
});

/// Maps controller - canonical interface (via alias)
final mapControllerProvider = Provider<mshim.MapController>((ref) {
  if (_useNoopMaps) return const mshim.NoOpMapController();
  // return gmap.GoogleMapControllerAdapter(); // When real impl is ready
  return const mshim.NoOpMapController(); // Stub for now
});

// ============================================================================
// Uplink Providers (CENT-MOB-TRACKING-001)
// ============================================================================

/// Uplink configuration - reads from environment/config
final uplinkConfigProvider = Provider<uplink.UplinkConfig>((ref) {
  // Check if uplink should be enabled based on availability
  final asyncAvailability = ref.watch(mobilityAvailabilityProvider);
  
  final isEnabled = asyncAvailability.maybeWhen(
    data: (availability) => availability.isUplinkEnabled,
    orElse: () => false,
  );

  return uplink.UplinkConfig(
    uplinkEnabled: isEnabled,
    // Other config values use defaults from UplinkConfig
  );
});

/// Uplink service for transmitting location data to backend
final uplinkServiceProvider = Provider<uplink.UplinkService>((ref) {
  final config = ref.watch(uplinkConfigProvider);
  final service = uplink.UplinkService(config);
  
  // Initialize on first access
  service.initialize();
  
  // Dispose when provider is disposed
  ref.onDispose(() => service.dispose());
  
  return service;
});

/// Current uplink queue size (for diagnostics)
final uplinkQueueSizeProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(uplinkServiceProvider);
  return service.getQueueSize();
});

// ============================================================================
// Tracking State Provider (combines availability + trip data)
// ============================================================================

/// Combined tracking state for UI consumption
class TrackingInfo {
  final TrackingAvailabilityStatus availabilityStatus;
  final String? activeTripId;
  final shim.LocationPoint? lastLocation;
  final bool isUplinkActive;

  const TrackingInfo({
    required this.availabilityStatus,
    this.activeTripId,
    this.lastLocation,
    this.isUplinkActive = false,
  });

  bool get isTrackingActive => activeTripId != null;
  bool get canStartTracking =>
      availabilityStatus == TrackingAvailabilityStatus.available;

  const TrackingInfo.unavailable()
      : availabilityStatus = TrackingAvailabilityStatus.unavailable,
        activeTripId = null,
        lastLocation = null,
        isUplinkActive = false;

  const TrackingInfo.loading()
      : availabilityStatus = TrackingAvailabilityStatus.unknown,
        activeTripId = null,
        lastLocation = null,
        isUplinkActive = false;
}

/// Provider for combined tracking info
final trackingInfoProvider = Provider<TrackingInfo>((ref) {
  final availabilityStatus = ref.watch(trackingAvailabilityStatusProvider);
  final uplinkConfig = ref.watch(uplinkConfigProvider);

  return TrackingInfo(
    availabilityStatus: availabilityStatus,
    isUplinkActive: uplinkConfig.uplinkEnabled,
  );
});

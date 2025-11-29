// Component: Realtime Provider
// Created by: Cursor B-central
// Purpose: Riverpod provider for realtime client integration with mobility shims
// Last updated: 2025-11-25 (CENT-MOB-TRACKING-001)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_shims/realtime_shims.dart';
import 'package:mobility_shims/mobility_shims.dart' as shim;

import 'mobility_availability.dart';
import 'mobility_providers.dart';

// ============================================================================
// Realtime Client Provider
// ============================================================================
// Uses NoOpRealtimeClient from realtime_shims package.
// Local NoOp implementations have been removed per CENT-MOB-TRACKING-001.
// ============================================================================

/// Realtime client provider - uses canonical NoOpRealtimeClient from shims
/// 
/// When a real realtime backend is available, this provider should be updated
/// to return the appropriate implementation based on MobilityAvailability.
final realtimeClientProvider = Provider<RealtimeClient>((ref) {
  final availabilityStatus = ref.watch(trackingAvailabilityStatusProvider);
  
  // Sale-Only behavior: if tracking is not available, return NoOp
  if (availabilityStatus != TrackingAvailabilityStatus.available) {
    return const NoOpRealtimeClient();
  }
  
  // When backend is available, still use NoOp until real implementation is ready
  // TODO: Replace with real implementation when backend realtime service is ready
  return const NoOpRealtimeClient();
});

// ============================================================================
// Mobility Realtime Adapter (bridges mobility events to realtime interface)
// ============================================================================

/// Adapter that converts mobility TripEvents to RealtimeEvents
/// This allows the app to use the existing RealtimeClient interface
/// while the actual data comes from mobility shims.
class MobilityRealtimeAdapter {
  final shim.TripRecorder tripRecorder;
  final MobilityAvailabilityService availabilityService;

  MobilityRealtimeAdapter({
    required this.tripRecorder,
    required this.availabilityService,
  });

  /// Watch for location updates on an active trip
  /// Returns empty stream if realtime tracking is not available (Sale-Only)
  Stream<RealtimeEvent> watchTripLocations(String tripId) async* {
    final availability = await availabilityService.getAvailability();
    
    if (!availability.isRealtimeTrackingAvailable) {
      // Sale-Only: return empty stream when tracking unavailable
      return;
    }

    await for (final point in tripRecorder.points) {
      yield RealtimeEvent(
        type: 'location_update',
        data: {
          'tripId': tripId,
          'latitude': point.latitude,
          'longitude': point.longitude,
          'accuracy': point.accuracy,
          'timestamp': point.timestamp?.toIso8601String(),
        },
      );
    }
  }

  /// Check if realtime tracking is currently available
  Future<bool> isTrackingAvailable() async {
    final availability = await availabilityService.getAvailability();
    return availability.isRealtimeTrackingAvailable;
  }
}

/// Provider for MobilityRealtimeAdapter
final mobilityRealtimeAdapterProvider = Provider<MobilityRealtimeAdapter>((ref) {
  final tripRecorder = ref.watch(tripRecorderProvider);
  final availabilityService = ref.watch(mobilityAvailabilityServiceProvider);
  
  return MobilityRealtimeAdapter(
    tripRecorder: tripRecorder,
    availabilityService: availabilityService,
  );
});

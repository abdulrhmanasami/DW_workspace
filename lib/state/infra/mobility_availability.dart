// Component: Mobility Availability
// Created by: Cursor B-central
// Purpose: Sale-Only availability check for realtime tracking features
// Last updated: 2025-11-25

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_shims/foundation_shims.dart' as fnd;
import '../../config/config_manager.dart';
import '../../config/feature_flags.dart';

/// Status indicating whether realtime tracking is available
enum TrackingAvailabilityStatus {
  /// Initial state, not yet determined
  unknown,

  /// Realtime tracking is available and ready
  available,

  /// Realtime tracking is not available (backend not configured or feature disabled)
  unavailable,
}

/// Immutable availability state for mobility features
class MobilityAvailability {
  final bool isRealtimeTrackingAvailable;
  final bool isBackgroundTrackingAvailable;
  final bool isUplinkEnabled;
  final String? unavailabilityReason;

  const MobilityAvailability({
    required this.isRealtimeTrackingAvailable,
    required this.isBackgroundTrackingAvailable,
    required this.isUplinkEnabled,
    this.unavailabilityReason,
  });

  /// No features available
  const MobilityAvailability.unavailable({String? reason})
      : isRealtimeTrackingAvailable = false,
        isBackgroundTrackingAvailable = false,
        isUplinkEnabled = false,
        unavailabilityReason = reason;

  /// All features available
  const MobilityAvailability.available()
      : isRealtimeTrackingAvailable = true,
        isBackgroundTrackingAvailable = true,
        isUplinkEnabled = true,
        unavailabilityReason = null;

  TrackingAvailabilityStatus get trackingStatus =>
      isRealtimeTrackingAvailable
          ? TrackingAvailabilityStatus.available
          : TrackingAvailabilityStatus.unavailable;
}

/// Service interface for checking mobility feature availability
abstract class MobilityAvailabilityService {
  /// Get current availability synchronously (cached value)
  MobilityAvailability get currentAvailability;

  /// Check and return availability (may refresh from config)
  Future<MobilityAvailability> getAvailability();

  /// Stream of availability changes
  Stream<MobilityAvailability> get availabilityStream;
}

/// Implementation that checks config and feature flags
class MobilityAvailabilityServiceImpl implements MobilityAvailabilityService {
  MobilityAvailabilityServiceImpl({
    fnd.ConfigManager? configManager,
  }) : _configManager = configManager ?? ConfigManager.instance;

  final fnd.ConfigManager _configManager;
  MobilityAvailability _cached = const MobilityAvailability.unavailable(
    reason: 'Not initialized',
  );

  @override
  MobilityAvailability get currentAvailability => _cached;

  @override
  Future<MobilityAvailability> getAvailability() async {
    _cached = _computeAvailability();
    return _cached;
  }

  @override
  Stream<MobilityAvailability> get availabilityStream async* {
    // Initial value
    yield await getAvailability();
    // For now, no dynamic updates - availability is determined at startup
  }

  MobilityAvailability _computeAvailability() {
    // Check feature flag first
    if (!FeatureFlags.enableRealtimeTracking) {
      return const MobilityAvailability.unavailable(
        reason: 'Realtime tracking disabled by feature flag',
      );
    }

    // Check backend availability (fail-closed)
    if (!AppConfig.canUseBackendFeature()) {
      return const MobilityAvailability.unavailable(
        reason: 'Backend services not configured',
      );
    }

    // Check if uplink endpoint is configured
    final uplinkEndpoint = _configManager.getString('mobility.uplink.endpoint');
    final isUplinkConfigured =
        uplinkEndpoint != null && uplinkEndpoint.isNotEmpty;

    // Even if uplink is not configured, we allow tracking if backend is available
    // The uplink just won't send data
    return MobilityAvailability(
      isRealtimeTrackingAvailable: true,
      isBackgroundTrackingAvailable: true,
      isUplinkEnabled: isUplinkConfigured,
      unavailabilityReason: null,
    );
  }
}

/// No-op implementation for when mobility is completely disabled
class NoOpMobilityAvailabilityService implements MobilityAvailabilityService {
  const NoOpMobilityAvailabilityService();

  @override
  MobilityAvailability get currentAvailability =>
      const MobilityAvailability.unavailable(
        reason: 'Mobility services disabled',
      );

  @override
  Future<MobilityAvailability> getAvailability() async => currentAvailability;

  @override
  Stream<MobilityAvailability> get availabilityStream async* {
    yield currentAvailability;
  }
}

/// Provider for MobilityAvailabilityService
final mobilityAvailabilityServiceProvider =
    Provider<MobilityAvailabilityService>((ref) {
  // Use real implementation - it will check flags and config internally
  return MobilityAvailabilityServiceImpl();
});

/// Provider for current availability state
final mobilityAvailabilityProvider = FutureProvider<MobilityAvailability>((ref) {
  final service = ref.watch(mobilityAvailabilityServiceProvider);
  return service.getAvailability();
});

/// Provider for tracking availability status (convenience)
final trackingAvailabilityStatusProvider =
    Provider<TrackingAvailabilityStatus>((ref) {
  final asyncAvailability = ref.watch(mobilityAvailabilityProvider);
  return asyncAvailability.when(
    data: (availability) => availability.trackingStatus,
    loading: () => TrackingAvailabilityStatus.unknown,
    error: (_, __) => TrackingAvailabilityStatus.unavailable,
  );
});


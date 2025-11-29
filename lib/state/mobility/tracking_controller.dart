// Tracking Controller - Session Management with Maps Integration
// Created by: Cursor B-mobility
// Purpose: Complete tracking session lifecycle with consent/kill-switch enforcement
// Last updated: 2025-11-14

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_shims/foundation_shims.dart' as fnd;
import 'package:foundation_shims/providers/remote_config_providers.dart' as rc;
export 'package:mobility_shims/mobility.dart' show TrackingSessionState;
import 'package:mobility_shims/mobility.dart' as mob;
import 'package:mobility_uplink_impl/mobility_uplink_impl.dart';

import '../infra/triprecorder_provider.dart';

// Provider for uplink service - defined here since it's not in mobility_shims
final uplinkServiceProvider = Provider<UplinkService>((ref) {
  // Return a stub implementation for now - disabled uplink
  return UplinkService(const UplinkConfig(uplinkEnabled: false));
});

// Tracking controller with full session management
class TrackingController extends StateNotifier<mob.TrackingSessionState> {
  final Ref _ref;

  StreamSubscription<mob.LocationPoint>? _pointSubscription;
  mob.BackgroundTracker? _backgroundTracker;
  mob.TripRecorder? _tripRecorder;
  UplinkService? _uplinkService;

  TrackingController(this._ref)
    : super(const mob.TrackingSessionState(status: mob.TrackingStatus.stopped));

  // Initialize and check permissions
  Future<void> init() async {
    try {
      final locationProviderInstance = _ref.read(mob.locationProvider);
      final permission = await locationProviderInstance.requestPermission();
      final serviceEnabled = await locationProviderInstance.serviceEnabled();

      state = state.copyWith(
        permission: permission,
        errorMessage: !serviceEnabled ? 'خدمة تحديد الموقع غير مفعلة' : null,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'فشل في تهيئة التتبع: $e',
        status: mob.TrackingStatus.error,
      );
    }
  }

  // Start tracking session
  Future<void> start() async {
    if (state.status == mob.TrackingStatus.running) return;

    try {
      // Check consent and kill-switch
      final trackingEnabled = _ref.read(mob.mobilityConfigProvider);
      final consentGranted = _ref.read(mob.consentBackgroundLocationProvider);

      if (!trackingEnabled) {
        throw mob.TrackingDisabledException('التتبع معطل عبر إعدادات النظام');
      }

      if (!consentGranted) {
        throw mob.ConsentDeniedException('لم يتم منح موافقة تتبع الموقع');
      }

      // Check permissions
      final locationProvider = _ref.read(mob.locationProvider);
      final serviceEnabled = await locationProvider.serviceEnabled();

      if (!serviceEnabled) {
        throw mob.PermissionDeniedException('خدمة تحديد الموقع غير مفعلة');
      }

      final sessionId = DateTime.now().millisecondsSinceEpoch.toString();

      state = state.copyWith(
        status: mob.TrackingStatus.starting,
        errorMessage: null,
        sessionId: sessionId,
      );

      // Start background tracking if available
      final backgroundTracker = _ref.read(mob.backgroundTrackerProvider);
      await backgroundTracker.start();

      // Begin trip recording
      final tripRecorder = _ref.read(tripRecorderProvider);
      await tripRecorder.beginTrip(sessionId);

      // Get uplink service
      final uplinkService = _ref.read(uplinkServiceProvider);

      _pointSubscription = tripRecorder.points.listen(
        (point) async {
          state = state.copyWith(
            lastPoint: point,
            lastUpdate: DateTime.now(),
            status: mob.TrackingStatus.running,
          );

          final activeSessionId = state.sessionId;
          if (activeSessionId != null) {
            await uplinkService.enqueue(point, activeSessionId);
          }
        },
        onError: (error) {
          state = state.copyWith(
            errorMessage: 'خطأ في التتبع: $error',
            status: mob.TrackingStatus.error,
          );
        },
      );

      // Store references for cleanup
      _tripRecorder = tripRecorder;
      _backgroundTracker = backgroundTracker;
      _uplinkService = uplinkService;

      // Mark as running once setup is complete
      state = state.copyWith(status: mob.TrackingStatus.running);
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        status: mob.TrackingStatus.error,
      );
      rethrow;
    }
  }

  // Stop tracking session
  Future<void> stop() async {
    try {
      await _uplinkService?.flush(force: true);
      await _tripRecorder?.endTrip();
      await _pointSubscription?.cancel();
      _pointSubscription = null;

      await _backgroundTracker?.stop();
      _tripRecorder = null;

      state = state.copyWith(
        status: mob.TrackingStatus.stopped,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'خطأ في إيقاف التتبع: $e',
        status: mob.TrackingStatus.error,
      );
      rethrow;
    }
  }

  @override
  void dispose() {
    _pointSubscription?.cancel();
    unawaited(_tripRecorder?.endTrip());
    _backgroundTracker?.stop();
    super.dispose();
  }
}

// Providers
final trackingControllerProvider =
    StateNotifierProvider<TrackingController, mob.TrackingSessionState>(
      (ref) => TrackingController(ref),
    );

final trackingConfigProvider = Provider<TrackingConfig>((ref) {
  final remoteConfig = ref.watch(rc.remoteConfigProvider);

  final sampleInterval = remoteConfig.getInt(
    fnd.RemoteConfigKeys.trackingSampleIntervalMs,
    defaultValue: 5000,
  );
  final accuracy = remoteConfig.getString(
    fnd.RemoteConfigKeys.trackingAccuracy,
    defaultValue: fnd.TrackingAccuracyValues.balanced,
  );
  final mode = remoteConfig.getString(
    fnd.RemoteConfigKeys.trackingMode,
    defaultValue: fnd.TrackingModeValues.auto,
  );

  return TrackingConfig(
    sampleIntervalMs: sampleInterval,
    accuracy: accuracy,
    mode: mode,
  );
});

// Tracking configuration from RemoteConfig
class TrackingConfig {
  final int sampleIntervalMs;
  final String accuracy;
  final String mode;

  const TrackingConfig({
    required this.sampleIntervalMs,
    required this.accuracy,
    required this.mode,
  });

  @override
  String toString() =>
      'TrackingConfig(interval: ${sampleIntervalMs}ms, accuracy: $accuracy, mode: $mode)';
}

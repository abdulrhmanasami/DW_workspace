/// Component: Mobility Binding - Riverpod Overrides
/// Created by: Cursor B-mobility
/// Purpose: Centralized provider overrides for mobility services with consent/kill-switch enforcement
/// Last updated: 2025-11-24

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobility_adapter_geolocator/mobility_adapter_geolocator.dart';
import 'package:mobility_shims/mobility.dart';

/// Mobility provider overrides for Riverpod
/// Add these to ProviderScope in main.dart or app_providers.dart
final mobilityOverrides = <Override>[
  // Location provider with consent/kill-switch enforcement
  locationProvider.overrideWith((ref) {
    final trackingEnabled = ref.watch(mobilityConfigProvider);
    final consentGranted = ref.watch(consentBackgroundLocationProvider);

    if (!trackingEnabled) {
      return const _DisabledLocationProvider(
        reason: 'Tracking disabled via remote config',
        consentDenied: false,
      );
    }

    if (!consentGranted) {
      return const _DisabledLocationProvider(
        reason: 'Background location consent not granted',
        consentDenied: true,
      );
    }

    final source = GeolocatorLocationSource();
    return _GeolocatorLocationProvider(source);
  }),

  // Background tracker with consent/kill-switch enforcement
  backgroundTrackerProvider.overrideWith((ref) {
    final trackingEnabled = ref.watch(mobilityConfigProvider);
    final consentGranted = ref.watch(consentBackgroundLocationProvider);

    if (!trackingEnabled || !consentGranted) {
      return const _DisabledBackgroundTracker();
    }

    unawaited(WorkmanagerBackgroundTracker.initialize());
    final tracker = WorkmanagerBackgroundTracker();
    return _WorkmanagerBackgroundTrackerAdapter(tracker);
  }),
];

class _GeolocatorLocationProvider implements LocationProvider {
  _GeolocatorLocationProvider(this._source);

  final GeolocatorLocationSource _source;

  static const _defaultSettings = PositionSettings(
    distanceFilterMeters: 10,
    interval: Duration(seconds: 5),
  );

  @override
  Stream<LocationPoint> watch() {
    return _source
        .positionStream(_defaultSettings)
        .map(_positionFixToLocationPoint);
  }

  @override
  Future<LocationPoint> getCurrent() async {
    final position = await _source.getCurrentPosition();
    return _positionFixToLocationPoint(position);
  }

  @override
  Future<PermissionStatus> requestPermission() async {
    final permission = await _source.requestPermission();
    return _mapPermission(permission);
  }

  @override
  Future<bool> serviceEnabled() => _source.isServiceEnabled();

  LocationPoint _positionFixToLocationPoint(PositionFix fix) {
    return LocationPoint(
      latitude: fix.lat,
      longitude: fix.lng,
      accuracyMeters: fix.accuracy,
      timestamp: fix.timestamp,
    );
  }

  PermissionStatus _mapPermission(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.denied:
        return PermissionStatus.denied;
      case LocationPermission.deniedForever:
        return PermissionStatus.permanentlyDenied;
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return PermissionStatus.granted;
    }
  }
}

class _DisabledLocationProvider implements LocationProvider {
  const _DisabledLocationProvider({
    required this.reason,
    required this.consentDenied,
  });

  final String reason;
  final bool consentDenied;

  @override
  Stream<LocationPoint> watch() {
    return Stream<LocationPoint>.error(_buildException());
  }

  @override
  Future<LocationPoint> getCurrent() async {
    throw _buildException();
  }

  @override
  Future<PermissionStatus> requestPermission() async {
    return consentDenied ? PermissionStatus.denied : PermissionStatus.restricted;
  }

  @override
  Future<bool> serviceEnabled() async => false;

  Exception _buildException() {
    return consentDenied
        ? ConsentDeniedException(reason)
        : TrackingDisabledException(reason);
  }
}

class _WorkmanagerBackgroundTrackerAdapter implements BackgroundTracker {
  _WorkmanagerBackgroundTrackerAdapter(this._tracker);

  final WorkmanagerBackgroundTracker _tracker;

  @override
  Future<void> start() => _tracker.startTracking();

  @override
  Future<void> stop() => _tracker.stopTracking();

  @override
  Stream<TrackingStatus> status() => _tracker.isTrackingStream
      .map(
        (isRunning) =>
            isRunning ? TrackingStatus.running : TrackingStatus.stopped,
      )
      .distinct();
}

class _DisabledBackgroundTracker implements BackgroundTracker {
  const _DisabledBackgroundTracker();

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Stream<TrackingStatus> status() =>
      Stream<TrackingStatus>.value(TrackingStatus.stopped);
}

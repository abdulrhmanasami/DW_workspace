// ignore_for_file: dangling_library_doc_comments
/// Component: Background Controller Implementation
/// Created by: Cursor (auto-generated)
/// Purpose: Background location tracking using flutter_background_geolocation
/// Last updated: 2025-11-11

import 'dart:async';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:mobility_shims/mobility.dart';

/// Background location tracking implementation using flutter_background_geolocation
class BackgroundControllerImpl {
  final StreamController<LocationPoint> _locationStreamController =
      StreamController<LocationPoint>.broadcast();

  bool _isInitialized = false;

  BackgroundControllerImpl() {
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;

    // Configure background geolocation
    await bg.BackgroundGeolocation.ready(bg.Config(
      desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
      distanceFilter: 10.0, // Update every 10 meters
      stopOnTerminate: false,
      startOnBoot: false,
      debug: false,
      logLevel: bg.Config.LOG_LEVEL_OFF,
      notification: bg.Notification(
        title: 'Location Tracking',
        text: 'Tracking your location for delivery services',
        channelName: 'Location Tracking',
      ),
    ));

    // Listen to location updates
    bg.BackgroundGeolocation.onLocation((bg.Location location) {
      final locationPoint = LocationPoint(
        latitude: location.coords.latitude,
        longitude: location.coords.longitude,
        altitude: location.coords.altitude,
        accuracy: location.coords.accuracy,
        speed: location.coords.speed,
        bearing: location.coords.heading,
        timestamp: DateTime.parse(location.timestamp),
      );

      _locationStreamController.add(locationPoint);
    });

    _isInitialized = true;
  }

    Future<void> startForeground() async {
    await _initialize();
    await bg.BackgroundGeolocation.start();
  }

    Future<void> stop() async {
    await bg.BackgroundGeolocation.stop();
  }

    Stream<LocationPoint> points() => _locationStreamController.stream;

  /// Dispose resources
  void dispose() {
    _locationStreamController.close();
  }
}

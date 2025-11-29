import 'dart:async';

import 'background_contracts.dart';
import '../location/models.dart';
import 'location_service.dart';

/// Component: Geolocation Port
/// Created by: Cursor (auto-generated)
/// Purpose: Production-grade geolocation interface for platform-agnostic location services
/// Last updated: 2025-11-02

/// Port interface for geolocation services
/// This provides a clean abstraction over platform-specific location APIs
abstract class GeolocationPort {
  /// Starts location tracking
  /// Returns a stream of location updates
  Future<Stream<LocationPoint>> startTracking({
    LocationAccuracy desiredAccuracy = LocationAccuracy.high,
    Duration updateInterval = const Duration(seconds: 1),
  });

  /// Stops location tracking
  Future<void> stopTracking();

  /// Gets the current location once
  Future<LocationPoint> getCurrentLocation({
    LocationAccuracy desiredAccuracy = LocationAccuracy.high,
  });

  /// Checks if location services are enabled on the device
  Future<bool> isLocationServiceEnabled();

  /// Checks if location permissions are granted
  Future<LocationPermissionStatus> checkPermissionStatus();

  /// Requests location permissions from the user
  Future<LocationPermissionStatus> requestPermission();

  /// Gets the current tracking status
  Future<TrackingStatus> getTrackingStatus();
}

/// Location accuracy levels
enum LocationAccuracy {
  /// Lowest power consumption, least accurate (~10km)
  low,

  /// Balanced power and accuracy (~100m)
  medium,

  /// High accuracy, higher power consumption (~10m)
  high,

  /// Highest accuracy available (~1m), highest power consumption
  best,
}

/// Location permission status
enum LocationPermissionStatus {
  /// Permission granted
  granted,

  /// Permission denied
  denied,

  /// Permission permanently denied (user selected "Don't ask again")
  permanentlyDenied,

  /// Permission restricted (e.g., parental controls)
  restricted,

  /// Permission not determined yet
  notDetermined,
}

/// Configuration for geolocation tracking
class GeolocationConfig {
  final LocationAccuracy accuracy;
  final Duration updateInterval;
  final double
  distanceFilter; // Minimum distance change to trigger update (meters)
  final bool enableBackgroundTracking;
  final bool enableHeadingUpdates;

  const GeolocationConfig({
    this.accuracy = LocationAccuracy.high,
    this.updateInterval = const Duration(seconds: 1),
    this.distanceFilter = 5.0, // 5 meters
    this.enableBackgroundTracking = false,
    this.enableHeadingUpdates = false,
  });

  /// Creates a config optimized for battery efficiency
  factory GeolocationConfig.powerEfficient() {
    return const GeolocationConfig(
      accuracy: LocationAccuracy.medium,
      updateInterval: Duration(seconds: 30),
      distanceFilter: 50.0,
    );
  }

  /// Creates a config optimized for high accuracy
  factory GeolocationConfig.highAccuracy() {
    return const GeolocationConfig(
      accuracy: LocationAccuracy.best,
      updateInterval: Duration(milliseconds: 500),
      distanceFilter: 1.0,
    );
  }
}

/// Extension methods for GeolocationPort
extension GeolocationPortExtensions on GeolocationPort {
  /// Starts tracking with a configuration object
  Future<Stream<LocationPoint>> startTrackingWithConfig(
    GeolocationConfig config,
  ) {
    return startTracking(
      desiredAccuracy: config.accuracy,
      updateInterval: config.updateInterval,
    );
  }
}

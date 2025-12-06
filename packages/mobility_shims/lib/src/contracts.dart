// Mobility Contracts - Abstract Interfaces
// Created by: Cursor B-mobility
// Purpose: Core abstract interfaces for mobility operations
// Last updated: 2025-11-13

import 'package:mobility_shims/location/models.dart' show LocationPoint;
import 'background_contracts.dart' show TrackingStatus, PermissionStatus;

/// Abstract location provider interface
abstract class LocationProvider {
  /// Watch location changes as a stream
  Stream<LocationPoint> watch();

  /// Get current location once
  Future<LocationPoint> getCurrent();

  /// Request location permission
  Future<PermissionStatus> requestPermission();

  /// Check if location service is enabled
  Future<bool> serviceEnabled();
}

/// Abstract background tracker interface
abstract class BackgroundTracker {
  /// Start background tracking
  Future<void> start();

  /// Stop background tracking
  Future<void> stop();

  /// Get tracking status stream
  Stream<TrackingStatus> status();
}

/// Exception thrown when location consent is denied
class ConsentDeniedException implements Exception {
  final String message;

  ConsentDeniedException(this.message);

  @override
  String toString() => 'ConsentDeniedException: $message';
}

/// Exception thrown when tracking is disabled via kill-switch
class TrackingDisabledException implements Exception {
  final String message;

  TrackingDisabledException(this.message);

  @override
  String toString() => 'TrackingDisabledException: $message';
}

/// Exception thrown when location permission is denied
class PermissionDeniedException implements Exception {
  final String message;

  PermissionDeniedException(this.message);

  @override
  String toString() => 'PermissionDeniedException: $message';
}

// Background Workmanager Tracker Implementation
// Created by: Cursor B-mobility
// Purpose: Workmanager-based implementation of BackgroundTracker with platform guards
// Last updated: 2025-11-16
// Note: Isolated from mobility_shims to prevent platform-specific code compilation

import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:mobility_shims/mobility.dart';

/// Background task unique name
const String _backgroundLocationTask = 'com.deliveryways.background_location';

/// Stream controller for tracking status
StreamController<TrackingStatus>? _statusController;

/// Background task callback - called by Workmanager
@pragma('vm:entry-point')
void backgroundLocationCallback() {
  // Platform guard - this callback should only run on Android
  if (!Platform.isAndroid) {
    debugPrint(
        'Background location callback called on unsupported platform: ${Platform.operatingSystem}');
    return;
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      // On Android, we can use Workmanager for periodic background tasks
      Workmanager().executeTask((task, inputData) async {
        // TODO: Implement actual background location collection
        // This would typically:
        // 1. Get current location using Geolocator
        // 2. Store/send the location data
        // 3. Return true for success, false for failure

        // For now, just log that we're running
        debugPrint('Background location task executed at ${DateTime.now()}');

        // Update status
        _statusController?.add(TrackingStatus.running);

        return true;
      });
      break;

    case TargetPlatform.iOS:
      // On iOS, background processing is more limited
      // If background capabilities are not configured, this becomes no-op
      debugPrint('Background location task called on iOS - limited support');
      break;

    default:
      // Other platforms - no-op
      debugPrint('Background location task not supported on this platform');
      break;
  }
}

/// Workmanager-based implementation of BackgroundTrackingController
class WorkmanagerBackgroundTracker {
  WorkmanagerBackgroundTracker() {
    // Platform guard - only initialize on Android
    if (!Platform.isAndroid && !kIsWeb) {
      debugPrint(
          'WorkmanagerBackgroundTracker: Unsupported platform ${Platform.operatingSystem}, using no-op');
      return;
    }

    _statusController ??= StreamController<TrackingStatus>.broadcast();
    _statusController!.add(TrackingStatus.stopped);
  }

    Future<bool> get isTracking async {
    // Platform guard
    if (!Platform.isAndroid && !kIsWeb) return false;

    // TODO: Check actual workmanager task status
    return _statusController?.hasListener ?? false;
  }

    Stream<bool> get isTrackingStream {
    // Platform guard
    if (!Platform.isAndroid && !kIsWeb) return Stream.value(false);

    return (_statusController?.stream ?? Stream.value(TrackingStatus.stopped))
        .map((status) => status == TrackingStatus.running);
  }

    Future<void> startTracking() async {
    // Platform guard
    if (!Platform.isAndroid && !kIsWeb) {
      debugPrint(
          'startTracking: Unsupported platform ${Platform.operatingSystem}');
      return;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Register periodic background task
        await Workmanager().registerPeriodicTask(
          _backgroundLocationTask,
          _backgroundLocationTask,
          frequency: const Duration(minutes: 15), // Every 15 minutes
          constraints: Constraints(
            networkType: NetworkType.connected, // Require network
          ),
        );

        _statusController?.add(TrackingStatus.running);
        break;

      case TargetPlatform.iOS:
        // iOS has limited background processing
        // Background location updates require specific capabilities in Info.plist
        // If not configured, this becomes safe no-op to prevent crashes
        debugPrint(
          'Background tracking on iOS: Safe no-op (requires location background capabilities)',
        );

        // iOS background location tracking is complex and requires:
        // 1. Background location capability in Xcode
        // 2. UIBackgroundModes: location in Info.plist
        // 3. User permission set to "Always"
        // For now, treat as unsupported to be safe
        _statusController?.add(TrackingStatus.stopped);
        break;

      default:
        // Other platforms - no-op
        debugPrint('Background tracking not supported on this platform');
        _statusController?.add(TrackingStatus.stopped);
        break;
    }
  }

    Future<void> stopTracking() async {
    // Platform guard
    if (!Platform.isAndroid && !kIsWeb) {
      debugPrint(
          'stopTracking: Unsupported platform ${Platform.operatingSystem}');
      return;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Cancel the background task
        await Workmanager().cancelByUniqueName(_backgroundLocationTask);
        _statusController?.add(TrackingStatus.stopped);
        break;

      case TargetPlatform.iOS:
        // iOS background task management - safe no-op
        _statusController?.add(TrackingStatus.stopped);
        break;

      default:
        // Other platforms - no-op
        _statusController?.add(TrackingStatus.stopped);
        break;
    }
  }

  /// Initialize Workmanager (call this in app startup)
  static Future<void> initialize() async {
    // Platform guard - only initialize on Android
    if (!Platform.isAndroid && !kIsWeb) {
      debugPrint(
          'Workmanager initialization skipped on platform: ${Platform.operatingSystem}');
      return;
    }

    await Workmanager().initialize(
      backgroundLocationCallback,
      // ignore: deprecated_member_use
      isInDebugMode: kDebugMode,
    );
  }
}

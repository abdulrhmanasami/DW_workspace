/// Component: Background Tracking Controller
/// Created by: Cursor B-mobility
/// Purpose: Interface for background location tracking management
/// Last updated: 2025-11-16

import 'background_contracts.dart';

abstract class BackgroundTrackingController {
  Stream<TrackingSessionState> get state;
  Future<void> startForeground();
  Future<void> stop();
}

/// No-Op implementation for safe fallback when background tracking is not available
class NoOpBackgroundTrackingController implements BackgroundTrackingController {
  const NoOpBackgroundTrackingController();

  @override
  Stream<TrackingSessionState> get state =>
      const Stream<TrackingSessionState>.empty();

  @override
  Future<void> startForeground() async {
    // No-op: Background tracking not available
  }

  @override
  Future<void> stop() async {
    // No-op: Background tracking not available
  }
}

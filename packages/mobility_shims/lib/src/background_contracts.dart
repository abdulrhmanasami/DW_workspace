import 'package:mobility_shims/location/models.dart' show LocationPoint;

/// Permission status for location services
enum PermissionStatus {
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

/// Canonical tracking status shared across mobility layers.
enum TrackingStatus {
  /// Tracking is fully stopped.
  stopped,

  /// Tracker is initializing sensors/services.
  starting,

  /// Tracker is actively streaming location updates.
  running,

  /// Tracker is temporarily paused but can resume without re-init.
  paused,

  /// Tracker encountered a fatal error and requires manual recovery.
  error,
}

/// Immutable representation of the current tracking session.
class TrackingSessionState {
  final TrackingStatus status;
  final LocationPoint? lastPoint;
  final PermissionStatus? permission;
  final String? sessionId;
  final String? errorMessage;
  final DateTime? lastUpdate;

  const TrackingSessionState({
    required this.status,
    this.lastPoint,
    this.permission,
    this.sessionId,
    this.errorMessage,
    this.lastUpdate,
  });

  TrackingSessionState copyWith({
    TrackingStatus? status,
    LocationPoint? lastPoint,
    PermissionStatus? permission,
    String? sessionId,
    String? errorMessage,
    DateTime? lastUpdate,
  }) {
    return TrackingSessionState(
      status: status ?? this.status,
      lastPoint: lastPoint ?? this.lastPoint,
      permission: permission ?? this.permission,
      sessionId: sessionId ?? this.sessionId,
      errorMessage: errorMessage ?? this.errorMessage,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  @override
  String toString() =>
      'TrackingSessionState('
      'status: $status, lastPoint: $lastPoint, permission: $permission, '
      'sessionId: $sessionId, errorMessage: $errorMessage, lastUpdate: $lastUpdate)';
}

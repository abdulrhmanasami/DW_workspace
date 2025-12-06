import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobility_shims/location/location_source.dart';
import 'package:mobility_shims/location/location_permissions.dart';
import 'package:mobility_shims/src/background_tracking_controller.dart';
import 'package:mobility_shims/src/geofence_contracts.dart';
import 'package:mobility_shims/src/trips_contracts.dart';

// Location services
final locationSourceProvider = Provider<LocationSource>(
  (_) => throw UnimplementedError('Bind adapter in app layer'),
);

final locationServiceProvider = Provider<LocationService>(
  (_) => throw UnimplementedError('Bind adapter in app layer'),
);

final locationPermissionServiceProvider = Provider<LocationPermissionService>(
  (_) => throw UnimplementedError('Bind adapter in app layer'),
);

// Background tracking
final backgroundTrackingControllerProvider =
    Provider<BackgroundTrackingController>(
      (_) => throw UnimplementedError('Bind adapter in app layer'),
    );

// Geofence management
final geofenceManagerProvider = Provider<GeofenceManager>(
  (_) => throw UnimplementedError('Bind adapter in app layer'),
);

// Trip recording
final tripRecorderProvider = Provider<TripRecorder>(
  (_) => throw UnimplementedError('Bind adapter in app layer'),
);

// Legacy provider name for backward compatibility
final locationProvider = locationSourceProvider;

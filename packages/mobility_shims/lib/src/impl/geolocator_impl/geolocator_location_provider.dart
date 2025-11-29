// Geolocator Location Provider Implementation
// Created by: Cursor B-mobility
// Purpose: Geolocator-based implementation of LocationProvider
// Last updated: 2025-11-13

import 'package:geolocator/geolocator.dart' as geo;

import '../../background_contracts.dart';
import '../../contracts.dart';
import '../../location/models.dart';

/// Converts Geolocator Position to LocationPoint
LocationPoint _positionToLocationPoint(geo.Position position) {
  return LocationPoint(
    latitude: position.latitude,
    longitude: position.longitude,
    accuracyMeters: position.accuracy,
    altitudeMeters: position.altitude,
    speedMetersPerSecond: position.speed,
    timestamp: position.timestamp,
  );
}

/// Converts Geolocator permission to PermissionStatus
PermissionStatus _geolocatorPermissionToPermissionStatus(
  geo.LocationPermission permission,
) {
  switch (permission) {
    case geo.LocationPermission.denied:
      return PermissionStatus.denied;
    case geo.LocationPermission.deniedForever:
      return PermissionStatus.permanentlyDenied;
    case geo.LocationPermission.whileInUse:
    case geo.LocationPermission.always:
      return PermissionStatus.granted;
    case geo.LocationPermission.unableToDetermine:
      return PermissionStatus.notDetermined;
    case geo.LocationPermission.restricted:
      return PermissionStatus.restricted;
  }
}

/// Geolocator-based implementation of LocationProvider
class GeolocatorLocationProvider implements LocationProvider {
  const GeolocatorLocationProvider();

  @override
  Stream<LocationPoint> watch() {
    const locationSettings = geo.LocationSettings(
      accuracy: geo.LocationAccuracy.high,
      distanceFilter: 10, // Minimum distance change for updates
    );

    return geo.Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).map(_positionToLocationPoint);
  }

  @override
  Future<LocationPoint> getCurrent() async {
    final position = await geo.Geolocator.getCurrentPosition(
      desiredAccuracy: geo.LocationAccuracy.high,
    );
    return _positionToLocationPoint(position);
  }

  @override
  Future<PermissionStatus> requestPermission() async {
    final permission = await geo.Geolocator.requestPermission();
    return _geolocatorPermissionToPermissionStatus(permission);
  }

  @override
  Future<bool> serviceEnabled() async {
    return await geo.Geolocator.isLocationServiceEnabled();
  }
}

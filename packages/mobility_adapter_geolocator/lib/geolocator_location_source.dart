import 'dart:io' show Platform;
import 'package:geolocator/geolocator.dart' as g;
import 'package:mobility_shims/mobility.dart';

LocationPermission _mapPerm(g.LocationPermission p) => switch (p) {
      g.LocationPermission.denied => LocationPermission.denied,
      g.LocationPermission.deniedForever => LocationPermission.deniedForever,
      g.LocationPermission.whileInUse => LocationPermission.whileInUse,
      g.LocationPermission.always => LocationPermission.always,
      _ => LocationPermission.denied,
    };

PositionFix _mapPos(g.Position p) => PositionFix(
      lat: p.latitude,
      lng: p.longitude,
      accuracy: p.accuracy,
      timestamp: p.timestamp ?? DateTime.now(),
    );

class GeolocatorLocationSource implements LocationSource {
  @override
  Future<bool> isServiceEnabled() => g.Geolocator.isLocationServiceEnabled();

  @override
  Future<LocationPermission> checkPermission() async =>
      _mapPerm(await g.Geolocator.checkPermission());

  @override
  Future<LocationPermission> requestPermission() async =>
      _mapPerm(await g.Geolocator.requestPermission());

  @override
  Future<PositionFix> getCurrentPosition() async =>
      _mapPos(await g.Geolocator.getCurrentPosition());

  @override
  Stream<PositionFix> positionStream(PositionSettings settings) {
    final df = settings.distanceFilterMeters.toInt();

    if (Platform.isAndroid) {
      final s = g.AndroidSettings(
        distanceFilter: df,
        intervalDuration: settings.interval,
        accuracy: g.LocationAccuracy.best,
      );
      return g.Geolocator.getPositionStream(locationSettings: s).map(_mapPos);
    } else if (Platform.isIOS) {
      final s = g.AppleSettings(
        distanceFilter: df,
        accuracy: g.LocationAccuracy.best,
        pauseLocationUpdatesAutomatically: true,
        showBackgroundLocationIndicator:
            false, // Foreground only in this ticket
      );
      return g.Geolocator.getPositionStream(locationSettings: s).map(_mapPos);
    }

    final generic = g.LocationSettings(distanceFilter: df);
    return g.Geolocator.getPositionStream(locationSettings: generic)
        .map(_mapPos);
  }
}

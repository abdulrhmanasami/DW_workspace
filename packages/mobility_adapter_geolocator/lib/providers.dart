import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobility_shims/mobility.dart';
import 'geolocator_location_source.dart';

final geolocatorLocationSourceProvider = Provider<LocationSource>(
  (_) => GeolocatorLocationSource(),
);

/// Provider for background tracking controller - Android-only with platform guards
final backgroundTrackingControllerProvider =
    Provider<BackgroundTrackingController>((ref) {
  // Stubbed implementation until background tracking adapter is wired.
  return const NoOpBackgroundTrackingController();
});

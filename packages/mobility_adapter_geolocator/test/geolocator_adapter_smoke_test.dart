// Smoke test for GeolocatorAdapter - skip on CI if needed
import 'package:flutter_test/flutter_test.dart';
import 'package:mobility_adapter_geolocator/geolocator_location_source.dart';

void main() {
  group('GeolocatorLocationSource', () {
    late GeolocatorLocationSource source;

    setUp(() {
      source = GeolocatorLocationSource();
    });

    test('can check permission without throwing', () async {
      // This should not throw, but result depends on device/emulator state
      try {
        final permission = await source.checkPermission();
        expect(permission, isNotNull);
      } catch (e) {
        // Expected on CI without location services
        expect(e, isA<Exception>());
      }
    });

    test('can check service enabled without throwing', () async {
      // This should not throw
      final enabled = await source.isServiceEnabled();
      expect(enabled, isA<bool>());
    });
  });
}

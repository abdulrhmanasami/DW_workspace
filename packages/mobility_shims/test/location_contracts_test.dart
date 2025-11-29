import 'package:flutter_test/flutter_test.dart';
import 'package:mobility_shims/mobility.dart';

void main() {
  group('PositionFix', () {
    test('can be created', () {
      final position = PositionFix(
        lat: 50.0,
        lng: 6.9,
        accuracy: 10.0,
        timestamp: DateTime.now(),
      );

      expect(position.lat, 50.0);
      expect(position.lng, 6.9);
      expect(position.accuracy, 10.0);
    });
  });

  group('PositionSettings', () {
    test('can be created', () {
      final settings = PositionSettings(
        distanceFilterMeters: 5.0,
        interval: Duration(seconds: 1),
      );

      expect(settings.distanceFilterMeters, 5.0);
      expect(settings.interval, Duration(seconds: 1));
    });
  });
}

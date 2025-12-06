
import 'package:flutter_test/flutter_test.dart';
import 'package:maps_shims/maps_shims.dart';

void main() {
  group('GeoPoint', () {
    test('creates with valid coordinates', () {
      const point = GeoPoint(24.7136, 46.6753);
      expect(point.latitude, 24.7136);
      expect(point.longitude, 46.6753);
    });

    test('throws assertion error for invalid latitude', () {
      expect(() => GeoPoint(91.0, 0.0), throwsAssertionError);
      expect(() => GeoPoint(-91.0, 0.0), throwsAssertionError);
    });

    test('throws assertion error for invalid longitude', () {
      expect(() => GeoPoint(0.0, 181.0), throwsAssertionError);
      expect(() => GeoPoint(0.0, -181.0), throwsAssertionError);
    });

    test('equality works correctly', () {
      const a = GeoPoint(24.7136, 46.6753);
      const b = GeoPoint(24.7136, 46.6753);
      const c = GeoPoint(24.7136, 46.6754);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('hashCode is consistent with equality', () {
      const a = GeoPoint(24.7136, 46.6753);
      const b = GeoPoint(24.7136, 46.6753);

      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString returns readable format', () {
      const point = GeoPoint(24.7136, 46.6753);
      expect(point.toString(), contains('24.7136'));
      expect(point.toString(), contains('46.6753'));
    });
  });

  group('MapBounds', () {
    test('contains returns true for point inside', () {
      const bounds = MapBounds(
        southWest: GeoPoint(0.0, 0.0),
        northEast: GeoPoint(10.0, 10.0),
      );

      expect(bounds.contains(const GeoPoint(5.0, 5.0)), isTrue);
      expect(bounds.contains(const GeoPoint(0.0, 0.0)), isTrue);
      expect(bounds.contains(const GeoPoint(10.0, 10.0)), isTrue);
    });

    test('contains returns false for point outside', () {
      const bounds = MapBounds(
        southWest: GeoPoint(0.0, 0.0),
        northEast: GeoPoint(10.0, 10.0),
      );

      expect(bounds.contains(const GeoPoint(-1.0, 5.0)), isFalse);
      expect(bounds.contains(const GeoPoint(5.0, 11.0)), isFalse);
    });

    test('center returns correct point', () {
      const bounds = MapBounds(
        southWest: GeoPoint(0.0, 0.0),
        northEast: GeoPoint(10.0, 10.0),
      );

      final center = bounds.center;
      expect(center.latitude, 5.0);
      expect(center.longitude, 5.0);
    });

    test('equality compares corners', () {
      const a = MapBounds(
        southWest: GeoPoint(0.0, 0.0),
        northEast: GeoPoint(10.0, 10.0),
      );
      const b = MapBounds(
        southWest: GeoPoint(0.0, 0.0),
        northEast: GeoPoint(10.0, 10.0),
      );
      const c = MapBounds(
        southWest: GeoPoint(0.0, 0.0),
        northEast: GeoPoint(10.0, 11.0),
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('MapZoom', () {
    test('creates with any double value', () {
      const zoom = MapZoom(16.5);
      expect(zoom.value, 16.5);
    });

    test('equality works correctly', () {
      const a = MapZoom(16.0);
      const b = MapZoom(16.0);
      const c = MapZoom(17.0);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('MapCameraTarget', () {
    test('creates with required center', () {
      const center = GeoPoint(24.7136, 46.6753);
      const target = MapCameraTarget(center: center);

      expect(target.center, center);
      expect(target.zoom, isNull);
    });

    test('creates with zoom', () {
      const center = GeoPoint(24.7136, 46.6753);
      const zoom = MapZoom(16.0);
      const target = MapCameraTarget(center: center, zoom: zoom);

      expect(target.center, center);
      expect(target.zoom, zoom);
    });

    test('copyWith updates selected fields', () {
      const original = MapCameraTarget(
        center: GeoPoint(24.7136, 46.6753),
        zoom: MapZoom(14.0),
      );

      final updated = original.copyWith(zoom: const MapZoom(16.0));

      expect(updated.center, original.center);
      expect(updated.zoom!.value, 16.0);
    });

    test('equality includes all fields', () {
      const a = MapCameraTarget(
        center: GeoPoint(24.7136, 46.6753),
        zoom: MapZoom(16.0),
      );
      const b = MapCameraTarget(
        center: GeoPoint(24.7136, 46.6753),
        zoom: MapZoom(16.0),
      );
      const c = MapCameraTarget(
        center: GeoPoint(24.7136, 46.6753),
        zoom: MapZoom(17.0),
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('MapMarkerId', () {
    test('creates with string value', () {
      const id = MapMarkerId('pickup_1');
      expect(id.value, 'pickup_1');
    });

    test('equality works correctly', () {
      const a = MapMarkerId('pickup_1');
      const b = MapMarkerId('pickup_1');
      const c = MapMarkerId('pickup_2');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('MapMarker', () {
    test('creates with required fields', () {
      const marker = MapMarker(
        id: MapMarkerId('pickup'),
        position: GeoPoint(24.7136, 46.6753),
      );

      expect(marker.id.value, 'pickup');
      expect(marker.position.latitude, 24.7136);
      expect(marker.label, isNull);
    });

    test('creates with optional label', () {
      const marker = MapMarker(
        id: MapMarkerId('pickup'),
        position: GeoPoint(24.7136, 46.6753),
        label: 'Pickup Location',
      );

      expect(marker.label, 'Pickup Location');
    });

    test('equality includes all fields', () {
      const a = MapMarker(
        id: MapMarkerId('pickup'),
        position: GeoPoint(24.7136, 46.6753),
        label: 'Pickup',
      );
      const b = MapMarker(
        id: MapMarkerId('pickup'),
        position: GeoPoint(24.7136, 46.6753),
        label: 'Pickup',
      );
      const c = MapMarker(
        id: MapMarkerId('pickup'),
        position: GeoPoint(24.7136, 46.6753),
        label: 'Dropoff',
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('MapPolylineId', () {
    test('creates with string value', () {
      const id = MapPolylineId('route_1');
      expect(id.value, 'route_1');
    });

    test('equality works correctly', () {
      const a = MapPolylineId('route_1');
      const b = MapPolylineId('route_1');
      const c = MapPolylineId('route_2');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('MapPolyline', () {
    test('creates with required fields', () {
      const polyline = MapPolyline(
        id: MapPolylineId('route'),
        points: [
          GeoPoint(24.7136, 46.6753),
          GeoPoint(24.7200, 46.6800),
        ],
      );

      expect(polyline.id.value, 'route');
      expect(polyline.points.length, 2);
      expect(polyline.isPrimaryRoute, isFalse);
    });

    test('creates with primary route flag', () {
      const polyline = MapPolyline(
        id: MapPolylineId('route'),
        points: [
          GeoPoint(24.7136, 46.6753),
          GeoPoint(24.7200, 46.6800),
        ],
        isPrimaryRoute: true,
      );

      expect(polyline.isPrimaryRoute, isTrue);
    });

    test('equality compares points correctly', () {
      const a = MapPolyline(
        id: MapPolylineId('route'),
        points: [GeoPoint(0, 0), GeoPoint(1, 1)],
      );
      const b = MapPolyline(
        id: MapPolylineId('route'),
        points: [GeoPoint(0, 0), GeoPoint(1, 1)],
      );
      const c = MapPolyline(
        id: MapPolylineId('route'),
        points: [GeoPoint(0, 0), GeoPoint(2, 2)], // different point
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}

/// DW Map Controller Tests
/// Track B - Ticket #109: Pure Dart Map Shim v1
/// Purpose: Unit tests for InMemoryMapController and core types

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:maps_shims/maps_shims.dart';

void main() {
  group('DWLatLng', () {
    test('equality works correctly', () {
      const a = DWLatLng(24.7136, 46.6753);
      const b = DWLatLng(24.7136, 46.6753);
      const c = DWLatLng(24.7136, 46.6754);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('hashCode is consistent with equality', () {
      const a = DWLatLng(24.7136, 46.6753);
      const b = DWLatLng(24.7136, 46.6753);

      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString returns readable format', () {
      const point = DWLatLng(24.7136, 46.6753);
      expect(point.toString(), contains('24.7136'));
      expect(point.toString(), contains('46.6753'));
    });
  });

  group('DWLatLngBounds', () {
    test('contains returns true for point inside', () {
      const bounds = DWLatLngBounds(
        southWest: DWLatLng(0.0, 0.0),
        northEast: DWLatLng(10.0, 10.0),
      );

      expect(bounds.contains(const DWLatLng(5.0, 5.0)), isTrue);
      expect(bounds.contains(const DWLatLng(0.0, 0.0)), isTrue);
      expect(bounds.contains(const DWLatLng(10.0, 10.0)), isTrue);
    });

    test('contains returns false for point outside', () {
      const bounds = DWLatLngBounds(
        southWest: DWLatLng(0.0, 0.0),
        northEast: DWLatLng(10.0, 10.0),
      );

      expect(bounds.contains(const DWLatLng(-1.0, 5.0)), isFalse);
      expect(bounds.contains(const DWLatLng(5.0, 11.0)), isFalse);
    });

    test('center returns correct point', () {
      const bounds = DWLatLngBounds(
        southWest: DWLatLng(0.0, 0.0),
        northEast: DWLatLng(10.0, 10.0),
      );

      final center = bounds.center;
      expect(center.latitude, 5.0);
      expect(center.longitude, 5.0);
    });
  });

  group('DWMapMarker', () {
    test('creates with required fields', () {
      const marker = DWMapMarker(
        id: 'pickup',
        position: DWLatLng(24.7136, 46.6753),
      );

      expect(marker.id, 'pickup');
      expect(marker.position.latitude, 24.7136);
      expect(marker.type, DWMapMarkerType.poi);
      expect(marker.label, isNull);
    });

    test('equality includes all fields', () {
      const a = DWMapMarker(
        id: 'pickup',
        position: DWLatLng(24.7136, 46.6753),
        type: DWMapMarkerType.userPickup,
        label: 'Pickup',
      );
      const b = DWMapMarker(
        id: 'pickup',
        position: DWLatLng(24.7136, 46.6753),
        type: DWMapMarkerType.userPickup,
        label: 'Pickup',
      );
      const c = DWMapMarker(
        id: 'pickup',
        position: DWLatLng(24.7136, 46.6753),
        type: DWMapMarkerType.destination, // different type
        label: 'Pickup',
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('DWMapPolyline', () {
    test('creates with required fields', () {
      const polyline = DWMapPolyline(
        id: 'route',
        points: [
          DWLatLng(24.7136, 46.6753),
          DWLatLng(24.7200, 46.6800),
        ],
      );

      expect(polyline.id, 'route');
      expect(polyline.points.length, 2);
      expect(polyline.style, DWMapPolylineStyle.route);
    });

    test('equality compares points correctly', () {
      const a = DWMapPolyline(
        id: 'route',
        points: [DWLatLng(0, 0), DWLatLng(1, 1)],
      );
      const b = DWMapPolyline(
        id: 'route',
        points: [DWLatLng(0, 0), DWLatLng(1, 1)],
      );
      const c = DWMapPolyline(
        id: 'route',
        points: [DWLatLng(0, 0), DWLatLng(2, 2)], // different point
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('DWMapCameraPosition', () {
    test('creates with defaults', () {
      const camera = DWMapCameraPosition(
        target: DWLatLng(24.7136, 46.6753),
      );

      expect(camera.target.latitude, 24.7136);
      expect(camera.zoom, 14.0);
      expect(camera.tilt, 0.0);
      expect(camera.bearing, 0.0);
    });

    test('copyWith updates selected fields', () {
      const original = DWMapCameraPosition(
        target: DWLatLng(24.7136, 46.6753),
        zoom: 14.0,
      );

      final updated = original.copyWith(zoom: 16.0);

      expect(updated.target, original.target);
      expect(updated.zoom, 16.0);
    });
  });

  group('InMemoryMapController', () {
    late InMemoryMapController controller;

    setUp(() {
      controller = InMemoryMapController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('initial state is empty', () {
      expect(controller.markers, isEmpty);
      expect(controller.polylines, isEmpty);
      expect(controller.camera, isNull);
    });

    group('DWSetContentCommand', () {
      test('sets markers and polylines', () {
        const marker1 = DWMapMarker(
          id: 'pickup',
          position: DWLatLng(24.7136, 46.6753),
          type: DWMapMarkerType.userPickup,
        );
        const marker2 = DWMapMarker(
          id: 'destination',
          position: DWLatLng(24.7200, 46.6800),
          type: DWMapMarkerType.destination,
        );
        const polyline = DWMapPolyline(
          id: 'route',
          points: [DWLatLng(24.7136, 46.6753), DWLatLng(24.7200, 46.6800)],
        );

        controller.commands.add(DWSetContentCommand(
          markers: [marker1, marker2],
          polylines: [polyline],
        ));

        expect(controller.markers.length, 2);
        expect(controller.polylines.length, 1);
        expect(controller.markerById('pickup'), isNotNull);
        expect(controller.markerById('destination'), isNotNull);
        expect(controller.polylineById('route'), isNotNull);
      });

      test('sets camera if provided', () {
        const camera = DWMapCameraPosition(
          target: DWLatLng(24.7136, 46.6753),
          zoom: 15.0,
        );

        controller.commands.add(DWSetContentCommand(
          markers: [],
          polylines: [],
          camera: camera,
        ));

        expect(controller.camera, isNotNull);
        expect(controller.camera!.target.latitude, 24.7136);
        expect(controller.camera!.zoom, 15.0);
      });

      test('replaces previous content', () {
        // First set
        controller.commands.add(const DWSetContentCommand(
          markers: [
            DWMapMarker(id: 'm1', position: DWLatLng(0, 0)),
            DWMapMarker(id: 'm2', position: DWLatLng(1, 1)),
          ],
          polylines: [],
        ));

        expect(controller.markers.length, 2);

        // Second set (replaces first)
        controller.commands.add(const DWSetContentCommand(
          markers: [DWMapMarker(id: 'm3', position: DWLatLng(2, 2))],
          polylines: [],
        ));

        expect(controller.markers.length, 1);
        expect(controller.markerById('m1'), isNull);
        expect(controller.markerById('m3'), isNotNull);
      });
    });

    group('DWAnimateToBoundsCommand', () {
      test('sets camera to center of bounds', () {
        const bounds = DWLatLngBounds(
          southWest: DWLatLng(0.0, 0.0),
          northEast: DWLatLng(10.0, 10.0),
        );

        controller.commands.add(DWAnimateToBoundsCommand(bounds));

        expect(controller.camera, isNotNull);
        expect(controller.camera!.target.latitude, 5.0);
        expect(controller.camera!.target.longitude, 5.0);
      });
    });

    group('DWAnimateToPositionCommand', () {
      test('sets camera to specified position', () {
        const position = DWMapCameraPosition(
          target: DWLatLng(24.7136, 46.6753),
          zoom: 16.0,
          bearing: 45.0,
        );

        controller.commands.add(DWAnimateToPositionCommand(position));

        expect(controller.camera, equals(position));
      });

      test('emits DWCameraMovedEvent after animation', () async {
        const position = DWMapCameraPosition(
          target: DWLatLng(24.7136, 46.6753),
        );

        final events = <DWMapEvent>[];
        final subscription = controller.events.listen(events.add);

        controller.commands.add(DWAnimateToPositionCommand(position));

        // Allow stream to process
        await Future<void>.delayed(Duration.zero);

        expect(events.length, 1);
        expect(events.first, isA<DWCameraMovedEvent>());
        expect((events.first as DWCameraMovedEvent).position, equals(position));

        await subscription.cancel();
      });
    });

    group('DWClearCommand', () {
      test('clears all markers and polylines', () {
        // Set some content
        controller.commands.add(const DWSetContentCommand(
          markers: [DWMapMarker(id: 'm1', position: DWLatLng(0, 0))],
          polylines: [
            DWMapPolyline(
              id: 'p1',
              points: [DWLatLng(0, 0), DWLatLng(1, 1)],
            ),
          ],
        ));

        expect(controller.markers.length, 1);
        expect(controller.polylines.length, 1);

        // Clear
        controller.commands.add(const DWClearCommand());

        expect(controller.markers, isEmpty);
        expect(controller.polylines, isEmpty);
      });
    });

    group('Events Stream', () {
      test('simulateMarkerTap emits DWMarkerTappedEvent', () async {
        final events = <DWMapEvent>[];
        final subscription = controller.events.listen(events.add);

        controller.simulateMarkerTap('driver_1');

        await Future<void>.delayed(Duration.zero);

        expect(events.length, 1);
        expect(events.first, isA<DWMarkerTappedEvent>());
        expect((events.first as DWMarkerTappedEvent).markerId, 'driver_1');

        await subscription.cancel();
      });

      test('simulateMapTap emits DWMapTappedEvent', () async {
        final events = <DWMapEvent>[];
        final subscription = controller.events.listen(events.add);

        controller.simulateMapTap(const DWLatLng(24.7136, 46.6753));

        await Future<void>.delayed(Duration.zero);

        expect(events.length, 1);
        expect(events.first, isA<DWMapTappedEvent>());
        expect(
          (events.first as DWMapTappedEvent).position.latitude,
          24.7136,
        );

        await subscription.cancel();
      });

      test('simulateMapReady emits DWMapReadyEvent', () async {
        final events = <DWMapEvent>[];
        final subscription = controller.events.listen(events.add);

        controller.simulateMapReady();

        await Future<void>.delayed(Duration.zero);

        expect(events.length, 1);
        expect(events.first, isA<DWMapReadyEvent>());

        await subscription.cancel();
      });
    });

    group('Command History', () {
      test('records all commands', () {
        controller.commands.add(const DWSetContentCommand(
          markers: [],
          polylines: [],
        ));
        controller.commands.add(const DWClearCommand());
        controller.commands.add(const DWAnimateToPositionCommand(
          DWMapCameraPosition(target: DWLatLng(0, 0)),
        ));

        expect(controller.commandHistory.length, 3);
        expect(controller.commandHistory[0], isA<DWSetContentCommand>());
        expect(controller.commandHistory[1], isA<DWClearCommand>());
        expect(controller.commandHistory[2], isA<DWAnimateToPositionCommand>());
      });
    });

    group('Dispose', () {
      test('does not throw when disposed', () {
        expect(() => controller.dispose(), returnsNormally);
      });

      test('can be disposed multiple times without error', () {
        controller.dispose();
        // Second dispose should not throw
        expect(() => controller.dispose(), returnsNormally);
      });
    });
  });
}


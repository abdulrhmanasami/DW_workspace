/// In-Memory Map Port Tests - Unit tests for InMemoryMapPort
/// Track B - Ticket #198: MapInterface تفاعلي (Streams/Sinks) + Stub Implementation
/// Purpose: Test InMemoryMapPort behavior with commands and events

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:maps_shims/maps_shims.dart';

void main() {
  group('InMemoryMapPort', () {
    late InMemoryMapPort port;

    setUp(() {
      port = InMemoryMapPort();
    });

    tearDown(() {
      port.dispose();
    });

    test('initial state is empty', () {
      expect(port.markers, isEmpty);
      expect(port.polylines, isEmpty);
      expect(port.camera, isNull);
    });

    group('SetCameraCommand', () {
      test('sets camera to specified target', () {
        const target = MapCameraTarget(
          center: GeoPoint(24.7136, 46.6753),
          zoom: MapZoom(16.0),
        );

        port.commands.add(SetCameraCommand(target));

        expect(port.camera, isNotNull);
        expect(port.camera!.center.latitude, 24.7136);
        expect(port.camera!.zoom!.value, 16.0);
      });

      test('emits CameraMovedEvent after camera change', () async {
        const target = MapCameraTarget(
          center: GeoPoint(24.7136, 46.6753),
        );

        final events = <MapEvent>[];
        final subscription = port.events.listen(events.add);

        port.commands.add(SetCameraCommand(target));

        // Allow stream to process
        await Future<void>.delayed(Duration.zero);

        expect(events.length, 1);
        expect(events.first, isA<CameraMovedEvent>());
        expect((events.first as CameraMovedEvent).target.center.latitude, 24.7136);

        await subscription.cancel();
      });
    });

    group('FitBoundsCommand', () {
      test('sets camera to center of bounds', () {
        const bounds = MapBounds(
          southWest: GeoPoint(0.0, 0.0),
          northEast: GeoPoint(10.0, 10.0),
        );

        port.commands.add(FitBoundsCommand(bounds));

        expect(port.camera, isNotNull);
        expect(port.camera!.center.latitude, 5.0);
        expect(port.camera!.center.longitude, 5.0);
      });
    });

    group('SetMarkersCommand', () {
      test('sets markers on the map', () {
        const marker1 = MapMarker(
          id: MapMarkerId('pickup'),
          position: GeoPoint(24.7136, 46.6753),
          label: 'Pickup Location',
        );
        const marker2 = MapMarker(
          id: MapMarkerId('destination'),
          position: GeoPoint(24.7200, 46.6800),
        );

        port.commands.add(SetMarkersCommand([marker1, marker2]));

        expect(port.markers.length, 2);
        expect(port.markerById(MapMarkerId('pickup')), isNotNull);
        expect(port.markerById(MapMarkerId('destination')), isNotNull);
        expect(port.markerById(MapMarkerId('nonexistent')), isNull);
      });

      test('replaces previous markers', () {
        // Set initial markers
        port.commands.add(SetMarkersCommand([
          const MapMarker(
            id: MapMarkerId('m1'),
            position: GeoPoint(0, 0),
          ),
          const MapMarker(
            id: MapMarkerId('m2'),
            position: GeoPoint(1, 1),
          ),
        ]));

        expect(port.markers.length, 2);

        // Replace with different markers
        port.commands.add(SetMarkersCommand([
          const MapMarker(
            id: MapMarkerId('m3'),
            position: GeoPoint(2, 2),
          ),
        ]));

        expect(port.markers.length, 1);
        expect(port.markerById(MapMarkerId('m1')), isNull);
        expect(port.markerById(MapMarkerId('m3')), isNotNull);
      });
    });

    group('SetPolylinesCommand', () {
      test('sets polylines on the map', () {
        const polyline1 = MapPolyline(
          id: MapPolylineId('route1'),
          points: [GeoPoint(0, 0), GeoPoint(1, 1)],
          isPrimaryRoute: true,
        );
        const polyline2 = MapPolyline(
          id: MapPolylineId('route2'),
          points: [GeoPoint(1, 1), GeoPoint(2, 2)],
          isPrimaryRoute: false,
        );

        port.commands.add(SetPolylinesCommand([polyline1, polyline2]));

        expect(port.polylines.length, 2);
        expect(port.polylineById(MapPolylineId('route1')), isNotNull);
        expect(port.polylineById(MapPolylineId('route2')), isNotNull);
        expect(port.polylineById(MapPolylineId('nonexistent')), isNull);
      });

      test('replaces previous polylines', () {
        // Set initial polylines
        port.commands.add(SetPolylinesCommand([
          const MapPolyline(
            id: MapPolylineId('p1'),
            points: [GeoPoint(0, 0), GeoPoint(1, 1)],
          ),
        ]));

        expect(port.polylines.length, 1);

        // Replace with different polylines
        port.commands.add(SetPolylinesCommand([
          const MapPolyline(
            id: MapPolylineId('p2'),
            points: [GeoPoint(2, 2), GeoPoint(3, 3)],
          ),
        ]));

        expect(port.polylines.length, 1);
        expect(port.polylineById(MapPolylineId('p1')), isNull);
        expect(port.polylineById(MapPolylineId('p2')), isNotNull);
      });
    });

    group('Events Stream', () {
      test('simulateMarkerTap emits MarkerTappedEvent', () async {
        final events = <MapEvent>[];
        final subscription = port.events.listen(events.add);

        port.simulateMarkerTap(MapMarkerId('driver_1'));

        await Future<void>.delayed(Duration.zero);

        expect(events.length, 1);
        expect(events.first, isA<MarkerTappedEvent>());
        expect((events.first as MarkerTappedEvent).markerId.value, 'driver_1');

        await subscription.cancel();
      });

      test('simulateMapTap emits MapTappedEvent', () async {
        final events = <MapEvent>[];
        final subscription = port.events.listen(events.add);

        port.simulateMapTap(const GeoPoint(24.7136, 46.6753));

        await Future<void>.delayed(Duration.zero);

        expect(events.length, 1);
        expect(events.first, isA<MapTappedEvent>());
        expect(
          (events.first as MapTappedEvent).position.latitude,
          24.7136,
        );

        await subscription.cancel();
      });

      test('simulateCameraMoved emits CameraMovedEvent', () async {
        final events = <MapEvent>[];
        final subscription = port.events.listen(events.add);

        const target = MapCameraTarget(center: GeoPoint(24.7136, 46.6753));
        port.simulateCameraMoved(target);

        await Future<void>.delayed(Duration.zero);

        expect(events.length, 1);
        expect(events.first, isA<CameraMovedEvent>());
        expect((events.first as CameraMovedEvent).target.center.latitude, 24.7136);

        await subscription.cancel();
      });

      test('simulateMapReady emits MapReadyEvent', () async {
        final events = <MapEvent>[];
        final subscription = port.events.listen(events.add);

        port.simulateMapReady();

        await Future<void>.delayed(Duration.zero);

        expect(events.length, 1);
        expect(events.first, isA<MapReadyEvent>());

        await subscription.cancel();
      });
    });

    group('Command History', () {
      test('records all commands', () {
        port.commands.add(SetMarkersCommand([]));
        port.commands.add(FitBoundsCommand(MapBounds(
          southWest: GeoPoint(0, 0),
          northEast: GeoPoint(1, 1),
        )));
        port.commands.add(SetCameraCommand(MapCameraTarget(
          center: GeoPoint(0, 0),
        )));

        expect(port.commandHistory.length, 3);
        expect(port.commandHistory[0], isA<SetMarkersCommand>());
        expect(port.commandHistory[1], isA<FitBoundsCommand>());
        expect(port.commandHistory[2], isA<SetCameraCommand>());
      });
    });

    group('Dispose', () {
      test('does not throw when disposed', () {
        expect(() => port.dispose(), returnsNormally);
      });

      test('can be disposed multiple times without error', () {
        port.dispose();
        // Second dispose should not throw
        expect(() => port.dispose(), returnsNormally);
      });
    });
  });
}

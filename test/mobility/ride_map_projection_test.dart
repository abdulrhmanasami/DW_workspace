/// Ride Map Projection Unit Tests - Track B Ticket #199
/// Purpose: Test the ride map projection from FSM stages to map snapshots
/// Created by: Track B - Ticket #199
/// Last updated: 2025-12-03

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:maps_shims/maps_shims.dart';

import 'package:delivery_ways_clean/state/mobility/ride_map_projection.dart';

class _RecordingMapPort implements MapPort {
  final List<MapCommand> recordedCommands = <MapCommand>[];

  @override
  Stream<MapEvent> get events => const Stream<MapEvent>.empty();

  @override
  Sink<MapCommand> get commands => _RecordingSink(recordedCommands);

  @override
  void dispose() {
    // Nothing to dispose
  }
}

class _RecordingSink implements Sink<MapCommand> {
  final List<MapCommand> _commands;

  _RecordingSink(this._commands);

  @override
  void add(MapCommand command) {
    _commands.add(command);
  }

  @override
  void close() {
    // Nothing to close
  }
}

void main() {
  group('RideMapProjector.project', () {
    test('confirmation stage shows pickup + dropoff + route', () {
      final pickup = const GeoPoint(24.7136, 46.6753);
      final dropoff = const GeoPoint(24.7743, 46.7386);

      final route = MapPolyline(
        id: const MapPolylineId('route'),
        points: [pickup, dropoff],
        isPrimaryRoute: true,
      );

      final snapshot = RideMapProjector.project(
        stage: RideMapStage.confirmingQuote,
        pickupLocation: pickup,
        dropoffLocation: dropoff,
        routePolyline: route,
      );

      expect(snapshot.markers.length, 2);
      expect(
        snapshot.markers.map((m) => m.title ?? m.label),
        containsAll(<String>['Pickup', 'Dropoff']),
      );
      expect(snapshot.polylines.length, 1);
      expect(snapshot.polylines.single.points.first, pickup);
      expect(snapshot.polylines.single.points.last, dropoff);

      final center = snapshot.cameraTarget.center;
      expect(center.latitude, closeTo((pickup.latitude + dropoff.latitude) / 2, 1e-6));
      expect(center.longitude, closeTo((pickup.longitude + dropoff.longitude) / 2, 1e-6));
      expect(snapshot.cameraTarget.zoom!.value, 13.0);
    });

    test('waitingForDriver shows driver + pickup markers', () {
      final pickup = const GeoPoint(24.7136, 46.6753);
      final driver = const GeoPoint(24.7200, 46.6800);

      final snapshot = RideMapProjector.project(
        stage: RideMapStage.waitingForDriver,
        pickupLocation: pickup,
        driverLocation: driver,
      );

      expect(snapshot.markers.length, 2);
      expect(
        snapshot.markers.map((m) => m.title ?? m.label),
        containsAll(<String>['Pickup', 'Driver']),
      );
      expect(snapshot.polylines, isEmpty);

      final center = snapshot.cameraTarget.center;
      expect(center.latitude, closeTo((pickup.latitude + driver.latitude) / 2, 1e-6));
      expect(center.longitude, closeTo((pickup.longitude + driver.longitude) / 2, 1e-6));
    });

    test('inProgress shows driver + dropoff + route when available', () {
      final driver = const GeoPoint(24.7200, 46.6800);
      final dropoff = const GeoPoint(24.7743, 46.7386);

      final route = MapPolyline(
        id: const MapPolylineId('route'),
        points: [driver, dropoff],
        isPrimaryRoute: true,
      );

      final snapshot = RideMapProjector.project(
        stage: RideMapStage.inProgressToDestination,
        driverLocation: driver,
        dropoffLocation: dropoff,
        routePolyline: route,
      );

      expect(snapshot.markers.length, 2);
      expect(
        snapshot.markers.map((m) => m.title ?? m.label),
        containsAll(<String>['Driver', 'Dropoff']),
      );
      expect(snapshot.polylines.length, 1);
    });

    test('idle stage shows only pickup marker with close zoom', () {
      final userLocation = const GeoPoint(24.7136, 46.6753);

      final snapshot = RideMapProjector.project(
        stage: RideMapStage.idle,
        userLocation: userLocation,
      );

      expect(snapshot.markers, isEmpty);
      expect(snapshot.polylines, isEmpty);

      final center = snapshot.cameraTarget.center;
      expect(center.latitude, closeTo(userLocation.latitude, 1e-6));
      expect(center.longitude, closeTo(userLocation.longitude, 1e-6));
      expect(snapshot.cameraTarget.zoom!.value, 15.0);
    });

    test('completed stage does not show driver marker', () {
      final pickup = const GeoPoint(24.7136, 46.6753);
      final driver = const GeoPoint(24.7200, 46.6800);

      final snapshot = RideMapProjector.project(
        stage: RideMapStage.completed,
        pickupLocation: pickup,
        driverLocation: driver,
      );

      expect(snapshot.markers.length, 1);
      expect(snapshot.markers.single.title ?? snapshot.markers.single.label, 'Pickup');
      expect(snapshot.polylines, isEmpty);
    });

    test('error stage does not show route polyline', () {
      final pickup = const GeoPoint(24.7136, 46.6753);
      final dropoff = const GeoPoint(24.7743, 46.7386);

      final route = MapPolyline(
        id: const MapPolylineId('route'),
        points: [pickup, dropoff],
        isPrimaryRoute: true,
      );

      final snapshot = RideMapProjector.project(
        stage: RideMapStage.error,
        pickupLocation: pickup,
        dropoffLocation: dropoff,
        routePolyline: route,
      );

      // ❌ لا نعرض route في حالة error
      expect(snapshot.polylines, isEmpty);

      // ✅ نسمح ببقاء pickup/dropoff markers للمستخدم
      expect(snapshot.markers.length, 2);
      expect(
        snapshot.markers.map((m) => m.label),
        containsAll(<String>['Pickup', 'Dropoff']),
      );
    });

    test('searchingDestination shows only pickup marker', () {
      final pickup = const GeoPoint(24.7136, 46.6753);
      final dropoff = const GeoPoint(24.7743, 46.7386);

      final snapshot = RideMapProjector.project(
        stage: RideMapStage.searchingDestination,
        pickupLocation: pickup,
        dropoffLocation: dropoff,
      );

      expect(snapshot.markers.length, 1);
      expect(snapshot.markers.single.title ?? snapshot.markers.single.label, 'Pickup');
      expect(snapshot.polylines, isEmpty);
    });
  });

  group('RideMapProjector.toCommands & pumpToPort', () {
    test('toCommands creates camera + markers + optional polylines commands', () {
      final pickup = const GeoPoint(24.7136, 46.6753);

      final snapshot = RideMapProjector.project(
        stage: RideMapStage.idle,
        userLocation: pickup,
      );

      final commands = RideMapProjector.toCommands(snapshot);

      expect(
        commands.whereType<SetCameraCommand>().length,
        1,
      );
      expect(
        commands.whereType<SetMarkersCommand>().length,
        1,
      );
      // لا ينبغي وجود SetPolylinesCommand لأن snapshot.polylines فارغة
      expect(
        commands.whereType<SetPolylinesCommand>().length,
        0,
      );
    });

    test('toCommands includes SetPolylinesCommand when polylines present', () {
      final pickup = const GeoPoint(24.7136, 46.6753);
      final dropoff = const GeoPoint(24.7743, 46.7386);

      final route = MapPolyline(
        id: const MapPolylineId('route'),
        points: [pickup, dropoff],
        isPrimaryRoute: true,
      );

      final snapshot = RideMapProjector.project(
        stage: RideMapStage.confirmingQuote,
        pickupLocation: pickup,
        dropoffLocation: dropoff,
        routePolyline: route,
      );

      final commands = RideMapProjector.toCommands(snapshot);

      expect(
        commands.whereType<SetCameraCommand>().length,
        1,
      );
      expect(
        commands.whereType<SetMarkersCommand>().length,
        1,
      );
      expect(
        commands.whereType<SetPolylinesCommand>().length,
        1,
      );
    });

    test('pumpToPort pushes commands into MapPort (RecordingMapPort)', () async {
      final pickup = const GeoPoint(24.7136, 46.6753);
      final dropoff = const GeoPoint(24.7743, 46.7386);

      final route = MapPolyline(
        id: const MapPolylineId('route'),
        points: [pickup, dropoff],
        isPrimaryRoute: true,
      );

      final snapshot = RideMapProjector.project(
        stage: RideMapStage.confirmingQuote,
        pickupLocation: pickup,
        dropoffLocation: dropoff,
        routePolyline: route,
      );

      final port = _RecordingMapPort();

      RideMapProjector.pumpToPort(snapshot: snapshot, port: port);

      // ✅ تم إرسال أوامر للـ port
      expect(port.recordedCommands.isNotEmpty, true);

      // ✅ يوجد أمر واحد لضبط الكاميرا
      expect(
        port.recordedCommands.whereType<SetCameraCommand>().length,
        1,
      );

      // ✅ يوجد أمر markers
      expect(
        port.recordedCommands.whereType<SetMarkersCommand>().length,
        1,
      );

      // ✅ يوجد أمر polyline لأن snapshot فيه route
      expect(
        port.recordedCommands.whereType<SetPolylinesCommand>().length,
        1,
      );

      port.dispose();
    });
  });
}

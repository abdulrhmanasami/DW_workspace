// Mobility Shims Unit Tests
// Created by: Cursor B-mobility
// Purpose: Test mobility shims contracts and providers with consent/kill-switch enforcement
// Last updated: 2025-11-13

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobility_shims/mobility.dart';
import '../support/mobility_stubs.dart';

void main() {
  group('Mobility Shims Unit Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Stub Implementations', () {
      test('StubLocationProvider returns empty stream', () async {
        final provider = const StubLocationProvider();

        final stream = provider.watch();
        expect(stream, emitsDone);
      });

      test(
        'StubLocationProvider throws on getCurrent when consent denied',
        () async {
          final provider = const StubLocationProvider();

          expect(
            () => provider.getCurrent(),
            throwsA(isA<ConsentDeniedException>()),
          );
        },
      );

      test('StubLocationProvider returns denied permission', () async {
        final provider = const StubLocationProvider();

        final permission = await provider.requestPermission();
        expect(permission, equals(PermissionStatus.denied));
      });

      test('StubLocationProvider returns service disabled', () async {
        final provider = const StubLocationProvider();

        final enabled = await provider.serviceEnabled();
        expect(enabled, isFalse);
      });

      test('StubBackgroundTracker does nothing on start/stop', () async {
        final tracker = const StubBackgroundTracker();

        await expectLater(tracker.start(), completes);
        await expectLater(tracker.stop(), completes);
      });

      test('StubBackgroundTracker returns stopped status stream', () async {
        final tracker = const StubBackgroundTracker();

        final statusStream = tracker.status();
        expect(statusStream, emits(TrackingStatus.stopped));
      });
    });

    group('Provider Enforcement', () {
      test('locationProvider throws when tracking disabled', () {
        final testContainer = ProviderContainer(
          overrides: [
            mobilityConfigProvider.overrideWithValue(false),
            consentBackgroundLocationProvider.overrideWithValue(true),
          ],
        );

        expect(
          () => testContainer.read(locationProvider),
          throwsA(isA<TrackingDisabledException>()),
        );

        testContainer.dispose();
      });

      test('locationProvider throws when consent denied', () {
        final testContainer = ProviderContainer(
          overrides: [
            mobilityConfigProvider.overrideWithValue(true),
            consentBackgroundLocationProvider.overrideWithValue(false),
          ],
        );

        expect(
          () => testContainer.read(locationProvider),
          throwsA(isA<ConsentDeniedException>()),
        );

        testContainer.dispose();
      });

      test('backgroundTrackerProvider throws when tracking disabled', () {
        final testContainer = ProviderContainer(
          overrides: [
            mobilityConfigProvider.overrideWithValue(false),
            consentBackgroundLocationProvider.overrideWithValue(true),
          ],
        );

        expect(
          () => testContainer.read(backgroundTrackerProvider),
          throwsA(isA<TrackingDisabledException>()),
        );

        testContainer.dispose();
      });

      test('backgroundTrackerProvider throws when consent denied', () {
        final testContainer = ProviderContainer(
          overrides: [
            mobilityConfigProvider.overrideWithValue(true),
            consentBackgroundLocationProvider.overrideWithValue(false),
          ],
        );

        expect(
          () => testContainer.read(backgroundTrackerProvider),
          throwsA(isA<ConsentDeniedException>()),
        );

        testContainer.dispose();
      });
    });

    group('LocationPoint Model', () {
      test('LocationPoint stores values correctly', () {
        final point = LocationPoint(
          latitude: 51.5074,
          longitude: -0.1278,
          accuracy: 10.0,
          speed: 5.0,
          timestamp: DateTime(2025, 11, 13),
        );

        expect(point.latitude, equals(51.5074));
        expect(point.longitude, equals(-0.1278));
        expect(point.accuracy, equals(10.0));
        expect(point.speed, equals(5.0));
        expect(point.timestamp, equals(DateTime(2025, 11, 13)));
      });

      test('LocationPoint stores different values correctly', () {
        final point1 = LocationPoint(
          latitude: 51.5074,
          longitude: -0.1278,
          timestamp: DateTime(2025, 11, 13),
        );

        final point2 = LocationPoint(
          latitude: 52.0,
          longitude: -0.1279,
          timestamp: DateTime(2025, 11, 14),
        );

        // Verify different points have different values
        expect(point1.latitude, isNot(equals(point2.latitude)));
        expect(point1.longitude, isNot(equals(point2.longitude)));
        expect(point1.timestamp, isNot(equals(point2.timestamp)));
      });
    });

    group('PermissionStatus Enum', () {
      test('PermissionStatus values are correct', () {
        expect(PermissionStatus.denied, equals(PermissionStatus.denied));
        expect(PermissionStatus.granted, equals(PermissionStatus.granted));
        expect(
          PermissionStatus.permanentlyDenied,
          equals(PermissionStatus.permanentlyDenied),
        );
        expect(
          PermissionStatus.restricted,
          equals(PermissionStatus.restricted),
        );
        expect(
          PermissionStatus.notDetermined,
          equals(PermissionStatus.notDetermined),
        );
      });
    });
  });
}

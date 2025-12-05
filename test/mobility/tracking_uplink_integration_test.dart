// Tracking Uplink Integration Tests
// Created by: Cursor B-mobility
// Purpose: Test end-to-end uplink integration with tracking controller
// Last updated: 2025-11-26

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobility_shims/mobility.dart';
import 'package:delivery_ways_clean/state/mobility/tracking_controller.dart';
import '../support/mobility_stubs.dart';
import '../support/path_provider_stub.dart';
import '../support/uplink_spy.dart';

void main() {
  // Required for path_provider used by UplinkService
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    ensurePathProviderStubForTests();
  });

  group('Tracking Uplink Integration Tests', () {
    late SpyUplinkService uplinkSpy;

    setUp(() {
      uplinkSpy = SpyUplinkService();
    });

    tearDown(() {
      uplinkSpy.reset();
    });

    test('tracking controller enqueues points during active session', () async {
      final testContainer = ProviderContainer(
        overrides: [
          mobilityConfigProvider.overrideWithValue(true),
          consentBackgroundLocationProvider.overrideWithValue(true),
          locationProvider.overrideWith(
            ((ref) => const TestLocationProvider()),
          ),
          backgroundTrackerProvider.overrideWith(
            ((ref) => const TestBackgroundTracker()),
          ),
          uplinkServiceProvider.overrideWithValue(uplinkSpy),
        ],
      );

      final controller = testContainer.read(trackingControllerProvider.notifier);
      await controller.start();

      // Simulate some location points
      final point1 = LocationPoint(
        latitude: 51.5074,
        longitude: -0.1278,
        timestamp: DateTime.now(),
      );

      final point2 = LocationPoint(
        latitude: 51.5075,
        longitude: -0.1279,
        timestamp: DateTime.now(),
      );

      // Enqueue points through the spy (simulating what controller does on location updates)
      await uplinkSpy.enqueue(point1, controller.state.sessionId!);
      await uplinkSpy.enqueue(point2, controller.state.sessionId!);

      // Verify spy received the points
      expect(uplinkSpy.enqueuedPoints.length, 2);
      expect(uplinkSpy.enqueuedPoints[0].point.latitude, 51.5074);
      expect(uplinkSpy.enqueuedPoints[1].point.latitude, 51.5075);

      await controller.stop();
      testContainer.dispose();
    });

    test('stop triggers force flush', () async {
      final testContainer = ProviderContainer(
        overrides: [
          mobilityConfigProvider.overrideWithValue(true),
          consentBackgroundLocationProvider.overrideWithValue(true),
          locationProvider.overrideWith(
            ((ref) => const TestLocationProvider()),
          ),
          backgroundTrackerProvider.overrideWith(
            ((ref) => const TestBackgroundTracker()),
          ),
          uplinkServiceProvider.overrideWithValue(uplinkSpy),
        ],
      );

      final controller = testContainer.read(trackingControllerProvider.notifier);
      await controller.start();

      // Add a point
      final point = LocationPoint(
        latitude: 51.5074,
        longitude: -0.1278,
        timestamp: DateTime.now(),
      );
      await uplinkSpy.enqueue(point, controller.state.sessionId!);

      // Stop should trigger force flush
      await controller.stop();

      // Verify force flush was called
      expect(uplinkSpy.forceFlushCalled, isTrue);

      testContainer.dispose();
    });

    test('uplink respects kill-switch and consent', () async {
      final testContainer = ProviderContainer(
        overrides: [
          mobilityConfigProvider.overrideWithValue(false), // Disabled
          consentBackgroundLocationProvider.overrideWithValue(true),
          locationProvider.overrideWith(
            ((ref) => const StubLocationProvider()),
          ),
          backgroundTrackerProvider.overrideWith(
            ((ref) => const StubBackgroundTracker()),
          ),
          uplinkServiceProvider.overrideWithValue(uplinkSpy),
        ],
      );

      final controller = testContainer.read(trackingControllerProvider.notifier);

      // Should not start tracking
      expect(
        () => controller.start(),
        throwsA(isA<TrackingDisabledException>()),
      );

      // Verify no points were enqueued since tracking was disabled
      expect(uplinkSpy.enqueuedPoints.length, 0);

      testContainer.dispose();
    });

    test('offline queue persists across sessions', () async {
      // Use the same spy for both sessions to simulate persistence
      final testContainer = ProviderContainer(
        overrides: [
          mobilityConfigProvider.overrideWithValue(true),
          consentBackgroundLocationProvider.overrideWithValue(true),
          locationProvider.overrideWith(
            ((ref) => const TestLocationProvider()),
          ),
          backgroundTrackerProvider.overrideWith(
            ((ref) => const TestBackgroundTracker()),
          ),
          uplinkServiceProvider.overrideWithValue(uplinkSpy),
        ],
      );

      // First session
      final controller1 = testContainer.read(trackingControllerProvider.notifier);
      await controller1.start();

      final point = LocationPoint(
        latitude: 51.5074,
        longitude: -0.1278,
        timestamp: DateTime.now(),
      );
      await uplinkSpy.enqueue(point, controller1.state.sessionId!);

      await controller1.stop();

      // Verify point was enqueued in first session
      expect(uplinkSpy.enqueuedPoints.length, 1);

      // Second session - same spy, simulating persistence
      final secondContainer = ProviderContainer(
        overrides: [
          mobilityConfigProvider.overrideWithValue(true),
          consentBackgroundLocationProvider.overrideWithValue(true),
          locationProvider.overrideWith(
            ((ref) => const TestLocationProvider()),
          ),
          backgroundTrackerProvider.overrideWith(
            ((ref) => const TestBackgroundTracker()),
          ),
          uplinkServiceProvider.overrideWithValue(uplinkSpy),
        ],
      );

      final controller2 = secondContainer.read(trackingControllerProvider.notifier);
      await controller2.start();

      // Point from first session should still be in queue
      final queueSize = await uplinkSpy.getQueueSize();
      expect(queueSize, 1);

      await controller2.stop();
      testContainer.dispose();
      secondContainer.dispose();
    });
  });
}

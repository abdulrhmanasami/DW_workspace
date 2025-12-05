// Tracking Controller Unit Tests
// Created by: Cursor B-mobility
// Purpose: Test TrackingController session lifecycle and consent enforcement
// Last updated: 2025-11-14

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobility_shims/mobility.dart';
import 'package:delivery_ways_clean/state/mobility/tracking_controller.dart';
import 'package:delivery_ways_clean/state/infra/triprecorder_provider.dart';
import '../support/mobility_stubs.dart';
import '../support/path_provider_stub.dart';

void main() {
  setUpAll(() {
    ensurePathProviderStubForTests();
  });

  group('TrackingController Tests', () {
    late ProviderContainer container;
    late TrackingController controller;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          mobilityConfigProvider.overrideWithValue(true),
          consentBackgroundLocationProvider.overrideWithValue(true),
          locationProvider.overrideWith(
            (ref) => const StubLocationProvider(),
          ),
          backgroundTrackerProvider.overrideWith(
            (ref) => const StubBackgroundTracker(),
          ),
          tripRecorderProvider.overrideWithValue(InMemoryTripRecorder()),
        ],
      );
      controller = container.read(trackingControllerProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is stopped', () {
      expect(controller.state.status, TrackingStatus.stopped);
      expect(controller.state.lastPoint, isNull);
      expect(controller.state.sessionId, isNull);
      expect(controller.state.errorMessage, isNull);
    });

    test('init checks permissions and service status', () async {
      // Mock providers to return stub implementations
      final testContainer = ProviderContainer(
        overrides: [
          mobilityConfigProvider.overrideWithValue(true),
          consentBackgroundLocationProvider.overrideWithValue(true),
          locationProvider.overrideWith(
            (ref) => const StubLocationProvider(),
          ),
          backgroundTrackerProvider.overrideWith(
            (ref) => const StubBackgroundTracker(),
          ),
          tripRecorderProvider.overrideWithValue(InMemoryTripRecorder()),
        ],
      );

      final testController = testContainer.read(trackingControllerProvider.notifier);
      await testController.init();

      expect(testController.state.permission, PermissionStatus.denied);
      testContainer.dispose();
    });

    test('start throws when tracking disabled', () async {
      final testContainer = ProviderContainer(
        overrides: [
          mobilityConfigProvider.overrideWithValue(false), // Disabled
          consentBackgroundLocationProvider.overrideWithValue(true),
          locationProvider.overrideWith(
            (ref) => const StubLocationProvider(),
          ),
          backgroundTrackerProvider.overrideWith(
            (ref) => const StubBackgroundTracker(),
          ),
          tripRecorderProvider.overrideWithValue(InMemoryTripRecorder()),
        ],
      );

      final testController = testContainer.read(trackingControllerProvider.notifier);

      expect(
        () => testController.start(),
        throwsA(isA<TrackingDisabledException>()),
      );

      testContainer.dispose();
    });

    test('start throws when consent denied', () async {
      final testContainer = ProviderContainer(
        overrides: [
          mobilityConfigProvider.overrideWithValue(true),
          consentBackgroundLocationProvider.overrideWithValue(false), // Denied
          locationProvider.overrideWith(
            (ref) => const StubLocationProvider(),
          ),
          backgroundTrackerProvider.overrideWith(
            (ref) => const StubBackgroundTracker(),
          ),
          tripRecorderProvider.overrideWithValue(InMemoryTripRecorder()),
        ],
      );

      final testController = testContainer.read(trackingControllerProvider.notifier);

      expect(
        () => testController.start(),
        throwsA(isA<ConsentDeniedException>()),
      );

      testContainer.dispose();
    });

    test('status transitions: stopped -> starting -> running', () async {
      final testContainer = ProviderContainer(
        overrides: [
          mobilityConfigProvider.overrideWithValue(true),
          consentBackgroundLocationProvider.overrideWithValue(true),
          locationProvider.overrideWith(
            (ref) => const TestLocationProvider(),
          ),
          backgroundTrackerProvider.overrideWith(
            (ref) => const TestBackgroundTracker(),
          ),
          tripRecorderProvider.overrideWithValue(InMemoryTripRecorder()),
        ],
      );

      final testController = testContainer.read(trackingControllerProvider.notifier);

      // Initial state
      expect(testController.state.status, TrackingStatus.stopped);

      // Start tracking and wait for completion
      await testController.start();

      // Final state should be running
      expect(testController.state.status, TrackingStatus.running);
      expect(testController.state.sessionId, isNotNull);

      testContainer.dispose();
    });

    test('stop transitions to stopped and cleans up', () async {
      final testContainer = ProviderContainer(
        overrides: [
          mobilityConfigProvider.overrideWithValue(true),
          consentBackgroundLocationProvider.overrideWithValue(true),
          locationProvider.overrideWith(
            (ref) => const TestLocationProvider(),
          ),
          backgroundTrackerProvider.overrideWith(
            (ref) => const TestBackgroundTracker(),
          ),
          tripRecorderProvider.overrideWithValue(InMemoryTripRecorder()),
        ],
      );

      final testController = testContainer.read(trackingControllerProvider.notifier);
      await testController.start();
      expect(testController.state.status, TrackingStatus.running);

      await testController.stop();
      expect(testController.state.status, TrackingStatus.stopped);

      testContainer.dispose();
    });

    test('error handling for service disabled', () async {
      final testContainer = ProviderContainer(
        overrides: [
          mobilityConfigProvider.overrideWithValue(true),
          consentBackgroundLocationProvider.overrideWithValue(true),
          locationProvider.overrideWith(
            (ref) {
              // Simulate service disabled
              return const StubLocationProvider();
            },
          ),
          backgroundTrackerProvider.overrideWith(
            (ref) => const StubBackgroundTracker(),
          ),
          tripRecorderProvider.overrideWithValue(InMemoryTripRecorder()),
        ],
      );

      final testController = testContainer.read(trackingControllerProvider.notifier);
      await testController.init();

      expect(testController.state.errorMessage, contains('غير مفعلة'));

      testContainer.dispose();
    });
  });

  group('TrackingConfig Tests', () {
    test('TrackingConfig creates with correct values', () {
      const config = TrackingConfig(
        sampleIntervalMs: 5000,
        accuracy: 'balanced',
        mode: 'auto',
      );

      expect(config.sampleIntervalMs, 5000);
      expect(config.accuracy, 'balanced');
      expect(config.mode, 'auto');
    });

    test('TrackingConfig toString works', () {
      const config = TrackingConfig(
        sampleIntervalMs: 3000,
        accuracy: 'high',
        mode: 'foreground',
      );

      final string = config.toString();
      expect(string, contains('3000ms'));
      expect(string, contains('high'));
      expect(string, contains('foreground'));
    });
  });
}

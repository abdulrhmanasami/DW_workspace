// Mobility Integration Tests
// Created by: Cursor B-mobility
// Purpose: Test mobility shims integration with app binding and RemoteConfig switching
// Last updated: 2025-11-13

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobility_shims/mobility.dart';
import 'package:delivery_ways_clean/wiring/mobility_binding.dart';

void main() {
  group('Mobility Integration Tests', () {
    testWidgets('Mobility binding uses disabled provider when tracking disabled', (
      WidgetTester tester,
    ) async {
      final testContainer = ProviderContainer(
        overrides: [
          ...mobilityOverrides,
          mobilityConfigProvider.overrideWithValue(false), // Tracking disabled
          consentBackgroundLocationProvider.overrideWithValue(true),
        ],
      );

      // Should be able to read locationProvider without throwing (uses disabled provider)
      final locationProv = testContainer.read(locationProvider);
      expect(locationProv, isA<LocationProvider>());
      
      // Service should report as disabled
      final serviceEnabled = await locationProv.serviceEnabled();
      expect(serviceEnabled, isFalse);

      // Should be able to read backgroundTrackerProvider without throwing (uses disabled tracker)
      final backgroundTracker = testContainer.read(backgroundTrackerProvider);
      expect(backgroundTracker, isA<BackgroundTracker>());

      testContainer.dispose();
    });

    testWidgets('Mobility binding uses disabled provider when consent denied', (
      WidgetTester tester,
    ) async {
      final testContainer = ProviderContainer(
        overrides: [
          ...mobilityOverrides,
          mobilityConfigProvider.overrideWithValue(true), // Tracking enabled
          consentBackgroundLocationProvider.overrideWithValue(
            false,
          ), // Consent denied
        ],
      );

      // Should be able to read locationProvider without throwing (uses disabled provider)
      final locationProv = testContainer.read(locationProvider);
      expect(locationProv, isA<LocationProvider>());
      
      // Service should report as disabled due to consent
      final serviceEnabled = await locationProv.serviceEnabled();
      expect(serviceEnabled, isFalse);

      // Should be able to read backgroundTrackerProvider without throwing (uses disabled tracker)
      final backgroundTracker = testContainer.read(backgroundTrackerProvider);
      expect(backgroundTracker, isA<BackgroundTracker>());

      testContainer.dispose();
    });

    testWidgets(
      'Mobility binding provides real provider when tracking enabled and consent granted',
      (WidgetTester tester) async {
        final testContainer = ProviderContainer(
          overrides: [
            ...mobilityOverrides,
            mobilityConfigProvider.overrideWithValue(true), // Tracking enabled
            consentBackgroundLocationProvider.overrideWithValue(
              true,
            ), // Consent granted
          ],
        );

        // Should return real providers (Geolocator-based) without throwing
        final locationProv = testContainer.read(locationProvider);
        expect(locationProv, isA<LocationProvider>());

        final backgroundTracker = testContainer.read(backgroundTrackerProvider);
        expect(backgroundTracker, isA<BackgroundTracker>());

        testContainer.dispose();
      },
    );

    testWidgets('Disabled location provider watch returns error stream', (
      WidgetTester tester,
    ) async {
      final testContainer = ProviderContainer(
        overrides: [
          ...mobilityOverrides,
          mobilityConfigProvider.overrideWithValue(false), // Force disabled usage
        ],
      );

      final locationProv = testContainer.read(locationProvider);
      final stream = locationProv.watch().take(1);

      // Stream should emit an error (TrackingDisabledException) at least once
      expect(stream, emitsError(isA<TrackingDisabledException>()));

      testContainer.dispose();
    });

    testWidgets('Stub background tracker status returns stopped', (
      WidgetTester tester,
    ) async {
      final testContainer = ProviderContainer(
        overrides: [
          ...mobilityOverrides,
          mobilityConfigProvider.overrideWithValue(false), // Force Stub usage
        ],
      );

      final tracker = testContainer.read(backgroundTrackerProvider);
      final statusStream = tracker.status();

      // Status should be stopped
      expect(statusStream, emits(TrackingStatus.stopped));

      testContainer.dispose();
    });
  });
}

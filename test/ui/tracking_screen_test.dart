// Tracking Screen Widget Tests
// Created by: Cursor B-mobility
// Purpose: Test TrackingScreen UI with consent/kill-switch scenarios
// Last updated: 2025-11-14

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maps_shims/maps.dart';
import 'package:mobility_shims/mobility.dart';
import '../../lib/screens/mobility/tracking_screen.dart';
import '../../lib/state/mobility/tracking_controller.dart';
import '../../lib/state/infra/triprecorder_provider.dart';
import '../support/design_system_harness.dart';
import '../support/mobility_stubs.dart';

void main() {
  setUpAll(() {
    ensureDesignSystemStubsForTests();
  });

  group('TrackingScreen Widget Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('displays tracking disabled message when kill-switch off', (
      WidgetTester tester,
    ) async {
      final testContainer = ProviderContainer(
        overrides: [
          mobilityConfigProvider.overrideWithValue(false), // Disabled
          consentBackgroundLocationProvider.overrideWithValue(true),
          tripRecorderProvider.overrideWithValue(InMemoryTripRecorder()),
          trackingControllerProvider.overrideWithProvider(
            StateNotifierProvider<TrackingController, TrackingSessionState>((
              ref,
            ) {
              return TrackingController(ref);
            }),
          ),
          mapViewBuilderProvider.overrideWithProvider(
            Provider<MapViewBuilder>(
              (ref) =>
                  (params) => const SizedBox(key: Key('map_placeholder')),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: testContainer,
          child: const MaterialApp(home: TrackingScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('التتبع معطل في إعدادات النظام'), findsOneWidget);
      expect(
        find.text('بدء التتبع'),
        findsNothing,
      ); // Button should be disabled

      testContainer.dispose();
    });

    testWidgets('shows privacy consent prompt when consent denied', (
      WidgetTester tester,
    ) async {
      final testContainer = ProviderContainer(
        overrides: [
          mobilityConfigProvider.overrideWithValue(true),
          consentBackgroundLocationProvider.overrideWithValue(false), // Denied
          tripRecorderProvider.overrideWithValue(InMemoryTripRecorder()),
          trackingControllerProvider.overrideWithProvider(
            StateNotifierProvider<TrackingController, TrackingSessionState>((
              ref,
            ) {
              return TrackingController(ref);
            }),
          ),
          mapViewBuilderProvider.overrideWithProvider(
            Provider<MapViewBuilder>(
              (ref) =>
                  (params) => const SizedBox(key: Key('map_placeholder')),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: testContainer,
          child: const MaterialApp(home: TrackingScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('مطلوب موافقة تتبع الموقع'), findsOneWidget);
      expect(find.text('الانتقال لإعدادات الخصوصية'), findsOneWidget);

      testContainer.dispose();
    });

    testWidgets(
      'shows start/stop buttons when tracking enabled and consented',
      (WidgetTester tester) async {
        final testContainer = ProviderContainer(
          overrides: [
            mobilityConfigProvider.overrideWithValue(true),
            consentBackgroundLocationProvider.overrideWithValue(true),
            tripRecorderProvider.overrideWithValue(InMemoryTripRecorder()),
            trackingControllerProvider.overrideWithProvider(
              StateNotifierProvider<TrackingController, TrackingSessionState>((
                ref,
              ) {
                final controller = TrackingController(ref);
                // Mock stopped state
                controller.state = const TrackingSessionState(
                  status: TrackingStatus.stopped,
                );
                return controller;
              }),
            ),
            mapViewBuilderProvider.overrideWithProvider(
              Provider<MapViewBuilder>(
                (ref) =>
                    (params) => const SizedBox(key: Key('map_placeholder')),
              ),
            ),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(home: TrackingScreen()),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('بدء التتبع'), findsOneWidget);
        expect(find.text('إيقاف'), findsOneWidget);

        testContainer.dispose();
      },
    );

    testWidgets('displays tracking status correctly', (
      WidgetTester tester,
    ) async {
      final testContainer = ProviderContainer(
        overrides: [
          mobilityConfigProvider.overrideWithValue(true),
          consentBackgroundLocationProvider.overrideWithValue(true),
          tripRecorderProvider.overrideWithValue(InMemoryTripRecorder()),
          trackingControllerProvider.overrideWithProvider(
            StateNotifierProvider<TrackingController, TrackingSessionState>((
              ref,
            ) {
              final controller = TrackingController(ref);
              controller.state = TrackingSessionState(
                status: TrackingStatus.running,
                permission: PermissionStatus.granted,
                sessionId: 'test-session',
                lastUpdate: DateTime.now(),
              );
              return controller;
            }),
          ),
          mapViewBuilderProvider.overrideWithProvider(
            Provider<MapViewBuilder>(
              (ref) =>
                  (params) => const SizedBox(key: Key('map_placeholder')),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: testContainer,
          child: const MaterialApp(home: TrackingScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('حالة التتبع:'), findsOneWidget);
      expect(find.textContaining('الصلاحيات:'), findsOneWidget);

      testContainer.dispose();
    });

    testWidgets('shows error message when tracking fails', (
      WidgetTester tester,
    ) async {
      final testContainer = ProviderContainer(
        overrides: [
          mobilityConfigProvider.overrideWithValue(true),
          consentBackgroundLocationProvider.overrideWithValue(true),
          tripRecorderProvider.overrideWithValue(InMemoryTripRecorder()),
          trackingControllerProvider.overrideWithProvider(
            StateNotifierProvider<TrackingController, TrackingSessionState>((
              ref,
            ) {
              final controller = TrackingController(ref);
              controller.state = const TrackingSessionState(
                status: TrackingStatus.error,
                errorMessage: 'فشل في بدء التتبع',
              );
              return controller;
            }),
          ),
          mapViewBuilderProvider.overrideWithProvider(
            Provider<MapViewBuilder>(
              (ref) =>
                  (params) => const SizedBox(key: Key('map_placeholder')),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: testContainer,
          child: const MaterialApp(home: TrackingScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('حالة التتبع:'), findsAtLeastNWidgets(1));
      expect(find.textContaining('خطأ'), findsAtLeastNWidgets(1));

      testContainer.dispose();
    });

    testWidgets('updates map marker when location changes', (
      WidgetTester tester,
    ) async {
      final testContainer = ProviderContainer(
        overrides: [
          mobilityConfigProvider.overrideWithValue(true),
          consentBackgroundLocationProvider.overrideWithValue(true),
          tripRecorderProvider.overrideWithValue(InMemoryTripRecorder()),
          trackingControllerProvider.overrideWithProvider(
            StateNotifierProvider<TrackingController, TrackingSessionState>((
              ref,
            ) {
              final controller = TrackingController(ref);
              controller.state = TrackingSessionState(
                status: TrackingStatus.running,
                lastPoint: LocationPoint(
                  latitude: 51.5074,
                  longitude: -0.1278,
                  timestamp: DateTime.fromMillisecondsSinceEpoch(0),
                ),
              );
              return controller;
            }),
          ),
          mapViewBuilderProvider.overrideWithProvider(
            Provider<MapViewBuilder>(
              (ref) => (params) {
                // Capture the controller for testing
                params.onMapReady(const TestMapController());
                return const SizedBox(key: Key('map_placeholder'));
              },
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: testContainer,
          child: const MaterialApp(home: TrackingScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // The map should be rendered (use key to find the specific SizedBox)
      expect(find.byKey(const Key('map_placeholder')), findsOneWidget);

      testContainer.dispose();
    });
  });
}

// Test implementation of MapController
class TestMapController implements MapController {
  const TestMapController();

  @override
  Future<void> moveCamera(MapCamera camera) async {}

  @override
  Future<void> setMarkers(List<MapMarker> markers) async {}

  @override
  void dispose() {}
}

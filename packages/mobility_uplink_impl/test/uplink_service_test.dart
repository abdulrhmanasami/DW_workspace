// Uplink Service Tests
// Created by: Cursor B-mobility
// Purpose: Test complete uplink service functionality
// Last updated: 2025-11-14

import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobility_shims/mobility.dart';
import 'package:mobility_uplink_impl/src/uplink_client.dart';
import 'package:mobility_uplink_impl/src/uplink_service.dart';
import 'package:mobility_uplink_impl/uplink_config.dart';

void main() {
  group('UplinkService Tests', () {
    late UplinkConfig config;
    late UplinkService service;

    setUp(() {
      config = UplinkConfig(
        uplinkEnabled: true,
        flushInterval: const Duration(seconds: 10),
        batchSize: 2, // Small batch for testing
        maxQueue: 10,
        endpoint: Uri.parse('https://api.example.com'),
        requestTimeout: const Duration(seconds: 15),
        maxRetries: 0, // Disable retries for testing
      );

      final mockClient = MockClient((request) async {
        return http.Response('{"uploaded": true}', 200);
      });

      service = UplinkService(
        config,
        client: UplinkClient(config, httpClient: mockClient),
      );
    });

    tearDown(() {
      service.dispose();
    });

    test('enqueue adds point to queue when enabled', () async {
      await service.initialize();

      final point = LocationPoint(
        latitude: 51.5074,
        longitude: -0.1278,
        timestamp: DateTime.now(),
      );

      await service.enqueue(point, 'test-session');

      final queueSize = await service.getQueueSize();
      expect(queueSize, 1);
    });

    test('enqueue skips when uplink disabled', () async {
      final disabledConfig = UplinkConfig(
        uplinkEnabled: false,
        flushInterval: const Duration(seconds: 10),
        batchSize: 2,
        maxQueue: 10,
        endpoint: Uri.parse('https://api.example.com'),
        requestTimeout: const Duration(seconds: 15),
        maxRetries: 0,
      );

      final disabledService = UplinkService(disabledConfig);
      await disabledService.initialize();

      final point = LocationPoint(
        latitude: 51.5074,
        longitude: -0.1278,
        timestamp: DateTime.now(),
      );

      await disabledService.enqueue(point, 'test-session');

      final queueSize = await disabledService.getQueueSize();
      expect(queueSize, 0);
    });

    test('flush uploads batched points', () async {
      await service.initialize();

      for (int i = 0; i < 3; i++) {
        final point = LocationPoint(
          latitude: 51.5074 + i,
          longitude: -0.1278,
          timestamp: DateTime.now(),
        );
        await service.enqueue(point, 'test-session');
      }

      final initialSize = await service.getQueueSize();
      expect(initialSize, 3);

      await service.flush();

      final finalSize = await service.getQueueSize();
      expect(finalSize, 1);
    });

    test('flush with force uploads all remaining points', () async {
      await service.initialize();

      for (int i = 0; i < 2; i++) {
        final point = LocationPoint(
          latitude: 51.5074 + i,
          longitude: -0.1278,
          timestamp: DateTime.now(),
        );
        await service.enqueue(point, 'test-session');
      }

      await service.flush(force: true);

      final finalSize = await service.getQueueSize();
      expect(finalSize, 0);
    });

    test('clearQueue removes all queued items', () async {
      await service.initialize();

      for (int i = 0; i < 3; i++) {
        final point = LocationPoint(
          latitude: 51.5074 + i,
          longitude: -0.1278,
          timestamp: DateTime.now(),
        );
        await service.enqueue(point, 'test-session');
      }

      await service.clearQueue();

      final size = await service.getQueueSize();
      expect(size, 0);
    });

    test('periodic flush is scheduled when enabled', () async {
      await service.initialize();
      expect((service as dynamic)._flushTimer, isNotNull);
    });

    test('dispose cancels periodic flush', () {
      service.dispose();
      expect((service as dynamic)._flushTimer?.isActive, isFalse);
    });
  });
}

// Uplink Queue Tests
// Created by: Cursor B-mobility
// Purpose: Test offline queue functionality with persistence and cleanup
// Last updated: 2025-11-14

import 'package:test/test.dart';
import 'package:mobility_shims/mobility.dart';
import 'package:mobility_uplink_impl/src/uplink_queue.dart';

void main() {
  group('UplinkQueue Tests', () {
    late UplinkQueue queue;

    setUp(() async {
      queue = UplinkQueue(maxQueueSize: 10);
    });

    test('enqueue adds item to queue', () async {
      final point = LocationPoint(
        latitude: 51.5074,
        longitude: -0.1278,
        timestamp: DateTime.now(),
      );
      final item = UplinkQueueItem(
        sessionId: 'test-session',
        point: point,
        queuedAt: DateTime.now(),
      );

      await queue.initialize();
      await queue.enqueue(item);

      final size = await queue.getQueueSize();
      expect(size, 1);
    });

    test('peekBatch returns correct number of items', () async {
      await queue.initialize();

      // Add multiple items
      for (int i = 0; i < 5; i++) {
        final point = LocationPoint(
          latitude: 51.5074 + i,
          longitude: -0.1278,
          timestamp: DateTime.now(),
        );
        final item = UplinkQueueItem(
          sessionId: 'test-session',
          point: point,
          queuedAt: DateTime.now(),
        );
        await queue.enqueue(item);
      }

      final batch = await queue.peekBatch(3);
      expect(batch.length, 3);
    });

    test('removeBatch removes items from queue', () async {
      await queue.initialize();

      for (int i = 0; i < 5; i++) {
        final point = LocationPoint(
          latitude: 51.5074 + i,
          longitude: -0.1278,
          timestamp: DateTime.now(),
        );
        final item = UplinkQueueItem(
          sessionId: 'test-session',
          point: point,
          queuedAt: DateTime.now(),
        );
        await queue.enqueue(item);
      }

      await queue.removeBatch(3);

      final size = await queue.getQueueSize();
      expect(size, 2);
    });

    test('rotation maintains max queue size', () async {
      final smallQueue = UplinkQueue(maxQueueSize: 3);
      await smallQueue.initialize();

      for (int i = 0; i < 5; i++) {
        final point = LocationPoint(
          latitude: 51.5074 + i,
          longitude: -0.1278,
          timestamp: DateTime.now(),
        );
        final item = UplinkQueueItem(
          sessionId: 'test-session',
          point: point,
          queuedAt: DateTime.now(),
        );
        await smallQueue.enqueue(item);
      }

      final size = await smallQueue.getQueueSize();
      expect(size, 3); // Should be rotated to max size
    });

    test('clear removes all items', () async {
      await queue.initialize();

      for (int i = 0; i < 3; i++) {
        final point = LocationPoint(
          latitude: 51.5074 + i,
          longitude: -0.1278,
          timestamp: DateTime.now(),
        );
        final item = UplinkQueueItem(
          sessionId: 'test-session',
          point: point,
          queuedAt: DateTime.now(),
        );
        await queue.enqueue(item);
      }

      await queue.clear();
      final size = await queue.getQueueSize();
      expect(size, 0);
    });

    test('persistence across queue instances', () async {
      await queue.initialize();

      final point = LocationPoint(
        latitude: 51.5074,
        longitude: -0.1278,
        timestamp: DateTime.now(),
      );
      final item = UplinkQueueItem(
        sessionId: 'test-session',
        point: point,
        queuedAt: DateTime.now(),
      );
      await queue.enqueue(item);

      final newQueue = UplinkQueue(maxQueueSize: 10);
      await newQueue.initialize();

      final size = await newQueue.getQueueSize();
      expect(size, 1);
    });
  });
}

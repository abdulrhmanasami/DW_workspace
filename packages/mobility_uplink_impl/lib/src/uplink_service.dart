// Uplink Service - Main service for location data transmission
// Created by: Cursor B-mobility
// Purpose: Coordinate queue, client, and configuration for reliable data transmission
// Last updated: 2025-11-14

import 'dart:async';
import 'package:mobility_shims/mobility.dart';
import '../uplink_config.dart';
import 'uplink_client.dart';
import 'uplink_endpoints.dart';
import 'uplink_queue.dart';

/// Uplink service for mobility tracking data
class UplinkService {
  final UplinkConfig config;
  final UplinkClient _client;
  final UplinkQueue _queue;
  final UplinkEndpoints _endpoints;

  Timer? _flushTimer;
  bool _isInitialized = false;

  UplinkService(this.config, {UplinkClient? client, UplinkQueue? queue})
      : _client = client ?? UplinkClient(config),
        _queue = queue ?? UplinkQueue(maxQueueSize: config.maxQueue),
        _endpoints = UplinkEndpoints(config.endpoint);

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _queue.initialize();

    // Start periodic flush timer if enabled
    if (config.uplinkEnabled) {
      _startPeriodicFlush();
    }

    _isInitialized = true;
  }

  /// Enqueue a location point for transmission
  Future<void> enqueue(LocationPoint point, String sessionId) async {
    await _ensureInitialized();

    // Don't enqueue if uplink is disabled
    if (!config.uplinkEnabled) {
      return;
    }

    final item = UplinkQueueItem(
      sessionId: sessionId,
      point: point,
      queuedAt: DateTime.now(),
    );

    await _queue.enqueue(item);
  }

  /// Flush queued items to server
  Future<void> flush({bool force = false}) async {
    await _ensureInitialized();

    if (!config.uplinkEnabled) {
      return;
    }

    final batch = await _queue.peekBatch(config.batchSize);
    if (batch.isEmpty) {
      return;
    }

    // Group by session ID
    final sessionBatches = <String, List<UplinkQueueItem>>{};
    for (final item in batch) {
      sessionBatches.putIfAbsent(item.sessionId, () => []).add(item);
    }

    // Upload each session batch
    var uploadedCount = 0;
    for (final entry in sessionBatches.entries) {
      final sessionId = entry.key;
      final items = entry.value;

      try {
        await _uploadBatch(sessionId, items);
        uploadedCount += items.length;
      } catch (e) {
        // Log error but continue with other sessions
        // In production, this would use proper logging
        print('Failed to upload batch for session $sessionId: $e');

        // If not forced and this is a network/server error, don't remove from queue
        if (!force && _isRetryableError(e)) {
          continue;
        }
      }
    }

    // Remove successfully uploaded items
    if (uploadedCount > 0) {
      await _queue.removeBatch(uploadedCount);
    }
  }

  /// Get current queue size
  Future<int> getQueueSize() async {
    await _ensureInitialized();
    return _queue.getQueueSize();
  }

  /// Clear all queued data
  Future<void> clearQueue() async {
    await _ensureInitialized();
    await _queue.clear();
  }

  /// Dispose the service
  void dispose() {
    _flushTimer?.cancel();
    _client.dispose();
  }

  /// Ensure service is initialized
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Start periodic flush timer
  void _startPeriodicFlush() {
    _flushTimer = Timer.periodic(config.flushInterval, (_) => flush());
  }

  /// Upload a batch of points for a session
  Future<void> _uploadBatch(
      String sessionId, List<UplinkQueueItem> items) async {
    final points = items
        .map((item) => {
              'latitude': item.point.latitude,
              'longitude': item.point.longitude,
              'accuracy': item.point.accuracy,
              'speed': item.point.speed,
              'timestamp': (item.point.timestamp ?? item.queuedAt).toIso8601String(),
              'recordedAt': item.queuedAt.toIso8601String(),
            })
        .toList();

    final payload = {
      'sessionId': sessionId,
      'points': points,
    };

    final uri = _endpoints.uploadPointsBatch(sessionId);
    await _client.post(uri, payload);
  }

  /// Check if error is retryable
  bool _isRetryableError(Object error) {
    // Network errors and server errors are retryable
    return error is UplinkNetworkException ||
        error is UplinkTimeoutException ||
        (error is UplinkHttpException &&
            error.statusCode != null &&
            error.statusCode! >= 400 &&
            error.statusCode! < 500);
  }
}

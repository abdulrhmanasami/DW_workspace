// Uplink Queue - Offline storage and batching
// Created by: Cursor B-mobility
// Purpose: Persistent queue for location points with automatic cleanup
// Last updated: 2025-11-14

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:mobility_shims/mobility.dart';

/// Queue item for uplink
class UplinkQueueItem {
  final String sessionId;
  final LocationPoint point;
  final DateTime queuedAt;

  const UplinkQueueItem({
    required this.sessionId,
    required this.point,
    required this.queuedAt,
  });

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'latitude': point.latitude,
        'longitude': point.longitude,
        'accuracy': point.accuracy,
        'speed': point.speed,
        'timestamp': (point.timestamp ?? queuedAt).toIso8601String(),
        'queuedAt': queuedAt.toIso8601String(),
      };

  factory UplinkQueueItem.fromJson(Map<String, dynamic> json) {
    return UplinkQueueItem(
      sessionId: json['sessionId'] as String,
      point: LocationPoint(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        accuracy: (json['accuracy'] as num?)?.toDouble(),
        speed: (json['speed'] as num?)?.toDouble(),
        timestamp: DateTime.parse(json['timestamp'] as String),
      ),
      queuedAt: DateTime.parse(json['queuedAt'] as String),
    );
  }
}

/// Persistent queue for uplink operations
class UplinkQueue {
  final String _queueDirName = 'mobility_uplink';
  final String _queueFileName = 'queue.jsonl';
  final int maxQueueSize;

  File? _queueFile;
  bool _initialized = false;

  UplinkQueue({required this.maxQueueSize});

  /// Initialize the queue file
  Future<void> initialize() async {
    if (_initialized) return;

    final appDir = await getApplicationDocumentsDirectory();
    final queueDir = Directory(path.join(appDir.path, _queueDirName));

    // Create directory if it doesn't exist
    if (!await queueDir.exists()) {
      await queueDir.create(recursive: true);
    }

    _queueFile = File(path.join(queueDir.path, _queueFileName));
    _initialized = true;

    // Clean up old entries on initialization
    await _cleanupOldEntries();
  }

  /// Add item to queue
  Future<void> enqueue(UplinkQueueItem item) async {
    await _ensureInitialized();

    final line = jsonEncode(item.toJson());
    await _queueFile!.writeAsString('$line\n', mode: FileMode.append);

    // Rotate if queue is too large
    await _rotateIfNeeded();
  }

  /// Get batch of items for upload (doesn't remove them)
  Future<List<UplinkQueueItem>> peekBatch(int batchSize) async {
    await _ensureInitialized();

    if (!await _queueFile!.exists()) {
      return [];
    }

    final lines = await _queueFile!.readAsLines();
    final items = <UplinkQueueItem>[];

    for (final line in lines.take(batchSize)) {
      try {
        final json = jsonDecode(line) as Map<String, dynamic>;
        items.add(UplinkQueueItem.fromJson(json));
      } catch (e) {
        // Skip corrupted lines
        continue;
      }
    }

    return items;
  }

  /// Remove uploaded items from queue
  Future<void> removeBatch(int count) async {
    await _ensureInitialized();

    if (!await _queueFile!.exists()) {
      return;
    }

    final lines = await _queueFile!.readAsLines();
    if (count >= lines.length) {
      // Remove entire file
      await _queueFile!.delete();
    } else {
      // Keep remaining lines
      final remainingLines = lines.sublist(count);
      await _queueFile!.writeAsString('${remainingLines.join('\n')}\n');
    }
  }

  /// Get current queue size
  Future<int> getQueueSize() async {
    await _ensureInitialized();

    if (!await _queueFile!.exists()) {
      return 0;
    }

    final lines = await _queueFile!.readAsLines();
    return lines.length;
  }

  /// Clear all queued items
  Future<void> clear() async {
    await _ensureInitialized();

    if (await _queueFile!.exists()) {
      await _queueFile!.delete();
    }
  }

  /// Ensure queue is initialized
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  /// Rotate queue file if it gets too large
  Future<void> _rotateIfNeeded() async {
    final size = await getQueueSize();
    if (size >= maxQueueSize) {
      // Keep only the most recent half
      final lines = await _queueFile!.readAsLines();
      final keepCount = (maxQueueSize ~/ 2).clamp(1, lines.length);
      final remainingLines = lines.sublist(lines.length - keepCount);

      await _queueFile!.writeAsString('${remainingLines.join('\n')}\n');
    }
  }

  /// Clean up entries older than 7 days
  Future<void> _cleanupOldEntries() async {
    if (!await _queueFile!.exists()) {
      return;
    }

    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final lines = await _queueFile!.readAsLines();
    final validLines = <String>[];

    for (final line in lines) {
      try {
        final json = jsonDecode(line) as Map<String, dynamic>;
        final item = UplinkQueueItem.fromJson(json);
        if (item.queuedAt.isAfter(cutoff)) {
          validLines.add(line);
        }
      } catch (e) {
        // Skip corrupted lines
        continue;
      }
    }

    if (validLines.length != lines.length) {
      await _queueFile!.writeAsString('${validLines.join('\n')}\n');
    }
  }
}

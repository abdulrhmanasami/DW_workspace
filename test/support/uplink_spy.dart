// Uplink Spy for Testing
// Created by: Cursor A
// Purpose: Spy implementation for uplink service testing
// Last updated: 2025-11-26

import 'package:mobility_shims/mobility.dart';
import 'package:mobility_uplink_impl/mobility_uplink_impl.dart' show UplinkService;

/// Spy implementation for tests:
/// - يجمع كل النقاط التي تم تمريرها لـ enqueue.
/// - لا يكتب على الشبكة ولا على القرص.
class SpyUplinkService implements UplinkService {
  final List<EnqueuedPoint> enqueuedPoints = [];
  int _flushCount = 0;
  bool _forceFlushCalled = false;

  /// Record of all enqueue calls with sessionId
  List<EnqueuedPoint> get points => List.unmodifiable(enqueuedPoints);

  /// Number of times flush was called
  int get flushCount => _flushCount;

  /// Whether force flush was called
  bool get forceFlushCalled => _forceFlushCalled;

  @override
  Future<void> initialize() async {
    // No-op for spy - ready immediately
  }

  @override
  Future<void> enqueue(LocationPoint point, String sessionId) async {
    enqueuedPoints.add(EnqueuedPoint(point: point, sessionId: sessionId));
  }

  @override
  Future<void> flush({bool force = false}) async {
    _flushCount++;
    if (force) {
      _forceFlushCalled = true;
    }
  }

  @override
  Future<int> getQueueSize() async {
    return enqueuedPoints.length;
  }

  @override
  Future<void> clearQueue() async {
    enqueuedPoints.clear();
  }

  @override
  void dispose() {
    // No-op for spy
  }

  /// Reset spy state for fresh test
  void reset() {
    enqueuedPoints.clear();
    _flushCount = 0;
    _forceFlushCalled = false;
  }

  // Handle any other method calls gracefully
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Record of an enqueued point with its session ID
class EnqueuedPoint {
  final LocationPoint point;
  final String sessionId;

  const EnqueuedPoint({required this.point, required this.sessionId});
}


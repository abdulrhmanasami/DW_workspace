/// Map Port Providers - Track B Ticket #203
/// Purpose: Provide MapPort dependency with NoOp implementation for testing
/// Created by: Track B - Ticket #203
/// Last updated: 2025-12-03

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:maps_shims/maps_shims.dart';

/// NoOp implementation of MapPort that does nothing.
/// Used in runtime when map integration is not available or for testing.
class NoOpMapPort implements MapPort {
  @override
  Sink<MapCommand> get commands => const _NoOpSink();

  @override
  Stream<MapEvent> get events => const Stream.empty();

  @override
  void dispose() {
    // no-op
  }
}

class _NoOpSink implements Sink<MapCommand> {
  const _NoOpSink();

  @override
  void add(MapCommand data) {
    // ignore
  }

  @override
  void close() {
    // ignore
  }
}

/// Global provider for MapPort dependency.
/// Defaults to NoOpMapPort for runtime, can be overridden in tests.
final rideMapPortProvider = Provider<MapPort>((ref) {
  // Later, this will be replaced with Google Maps / Map Stub implementation
  final port = NoOpMapPort();
  ref.onDispose(port.dispose);
  return port;
});

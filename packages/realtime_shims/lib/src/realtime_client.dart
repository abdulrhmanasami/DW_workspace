/// Component: Realtime Client
/// Created by: Cursor (auto-generated)
/// Purpose: Interface for realtime communication
/// Last updated: 2025-11-01

abstract class RealtimeClient {
  Future<void> connect();
  Future<void> disconnect();
  Future<void> send(String event, dynamic data);
  Stream<dynamic> get onEvent;
  Stream<ConnectionState> get connectionStateStream;

  // Channel-based API for compatibility
  RealtimeChannel channel(String channelName);
}

enum ConnectionState {
  connecting,
  connected,
  disconnected,
  error,
}

// Channel-based API interfaces
abstract class RealtimeChannel {
  String get name;
  Future<void> subscribe();
  Future<void> unsubscribe();
  Stream<RealtimeEvent> onEvent();
}

class RealtimeEvent {
  final String type;
  final dynamic data;
  final DateTime timestamp;

  RealtimeEvent({
    required this.type,
    this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Subscription contract
abstract class Subscription {
  String get id;
  String get channel;
  bool get isActive;
  Future<void> unsubscribe();
}

/// Channel contract
abstract class Channel {
  String get name;
  bool get isJoined;
  Future<void> join();
  Future<void> leave();
  Future<void> send(String event, dynamic data);
  Stream<RealtimeEvent> get events;
}

/// Realtime service contract
abstract class RealtimeService {
  Future<void> initialize();
  Future<void> connect();
  Future<void> disconnect();
  Channel createChannel(String name);
  Subscription subscribe(String channel, String event);
}

/// No-Op implementation for safe fallback when realtime services are not available
class NoOpRealtimeClient implements RealtimeClient {
  const NoOpRealtimeClient();

  @override
  Future<void> connect() async {
    // No-op: Realtime services not available
  }

  @override
  Future<void> disconnect() async {
    // No-op: Realtime services not available
  }

  @override
  Future<void> send(String event, dynamic data) async {
    // No-op: Realtime services not available
  }

  @override
  Stream<dynamic> get onEvent => const Stream.empty();

  @override
  Stream<ConnectionState> get connectionStateStream async* {
    yield ConnectionState.disconnected;
  }

  @override
  RealtimeChannel channel(String channelName) {
    return NoOpRealtimeChannel(channelName);
  }
}

/// No-Op implementation for realtime channels
class NoOpRealtimeChannel implements RealtimeChannel {
  @override
  final String name;

  const NoOpRealtimeChannel(this.name);

  @override
  Future<void> subscribe() async {
    // No-op: Realtime services not available
  }

  @override
  Future<void> unsubscribe() async {
    // No-op: Realtime services not available
  }

  @override
  Stream<RealtimeEvent> onEvent() => const Stream.empty();
}

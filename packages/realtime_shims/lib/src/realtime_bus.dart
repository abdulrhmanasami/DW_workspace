import 'dart:async';

import 'realtime_client.dart';

/// Component: Realtime Bus
/// Created by: Cursor (auto-generated)
/// Purpose: Production-grade realtime messaging bus interface
/// Last updated: 2025-11-02

/// Realtime messaging bus interface for publish-subscribe communication
/// This provides a clean abstraction for realtime messaging across different transport layers
abstract class RealtimeBus {
  /// Publishes a message to a specific topic/channel
  Future<void> publish(String topic, dynamic message);

  /// Subscribes to messages on a specific topic/channel
  /// Returns a stream of messages for the subscribed topic
  Stream<RealtimeMessage> subscribe(String topic);

  /// Unsubscribes from a specific topic/channel
  Future<void> unsubscribe(String topic);

  /// Unsubscribes from all topics/channels
  Future<void> unsubscribeAll();

  /// Gets the current connection status
  Future<BusConnectionStatus> getConnectionStatus();

  /// Stream of connection status changes
  Stream<BusConnectionStatus> get connectionStatusStream;

  /// Closes the bus and cleans up resources
  Future<void> close();
}

/// Message wrapper for realtime bus communication
class RealtimeMessage {
  final String topic;
  final dynamic payload;
  final String? senderId;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  RealtimeMessage({
    required this.topic,
    required this.payload,
    this.senderId,
    DateTime? timestamp,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Creates a message from JSON data
  factory RealtimeMessage.fromJson(Map<String, dynamic> json) {
    return RealtimeMessage(
      topic: json['topic'] as String,
      payload: json['payload'],
      senderId: json['senderId'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Converts message to JSON
  Map<String, dynamic> toJson() {
    return {
      'topic': topic,
      'payload': payload,
      'senderId': senderId,
      'timestamp': timestamp.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  @override
  String toString() {
    return 'RealtimeMessage(topic: $topic, payload: $payload, senderId: $senderId, timestamp: $timestamp)';
  }
}

/// Connection status for the realtime bus
enum BusConnectionStatus {
  /// Bus is disconnected
  disconnected,

  /// Bus is connecting
  connecting,

  /// Bus is connected
  connected,

  /// Bus encountered an error
  error,

  /// Bus is reconnecting after error
  reconnecting,
}

/// Configuration for realtime bus
class RealtimeBusConfig {
  final String? url;
  final Map<String, String>? headers;
  final Duration reconnectDelay;
  final int maxReconnectAttempts;
  final Duration heartbeatInterval;
  final bool enableCompression;

  const RealtimeBusConfig({
    this.url,
    this.headers,
    this.reconnectDelay = const Duration(seconds: 5),
    this.maxReconnectAttempts = 5,
    this.heartbeatInterval = const Duration(seconds: 30),
    this.enableCompression = false,
  });

  /// Creates a config for development environment
  factory RealtimeBusConfig.development() {
    return const RealtimeBusConfig(
      url: 'ws://localhost:8080',
      reconnectDelay: Duration(seconds: 1),
      maxReconnectAttempts: 10,
    );
  }

  /// Creates a config for production environment
  factory RealtimeBusConfig.production({
    required String url,
    Map<String, String>? headers,
  }) {
    return RealtimeBusConfig(
      url: url,
      headers: headers,
      reconnectDelay: const Duration(seconds: 5),
      maxReconnectAttempts: 5,
      heartbeatInterval: const Duration(seconds: 30),
      enableCompression: true,
    );
  }
}

/// Extension methods for RealtimeBus compatibility with RealtimeClient
extension RealtimeBusExtensions on RealtimeBus {
  /// Converts RealtimeBus to RealtimeClient interface
  RealtimeClient asRealtimeClient() {
    return _RealtimeBusAdapter(this);
  }
}

/// Adapter to convert RealtimeBus to RealtimeClient
class _RealtimeBusAdapter implements RealtimeClient {
  final RealtimeBus _bus;

  _RealtimeBusAdapter(this._bus);

  @override
  Future<void> connect() async {
    // Bus is always "connected" in this abstraction
    return;
  }

  @override
  Future<void> disconnect() async {
    await _bus.close();
  }

  @override
  Future<void> send(String event, dynamic data) async {
    await _bus.publish(event, data);
  }

  @override
  Stream<dynamic> get onEvent {
    // This is a simplified implementation
    // In practice, you'd need to subscribe to all topics
    return const Stream.empty();
  }

  @override
  Stream<ConnectionState> get connectionStateStream {
    return _bus.connectionStatusStream.map((status) {
      switch (status) {
        case BusConnectionStatus.disconnected:
          return ConnectionState.disconnected;
        case BusConnectionStatus.connecting:
          return ConnectionState.connecting;
        case BusConnectionStatus.connected:
          return ConnectionState.connected;
        case BusConnectionStatus.error:
          return ConnectionState.error;
        case BusConnectionStatus.reconnecting:
          return ConnectionState.connecting;
      }
    });
  }

  @override
  RealtimeChannel channel(String channelName) {
    return _RealtimeChannelAdapter(_bus, channelName);
  }
}

/// Adapter for realtime channels
class _RealtimeChannelAdapter implements RealtimeChannel {
  final RealtimeBus _bus;
  final String _channelName;

  _RealtimeChannelAdapter(this._bus, this._channelName);

  @override
  String get name => _channelName;

  @override
  Future<void> subscribe() async {
    // Subscription happens when listening to onEvent stream
  }

  @override
  Future<void> unsubscribe() async {
    await _bus.unsubscribe(_channelName);
  }

  @override
  Stream<RealtimeEvent> onEvent() {
    return _bus.subscribe(_channelName).map((message) {
      return RealtimeEvent(
        type: message.topic,
        data: message.payload,
        timestamp: message.timestamp,
      );
    });
  }
}

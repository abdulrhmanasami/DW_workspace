/// Component: WebSocket Manager
/// Created by: Cursor (auto-generated)
/// Purpose: Interface for WebSocket connections
/// Last updated: 2025-10-24

abstract class WebSocketManager {
  Future<void> connect(String url);
  Future<void> disconnect();
  Future<void> send(String message);
  Stream<String> get onMessage;
  Stream<bool> get isConnectedStream;
}

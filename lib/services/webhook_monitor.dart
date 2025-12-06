import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:core/core.dart' as core;
import 'package:delivery_ways_clean/config/config_manager.dart';

/// Component: WebhookMonitor
/// Created by: Cursor (auto-generated)
/// Purpose: Monitor and correlate webhook events with payment intents
/// Last updated: 2025-01-27

/// Webhook monitoring service
class WebhookMonitor {
  static WebhookMonitor? _instance;
  static WebhookMonitor get instance => _instance ??= WebhookMonitor._();

  WebhookMonitor._();

  // Event tracking
  final Map<String, DateTime> _pendingIntents = <String, DateTime>{};
  final Map<String, List<core.WebhookEvent>> _intentEvents =
      <String, List<core.WebhookEvent>>{};
  final StreamController<core.WebhookEvent> _eventController =
      StreamController.broadcast();

  // Configuration
  String? _webhookEndpoint;
  Timer? _monitoringTimer;
  bool _isMonitoring = false;

  void _logTelemetry(String type, Map<String, Object?> data) {
    // TODO: wire to foundation_shims.Telemetry
    debugPrint('[telemetry] $type: $data');
  }

  /// Initialize webhook monitoring
  void initialize({String? webhookEndpoint}) {
    _webhookEndpoint = webhookEndpoint;

    if (kDebugMode) {
      debugPrint('🔗 WebhookMonitor initialized');
      if (_webhookEndpoint != null) {
        debugPrint('   Endpoint: $_webhookEndpoint');
      }
    }
  }

  /// Start monitoring webhook events
  void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;

    // Poll for webhook events every 30 seconds
    _monitoringTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _pollWebhookEvents();
    });

    if (kDebugMode) {
      debugPrint('🔗 Webhook monitoring started');
    }
  }

  /// Stop monitoring webhook events
  void stopMonitoring() {
    _isMonitoring = false;
    _monitoringTimer?.cancel();
    _monitoringTimer = null;

    if (kDebugMode) {
      debugPrint('🔗 Webhook monitoring stopped');
    }
  }

  /// Track pending payment intent
  void trackPendingIntent(String intentId) {
    _pendingIntents[intentId] = DateTime.now();

    if (kDebugMode) {
      debugPrint('🔗 Tracking pending intent: $intentId');
    }
  }

  /// Get webhook events for an intent
  List<core.WebhookEvent> getIntentEvents(String intentId) {
    return _intentEvents[intentId] ?? <core.WebhookEvent>[];
  }

  /// Get all pending intents
  Map<String, DateTime> getPendingIntents() {
    return Map.from(_pendingIntents);
  }

  /// Stream of webhook events
  Stream<core.WebhookEvent> get eventStream => _eventController.stream;

  /// Poll for webhook events
  Future<void> _pollWebhookEvents() async {
    // Fail-closed: Only poll when backend is available
    if (!AppConfig.canUseBackendFeature()) {
      // Silent disable when backend not available
      return;
    }

    const endpoint = '${AppConfig.apiBaseUrl}/webhooks/status';
    if (endpoint.isEmpty) return;

    try {
      // TODO: Implement proper HTTP client usage when network_shims is fully implemented
      // For now, skip polling to avoid build errors
      if (kDebugMode) {
        debugPrint(
          '🔗 Webhook polling skipped (network_shims not fully implemented)',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error polling webhook events: $e');
      }
    }
  }

  /// Process webhook event from backend
  Future<void> processWebhookEvent(Map<String, dynamic> eventData) async {
    debugPrint('Processing webhook event: ${eventData['type']}');

    // Safe type checking and extraction
    final String webhookType = (eventData['type'] as String?) ?? 'unknown';
    final Map<String, dynamic>? dataSection =
        eventData['data'] as Map<String, dynamic>?;
    final Map<String, dynamic>? objectSection =
        dataSection?['object'] as Map<String, dynamic>?;
    final String intentId = (objectSection?['id'] as String?) ?? 'unknown';

    debugPrint('Webhook details - Type: $webhookType, Intent: $intentId');

    try {
      final core.WebhookEvent event = core.WebhookEvent.fromJson(eventData);

      debugPrint(
        'Webhook parsed - Status: webhook_parsed, Event: ${event.type.name}',
      );

      // Store event
      _intentEvents
          .putIfAbsent(event.intentId, () => <core.WebhookEvent>[])
          .add(event);

      // Track latency if we have a pending intent
      if (_pendingIntents.containsKey(event.intentId)) {
        final DateTime startTime = _pendingIntents[event.intentId]!;
        final int latency = DateTime.now().difference(startTime).inMilliseconds;

        _logTelemetry('trackWebhookLatency', <String, Object?>{
          'intentId': event.intentId,
          'latencyMs': latency,
          'eventType': event.type.name,
        });

        _pendingIntents.remove(event.intentId);
      }

      // Emit event
      _eventController.add(event);

      debugPrint('Webhook processed - Latency: ${event.latencyMs}ms');

      if (kDebugMode) {
        debugPrint(
          '🔗 Webhook event processed: ${event.type.name} for intent ${event.intentId}',
        );
      }
    } catch (e) {
      debugPrint('Webhook processing failed: $e');

      // Track error in telemetry
      final String errorWebhookType =
          (eventData['type'] as String?) ?? 'unknown';
      final Map<String, dynamic>? errorDataSection =
          eventData['data'] as Map<String, dynamic>?;
      final Map<String, dynamic>? errorObjectSection =
          errorDataSection?['object'] as Map<String, dynamic>?;
      final String errorIntentId =
          (errorObjectSection?['id'] as String?) ?? 'unknown';

      debugPrint(
        'Webhook error - Type: $errorWebhookType, Intent: $errorIntentId, Error: $e',
      );

      if (kDebugMode) {
        debugPrint('❌ Error processing webhook event: $e');
      }
    }
  }

  /// Get correlation report
  Map<String, dynamic> getCorrelationReport() {
    final Map<String, dynamic> report = <String, dynamic>{
      'pending_intents': _pendingIntents.length,
      'total_events': _intentEvents.values.fold<int>(
        0,
        (int sum, List<core.WebhookEvent> events) => sum + events.length,
      ),
      'intent_correlation': <String, dynamic>{},
    };

    // Calculate correlation metrics
    for (final MapEntry<String, List<core.WebhookEvent>> entry
        in _intentEvents.entries) {
      final String intentId = entry.key;
      final List<core.WebhookEvent> events = entry.value;

      final Map<String, dynamic> correlationData = <String, dynamic>{
        'event_count': events.length,
        'event_types': events
            .map((core.WebhookEvent e) => e.type.name)
            .toList(),
        'avg_latency_ms': events.isNotEmpty
            ? events
                      .map((core.WebhookEvent e) => e.latencyMs)
                      .reduce((int a, int b) => a + b) /
                  events.length
            : 0,
        'last_event': events.isNotEmpty
            ? events.last.timestamp.toIso8601String()
            : null,
      };

      (report['intent_correlation'] as Map<String, dynamic>)[intentId] =
          correlationData;
    }

    return report;
  }

  /// Clear old events (cleanup)
  void clearOldEvents({Duration maxAge = const Duration(hours: 24)}) {
    final DateTime cutoff = DateTime.now().subtract(maxAge);

    _intentEvents.removeWhere((
      String intentId,
      List<core.WebhookEvent> events,
    ) {
      events.removeWhere(
        (core.WebhookEvent event) => event.timestamp.isBefore(cutoff),
      );
      return events.isEmpty;
    });

    if (kDebugMode) {
      debugPrint('🔗 Cleared old webhook events');
    }
  }

  /// Dispose resources
  void dispose() {
    stopMonitoring();
    _eventController.close();
  }
}

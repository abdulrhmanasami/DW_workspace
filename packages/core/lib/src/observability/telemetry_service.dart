/// Component: TelemetryService Implementation
/// Created by: Cursor (auto-generated)
/// Purpose: Concrete telemetry service implementation for observability
/// Last updated: 2025-11-04

import 'dart:async';
import 'package:flutter/foundation.dart';

// Import with prefixes to avoid conflicts
import 'package:foundation_shims/foundation_shims.dart' as foundation;

/// Stub AppConfig for telemetry feature availability in core package
class AppConfig {
  static bool canUseTelemetryFeature() {
    // Fail-closed: assume telemetry is disabled unless configured
    return false;
  }
}

/// Telemetry service interface
abstract class TelemetryService {
  Future<void> logEvent(String name, {Map<String, Object?> params});

  Future<void> logScreen(String screenName, {Map<String, Object?> params});

  Future<void> logError(
    Object error, {
    StackTrace? stack,
    Map<String, Object?> context,
  });

  Future<void> setUserId(String? userId);

  Future<void> setUserProperty(String key, String value);

  // Payment tracking methods
  Future<void> trackPaymentSucceeded({
    required String paymentId,
    required double amount,
    String? currency,
  });

  Future<void> trackPaymentFailed({
    required String paymentId,
    required String reason,
    double? amount,
  });

  // Authentication tracking methods
  Future<void> trackAuthEvent(String event, {Map<String, Object?> params});

  // Screen tracking methods
  Future<void> trackScreenView(
    String screenName, {
    Map<String, Object?> params,
  });

  // API tracking methods
  Future<void> trackApiCall(
    String endpoint, {
    required int statusCode,
    int? durationMs,
    String? error,
  });

  // Error tracking methods
  Future<void> trackError(
    Object error, {
    StackTrace? stack,
    Map<String, Object?> context,
  });

  // Custom event tracking
  Future<void> trackCustomEvent(
    String eventName, {
    Map<String, Object?> params,
  });
}

/// Telemetry service for payment monitoring and analytics
class TelemetryServiceImpl implements TelemetryService {
  static TelemetryServiceImpl? _instance;
  static TelemetryServiceImpl get instance =>
      _instance ??= TelemetryServiceImpl._();

  late final foundation.Telemetry _telemetry;

  TelemetryServiceImpl._() {
    // Initialize telemetry from foundation_shims
    _telemetry = foundation.Telemetry.instance;
  }

  /// Getter for telemetry instance (used by SimpleTelemetryService)
  foundation.Telemetry get telemetry => _telemetry;

  // Payment metrics
  int _paymentSuccessCount = 0;
  int _paymentFailureCount = 0;
  int _paymentCancelCount = 0;
  int _threeDSChallengeCount = 0;
  int _threeDSChallengeSuccessCount = 0;
  int _applePayAttempts = 0;
  int _googlePayAttempts = 0;

  // Performance metrics
  final List<int> _paymentProcessingTimes = <int>[];
  final List<int> _webhookLatencies = <int>[];

  // Timers for rate calculations
  Timer? _metricsTimer;
  DateTime? _lastResetTime;

  /// Initialize telemetry service
  void initialize() {
    _lastResetTime = DateTime.now();

    // Reset metrics every hour for rate calculations
    _metricsTimer = Timer.periodic(const Duration(hours: 1), (_) {
      _resetHourlyMetrics();
    });

    // Configure telemetry keys if available from environment
    _configureTelemetryKeys();

    if (kDebugMode) {
      // TODO: Replace with proper logging: unawaited(print('📊 TelemetryService initialized');)
    }
  }

  /// Configure telemetry keys from environment variables
  void _configureTelemetryKeys() {
    // This method can be extended to configure telemetry providers
    // like Sentry, Firebase Analytics, etc. based on environment variables
    // For now, it's a placeholder for future telemetry key injection
  }

  /// Track payment initiation
  void trackPaymentInitiated({
    required String serviceType,
    required int amount,
    required String currency,
    String? paymentMethod,
  }) {
    final Map<String, dynamic> event = <String, Object>{
      'event': 'payment_initiated',
      'service_type': serviceType,
      'amount': amount,
      'currency': currency,
      'payment_method': paymentMethod ?? 'card',
      'timestamp': DateTime.now().toIso8601String(),
    };

    _logEvent(event);
  }

  /// Track payment success
  void trackPaymentSuccess({
    required String intentId,
    required String serviceType,
    required int amount,
    required String currency,
    String? paymentMethod,
    required int processingTimeMs,
  }) {
    _paymentSuccessCount++;
    _paymentProcessingTimes.add(processingTimeMs);

    final Map<String, dynamic> event = <String, Object>{
      'event': 'payment_succeeded',
      'intent_id': intentId,
      'service_type': serviceType,
      'amount': amount,
      'currency': currency,
      'payment_method': paymentMethod ?? 'card',
      'processing_time_ms': processingTimeMs,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _logEvent(event);
  }

  /// Track payment failure
  void trackPaymentFailure({
    required String serviceType,
    required int amount,
    required String currency,
    required String errorCode,
    required String errorMessage,
    String? paymentMethod,
  }) {
    _paymentFailureCount++;

    final Map<String, dynamic> event = <String, Object>{
      'event': 'payment_failed',
      'service_type': serviceType,
      'amount': amount,
      'currency': currency,
      'error_code': errorCode,
      'error_message': errorMessage,
      'payment_method': paymentMethod ?? 'card',
      'timestamp': DateTime.now().toIso8601String(),
    };

    _logEvent(event);
  }

  /// Track payment cancellation
  void trackPaymentCanceled({
    required String serviceType,
    required int amount,
    required String currency,
    String? paymentMethod,
  }) {
    _paymentCancelCount++;

    final Map<String, dynamic> event = <String, Object>{
      'event': 'payment_canceled',
      'service_type': serviceType,
      'amount': amount,
      'currency': currency,
      'payment_method': paymentMethod ?? 'card',
      'timestamp': DateTime.now().toIso8601String(),
    };

    _logEvent(event);
  }

  /// Track 3DS2 challenge initiation
  void track3DSChallengeStarted({
    required String intentId,
    required String serviceType,
  }) {
    _threeDSChallengeCount++;

    final Map<String, String> event = <String, String>{
      'event': '3ds_challenge_started',
      'intent_id': intentId,
      'service_type': serviceType,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _logEvent(event);
  }

  /// Track 3DS2 challenge completion
  void track3DSChallengeCompleted({
    required String intentId,
    required String serviceType,
    required bool success,
  }) {
    if (success) {
      _threeDSChallengeSuccessCount++;
    }

    final Map<String, dynamic> event = <String, Object>{
      'event': '3ds_challenge_completed',
      'intent_id': intentId,
      'service_type': serviceType,
      'success': success,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _logEvent(event);
  }

  /// Track Apple Pay attempt
  void trackApplePayAttempt({
    required String serviceType,
    required int amount,
    required String currency,
  }) {
    _applePayAttempts++;

    final Map<String, dynamic> event = <String, Object>{
      'event': 'apple_pay_attempt',
      'service_type': serviceType,
      'amount': amount,
      'currency': currency,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _logEvent(event);
  }

  /// Track Google Pay attempt
  void trackGooglePayAttempt({
    required String serviceType,
    required int amount,
    required String currency,
  }) {
    _googlePayAttempts++;

    final Map<String, dynamic> event = <String, Object>{
      'event': 'google_pay_attempt',
      'service_type': serviceType,
      'amount': amount,
      'currency': currency,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _logEvent(event);
  }

  /// Track webhook latency (enhanced for monitoring)
  void trackWebhookLatency({
    required String intentId,
    required int latencyMs,
    required String eventType,
  }) {
    _webhookLatencies.add(latencyMs);

    final Map<String, dynamic> event = <String, Object>{
      'event': 'webhook_latency',
      'intent_id': intentId,
      'latency_ms': latencyMs,
      'webhook_event': eventType,
      'timestamp': DateTime.now().toIso8601String(),
      'environment': _getEnvironment(),
    };

    _logEvent(event);

    // Track latency percentiles for monitoring
    _updateLatencyMetrics('webhook_latency', latencyMs);
  }

  /// Track webhook processing time
  void trackWebhookProcessingTime({
    required String eventId,
    required int processingTimeMs,
    required String eventType,
  }) {
    final Map<String, dynamic> event = <String, Object>{
      'event': 'webhook_processing_time',
      'event_id': eventId,
      'processing_time_ms': processingTimeMs,
      'event_type': eventType,
      'timestamp': DateTime.now().toIso8601String(),
      'environment': _getEnvironment(),
    };

    _logEvent(event);

    _updateLatencyMetrics('webhook_processing_time', processingTimeMs);
  }

  /// Track webhook errors
  void trackWebhookError({
    required String eventId,
    required String error,
    required int processingTimeMs,
  }) {
    final Map<String, dynamic> event = <String, Object>{
      'event': 'webhook_error',
      'event_id': eventId,
      'error': error,
      'processing_time_ms': processingTimeMs,
      'timestamp': DateTime.now().toIso8601String(),
      'environment': _getEnvironment(),
    };

    _logEvent(event);

    _incrementErrorCounter('webhook_errors');
  }

  /// Get payment success rate
  double get paymentSuccessRate {
    final int total =
        _paymentSuccessCount + _paymentFailureCount + _paymentCancelCount;
    if (total == 0) return 0.0;
    return (_paymentSuccessCount / total) * 100;
  }

  /// Get 3DS2 challenge rate
  double get threeDSChallengeRate {
    final int total = _paymentSuccessCount + _paymentFailureCount;
    if (total == 0) return 0.0;
    return (_threeDSChallengeCount / total) * 100;
  }

  /// Get 3DS2 challenge success rate
  double get threeDSChallengeSuccessRate {
    if (_threeDSChallengeCount == 0) return 0.0;
    return (_threeDSChallengeSuccessCount / _threeDSChallengeCount) * 100;
  }

  /// Get average payment processing time
  double get averagePaymentProcessingTime {
    if (_paymentProcessingTimes.isEmpty) return 0.0;
    return _paymentProcessingTimes.reduce((int a, int b) => a + b) /
        _paymentProcessingTimes.length;
  }

  /// Get average webhook latency
  double get averageWebhookLatency {
    if (_webhookLatencies.isEmpty) return 0.0;
    return _webhookLatencies.reduce((int a, int b) => a + b) /
        _webhookLatencies.length;
  }

  /// Get all metrics as a map (enhanced for monitoring)
  Map<String, dynamic> getAllMetrics() {
    return <String, dynamic>{
      'payment_success_count': _paymentSuccessCount,
      'payment_failure_count': _paymentFailureCount,
      'payment_cancel_count': _paymentCancelCount,
      'payment_success_rate': paymentSuccessRate,
      'three_ds_challenge_count': _threeDSChallengeCount,
      'three_ds_challenge_success_count': _threeDSChallengeSuccessCount,
      'three_ds_challenge_rate': threeDSChallengeRate,
      'three_ds_challenge_success_rate': threeDSChallengeSuccessRate,
      'apple_pay_attempts': _applePayAttempts,
      'google_pay_attempts': _googlePayAttempts,
      'average_payment_processing_time_ms': averagePaymentProcessingTime,
      'average_webhook_latency_ms': averageWebhookLatency,
      'webhook_latency_p95_ms': _getPercentile(_webhookLatencies, 95),
      'webhook_latency_p99_ms': _getPercentile(_webhookLatencies, 99),
      'payment_processing_time_p95_ms': _getPercentile(
        _paymentProcessingTimes,
        95,
      ),
      'payment_processing_time_p99_ms': _getPercentile(
        _paymentProcessingTimes,
        99,
      ),
      'last_reset_time': _lastResetTime?.toIso8601String(),
      'environment': _getEnvironment(),
    };
  }

  /// Log event using foundation_shims Telemetry
  void _logEvent(Map<String, dynamic> event) {
    // Fail-closed: Check telemetry availability
    if (!AppConfig.canUseTelemetryFeature()) {
      // Silent disable when telemetry not available
      return;
    }

    if (kDebugMode) {
      // TODO: Replace with proper logging: unawaited(print('📊 Telemetry Event: ${event['event']}');)
      if (event['intent_id'] != null) {
        // TODO: Replace with proper logging: unawaited(print('   Intent ID: ${event['intent_id']}');)
      }
      if (event['processing_time_ms'] != null) {
        // TODO: Replace with proper logging: unawaited(print('   Processing Time: ${event['processing_time_ms']}ms');)
      }
    }

    // Send to foundation_shims Telemetry
    _telemetry.logEvent(event['event'] as String, event);
  }

  /// Send event with specific type and attributes
  Future<void> sendEvent(
    String eventType,
    Map<String, Object?> attributes,
  ) async {
    // Fail-closed: Check telemetry availability
    if (!AppConfig.canUseTelemetryFeature()) {
      // Silent disable when telemetry not available
      return;
    }

    // Send to foundation_shims Telemetry
    await _telemetry.logEvent(eventType, attributes);
  }

  /// Send decision engine events
  Future<void> sendDecisionEvent({
    required String eventType,
    required String userId,
    required String decision,
    required String variant,
    String? configVersion,
    String? configSource,
    int? sessionCount,
    int? pinnedTtlDays,
    Map<String, dynamic>? additionalData,
  }) async {
    final attributes = {
      'user_id_hash': userId,
      'decision': decision,
      'variant': variant,
      if (configVersion != null) 'config_version': configVersion,
      if (configSource != null) 'config_source': configSource,
      if (sessionCount != null) 'session_count': sessionCount,
      if (pinnedTtlDays != null) 'pinned_ttl_days': pinnedTtlDays,
      if (additionalData != null) ...additionalData,
    };

    await sendEvent(eventType, attributes);
  }

  /// Send guardrail block event
  Future<void> sendGuardrailEvent({
    required String reason,
    required String userId,
    String? metric,
    double? value,
    double? threshold,
    Map<String, dynamic>? additionalData,
  }) async {
    final attributes = {
      'reason': reason,
      'user_id_hash': userId,
      if (metric != null) 'metric': metric,
      if (value != null) 'value': value,
      if (threshold != null) 'threshold': threshold,
      if (additionalData != null) ...additionalData,
    };

    await sendEvent('exp_decision.guardrail_block', attributes);
  }

  /// Send config loaded event
  Future<void> sendConfigLoadedEvent({
    required String configSource,
    required String configVersion,
    String? userId,
    int? sessionCount,
    int? pinnedTtlDays,
    Map<String, dynamic>? additionalData,
  }) async {
    final attributes = {
      'config_source': configSource,
      'config_version': configVersion,
      if (userId != null) 'user_id_hash': userId,
      if (sessionCount != null) 'session_count': sessionCount,
      if (pinnedTtlDays != null) 'pinned_ttl_days': pinnedTtlDays,
      if (additionalData != null) ...additionalData,
    };

    await sendEvent('exp_decision.config_loaded', attributes);
  }

  /// Update latency metrics for monitoring
  void _updateLatencyMetrics(String metricType, int latencyMs) {
    // Keep only last 1000 measurements for memory efficiency
    if (metricType == 'webhook_latency' && _webhookLatencies.length > 1000) {
      _webhookLatencies.removeAt(0);
    } else if (metricType == 'payment_processing_time' &&
        _paymentProcessingTimes.length > 1000) {
      _paymentProcessingTimes.removeAt(0);
    }
  }

  /// Increment error counter
  void _incrementErrorCounter(String errorType) {
    // Track error rates for monitoring
    if (kDebugMode) {
      // TODO: Replace with proper logging: unawaited(print('⚠️ Error counter incremented: $errorType');)
    }
  }

  /// Get percentile value from list
  double _getPercentile(List<int> values, int percentile) {
    if (values.isEmpty) return 0.0;

    final List<int> sorted = List<int>.from(values)..sort();
    final int index = (percentile / 100.0 * (sorted.length - 1)).round();
    return sorted[index].toDouble();
  }

  /// Get environment name
  String _getEnvironment() {
    // TODO: Get from environment configuration
    return 'staging'; // Default for now
  }

  /// Reset hourly metrics
  void _resetHourlyMetrics() {
    _lastResetTime = DateTime.now();

    if (kDebugMode) {
      // TODO: Replace with proper logging: print('📊 Telemetry metrics reset for new hour');
      print('   Success Rate: ${paymentSuccessRate.toStringAsFixed(2)}%');
      print(
        '   3DS Challenge Rate: ${threeDSChallengeRate.toStringAsFixed(2)}%',
      );
      print(
        '   Avg Processing Time: ${averagePaymentProcessingTime.toStringAsFixed(0)}ms',
      );
    }
  }

  /// Start a trace for performance monitoring
  Trace startTrace(String name) {
    return Trace._(name, this);
  }

  /// Track error with context
  void error(
    Object error,
    StackTrace stackTrace, {
    Map<String, String>? context,
  }) {
    final Map<String, String> event = <String, String>{
      'event': 'error',
      'error': error.toString(),
      'stack_trace': stackTrace.toString(),
      'timestamp': DateTime.now().toIso8601String(),
      'environment': _getEnvironment(),
    };

    if (context != null) {
      event.addAll(context);
    }

    _logEvent(event);

    if (kDebugMode) {
      print('❌ Telemetry Error: ${error.toString()}');
    }
  }

  /// Dispose resources
  void dispose() {
    _metricsTimer?.cancel();
  }

  @override
  Future<void> logEvent(String name, {Map<String, Object?>? params}) async {
    await sendEvent(name, params ?? {});
  }

  @override
  Future<void> logScreen(
    String screenName, {
    Map<String, Object?>? params,
  }) async {
    await logEvent(
      'screen_view',
      params: params ?? {'screen_name': screenName},
    );
  }

  @override
  Future<void> logError(
    Object error, {
    StackTrace? stack,
    Map<String, Object?>? context,
  }) async {
    final Map<String, Object> errorEvent = {
      'error': error.toString(),
      if (stack != null) 'stack_trace': stack.toString(),
      if (context != null)
        ...context.map((key, value) => MapEntry(key, value ?? '')),
    };
    await logEvent('error', params: errorEvent);
  }

  @override
  Future<void> setUserId(String? userId) async {
    await logEvent('set_user_id', params: {'user_id': userId});
  }

  @override
  Future<void> setUserProperty(String key, String value) async {
    await logEvent('set_user_property', params: {'key': key, 'value': value});
  }

  @override
  Future<void> trackPaymentSucceeded({
    required String paymentId,
    required double amount,
    String? currency,
  }) async {
    await logEvent(
      'payment_succeeded',
      params: {
        'payment_id': paymentId,
        'amount': amount,
        'currency': currency ?? 'USD',
      },
    );
  }

  @override
  Future<void> trackPaymentFailed({
    required String paymentId,
    required String reason,
    double? amount,
  }) async {
    await logEvent(
      'payment_failed',
      params: {
        'payment_id': paymentId,
        'reason': reason,
        if (amount != null) 'amount': amount,
      },
    );
  }

  @override
  Future<void> trackAuthEvent(
    String event, {
    Map<String, Object?>? params,
  }) async {
    await logEvent('auth_$event', params: params);
  }

  @override
  Future<void> trackScreenView(
    String screenName, {
    Map<String, Object?>? params,
  }) async {
    await logEvent(
      'screen_view',
      params: {'screen_name': screenName, ...?params},
    );
  }

  @override
  Future<void> trackApiCall(
    String endpoint, {
    required int statusCode,
    int? durationMs,
    String? error,
  }) async {
    await logEvent(
      'api_call',
      params: {
        'endpoint': endpoint,
        'status_code': statusCode,
        if (durationMs != null) 'duration_ms': durationMs,
        if (error != null) 'error': error,
      },
    );
  }

  @override
  Future<void> trackError(
    Object error, {
    StackTrace? stack,
    Map<String, Object?>? context,
  }) async {
    await logError(error, stack: stack, context: context);
  }

  @override
  Future<void> trackCustomEvent(
    String eventName, {
    Map<String, Object?>? params,
  }) async {
    await logEvent(eventName, params: params);
  }
}

/// Simplified Telemetry Service using foundation_shims
class SimpleTelemetryService {
  final foundation.Telemetry _telemetry;

  SimpleTelemetryService(this._telemetry);

  /// Getter for telemetry instance
  foundation.Telemetry get telemetry => _telemetry;

  void paymentStarted({required num amountMinor, required String currency}) {
    _telemetry.logEvent('payment_started', {
      'amountMinor': amountMinor,
      'currency': currency,
    });
  }

  /// Updated for payment tracking (2025-11-02)
  void paymentFinished(
    String status, {
    String? orderId,
    double? amount,
    String? currency,
    String? failureCode,
    String? failureMessage,
  }) {
    _telemetry
        .logEvent(status == 'success' ? 'payment_success' : 'payment_failure', {
          'status': status,
          'orderId': orderId,
          'amount': amount,
          'currency': currency,
          'failureCode': failureCode,
          'failureMessage': failureMessage,
        });
  }

  /// Track in-app review prompt shown
  void trackReviewPromptShown({
    required String variant,
    required int sessionCount,
    required String trigger,
  }) {
    _telemetry.logEvent('review_prompt_shown', {
      'variant': variant,
      'session_count': sessionCount,
      'trigger': trigger,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track in-app review user response
  void trackReviewResponse({
    required String variant,
    required int sessionCount,
    required String trigger,
    required String result,
  }) {
    _telemetry.logEvent('review_response', {
      'variant': variant,
      'session_count': sessionCount,
      'trigger': trigger,
      'result': result,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track in-app review prompt error
  void trackReviewPromptError({
    required String error,
    required String trigger,
  }) {
    _telemetry.logEvent('review_prompt_error', {
      'error': error,
      'trigger': trigger,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Send decision engine events
  Future<void> sendDecisionEvent({
    required String eventType,
    required String userId,
    required String decision,
    required String variant,
    String? configVersion,
    String? configSource,
    int? sessionCount,
    int? pinnedTtlDays,
    Map<String, dynamic>? additionalData,
  }) async {
    await TelemetryServiceImpl.instance.sendDecisionEvent(
      eventType: eventType,
      userId: userId,
      decision: decision,
      variant: variant,
      configVersion: configVersion,
      configSource: configSource,
      sessionCount: sessionCount,
      pinnedTtlDays: pinnedTtlDays,
      additionalData: additionalData,
    );
  }

  /// Send guardrail block event
  Future<void> sendGuardrailEvent({
    required String reason,
    required String userId,
    String? metric,
    double? value,
    double? threshold,
    Map<String, dynamic>? additionalData,
  }) async {
    await TelemetryServiceImpl.instance.sendGuardrailEvent(
      reason: reason,
      userId: userId,
      metric: metric,
      value: value,
      threshold: threshold,
      additionalData: additionalData,
    );
  }

  /// Send config loaded event
  Future<void> sendConfigLoadedEvent({
    required String configSource,
    required String configVersion,
    String? userId,
    int? sessionCount,
    int? pinnedTtlDays,
    Map<String, dynamic>? additionalData,
  }) async {
    await TelemetryServiceImpl.instance.sendConfigLoadedEvent(
      configSource: configSource,
      configVersion: configVersion,
      userId: userId,
      sessionCount: sessionCount,
      pinnedTtlDays: pinnedTtlDays,
      additionalData: additionalData,
    );
  }
}

/// Trace class for performance monitoring
class Trace {
  final String name;
  final TelemetryServiceImpl _service;
  final DateTime _startTime;
  final Map<String, dynamic> _attributes = <String, dynamic>{};

  Trace._(this.name, this._service) : _startTime = DateTime.now();

  /// Set trace attributes
  void setAttributes(Map<String, dynamic> attributes) {
    _attributes.addAll(attributes);
  }

  /// Stop the trace and record the duration
  void stop() {
    final Duration duration = DateTime.now().difference(_startTime);
    final Map<String, dynamic> event = <String, Object>{
      'event': 'trace_stop',
      'trace_name': name,
      'duration_ms': duration.inMilliseconds,
      'attributes': _attributes,
      'timestamp': DateTime.now().toIso8601String(),
      'environment': _service._getEnvironment(),
    };

    _service._logEvent(event);

    if (kDebugMode) {
      print('⏱️ Trace completed: $name (${duration.inMilliseconds}ms)');
    }
  }

  /// Send event with specific type and attributes
  Future<void> sendEvent(
    String eventType,
    Map<String, dynamic> attributes,
  ) async {
    await _service.sendEvent(eventType, attributes);
  }

  /// Send decision engine events
  Future<void> sendDecisionEvent({
    required String eventType,
    required String userId,
    required String decision,
    required String variant,
    String? configVersion,
    String? configSource,
    int? sessionCount,
    int? pinnedTtlDays,
    Map<String, dynamic>? additionalData,
  }) async {
    final attributes = {
      'user_id_hash': userId,
      'decision': decision,
      'variant': variant,
      if (configVersion != null) 'config_version': configVersion,
      if (configSource != null) 'config_source': configSource,
      if (sessionCount != null) 'session_count': sessionCount,
      if (pinnedTtlDays != null) 'pinned_ttl_days': pinnedTtlDays,
      if (additionalData != null) ...additionalData,
    };

    await sendEvent(eventType, attributes);
  }

  /// Send guardrail block event
  Future<void> sendGuardrailEvent({
    required String reason,
    required String userId,
    String? metric,
    double? value,
    double? threshold,
    Map<String, dynamic>? additionalData,
  }) async {
    final attributes = {
      'reason': reason,
      'user_id_hash': userId,
      if (metric != null) 'metric': metric,
      if (value != null) 'value': value,
      if (threshold != null) 'threshold': threshold,
      if (additionalData != null) ...additionalData,
    };

    await sendEvent('exp_decision.guardrail_block', attributes);
  }

  /// Send config loaded event
  Future<void> sendConfigLoadedEvent({
    required String version,
    required String source,
    required bool enabled,
    required bool killSwitch,
    required Map<String, double> weights,
    Map<String, dynamic>? additionalData,
  }) async {
    final attributes = {
      'version': version,
      'source': source,
      'enabled': enabled,
      'kill_switch': killSwitch,
      'weights': weights,
      if (additionalData != null) ...additionalData,
    };

    await sendEvent('exp_decision.config_loaded', attributes);
  }
}

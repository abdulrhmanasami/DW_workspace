/// Component: TelemetryNoop Implementation
/// Created by: Cursor (auto-generated)
/// Purpose: No-Op implementation of TelemetryService for development/testing
/// Last updated: 2025-11-02

import 'package:core/core.dart';

final class TelemetryNoop implements TelemetryService {
  @override
  Future<void> logEvent(String name,
      {Map<String, Object?> params = const {}}) async {}

  @override
  Future<void> logScreen(String screenName,
      {Map<String, Object?> params = const {}}) async {}

  @override
  Future<void> logError(Object error,
      {StackTrace? stack, Map<String, Object?> context = const {}}) async {}

  @override
  Future<void> setUserId(String? userId) async {}

  @override
  Future<void> setUserProperty(String key, String value) async {}

  @override
  Future<void> trackPaymentSucceeded(
      {required String paymentId,
      required double amount,
      String? currency}) async {}

  @override
  Future<void> trackPaymentFailed(
      {required String paymentId,
      required String reason,
      double? amount}) async {}

  @override
  Future<void> trackAuthEvent(String event,
      {Map<String, Object?> params = const {}}) async {}

  @override
  Future<void> trackScreenView(String screenName,
      {Map<String, Object?> params = const {}}) async {}

  @override
  Future<void> trackApiCall(String endpoint,
      {required int statusCode, int? durationMs, String? error}) async {}

  @override
  Future<void> trackError(Object error,
      {StackTrace? stack, Map<String, Object?> context = const {}}) async {}

  @override
  Future<void> trackCustomEvent(String eventName,
      {Map<String, Object?> params = const {}}) async {}
}

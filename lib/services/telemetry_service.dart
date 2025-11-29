import 'dart:async';

import 'package:foundation_shims/foundation_shims.dart' as fnd;

/// Component: Telemetry Service Adapter
/// Created by: Cursor (auto-generated)
/// Purpose: Proxy Telemetry access through foundation_shims
/// Last updated: 2025-11-24

/// A thin adapter that forwards calls to the hardened Telemetry singleton
/// exposed by foundation_shims. This keeps the legacy service API surface
/// intact while ensuring we never fall back to TelemetryNoop stubs.
class TelemetryService {
  const TelemetryService();

  fnd.Telemetry get _telemetry => fnd.Telemetry.instance;
  fnd.TelemetryConsent get consent => fnd.TelemetryConsent.instance;

  Future<void> logEvent(String name, [Map<String, dynamic>? params]) {
    return _telemetry.logEvent(name, params);
  }

  Future<void> error(String message, {Map<String, dynamic>? context}) {
    return _telemetry.error(message, context: context);
  }

  Future<void> setUserId(String? userId) {
    return _telemetry.setUserId(userId);
  }

  Future<void> setUserProperty(String name, dynamic value) {
    return _telemetry.setUserProperty(name, value);
  }

  Future<fnd.TelemetrySpan> startTrace(String name) {
    return _telemetry.startTrace(name);
  }
}

/// Legacy alias retained for code that still references TelemetryServiceImpl.
typedef TelemetryServiceImpl = TelemetryService;

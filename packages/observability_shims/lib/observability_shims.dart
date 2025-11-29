/// Component: Observability Shims Package
/// Created by: Cursor (auto-generated)
/// Purpose: Telemetry shims and implementations for Delivery Ways
/// Last updated: 2025-11-18

library;

// Telemetry exports - SINGLE SOURCE OF TRUTH
export 'package:foundation_shims/foundation_shims.dart'
    show Telemetry, TelemetrySpan, TelemetryConsent;

// Telemetry implementations
export 'telemetry_noop.dart';
export 'database_migration.dart';

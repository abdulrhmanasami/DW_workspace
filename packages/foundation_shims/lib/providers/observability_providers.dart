/// Component: Observability Riverpod Providers
/// Created by: Cursor B-central
/// Purpose: Consent-aware observability service providers
/// Last updated: 2025-11-12

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../src/observability/observability_gate.dart';
import '../src/observability/consent_guard.dart';
import '../src/telemetry.dart';

/// Provider for the observability gate - selects Real/NoOp based on consent
final observabilityGateProvider = Provider<ObservabilityGate>((ref) {
  // Check current consent from TelemetryConsent
  final hasConsent = TelemetryConsent.instance.isAllowed;
  final consent = hasConsent
      ? Consent
            .full // Assume full consent if allowed (can be refined later)
      : Consent.none;

  // Return appropriate gate implementation
  if (ConsentGuard.isTelemetryAllowed(consent)) {
    return RealObservabilityGate();
  } else {
    return NoOpObservabilityGate();
  }
});

/// Provider for observability binding - initializes the gate with consent
final observabilityBindingProvider = FutureProvider<void>((ref) async {
  final gate = ref.watch(observabilityGateProvider);

  // Get initial consent from TelemetryConsent
  final hasConsent = TelemetryConsent.instance.isAllowed;
  final initialConsent = hasConsent
      ? Consent
            .full // Assume full consent if allowed
      : Consent.none;

  // Initialize the gate
  await gate.init(initialConsent: initialConsent);

  // Set up a listener for consent changes (if needed in the future)
  // For now, consent changes will be handled by calling setConsent directly
});

/// Provider for current observability status
final observabilityStatusProvider = Provider<ObservabilityStatus>((ref) {
  final gate = ref.watch(observabilityGateProvider);
  final consent = gate.currentConsent;

  return ObservabilityStatus(
    consent: consent,
    isTelemetryEnabled: ConsentGuard.isTelemetryAllowed(consent),
    isCrashReportingEnabled: ConsentGuard.isCrashReportingAllowed(consent),
    isAnalyticsEnabled: ConsentGuard.isAnalyticsAllowed(consent),
  );
});

/// Observability status model
class ObservabilityStatus {
  final Consent consent;
  final bool isTelemetryEnabled;
  final bool isCrashReportingEnabled;
  final bool isAnalyticsEnabled;

  const ObservabilityStatus({
    required this.consent,
    required this.isTelemetryEnabled,
    required this.isCrashReportingEnabled,
    required this.isAnalyticsEnabled,
  });

  bool get hasAnyConsent => isTelemetryEnabled;
  bool get hasFullConsent => isCrashReportingEnabled && isAnalyticsEnabled;
}

/// Convenience provider for accessing the observability service
final observabilityServiceProvider = Provider<ObservabilityGate>((ref) {
  return ref.watch(observabilityGateProvider);
});

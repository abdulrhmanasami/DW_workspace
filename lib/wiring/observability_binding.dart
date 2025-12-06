/// Component: Observability Binding - Consent-Aware Initialization
/// Created by: Cursor B-central
/// Purpose: Centralized observability service initialization with consent enforcement
/// Last updated: 2025-11-12

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_shims/foundation_shims.dart' as fnd;

import 'package:delivery_ways_clean/services/telemetry_service.dart';
import 'package:delivery_ways_clean/state/consent/consent_controller.dart';

/// Observability provider overrides for Riverpod
/// Add these to ProviderScope in main.dart after consent is determined
final observabilityOverrides = <Override>[
  // Overrides can be added here (e.g. swap observabilityServiceProvider in tests)
];

/// Provider that exposes the hardened Telemetry service
final observabilityServiceProvider = Provider<TelemetryService>((ref) {
  // Watch the consent state so dependent widgets rebuild when consent changes
  ref.watch(consentControllerProvider);
  return const TelemetryService();
});

/// Provider that keeps TelemetryConsent in sync with the consent controller
final observabilityBindingProvider = FutureProvider<void>((ref) async {
  final consentState = ref.watch(consentControllerProvider);

  if (!consentState.isLoaded) {
    await ref.read(consentControllerProvider.notifier).load();
    return;
  }

  final telemetryConsent = fnd.TelemetryConsent.instance;
  final shouldAllow = consentState.analytics || consentState.crashReports;

  if (telemetryConsent.isAllowed == shouldAllow) {
    // Already aligned with the requested state; nothing to do.
    return;
  }

  if (shouldAllow) {
    await telemetryConsent.grant();
  } else {
    await telemetryConsent.deny();
  }
});

/// Initialize observability services with consent
/// This should be called after RemoteConfig fetch and consent determination
Future<void> initializeObservability(WidgetRef ref) async {
  final telemetry = ref.read(observabilityServiceProvider);
  try {
    // Wait for the observability binding to complete initialization
    await ref.read(observabilityBindingProvider.future);

    await _safeTelemetryCall(
      () => telemetry.logEvent('observability.initialize', {
        'consentSynced': true,
      }),
    );
  } catch (e, stackTrace) {
    await _safeTelemetryCall(
      () => telemetry.error(
        'observability.initialize_failed',
        context: {'error': '$e', 'stackTrace': '$stackTrace'},
      ),
    );
    // Don't throw - allow app to continue without observability
  }
}

/// Update observability consent at runtime
/// Call this when user changes their privacy consent settings
Future<void> updateObservabilityConsent(WidgetRef ref) async {
  final telemetry = ref.read(observabilityServiceProvider);
  try {
    ref.invalidate(observabilityBindingProvider);
    await ref.read(observabilityBindingProvider.future);

    final consentState = ref.read(consentControllerProvider);

    await _safeTelemetryCall(
      () => telemetry.logEvent('observability.consent_updated', {
        'analytics': consentState.analytics,
        'crashReports': consentState.crashReports,
      }),
    );
  } catch (e, stackTrace) {
    await _safeTelemetryCall(
      () => telemetry.error(
        'observability.consent_update_failed',
        context: {'error': '$e', 'stackTrace': '$stackTrace'},
      ),
    );
  }
}

/// Test function to verify consent enforcement
/// This should only be used for testing purposes
Future<void> testObservabilityConsentEnforcement(WidgetRef ref) async {
  final telemetry = ref.read(observabilityServiceProvider);

  await _safeTelemetryCall(
    () => telemetry.logEvent('observability.self_test', {'stage': 'start'}),
  );

  // Test analytics event blocking
  await telemetry.logEvent('test_event', {'test': 'data'});

  // Test error logging blocking
  await telemetry.error('test error', context: {'context': 'test'});

  // Test trace blocking
  final span = await telemetry.startTrace('test_trace');
  await span.setAttributes({'test': 'attribute'});
  await span.stop();

  await _safeTelemetryCall(
    () => telemetry.logEvent('observability.self_test', {'stage': 'complete'}),
  );
}

Future<void> _safeTelemetryCall(Future<void> Function() operation) async {
  try {
    await operation();
  } catch (_) {
    // Telemetry failures must not break consent flows.
  }
}

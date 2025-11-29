/// Telemetry providers
/// Provides Riverpod accessors for telemetry consent status.
/// This stays in infra to avoid leaking foundation shims across layers.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_shims/foundation_shims.dart';

/// Immutable snapshot of telemetry consent flags used by UX layers.
class TelemetryConsentState {
  const TelemetryConsentState({
    required this.marketingAllowed,
  });

  /// Whether the user allowed marketing communications.
  final bool marketingAllowed;
}

/// Provider that exposes the latest telemetry consent state.
final telemetryConsentProvider = Provider<TelemetryConsentState>((ref) {
  final marketingAllowed = TelemetryConsent.instance.isAllowed;
  return TelemetryConsentState(marketingAllowed: marketingAllowed);
});


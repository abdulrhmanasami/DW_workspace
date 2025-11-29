import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_shims/foundation_shims.dart';

/// Immutable snapshot of telemetry consent flags used by UX layers.
class TelemetryConsentState {
  const TelemetryConsentState({required this.marketingAllowed});

  final bool marketingAllowed;
}

/// Exposes the current telemetry consent state.
final telemetryConsentProvider = Provider<TelemetryConsentState>((ref) {
  final allowed = TelemetryConsent.instance.isAllowed;
  return TelemetryConsentState(marketingAllowed: allowed);
});


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_shims/foundation_shims.dart' as fnd;
import 'package:foundation_shims/providers/remote_config_providers.dart'
    show rcBool;

import 'payments_providers.dart' show paymentsRuntimeConfigProvider;
import 'package:delivery_ways_clean/config/config_manager.dart' as app_cfg;
import 'package:delivery_ways_clean/config/feature_flags.dart' show FeatureFlags;

// Canonical re-export from foundation_shims - no conflicts
export 'package:foundation_shims/foundation_shims.dart'
    show
        stripeGpayEnabledProvider,
        trackingEnabledProvider,
        mapsProviderKeyProvider,
        paymentsEnvProvider,
        uiThemeProvider,
        maintenanceModeEnabledProvider,
        navigatorKeyProvider;

// Kill-switch providers for centralized feature control (locally defined, no conflicts)
final paymentsEnabledProvider = Provider<bool>((ref) {
  final runtimeState = ref.watch(paymentsRuntimeConfigProvider);
  final killSwitchOpen = rcBool(ref, 'payments_enabled', defaultValue: true);
  return runtimeState.isComplete && killSwitchOpen;
});

final mapsEnabledProvider = Provider<bool>((ref) {
  return rcBool(ref, 'maps_enabled', defaultValue: true);
});

/// Remote-config-driven TLS pinning flag synced back into ConfigManager.
final certPinningEnabledProvider = Provider<bool>((ref) {
  final enabled = rcBool(
    ref,
    fnd.RemoteConfigKeys.certPinningEnabled,
    defaultValue: false,
  );

  final manager = app_cfg.ConfigManager.instance;
  final current = manager.getBool(FeatureFlags.certPinningFlagKey);
  if (current != enabled) {
    manager.overrideValue<bool>(FeatureFlags.certPinningFlagKey, enabled);
  }

  return enabled;
});

/// Component: Foundation Shims
/// Created by: Cursor (auto-generated)
/// Purpose: Foundation utilities and telemetry for clean version
/// Last updated: 2025-11-15
library;

/// Component: Foundation Shims - CLEAN PROVIDER EXPORTS
/// Created by: CENT-DSR+FND-PROVIDERS-CLEANUP
/// Purpose: Only foundation providers - no conflicts
/// Last updated: 2025-11-17

export 'config_manager.dart';
export 'payments_config.dart'
    show PaymentsConfig, loadPaymentsConfig, loadPaymentsConfigFromEnv;
export 'src/telemetry.dart';
export 'src/remote_config/remote_config_service.dart';
export 'src/image_cache_manager.dart';

// Feature Flags exports - SINGLE SOURCE OF TRUTH
export 'providers/feature_flags.dart';

// Navigation Service exports - SINGLE SOURCE OF TRUTH
export 'providers/navigation_service.dart';

// Remote Config exports - SINGLE SOURCE OF TRUTH
export 'providers/remote_config_providers.dart'
    show
        remoteConfigProvider,
        fetchRemoteConfigProvider,
        remoteConfigStatusProvider,
        remoteConfigHttpClientProvider;

// Observability exports (no provider conflicts)
export 'src/observability/consent_guard.dart';
export 'src/observability/observability_gate.dart';
export 'providers/observability_providers.dart';

// App Info exports (no provider conflicts)
export 'src/app_info/app_info.dart';
export 'providers/app_info_providers.dart';

// Onboarding Prefs exports (no provider conflicts)
export 'src/onboarding_prefs.dart';
export 'providers/onboarding_prefs_providers.dart';

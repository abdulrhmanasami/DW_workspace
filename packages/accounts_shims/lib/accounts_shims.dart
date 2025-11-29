/// Barrel export for accounts shims
export 'accounts_providers.dart'
    show
        userProfileProvider,
        stripeCustomerIdProvider,
        dsrServiceProvider,
        dsrServiceFactoryProvider;

// DSR exports - LEGACY: Use accounts.dart barrel instead
export 'src/dsr/dsr_models.dart';
export 'src/dsr/dsr_contracts.dart';
export 'src/dsr/dsr_service.dart';

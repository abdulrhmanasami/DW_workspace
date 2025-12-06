/// Barrel export for accounts shims
export 'accounts_providers.dart'
    show
        userProfileProvider,
        stripeCustomerIdProvider,
        dsrServiceProvider,
        dsrServiceFactoryProvider;

// DSR exports - canonical contracts only (avoid ambiguous legacy exports)
export 'src/dsr/dsr_contracts.dart';
export 'src/dsr/dsr_service.dart';

# Payments Package

This package contains the canonical contracts (models + services) plus the neutral factory that selects the concrete implementation (Stripe vs stub). App code must **only** import:

```dart
import 'package:payments_shims/payments.dart'; // types
import 'package:payments/providers.dart';     // factory + providers
```

## Factory usage

```
final cfg = loadPaymentsConfig(); // from foundation_shims
final PaymentService service = await getPaymentService(cfg: cfg);
final PaymentGateway gateway = ensurePaymentGateway();
```

`getPaymentService` caches the active gateway. Calling it multiple times with the same `PaymentsConfig` is cheap. `ensurePaymentGateway()`/`ensurePaymentService()` throw until the factory has been invoked, so wire them during app start (see `ServiceLocator.ensurePaymentsReady`).

## Configuration

`PaymentsConfig` carries everything the factory needs:
- `publishableKey`
- `merchantCountryCode`
- `merchantDisplayName`
- `usePaymentSheet`
- `environment`
- optional: `backendBaseUrl`, `merchantCategoryCode`, `googlePayEnabled`

`foundation_shims.loadPaymentsConfig()` reads these values from `ConfigManager` / RemoteConfig, keeping `app/lib` free from SDK dependencies.

## Switching implementations

The factory automatically selects the Stripe adapter when a publishable key **and** backend base URL are present. Otherwise it falls back to the compile-safe stub (`payments_stub_impl`). You can override RemoteConfig to toggle between them without touching `app/lib`.

To force the stub (e.g., disable payments via kill-switch), override Riverpod's `paymentGatewayProvider` with `buildStubPaymentGateway()`.

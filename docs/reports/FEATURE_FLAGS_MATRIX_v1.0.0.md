# Feature Flags Matrix v1.0.0

**Version**: 1.0.0
**Generated**: 2025-11-26
**Audit Cursor**: B-central
**Ticket**: DW-CENTRAL-CLIENT-HANDOVER-001

---

## 1) Summary

This document provides a comprehensive inventory of all feature flags in the Clean-B application, their default values, behavior, and backend dependencies.

### Total Flags: 32

| Category | Count |
|----------|-------|
| Authentication | 5 |
| Payments | 8 |
| Mobility/Tracking | 5 |
| RBAC | 3 |
| Infrastructure | 7 |
| Notifications/Onboarding | 4 |

---

## 2) Feature Flags Overview Table

| Flag | Area | Default (Debug) | Default (Release) | Depends on Backend? | Kill-Switch? |
|------|------|-----------------|-------------------|---------------------|--------------|
| `ENABLE_PASSWORDLESS_AUTH` | Auth | `true` | `true` | ✅ Yes | ❌ |
| `ENABLE_BIOMETRIC_AUTH` | Auth | `true` | `true` | ❌ No (device-only) | ❌ |
| `ENABLE_TWO_FACTOR_AUTH` | Auth | `false` | `false` | ✅ Yes | ✅ |
| `TWO_FACTOR_AUTH_FORCE_DISABLED` | Auth | `false` | `false` | N/A | ✅ (Kill-Switch) |
| `PAYMENTS_ENABLED` | Payments | `true` | `true` | ✅ Yes | ❌ |
| `PAYMENTS_FORCE_DISABLED` | Payments | `false` | `false` | N/A | ✅ (Kill-Switch) |
| `APPLE_PAY_ENABLED` | Payments | `false` | `false` | ✅ Yes | ❌ |
| `GOOGLE_PAY_ENABLED` | Payments | `false` | `false` | ✅ Yes | ❌ |
| `PAYMENTS_RBAC_CANONICAL_ENFORCED` | Payments | `true` | `true` | ❌ | ❌ |
| `PAYMENTS_FALLBACK_LEGACY` | Payments | `false` | `false` | ❌ | ❌ |
| `PAYMENTS_SECURITY_VALIDATION_ENABLED` | Payments | `true` | `true` | ❌ | ❌ |
| `ENABLE_REALTIME_TRACKING` | Mobility | `true` | `true` | ✅ Yes | ✅ |
| `REALTIME_TRACKING_FORCE_DISABLED` | Mobility | `false` | `false` | N/A | ✅ (Kill-Switch) |
| `ENABLE_BACKGROUND_TRACKING` | Mobility | `true` | `true` | ✅ Yes | ❌ |
| `USE_NOOP_MOBILITY` | Mobility | `true` | `true` | N/A | ❌ |
| `USE_NOOP_MAPS` | Mobility | `true` | `true` | N/A | ❌ |
| `ENABLE_NOTIFICATIONS` | Notifications | `true` | `true` | ✅ Yes (FCM) | ❌ |
| `ENABLE_PRODUCT_ONBOARDING` | Onboarding | `true` | `true` | ❌ | ❌ |
| `RBAC_ENFORCE` | RBAC | `false` | `false` | ❌ | ❌ |
| `RBAC_CANARY_PERCENTAGE` | RBAC | `10` | `10` | ❌ | ❌ |
| `RBAC_DENY_BY_DEFAULT` | RBAC | `true` | `true` | ❌ | ❌ |
| `CERT_PINNING_ENABLED` | Security | `false` | `true` | ❌ | ❌ |
| `API_BASE_URL` | Infrastructure | `''` | (required) | ✅ Yes | ❌ |
| `STRIPE_PUBLISHABLE_KEY` | Infrastructure | `''` | (required) | ✅ Yes | ❌ |
| `TELEMETRY_DSN` | Infrastructure | `''` | (optional) | ❌ | ❌ |
| `SENTRY_DSN` | Infrastructure | `''` | (optional) | ❌ | ❌ |
| `ENVIRONMENT` | Infrastructure | `development` | `production` | ❌ | ❌ |
| `PRODUCTION_ROLLOUT` | Infrastructure | `0` | `100` | ❌ | ❌ |
| `FEATURE_REQUIRES_BACKEND` | Infrastructure | `false` | `false` | ✅ Yes | ❌ |
| `FEATURE_REQUIRES_PAYMENTS` | Infrastructure | `false` | `false` | ✅ Yes | ❌ |
| `FEATURE_REQUIRES_TELEMETRY` | Infrastructure | `false` | `false` | ❌ | ❌ |
| `RELEASE_VERSION` | Infrastructure | `1.0.0` | (build-time) | ❌ | ❌ |

---

## 3) Detailed Behavior

### Authentication Flags

#### ENABLE_PASSWORDLESS_AUTH

- **Location(s):** `lib/config/feature_flags.dart`, `lib/state/auth/passwordless_auth_controller.dart`, `lib/screens/auth/phone_login_screen.dart`, `lib/screens/auth/otp_verification_screen.dart`
- **Environment Variable:** `ENABLE_PASSWORDLESS_AUTH`
- **Default:** Debug = `true`, Release = `true`
- **When true:**
  - Shows Phone/OTP authentication screens
  - Auth flows use `auth_http_impl` package for OTP requests
  - Requires backend endpoints: `/api/v1/auth/otp/request`, `/verify`, `/logout`, `/refresh`
- **When false:**
  - Throws `StateError` when accessing `passwordlessAuthControllerProvider`
  - App should use alternative auth path (not implemented in Clean-B)
- **Backend Dependency:** ✅ Required for OTP verification
- **Recommended Config:**
  - Dev/Staging: `true`
  - Production without Backend OTP: `false` (will break auth)
  - Production with Backend OTP: `true`

---

#### ENABLE_BIOMETRIC_AUTH

- **Location(s):** `lib/config/feature_flags.dart`, `stubs/device_security_shims/lib/device_security_shims.dart`
- **Environment Variable:** `ENABLE_BIOMETRIC_AUTH`
- **Default:** Debug = `true`, Release = `true`
- **When true:**
  - Enables fingerprint/Face ID unlock for returning users
  - Uses `local_auth` package via `device_security_shims`
  - Works independently of backend (device-only check)
- **When false:**
  - Biometric unlock option hidden
  - Users must use OTP for each session
- **Backend Dependency:** ❌ None (device-only feature)
- **Recommended Config:**
  - All environments: `true`

---

#### ENABLE_TWO_FACTOR_AUTH

- **Location(s):** `lib/config/feature_flags.dart`, `lib/state/auth/passwordless_auth_controller.dart`, `lib/screens/auth/two_factor_screen.dart`
- **Environment Variable:** `ENABLE_TWO_FACTOR_AUTH`
- **Kill-Switch Variable:** `TWO_FACTOR_AUTH_FORCE_DISABLED`
- **Default:** Debug = `false`, Release = `false`
- **When true AND backend enables MFA:**
  - MFA flow activated after primary OTP verification
  - User sees `TwoFactorScreen` for second factor entry
  - Supports: SMS, TOTP, Email, Push methods
- **When false:**
  - No MFA UI shown (Sale-Only behavior)
  - `evaluateMfaRequirement` returns `notRequired`
  - No fake/demo 2FA screens
- **Kill-Switch Behavior:**
  - If `TWO_FACTOR_AUTH_FORCE_DISABLED=true`, 2FA is disabled regardless of other settings
- **Backend Dependency:** ✅ Required (rule engine + MFA endpoints)
- **Recommended Config:**
  - Dev/Staging: `true` (for testing)
  - Production without Backend MFA: `false`
  - Production with Backend MFA: `true`

---

### Payments Flags

#### PAYMENTS_ENABLED / PAYMENTS_FORCE_DISABLED

- **Location(s):** `lib/config/feature_flags.dart`, `lib/wiring/payments_wiring.dart`, `packages/payments_shims/*`
- **Environment Variables:** `PAYMENTS_ENABLED`, `PAYMENTS_FORCE_DISABLED`
- **Default:** `PAYMENTS_ENABLED=true`, `PAYMENTS_FORCE_DISABLED=false`
- **When enabled:**
  - Payment UI (cards, checkout) visible
  - Stripe SDK initialized via `payments_stripe_impl`
  - Requires `STRIPE_PUBLISHABLE_KEY` to function
- **When disabled (or force disabled):**
  - Payment options hidden from UI
  - Cart preserved but checkout disabled
  - Graceful "Coming soon" message (Sale-Only)
- **Kill-Switch Behavior:**
  - `PAYMENTS_FORCE_DISABLED=true` overrides all other payment settings
- **Backend Dependency:** ✅ Required (`STRIPE_PUBLISHABLE_KEY`, webhook endpoint)
- **Recommended Config:**
  - Dev/Staging with Stripe test keys: `enabled`
  - Production without Stripe: `force_disabled`
  - Production with Stripe: `enabled`

---

#### APPLE_PAY_ENABLED / GOOGLE_PAY_ENABLED

- **Location(s):** `lib/config/feature_flags.dart`
- **Environment Variables:** `APPLE_PAY_ENABLED`, `GOOGLE_PAY_ENABLED`
- **Default:** Both `false`
- **When enabled:**
  - Shows Apple Pay / Google Pay buttons in checkout
  - Requires merchant account configuration in Stripe
- **When disabled:**
  - Only card payments available
- **Backend Dependency:** ✅ Required (merchant IDs configured in Stripe)
- **Recommended Config:**
  - Phase 1 (Current): Both `false`
  - Phase 2 (After merchant setup): Enable as needed

---

### Mobility / Tracking Flags

#### ENABLE_REALTIME_TRACKING

- **Location(s):** `lib/config/feature_flags.dart`, `lib/state/infra/mobility_availability.dart`, `lib/screens/order_tracking_screen.dart`
- **Environment Variable:** `ENABLE_REALTIME_TRACKING`
- **Kill-Switch Variable:** `REALTIME_TRACKING_FORCE_DISABLED`
- **Default:** `true`
- **When true AND backend available:**
  - Live courier tracking UI visible
  - Location streaming via `mobility_uplink_impl`
  - Requires DW-ALG backend API
- **When false OR backend unavailable:**
  - Tracking tab shows "Coming soon" (Sale-Only)
  - No fake/demo tracking data
  - Static order status card displayed
- **Kill-Switch Behavior:**
  - `REALTIME_TRACKING_FORCE_DISABLED=true` disables tracking regardless of other settings
- **Backend Dependency:** ✅ Required (DW-ALG API: `/api/mobility/*`)
- **Recommended Config:**
  - Dev/Staging without backend: `false`
  - Staging with backend: `true`
  - Production without DW-ALG: `false` (but flag will work, Sale-Only kicks in)
  - Production with DW-ALG: `true`

---

#### ENABLE_BACKGROUND_TRACKING

- **Location(s):** `lib/config/feature_flags.dart`, `packages/mobility_adapter_background/*`
- **Environment Variable:** `ENABLE_BACKGROUND_TRACKING`
- **Default:** `true`
- **When true:**
  - Background location collection active (for couriers)
  - Battery optimization applied
- **When false:**
  - Only foreground location available
- **Backend Dependency:** ✅ Same as realtime tracking
- **Recommended Config:**
  - Follows `ENABLE_REALTIME_TRACKING`

---

#### USE_NOOP_MOBILITY / USE_NOOP_MAPS

- **Location(s):** `lib/state/infra/mobility_providers.dart`
- **Environment Variables:** `USE_NOOP_MOBILITY`, `USE_NOOP_MAPS`
- **Default:** Both `true`
- **When true:**
  - NoOp implementations used (no real GPS/maps)
  - Safe for testing without device permissions
- **When false:**
  - Real implementations from adapters
  - Requires device permissions
- **Backend Dependency:** ❌ None
- **Recommended Config:**
  - Testing/CI: `true`
  - Device testing: `false`

---

### Notifications Flags

#### ENABLE_NOTIFICATIONS

- **Location(s):** `lib/state/onboarding/onboarding_feature_flags_provider.dart`, `lib/state/guidance/guidance_providers_bridge.dart`, `lib/screens/settings/notifications_settings_screen.dart`
- **Environment Variable:** `ENABLE_NOTIFICATIONS`
- **Default:** `true`
- **When true AND FCM configured:**
  - Push notifications active
  - Notification settings screen functional
- **When false OR FCM not configured:**
  - Notification settings hidden (Sale-Only)
  - No push notifications sent
- **Backend Dependency:** ✅ Required (FCM configuration, push gateway)
- **Recommended Config:**
  - Dev/Staging without FCM: UI still shows but won't receive pushes
  - Production without FCM: `false`
  - Production with FCM: `true`

---

### RBAC Flags

#### RBAC_ENFORCE / RBAC_CANARY_PERCENTAGE / RBAC_DENY_BY_DEFAULT

- **Location(s):** `lib/config/feature_flags.dart`, `lib/rbac/rbac_engine.dart`
- **Environment Variables:** `RBAC_ENFORCE`, `RBAC_CANARY_PERCENTAGE`, `RBAC_DENY_BY_DEFAULT`
- **Defaults:** `RBAC_ENFORCE=false`, `RBAC_CANARY_PERCENTAGE=10`, `RBAC_DENY_BY_DEFAULT=true`
- **When RBAC_ENFORCE true:**
  - Role-based access control applied
  - Canary percentage controls rollout
  - Deny-by-default prevents unauthorized access
- **When RBAC_ENFORCE false:**
  - RBAC checks skipped
  - All users have same permissions
- **Backend Dependency:** ❌ None (client-side enforcement)
- **Recommended Config:**
  - Staging: `RBAC_ENFORCE=true`, `RBAC_CANARY_PERCENTAGE=100`
  - Production Phase 1: `RBAC_ENFORCE=true`, `RBAC_CANARY_PERCENTAGE=10`
  - Production Full: `RBAC_ENFORCE=true`, `RBAC_CANARY_PERCENTAGE=100`

---

### Security Flags

#### CERT_PINNING_ENABLED

- **Location(s):** `lib/config/feature_flags.dart`, `lib/main.dart`, `packages/network_shims/*`
- **Environment Variable:** `CERT_PINNING_ENABLED`
- **Default:** Debug = `false`, Release = `true`
- **When true:**
  - TLS certificate pinning active
  - Prevents MITM attacks
  - May interfere with proxy debugging
- **When false:**
  - Standard TLS (no pinning)
  - Allows Charles/Proxyman debugging
- **Backend Dependency:** ❌ None
- **Recommended Config:**
  - Development: `false` (for debugging)
  - Staging: `false` (for QA)
  - Production: `true`

---

### Infrastructure Flags

#### API_BASE_URL / STRIPE_PUBLISHABLE_KEY

- **Location(s):** `lib/config/config_manager.dart`
- **Environment Variables:** `API_BASE_URL`, `STRIPE_PUBLISHABLE_KEY`
- **Defaults:** Empty strings
- **Behavior:**
  - `API_BASE_URL` determines if backend features are available
  - `STRIPE_PUBLISHABLE_KEY` determines if payments are available
  - Empty = feature unavailable (fail-closed)
- **Backend Dependency:** ✅ These ARE the backend configuration
- **Recommended Config:**
  - Dev: Staging URLs/keys
  - Staging: Staging URLs/test keys
  - Production: Production URLs/live keys

---

## 4) Recommended Profiles

### Profile A — Client Demo / Staging (No Payments / No DW-ALG)

For demonstrating the app without backend services.

```bash
flutter build apk --release \
  --dart-define=ENABLE_PASSWORDLESS_AUTH=true \
  --dart-define=ENABLE_BIOMETRIC_AUTH=true \
  --dart-define=ENABLE_TWO_FACTOR_AUTH=false \
  --dart-define=ENABLE_REALTIME_TRACKING=false \
  --dart-define=ENABLE_NOTIFICATIONS=false \
  --dart-define=PAYMENTS_ENABLED=false \
  --dart-define=ENABLE_PRODUCT_ONBOARDING=true \
  --dart-define=CERT_PINNING_ENABLED=false \
  --dart-define=ENVIRONMENT=staging \
  --dart-define=API_BASE_URL=https://staging.deliveryways.com
```

**Result:**
- Auth screens visible (but OTP requires backend)
- Biometric unlock available
- No 2FA, tracking, or payments UI
- Onboarding flow active
- Sale-Only behavior for unavailable features

---

### Profile B — Staging (Backend Ready for Auth, Payments in Test Mode)

For QA testing with staging backend.

```bash
flutter build apk --release \
  --dart-define=ENABLE_PASSWORDLESS_AUTH=true \
  --dart-define=ENABLE_BIOMETRIC_AUTH=true \
  --dart-define=ENABLE_TWO_FACTOR_AUTH=true \
  --dart-define=ENABLE_REALTIME_TRACKING=true \
  --dart-define=ENABLE_NOTIFICATIONS=true \
  --dart-define=PAYMENTS_ENABLED=true \
  --dart-define=ENABLE_PRODUCT_ONBOARDING=true \
  --dart-define=CERT_PINNING_ENABLED=false \
  --dart-define=ENVIRONMENT=staging \
  --dart-define=API_BASE_URL=https://staging.deliveryways.com \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_xxx \
  --dart-define=SENTRY_DSN=https://xxx@sentry.io/xxx
```

**Result:**
- Full feature set enabled
- All features functional with staging backend
- Test payments with Stripe test cards
- No certificate pinning (for debugging)

---

### Profile C — Production (Backend Auth Ready, Payments & Tracking Pending)

For first production release with partial backend.

```bash
flutter build apk --release \
  --dart-define=ENABLE_PASSWORDLESS_AUTH=true \
  --dart-define=ENABLE_BIOMETRIC_AUTH=true \
  --dart-define=ENABLE_TWO_FACTOR_AUTH=false \
  --dart-define=ENABLE_REALTIME_TRACKING=false \
  --dart-define=ENABLE_NOTIFICATIONS=false \
  --dart-define=PAYMENTS_ENABLED=false \
  --dart-define=ENABLE_PRODUCT_ONBOARDING=true \
  --dart-define=CERT_PINNING_ENABLED=true \
  --dart-define=RBAC_ENFORCE=true \
  --dart-define=RBAC_CANARY_PERCENTAGE=100 \
  --dart-define=ENVIRONMENT=production \
  --dart-define=API_BASE_URL=https://api.deliveryways.com \
  --dart-define=SENTRY_DSN=https://xxx@sentry.io/xxx \
  --dart-define=PRODUCTION_ROLLOUT=100
```

**Result:**
- Auth fully functional
- Payments, tracking, notifications hidden (Sale-Only)
- Certificate pinning active
- Full RBAC enforcement

---

### Profile D — Production (Full Feature Release)

For production release with all backend services ready.

```bash
flutter build apk --release \
  --dart-define=ENABLE_PASSWORDLESS_AUTH=true \
  --dart-define=ENABLE_BIOMETRIC_AUTH=true \
  --dart-define=ENABLE_TWO_FACTOR_AUTH=true \
  --dart-define=ENABLE_REALTIME_TRACKING=true \
  --dart-define=ENABLE_BACKGROUND_TRACKING=true \
  --dart-define=ENABLE_NOTIFICATIONS=true \
  --dart-define=PAYMENTS_ENABLED=true \
  --dart-define=ENABLE_PRODUCT_ONBOARDING=true \
  --dart-define=CERT_PINNING_ENABLED=true \
  --dart-define=RBAC_ENFORCE=true \
  --dart-define=RBAC_CANARY_PERCENTAGE=100 \
  --dart-define=ENVIRONMENT=production \
  --dart-define=API_BASE_URL=https://api.deliveryways.com \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_xxx \
  --dart-define=SENTRY_DSN=https://xxx@sentry.io/xxx \
  --dart-define=PRODUCTION_ROLLOUT=100
```

**Result:**
- All features enabled and functional
- Full production configuration

---

## 5) Kill-Switch Quick Reference

| Kill-Switch Flag | Overrides | Emergency Use |
|-----------------|-----------|---------------|
| `PAYMENTS_FORCE_DISABLED=true` | All payment flags | Disable payments immediately |
| `TWO_FACTOR_AUTH_FORCE_DISABLED=true` | `ENABLE_TWO_FACTOR_AUTH` | Disable 2FA if issues detected |
| `REALTIME_TRACKING_FORCE_DISABLED=true` | `ENABLE_REALTIME_TRACKING` | Disable tracking if backend fails |

**To activate a kill-switch in production:**
1. Release new build with kill-switch flag
2. Or use RemoteConfig to update `ConfigManager` values

---

## 6) Passing Flags

### Via `--dart-define` (Compile-time)

```bash
flutter build apk --release --dart-define=FLAG_NAME=value
```

### Via Environment Variables (CI/CD)

```yaml
# GitHub Actions example
- name: Build APK
  env:
    ENABLE_PASSWORDLESS_AUTH: true
    PAYMENTS_ENABLED: true
  run: |
    flutter build apk --release \
      --dart-define=ENABLE_PASSWORDLESS_AUTH=$ENABLE_PASSWORDLESS_AUTH \
      --dart-define=PAYMENTS_ENABLED=$PAYMENTS_ENABLED
```

### Via ConfigManager (Runtime)

Some flags can be overridden at runtime via `ConfigManager`:

```dart
// In app initialization
ConfigManager.instance.overrideValue('api.baseUrl', 'https://new-api.com');
```

---

## 7) Related Documents

- `docs/reports/PROJECT_STATUS_v3.2.1.md` — Current project status
- `docs/reports/RELEASE_EXECUTION_PLAN_v2.0.0.md` — Release steps
- `docs/reports/RISKS_AND_GAPS_REGISTER_v1.0.0.md` — Blockers and risks
- `docs/reports/CLIENT_DELIVERY_CHECKLIST_v1.0.0.md` — Delivery checklist

---

**Document Status**: FROZEN for Client Handover
**Next Review**: Post-backend integration



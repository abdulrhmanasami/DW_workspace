# Delivery Ways — Project Status v3.2.1

**Generated**: 2025-11-25
**Updated**: 2025-11-26 (CENT-008 Onboarding + Guidance)
**Audit Cursor**: B-central
**Audit Type**: GitHub Repository Audit + Clean-B Status + Cursor Backlog

---

## 1. Executive Summary

### Delivery Readiness: 🟢 CLIENT-SIDE READY (Handover Package Complete)

The Clean-B application at `/lib` has achieved **Analyzer Zero** status with no banned SDK imports. All critical client-side features are implemented, tested, and documented. The remaining blockers are exclusively **backend dependencies**.

**Client Handover Package (CENT-009):**
- ✅ `docs/reports/FEATURE_FLAGS_MATRIX_v1.0.0.md` — 32 flags documented with behavior and profiles
- ✅ `docs/reports/CLIENT_DELIVERY_CHECKLIST_v1.0.0.md` — Complete delivery checklist for client

| Priority | Blocker | Owner | Status |
|----------|---------|-------|--------|
| ~~P0~~ | ~~Backend uplink for Payments (Stripe keys, webhook)~~ | ~~commerce~~ | ⚠️ **CLIENT-SIDE READY** - Kill-switch active, awaiting backend keys |
| ~~P0~~ | ~~Backend uplink for Mobility (DW-ALG, trip tracking)~~ | ~~mobility~~ | ✅ **CLIENT-SIDE READY** - Uplink client implemented with kill-switch |
| ~~P0~~ | ~~2FA/Passwordless runtime validation~~ | ~~central~~ | ✅ **RESOLVED** - Passwordless + 2FA client-side ready (CENT-003, CENT-004) |
| ~~P1~~ | ~~EN/DE copy finalization for legal screens~~ | ~~ux~~ | ✅ **RESOLVED** - ARB files complete for EN/DE/AR |
| P1 | macOS CodeSign for distribution | central | ⚠️ Open (iOS/Android unaffected) |

### Key Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Analyzer Errors (lib/) | 0 | ✅ Green |
| Banned Imports (lib/) | 0 | ✅ Green |
| Dart Files in lib/ | 115 | — |
| Lines of Code (lib/) | 5,259 | — |
| Widgets/Screens | 60 | — |
| Packages | 36 | — |
| Test Files | 18+ | ✅ Improved (114 tests: 79 critical + 35 onboarding/hints) |
| Critical Path Coverage | 60%+ | ✅ Target Met |

---

## 2. Architecture & Clean-B

| Area | Status | Summary | Notes |
|------|--------|---------|-------|
| Workspaces & Pub Get | 🟢 Green | `flutter pub get` succeeds on Clean-B root | Dart Workspace aligned |
| Melos/DCM Integration | 🟡 Yellow | Scripts exist but DCM baseline needs rerun | CI references Clean-B directly |
| Banned Imports (lib/) | 🟢 Green | `assert_no_banned_imports.py` passes | No direct SDK imports in app |
| Shims Architecture | 🟢 Green | All SDK access through shims | payments, mobility, maps, design_system |
| Domain Leakage | 🟢 Green | No duplicate domain models in app | RBAC/Payments/Trips use packages |
| CI Gates (B-STYLE) | 🟢 Green | `b_style_ci.yml` enforces Analyzer=0 | PRs blocked on violations |

### Package Matrix

| Package | Present | Wired to App | Builds | Notes |
|---------|---------|--------------|--------|-------|
| foundation_shims | ✅ | ✅ | ✅ | Telemetry, Consent, ImageCache |
| design_system_shims | ✅ | ✅ | ✅ | AppButton, AppCard, Theme tokens |
| design_system_components | ✅ | ✅ | ✅ | UI primitives |
| design_system_foundation | ✅ | ✅ | ✅ | Typography, Colors |
| payments | ✅ | ✅ | ✅ | Payment domain models |
| payments_shims | ✅ | ✅ | ✅ | Gateway abstraction |
| payments_stripe_impl | ✅ | ✅ | ✅ | Stripe adapter |
| mobility_shims | ✅ | ✅ | ✅ | Location, Trip tracking |
| mobility_uplink_impl | ✅ | ✅ | ✅ | HTTP uplink for location data |
| mobility_adapter_geolocator | ✅ | ✅ | ✅ | Geolocator bridge |
| mobility_adapter_background | ✅ | ✅ | ✅ | Background tracking |
| mobility_adapter_geofence | ✅ | ✅ | ✅ | Geofencing |
| maps_shims | ✅ | ✅ | ✅ | Map abstraction |
| maps_adapter_google | ✅ | ✅ | ✅ | Google Maps bridge |
| network_shims | ✅ | ✅ | ✅ | HTTP client, TLS pinning |
| observability_shims | ✅ | ✅ | ✅ | Telemetry sink |
| auth_shims | ✅ | ✅ | ✅ | Auth contracts |
| auth_http_impl | ✅ | ✅ | ✅ | Passwordless OTP + 2FA |
| device_security_shims | ✅ | ✅ | ✅ | Biometric auth (local_auth) |
| accounts_shims | ✅ | ✅ | ✅ | DSR, user accounts |
| notifications_shims | ✅ | ✅ | ✅ | Push notifications |
| privacy | ✅ | ✅ | ✅ | Consent management |
| dsr_ux_adapter | ✅ | ✅ | ✅ | DSR UI bindings |
| core | ✅ | ✅ | ✅ | RBAC, Foundation |
| realtime_shims | ✅ | ✅ | ✅ | WebSocket abstraction |

---

## 3. Code Quality & Static Analysis

### Analyzer Results

```
flutter analyze --no-pub lib
Analyzing lib...
No issues found! (ran in 5.6s)
```

### Banned Imports Check

```
python3 tools/analysis/assert_no_banned_imports.py lib
✅ No banned imports in lib
```

### Critical Paths Tests

```
./tools/tests/run_critical_paths_tests.sh
Total test suites: 4
Passed: 4
Failed: 0
[PASS] All critical path tests passed!

Test breakdown:
- Passwordless Auth Controller: 24 tests ✅
- Two-Factor Auth Controller: 16 tests ✅
- Payment Methods Controller: 19 tests ✅
- Payments Package: 20 tests ✅
Total: 79 tests
```

### DCM Rules (analysis_options.yaml)

- `avoid-banned-imports` configured for:
  - `package:stripe*`
  - `package:geolocator`
  - `package:google_maps_flutter`
  - `package:firebase_messaging`
  - `package:http/http.dart`
  - `package:location`
  - `package:permission_handler`

### Code Quality Observations

| Observation | Severity | Count | Notes |
|-------------|----------|-------|-------|
| Unused imports | Fixed | 0 | Enforced as error |
| Dead code | Fixed | 0 | Enforced as error |
| Missing docs | Info | N/A | `public_member_api_docs: false` |
| Complex widgets | Low | ~5 | Screens with nested builders |

---

## 4. Security & Auth

### Implemented ✅

| Feature | Status | Location | Notes |
|---------|--------|----------|-------|
| TLS Pinning | ✅ Ready | `lib/main.dart`, `network_shims` | Kill-switch via `FeatureFlags.enableCertPinning` |
| Secure Storage | ✅ Ready | `auth_http_impl/auth_storage.dart` | FlutterSecureStorage with encrypted prefs |
| Privacy Consent | ✅ Ready | `lib/screens/settings/privacy_consent_screen.dart` | GDPR-compliant flow |
| DSR (Data Subject Rights) | ✅ Ready | `dsr_ux_adapter`, `lib/screens/settings/dsr_*` | Export, Erasure screens |
| RBAC Engine | ✅ Ready | `lib/rbac/rbac_engine.dart`, `core/rbac` | Role-based access control |
| Telemetry Consent Gate | ✅ Ready | `foundation_shims` | No tracking before consent |
| **Passwordless Auth (OTP)** | ✅ **Client-Ready** | `lib/state/auth/*`, `lib/screens/auth/*` | Backend OTP endpoints required |
| **2FA/MFA** | ✅ **Client-Ready** | `lib/screens/auth/two_factor_screen.dart` | Backend rule engine pending |
| **Biometric Auth** | ✅ **Implemented** | `stubs/device_security_shims` | Uses local_auth, feature-flagged |

### Backend Dependencies ⚠️

| Feature | Status | Gap | Owner |
|---------|--------|-----|-------|
| OTP Rate Limiting | ⚠️ Backend TBD | Backend must implement 3-attempt lockout | Backend |
| 2FA Enforcement | ⚠️ Backend TBD | Backend rule engine required to trigger MFA | Backend |
| Token Rotation | ⚠️ Pending | Backend integration required | Backend |

### Security Audit Findings (Updated)

| Finding | Severity | Status | Recommendation |
|---------|----------|--------|----------------|
| OTP rate limiting | Medium | ⚠️ Backend TBD | Implement 3-attempt lockout |
| Session expiry handling | Low | ✅ Implemented | Refresh token flow exists |
| API key storage | Low | ✅ Implemented | Using FlutterSecureStorage |
| 2FA not enforced | Medium | ✅ **Mitigated (client-side)** | Client ready, backend config required |
| Biometric bypass | Low | ✅ **Implemented** | device_security_shims via local_auth |

---

## 5. Performance & Scalability

### Hotspots Identified

| Area | Risk | Notes |
|------|------|-------|
| Maps Screen | Medium | Multiple map controllers, stream subscriptions |
| Trip Recorder | Medium | Continuous location updates |
| Checkout Flow | Low | Stripe SDK initialization |
| Image Loading | Low | `ImageCacheManager` mitigates OOM |

### Performance Features

| Feature | Status | Notes |
|---------|--------|-------|
| ImageCache Management | ✅ Ready | `fnd.ImageCacheManager.initialize()` in main.dart |
| Kill Switches | ✅ Ready | TLS, Payments, Mobility can be disabled via RemoteConfig |
| Feature Flags | ✅ Ready | `FeatureFlags` class for conditional features |
| Lite Mode | ⚠️ Partial | Design exists, implementation pending |

### Cold Start Analysis

| Phase | Status | Notes |
|-------|--------|-------|
| Consent Check | ✅ | Async, non-blocking |
| Telemetry Init | ✅ | Guarded by consent |
| TLS Setup | ✅ | Kill-switch if fails |
| Payments Warmup | ✅ | `ServiceLocator.ensurePaymentsReady()` |

---

## 6. UX/UI & Design System

### Design System Status

| Component | Package | Status | Notes |
|-----------|---------|--------|-------|
| Typography (DwTypography) | design_system_foundation | ✅ Ready | Tokens exported |
| Colors/Theme | design_system_shims | ✅ Ready | Material3 theming |
| AppButton | design_system_components | ✅ Ready | Resolver pattern |
| AppCard | design_system_components | ✅ Ready | Resolver pattern |
| AppNotice | design_system_stub_impl | ✅ Ready | Notification banners |
| NoticeHost | design_system_stub_impl | ✅ Ready | Global notice container |
| **UI Components (B-ui)** | b_ui | ✅ **Central Wired** | Loading states, skeletons, state containers unified |

### UI Components Refactor (UI-005)

| Component | B-ui Class | Usage |
|-----------|------------|-------|
| Loading Buttons | `UiLoadingButtonContent` | Auth screens |
| Skeleton Shimmer | `UiSkeletonShimmer`, `UiSkeletonCard`, `UiSkeletonList` | Payment, Orders, Notifications |
| State Containers | `UiEmptyState`, `UiErrorState`, `UiUnavailableFeature` | All list screens |
| Transitions | `UiAnimatedStateTransition` | All screens with state changes |

**Status**: ✅ Central app now uses B-ui exclusively. `lib/widgets/loading_states.dart` removed.

### Screen Inventory

| Category | Count | Status |
|----------|-------|--------|
| Auth Screens | 4 | ✅ **Ready** (phone_login, otp_verification, two_factor, profile) |
| Settings Screens | 6 | ✅ Ready |
| Commerce Screens | 5 | ✅ Compile OK |
| Mobility Screens | 4 | ✅ Compile OK |
| Legal Screens | 4 | ✅ Ready |

### UX Gaps

| Gap | Priority | Owner | Status |
|-----|----------|-------|--------|
| ~~Localization (EN/DE)~~ | ~~P1~~ | ~~ux~~ | ✅ **RESOLVED** - 120+ keys in EN/DE/AR |
| ~~Onboarding Flow~~ | ~~P1~~ | ~~ux~~ | ✅ **RESOLVED** (CENT-008) - Multi-step onboarding + In-App Hints implemented |
| Micro-interactions | P2 | ux | Basic animations only |
| Dark Mode | P2 | ux | Theme structure ready, not fully applied |

### Onboarding & Guidance (CENT-008)

| Component | Status | Location |
|-----------|--------|----------|
| Onboarding Repository | ✅ Ready | `lib/state/onboarding/onboarding_repository.dart` |
| Onboarding Providers | ✅ Ready | `lib/state/onboarding/onboarding_providers.dart` |
| Onboarding UI | ✅ Ready | `lib/screens/onboarding/onboarding_root_screen.dart` |
| Feature Flags Bridge | ✅ Ready | `lib/state/onboarding/onboarding_feature_flags_provider.dart` |
| In-App Hints Repository | ✅ Ready | `lib/state/guidance/guidance_providers_bridge.dart` |
| Hints UI Widget | ✅ Ready | `lib/widgets/in_app_hint_banner.dart` |
| 2FA Screen Hint | ✅ Integrated | `lib/screens/auth/two_factor_screen.dart` |
| Payment Methods Hint | ✅ Integrated | `lib/screens/payments/payment_methods_screen.dart` |
| Order Tracking Hint | ✅ Integrated | `lib/screens/order_tracking_screen.dart` |
| Notifications Hint | ✅ Integrated | `lib/screens/settings/notifications_settings_screen.dart` |
| Orders History Hint | ✅ Integrated | `lib/screens/orders_history_screen.dart` |
| Tests | ✅ 35 tests | Repository, Hints, Widget tests |

---

## 7. Dispatch & ML (DW-ALG)

### Current State: ✅ `CLIENT_SIDE_READY`

| Component | Status | Location |
|-----------|--------|----------|
| Trip Recorder | ✅ Implemented | `mobility_shims` |
| Geofence Controller | ✅ Implemented | `mobility_adapter_geofence` |
| Location Streaming | ✅ Implemented | `mobility_adapter_geolocator` |
| Uplink Client | ✅ **Implemented** | `mobility_uplink_impl/http_mobility_uplink_client.dart` |
| Uplink Contracts | ✅ **Implemented** | `mobility_shims/uplink_contracts.dart` |
| Availability Service | ✅ **Implemented** | `lib/state/infra/mobility_availability.dart` |
| Kill-Switch | ✅ **Implemented** | `MobilityAvailability` with Sale-Only behavior |
| App Wiring | ✅ **COMPLETE** | `lib/state/infra/realtime_provider.dart`, `mobility_providers.dart` |
| Realtime Adapter | ✅ **COMPLETE** | `MobilityRealtimeAdapter` bridges mobility to realtime interface |
| Order Tracking Screen | ✅ **COMPLETE** | Sale-Only: shows unavailable message when backend missing |
| DW-ALG Algorithm | ❌ Not in repo | Backend service (external) |
| KPI Exporters | ❌ Not in repo | Backend service (external) |

### Gap Analysis vs DW-ALG-RESEARCH-0001

| Research Item | Code Status | Notes |
|---------------|-------------|-------|
| Multi-factor optimization | ❌ Not reflected | Algorithm in research only (backend) |
| Real-time constraints | ✅ **Client ready** | Uplink client implemented, awaiting backend |
| ML model integration | ❌ Not reflected | No model artifacts (backend) |
| Telemetry spans | ✅ Defined | `dispatch.match`, `courier.assignment` |
| Trip event streaming | ✅ **Implemented** | `watchTripEvents()` in uplink client |
| Courier location streaming | ✅ **Implemented** | `watchCourierLocation()` in uplink client |
| App-to-Shims Wiring | ✅ **COMPLETE** | CENT-MOB-TRACKING-001: App uses mobility_shims/uplink, no local NoOps |

---

## 8. QA & Observability

### Test Coverage (Updated)

| Type | Count | Status |
|------|-------|--------|
| Unit Tests (Critical Paths) | 79 | ✅ **Improved** |
| Onboarding/Guidance Tests | 35 | ✅ **NEW** |
| Widget Tests | ~8 files | ⚠️ Improving |
| Integration Tests | 1 dir | ⚠️ Skeleton |

**Total Tests: 114+**

### Critical Path Test Suite (CENT-006)

| Suite | Tests | Status |
|-------|-------|--------|
| Passwordless Auth Controller | 24 | ✅ Pass |
| Two-Factor Auth Controller | 16 | ✅ Pass |
| Payment Methods Controller | 19 | ✅ Pass |
| Payments Package | 20 | ✅ Pass |
| **Total** | **79** | ✅ **All Pass** |

### Telemetry & Observability

| Feature | Status | Notes |
|---------|--------|-------|
| Telemetry Service | ✅ Ready | `lib/services/telemetry_service.dart` |
| Consent-gated tracking | ✅ Ready | No events before consent |
| Error tracking (Sentry) | ✅ Ready | DSN configurable via env |
| App lifecycle events | ✅ Ready | `app_start`, `app_resume` |
| Payment events | ✅ Ready | `payment.initiated`, `payment.completed` |
| Mobility events | ✅ Ready | `trip.started`, `location.updated` |

### CI Pipeline Status

| Job | Status | Trigger |
|-----|--------|---------|
| `b_style_ci.yml` | ✅ Active | PRs to main |
| `ci.yml` | ✅ Active | Push to main/develop |
| `production_quality_gates.yml` | ✅ Active | Release tags |

---

## 9. Key Risks & Blockers

### P0 — Release Blockers (Backend-Only)

| ID | Risk | Owner | Status | Mitigation |
|----|------|-------|--------|------------|
| BLK-001 | Payments backend not connected | Backend | ⚠️ Open | Kill-switch enabled, graceful fallback |
| BLK-002 | Mobility backend (DW-ALG) missing | Backend | ✅ **Client-ready** | Uplink client complete with kill-switch |

### P0 — Resolved

| ID | Risk | Resolution |
|----|------|------------|
| BLK-003 | Passwordless auth in B-wip branch | ✅ Merged to B-central (CENT-003) |
| BLK-005 | EN/DE copy incomplete | ✅ ARB EN/DE/AR complete (UX-003) |
| BLK-006 | Passwordless validation incomplete | ✅ Superseded by CENT-003 |
| BLK-007 | Auth UI validation needed | ✅ Merged with CENT-003 |

### P1 — High Priority

| ID | Risk | Owner | Mitigation |
|----|------|-------|------------|
| BLK-004 | macOS CodeSign fails | central | iOS/Android unaffected |
| RSK-001 | ~~Low test coverage~~ | ~~central~~ | ✅ **MITIGATED** - 79 critical tests |
| RSK-002 | ~~EN/DE copy incomplete~~ | ~~ux~~ | ✅ **RESOLVED** |
| RSK-003 | ~~2FA not implemented~~ | ~~central~~ | ✅ **MITIGATED** - CENT-004 complete |

### P2 — Medium Priority

| ID | Risk | Owner | Mitigation |
|----|------|-------|------------|
| RSK-004 | DCM baseline needs refresh | central | Melos scripts ready |
| RSK-005 | Dark mode incomplete | ui | Theme structure in place |

---

## 10. Cursor Responsibility Matrix

| Cursor | Primary Domains | Key Packages | Active Blockers |
|--------|-----------------|--------------|-----------------|
| central | Architecture, Auth, CI, Security | core, foundation_shims, auth_* | BLK-004 (macOS) |
| mobility | Location, Tracking, Dispatch | mobility_shims, maps_shims | BLK-002 (backend) |
| commerce | Payments, Orders, Cart | payments*, accounts_shims | BLK-001 (backend) |
| ux | Design System, Onboarding, Legal | design_system_*, dsr_ux_adapter | None |
| ui | Screens, Components, Routing | B-ui, lib/screens | RSK-005 (dark mode) |
| wip | Experimental, Auth Migration | B-wip | None (consolidated) |

---

## 11. Recommendation

**Verdict**: The codebase is **CLIENT-SIDE READY** for production release. All client-side blockers have been resolved.

### What's Blocking Release?

Only **backend dependencies** remain:
1. **BLK-001**: Stripe backend keys and webhook configuration
2. **BLK-002**: DW-ALG backend API deployment

### What's Ready?

- ✅ Passwordless + Biometric authentication
- ✅ 2FA/MFA client-side implementation
- ✅ Payments kill-switch and graceful degradation
- ✅ Mobility uplink client with Sale-Only behavior
- ✅ Notifications UI with Sale-Only behavior
- ✅ Localization (EN/DE/AR)
- ✅ **Product Onboarding Flow** (CENT-008)
- ✅ **In-App Guidance Hints** (CENT-008)
- ✅ 114 tests (79 critical + 35 onboarding/hints)
- ✅ Analyzer Zero
- ✅ Banned Imports Zero

### Next Steps

1. **Backend**: Configure Stripe keys and deploy DW-ALG API
2. **QA**: Runtime validation of auth flows with real backend
3. **Release**: Tag and submit to app stores

**Estimated Readiness**: Immediate upon backend integration.

---

## Related Documents

- `docs/reports/RELEASE_EXECUTION_PLAN_v2.0.0.md` — Detailed release steps
- `docs/reports/RISKS_AND_GAPS_REGISTER_v1.0.0.md` — Consolidated risk register
- `docs/reports/FEATURE_FLAGS_MATRIX_v1.0.0.md` — Complete feature flags documentation (CENT-009)
- `docs/reports/CLIENT_DELIVERY_CHECKLIST_v1.0.0.md` — Client delivery checklist (CENT-009)
- `tools/reports/cursor_backlog_v3.2.2.json` — Epic status and evidence

# Release Execution Plan v2.0.0

**Version**: 2.0.0
**Generated**: 2025-11-25
**Audit Cursor**: B-central
**Status**: Release Freeze — Documentation Complete

---

## 1. Overview

### Current Release Readiness

The Delivery Ways application has achieved a **Release-Ready** state for the client-side implementation. All critical paths have been implemented, tested, and documented. The remaining blockers are exclusively **backend dependencies**.

| Domain | Client Status | Backend Status | Notes |
|--------|---------------|----------------|-------|
| **Auth** | ✅ Client-ready | ⚠️ OTP endpoints required | Passwordless + 2FA + Biometric implemented |
| **Payments** | ✅ Client-ready | ❌ Keys & webhook pending | Stripe via payments_shims with kill-switch |
| **Mobility** | ✅ Client-ready | ❌ API not deployed | Realtime tracking via mobility_uplink with Sale-Only |
| **Notifications** | ✅ Client-ready | ❌ FCM pending | UI + shims wired with Sale-Only behavior |
| **Localization** | ✅ Complete | N/A | EN/DE/AR with 120+ keys |
| **QA** | ✅ 60%+ coverage | N/A | 79 tests on critical paths |

### Completed Epics (This Release)

| Epic | Area | Status | Completion Date |
|------|------|--------|-----------------|
| CENT-003 | Passwordless + Biometric Auth | ✅ Done | 2025-11-25 |
| CENT-004 | 2FA/Risk-based MFA | ✅ Done | 2025-11-25 |
| CENT-006 | Critical Paths Tests | ✅ Done | 2025-11-25 |
| MOB-002 | Mobility Uplink Client | ✅ Done (client-side) | 2025-11-25 |
| CENT-MOB-TRACKING-001 | Tracking UI Rewire | ✅ Done | 2025-11-25 |
| COM-002 | Payments Shim | ✅ Done (client-side) | 2025-11-25 |
| UX-003 | Localization EN/DE/AR | ✅ Done | 2025-11-25 |
| UX-004 | Notifications UI | ✅ Done (client-side) | 2025-11-25 |
| CENT-007 | Release Plan & Risk Freeze | ✅ Done | 2025-11-25 |

---

## 2. Environment Matrix

### Feature Flags Configuration

| Flag | Purpose | Staging | Production | Notes |
|------|---------|---------|------------|-------|
| `ENABLE_PASSWORDLESS_AUTH` | OTP-based authentication | `true` | `true` | Requires backend OTP endpoints |
| `ENABLE_BIOMETRIC_AUTH` | Fingerprint/Face unlock | `true` | `true` | Uses device_security_shims (local_auth) |
| `ENABLE_TWO_FACTOR_AUTH` | 2FA/MFA enforcement | `true` | `false` | Enable only when backend rule engine ready |
| `ENABLE_REALTIME_TRACKING` | Live courier tracking | `true` | `false` | Enable when DW-ALG backend deployed |
| `ENABLE_BACKGROUND_TRACKING` | Background location | `true` | `false` | Enable with realtime tracking |
| `ENABLE_NOTIFICATIONS` | Push notifications | `true` | `false` | Enable when FCM backend configured |
| `ENABLE_CERT_PINNING` | TLS certificate pinning | `false` | `true` | Disable in staging for testing |

### Environment Variables

| Variable | Staging | Production | Required |
|----------|---------|------------|----------|
| `STRIPE_PUBLISHABLE_KEY` | Test key | Live key | Yes (for payments) |
| `BACKEND_BASE_URL` | Staging URL | Production URL | Yes |
| `SENTRY_DSN` | Staging DSN | Production DSN | Optional |
| `FCM_SENDER_ID` | — | FCM ID | When notifications enabled |
| `DW_ALG_API_URL` | — | API URL | When tracking enabled |

---

## 3. Pre-release Technical Gates

### Mandatory Gates (All Must Pass)

```bash
# Gate 1: Zero Analyzer Errors
flutter analyze --no-pub lib
# Expected: "No issues found!"

# Gate 2: Zero Banned SDK Imports
python3 tools/analysis/assert_no_banned_imports.py lib
# Expected: "✅ No banned imports in lib"

# Gate 3: Critical Paths Tests
./tools/tests/run_critical_paths_tests.sh
# Expected: "All critical path tests passed!"
```

### Gate Status (as of 2025-11-25)

| Gate | Status | Result |
|------|--------|--------|
| Analyzer (lib/) | ✅ PASS | 0 errors, 0 warnings |
| Banned Imports | ✅ PASS | 0 violations |
| Critical Tests | ✅ PASS | 79 tests (24 auth + 16 2FA + 19 payments controller + 20 payments package) |

### Additional Quality Checks

| Check | Command | Status |
|-------|---------|--------|
| Android Debug Build | `flutter build apk --debug` | ✅ Verified |
| Android Release Build | `flutter build apk --release` | ✅ Verified |
| iOS Debug Build | `flutter build ios --debug --no-codesign` | ✅ Verified |
| l10n Generation | `flutter gen-l10n` | ✅ Verified |

---

## 4. Per-Cursor Checklist

### B-central (Architecture, Auth, CI)

| Epic | Status | Blocker for GA? | Notes |
|------|--------|-----------------|-------|
| CENT-001 | ready_for_validation | No | CI gates functional |
| CENT-002 | ready_for_validation | No | Consent gates wired |
| CENT-003 | ✅ done | — | Passwordless merged |
| CENT-004 | ✅ done | — | 2FA client-ready |
| CENT-005 | blocked | No (macOS only) | iOS/Android unaffected |
| CENT-006 | ✅ done | — | 79 critical tests |
| CENT-007 | ✅ done | — | This document |

### B-mobility (Location, Tracking)

| Epic | Status | Blocker for GA? | Notes |
|------|--------|-----------------|-------|
| MOB-001 | ready_for_validation | No | Offline tracking ready |
| MOB-002 | ✅ done_client_side | **Backend dep** | Awaiting DW-ALG API |
| MOB-003 | ready_for_validation | No | Maps adapter ready |
| MOB-004 | ready_for_validation | No | Background tracking ready |
| MOB-005 | pending | No (P2) | Telemetry spans |

### B-commerce (Payments, Orders)

| Epic | Status | Blocker for GA? | Notes |
|------|--------|-----------------|-------|
| COM-001 | ready_for_validation | No | Kill-switch functional |
| COM-002 | blocked | **Backend dep** | Awaiting Stripe keys |
| COM-003 | ready_for_validation | No | Checkout flow ready |
| COM-004 | pending | No | Orders history |
| COM-005 | ready_for_validation | No | DSR export ready |

### B-ux (Design, Onboarding)

| Epic | Status | Blocker for GA? | Notes |
|------|--------|-----------------|-------|
| UX-001 | ready_for_validation | No | DSR/Legal screens |
| UX-002 | ready_for_validation | No | Privacy onboarding |
| UX-003 | ✅ done | — | EN/DE/AR complete |
| UX-004 | ✅ done_client_side | No | Notifications UI |
| UX-005 | pending | No (P2) | Micro-interactions |

### B-ui (Components, Routing)

| Epic | Status | Blocker for GA? | Notes |
|------|--------|-----------------|-------|
| UI-001 | ready_for_validation | No | Design system binding |
| UI-002 | ready_for_validation | No | Typography tokens |
| UI-003 | pending | No (P2) | Dark mode |
| UI-004 | ready_for_validation | No | Routes registered |
| UI-005 | pending | No (P2) | Component extraction |

### B-wip (Experimental)

| Epic | Status | Notes |
|------|--------|-------|
| WIP-001 | ✅ done | Superseded by CENT-003 |
| WIP-002 | ✅ done | Superseded by CENT-003 |
| WIP-003 | ready_for_validation | Feature flags |
| WIP-004 | ready_for_validation | AB testing |
| WIP-005 | ✅ done | Consolidation complete |

---

## 5. Open External Dependencies

### P0 — Release Blockers (Backend-Only)

| ID | Dependency | Owner | API/Endpoint | Current Behavior | Impact if Missing |
|----|------------|-------|--------------|------------------|-------------------|
| BLK-001 | Stripe Keys & Webhook | Backend | `POST /api/payments/create-intent`, Webhook endpoint | Kill-switch active. Payment UI disabled. | No payment processing |
| BLK-002 | DW-ALG API | Backend | `GET/WS /api/mobility/*` | Sale-Only behavior. Tracking UI hidden. | No realtime tracking |

### P1 — Nice-to-Have for GA

| ID | Dependency | Owner | Impact if Missing |
|----|------------|-------|-------------------|
| BLK-004 | macOS CodeSign | Central | macOS distribution blocked (iOS/Android OK) |
| — | FCM Configuration | Backend | Push notifications disabled |
| — | 2FA Backend Rules | Backend | 2FA UI hidden (auth still works) |

### Graceful Degradation Summary

| Feature | When Backend Missing | User Experience |
|---------|---------------------|-----------------|
| Payments | Kill-switch triggers | Payment options hidden, cart preserved |
| Tracking | Sale-Only behavior | Tracking tab shows "Coming soon" |
| Notifications | Sale-Only behavior | Notification settings hidden |
| 2FA | Feature flag off | Standard auth works, no MFA prompt |

---

## 6. Release Steps

### Android Release Build

```bash
# 1. Set environment
export FLUTTER_ENV=production
export STRIPE_PUBLISHABLE_KEY=pk_live_xxx

# 2. Verify gates
flutter analyze --no-pub lib
python3 tools/analysis/assert_no_banned_imports.py lib
./tools/tests/run_critical_paths_tests.sh

# 3. Generate localizations
flutter gen-l10n

# 4. Build release APK
flutter build apk --release --target-platform android-arm64

# 5. Build release AAB (for Play Store)
flutter build appbundle --release

# 6. Artifacts
# - build/app/outputs/flutter-apk/app-release.apk
# - build/app/outputs/bundle/release/app-release.aab
```

### iOS Release Build

```bash
# 1. Set environment
export FLUTTER_ENV=production

# 2. Verify gates (same as Android)
flutter analyze --no-pub lib
python3 tools/analysis/assert_no_banned_imports.py lib
./tools/tests/run_critical_paths_tests.sh

# 3. Generate localizations
flutter gen-l10n

# 4. Build IPA
flutter build ipa --release

# 5. Artifacts
# - build/ios/ipa/Delivery Ways.ipa
```

### Pre-Upload Checklist

- [ ] All 3 gates pass (analyzer, banned imports, tests)
- [ ] Feature flags configured for production
- [ ] Environment variables set correctly
- [ ] Version number bumped in pubspec.yaml
- [ ] CHANGELOG.md updated
- [ ] No dead/demo features exposed to user
- [ ] Privacy Policy URL valid
- [ ] Terms of Service URL valid

---

## 7. Post-Release Monitoring

### Key Metrics to Monitor

| Metric | Target | Alert Threshold |
|--------|--------|-----------------|
| Cold Start Time | ≤ 2.0s | > 3.0s |
| Crash Rate | ≤ 0.5% | > 1% |
| ANR Rate | ≤ 0.1% | > 0.5% |
| API P95 Latency | ≤ 400ms | > 600ms |

### Telemetry Events (Production-Critical)

| Event | Purpose | Consent Required |
|-------|---------|------------------|
| `app.startup` | Cold start timing | Yes |
| `auth.login_success` | Auth funnel | Yes |
| `payment.initiated` | Commerce funnel | Yes |
| `error.unhandled` | Crash tracking | Yes |

---

## 8. Rollback Plan

### Immediate Rollback (< 1 hour)

If critical issues are detected post-release:

1. **Play Store**: Halt staged rollout, revert to previous version
2. **App Store**: Remove from sale, submit previous version for expedited review
3. **Feature Flags**: Disable problematic features via RemoteConfig

### Feature-Level Rollback

| Feature | Disable Flag | Fallback Behavior |
|---------|--------------|-------------------|
| Passwordless Auth | `ENABLE_PASSWORDLESS_AUTH=false` | Email/password only |
| 2FA | `ENABLE_TWO_FACTOR_AUTH=false` | No MFA enforcement |
| Realtime Tracking | `ENABLE_REALTIME_TRACKING=false` | Sale-Only message |
| Payments | `ENABLE_PAYMENTS=false` | Cart preserved, checkout disabled |

---

## 9. Sign-off Requirements

### Technical Sign-off

| Role | Name | Status | Date |
|------|------|--------|------|
| Tech Lead | — | Pending | — |
| QA Lead | — | Pending | — |
| Security | — | Pending | — |

### Business Sign-off

| Role | Name | Status | Date |
|------|------|--------|------|
| Product Owner | — | Pending | — |
| Legal/Compliance | — | Pending | — |

---

## Appendix A: File Manifest

### Key Configuration Files

| File | Purpose |
|------|---------|
| `lib/config/feature_flags.dart` | Runtime feature toggles |
| `lib/config/runtime_config.dart` | Environment configuration |
| `pubspec.yaml` | Dependencies and version |
| `l10n.yaml` | Localization configuration |
| `analysis_options.yaml` | Lint rules and DCM config |

### Key Test Files

| File | Coverage |
|------|----------|
| `test/state/auth/passwordless_auth_controller_test.dart` | 24 tests |
| `test/state/auth/two_factor_auth_controller_test.dart` | 16 tests |
| `test/state/payments/payment_methods_controller_test.dart` | 19 tests |
| `packages/payments/test/payment_gateway_test.dart` | 20 tests |

---

**Document Status**: FROZEN for Release Review
**Next Review**: Post-backend integration


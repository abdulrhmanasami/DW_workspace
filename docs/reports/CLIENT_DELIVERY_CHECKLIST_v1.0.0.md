# Client Delivery Checklist v1.0.0

**Version**: 1.0.0
**Generated**: 2025-11-26
**Audit Cursor**: B-central
**Ticket**: DW-CENTRAL-CLIENT-HANDOVER-001

---

## 1) Overview

### Executive Summary

The **Clean-B** Flutter application is **CLIENT-SIDE READY** for production release. All client-side implementation, testing, and documentation is complete.

| Metric | Status |
|--------|--------|
| Analyzer Errors (lib/) | ✅ **0** |
| Banned Imports (lib/) | ✅ **0** |
| Critical Path Tests | ✅ **114 tests passing** |
| Localization | ✅ **EN/DE/AR complete** |
| Feature Flags | ✅ **32 flags documented** |

### What's Blocking Production Release?

Only **backend dependencies** remain. The Flutter app is fully functional and will gracefully degrade (Sale-Only behavior) when backend services are unavailable.

| Blocker | Owner | Impact |
|---------|-------|--------|
| BLK-001: Stripe backend keys/webhook | Backend Team | No payment processing |
| BLK-002: DW-ALG backend API | Backend Team | No realtime tracking |
| BLK-004: macOS CodeSign | Central (P1) | macOS distribution blocked (iOS/Android OK) |

---

## 2) Pre-Requisites (Backend & Infrastructure)

### 2.1 Authentication Backend

**Epic Reference:** CENT-003, CENT-004

| Endpoint | Method | Purpose | Required For |
|----------|--------|---------|--------------|
| `/api/v1/auth/otp/request` | POST | Request OTP code | Passwordless login |
| `/api/v1/auth/otp/verify` | POST | Verify OTP code | Passwordless login |
| `/api/v1/auth/logout` | POST | Invalidate session | Logout |
| `/api/v1/auth/refresh` | POST | Refresh access token | Session management |
| `/api/v1/auth/mfa/requirement` | GET | Check if MFA required | 2FA flow |
| `/api/v1/auth/mfa/challenge` | POST | Start MFA challenge | 2FA flow |
| `/api/v1/auth/mfa/verify` | POST | Verify MFA code | 2FA flow |

**Security Requirements:**
- [ ] OTP rate limiting: 3 attempts per phone per 15 minutes
- [ ] OTP expiry: 5 minutes
- [ ] Session tokens: JWT with 15-minute access / 7-day refresh
- [ ] MFA methods: SMS, TOTP, Email, Push

**Client Package:** `packages/auth_http_impl/`

---

### 2.2 Payments Backend

**Epic Reference:** COM-002

| Endpoint | Method | Purpose | Required For |
|----------|--------|---------|--------------|
| `/api/v1/payments/capabilities` | GET | Get payment capabilities | Payment method display |
| `/api/v1/payments/methods` | GET | List saved payment methods | Payment selection |
| `/api/v1/payments/methods` | POST | Add payment method | Card management |
| `/api/v1/payments/methods/{id}` | DELETE | Remove payment method | Card management |
| `/api/v1/payments/create-intent` | POST | Create Stripe PaymentIntent | Checkout |
| `/api/v1/payments/webhook` | POST | Stripe webhook handler | Payment confirmation |

**Configuration Required:**
- [ ] `STRIPE_PUBLISHABLE_KEY` — Stripe publishable key (test or live)
- [ ] `STRIPE_SECRET_KEY` — Stripe secret key (backend only)
- [ ] Stripe webhook endpoint configured in Stripe Dashboard
- [ ] Webhook signing secret configured in backend

**Client Package:** `packages/payments_stripe_impl/`

**Kill-Switch:** Set `PAYMENTS_FORCE_DISABLED=true` to disable payments

---

### 2.3 Mobility / DW-ALG Backend

**Epic Reference:** MOB-002

| Endpoint | Method | Purpose | Required For |
|----------|--------|---------|--------------|
| `/api/v1/mobility/health` | GET | Check service availability | Availability check |
| `/api/v1/mobility/trips` | GET | List user trips | Trip history |
| `/api/v1/mobility/trips/{id}` | GET | Get trip details | Trip details |
| `/api/v1/mobility/trips/{id}/events` | WS | Stream trip events | Realtime tracking |
| `/api/v1/mobility/couriers/{id}/location` | WS | Stream courier location | Realtime tracking |

**Configuration Required:**
- [ ] `DW_ALG_API_URL` — DW-ALG service base URL
- [ ] WebSocket support for real-time streams
- [ ] Location data format: `{ lat, lng, timestamp, accuracy }`

**Client Package:** `packages/mobility_uplink_impl/`

**Kill-Switch:** Set `REALTIME_TRACKING_FORCE_DISABLED=true` to disable tracking

---

### 2.4 Notifications Backend

**Epic Reference:** UX-004

| Configuration | Purpose | Required For |
|---------------|---------|--------------|
| FCM Server Key | Send push notifications | Push notifications |
| FCM Sender ID | Identify notification source | Client registration |
| Notification Gateway | Backend service to trigger notifications | All push features |

**Configuration Required:**
- [ ] Firebase project created
- [ ] `FCM_SENDER_ID` — Firebase sender ID
- [ ] `google-services.json` (Android) added to project
- [ ] `GoogleService-Info.plist` (iOS) added to project
- [ ] Backend notification service deployed

**Client Package:** `packages/notifications_shims/`

---

### 2.5 Observability (Optional)

| Configuration | Purpose | Required For |
|---------------|---------|--------------|
| `SENTRY_DSN` | Error tracking | Crash reporting |
| `TELEMETRY_DSN` | Analytics | Usage analytics |

**Note:** These are optional. The app functions without them but won't report errors/analytics.

---

## 3) Environment & Flags Setup

### 3.1 Environment Variables Summary

Refer to `docs/reports/FEATURE_FLAGS_MATRIX_v1.0.0.md` for complete details.

| Environment | Configuration Focus |
|-------------|---------------------|
| **Development** | All features enabled with test data, no cert pinning |
| **Staging** | All features enabled with staging backend, test Stripe keys |
| **Production (Initial)** | Auth only, payments/tracking disabled via flags |
| **Production (Full)** | All features enabled with production backend |

### 3.2 Recommended Initial Production Config

```bash
# Core
API_BASE_URL=https://api.deliveryways.com
ENVIRONMENT=production

# Auth (enable if backend ready)
ENABLE_PASSWORDLESS_AUTH=true
ENABLE_BIOMETRIC_AUTH=true
ENABLE_TWO_FACTOR_AUTH=false  # Set true when MFA backend ready

# Payments (disable until Stripe configured)
PAYMENTS_ENABLED=false
# Or force disable: PAYMENTS_FORCE_DISABLED=true

# Tracking (disable until DW-ALG ready)
ENABLE_REALTIME_TRACKING=false
# Or force disable: REALTIME_TRACKING_FORCE_DISABLED=true

# Notifications (disable until FCM ready)
ENABLE_NOTIFICATIONS=false

# Security
CERT_PINNING_ENABLED=true
RBAC_ENFORCE=true
RBAC_CANARY_PERCENTAGE=100

# Observability
SENTRY_DSN=https://xxx@sentry.io/project
```

### 3.3 Flags Passing Method

Flags are passed via `--dart-define` at build time:

```bash
flutter build apk --release \
  --dart-define=FLAG_NAME=value \
  --dart-define=ANOTHER_FLAG=value
```

**Note:** Flags cannot be changed after build without a new release. For runtime control, use `ConfigManager` with RemoteConfig service.

---

## 4) Build Steps (per Platform)

### 4.1 Pre-Build Verification (All Platforms)

```bash
# Navigate to app directory
cd app

# 1. Clean previous builds
flutter clean

# 2. Get dependencies
flutter pub get

# 3. Generate localizations
flutter gen-l10n

# 4. GATE 1: Zero Analyzer Errors
flutter analyze --no-pub lib
# Expected: "No issues found!"

# 5. GATE 2: Zero Banned SDK Imports
python3 tools/analysis/assert_no_banned_imports.py lib
# Expected: "✅ No banned imports in lib"

# 6. GATE 3: Critical Path Tests Pass
./tools/tests/run_critical_paths_tests.sh
# Expected: "[PASS] All critical path tests passed!"
```

**⚠️ IMPORTANT:** If any gate fails, DO NOT proceed with build. Fix issues first.

---

### 4.2 Android Build

```bash
# Debug build (for testing)
flutter build apk --debug

# Release APK (for distribution)
flutter build apk --release \
  --dart-define=API_BASE_URL=https://api.deliveryways.com \
  --dart-define=ENVIRONMENT=production \
  --dart-define=ENABLE_PASSWORDLESS_AUTH=true \
  --dart-define=PAYMENTS_ENABLED=false \
  # ... other flags as needed

# Release AAB (for Play Store)
flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://api.deliveryways.com \
  # ... same flags as APK

# Artifacts
# - build/app/outputs/flutter-apk/app-release.apk
# - build/app/outputs/bundle/release/app-release.aab
```

---

### 4.3 iOS Build

```bash
# Debug build (for testing, no codesign)
flutter build ios --debug --no-codesign

# Release IPA (for App Store)
flutter build ipa --release \
  --dart-define=API_BASE_URL=https://api.deliveryways.com \
  --dart-define=ENVIRONMENT=production \
  --dart-define=ENABLE_PASSWORDLESS_AUTH=true \
  --dart-define=PAYMENTS_ENABLED=false \
  # ... other flags as needed

# Artifacts
# - build/ios/ipa/Delivery Ways.ipa
```

**⚠️ iOS Note:** Requires valid Apple Developer account and provisioning profiles.

---

### 4.4 macOS Build (Blocked — BLK-004)

```bash
# Currently blocked due to CodeSign resource fork issues
# iOS and Android are unaffected
# Status: P1, awaiting resolution
```

---

## 5) Runtime Validation Checklist

After building, validate on a real device:

### 5.1 Authentication Flow

| Test | Expected Result | Pass? |
|------|-----------------|-------|
| Open app | Onboarding or login screen | ☐ |
| Enter phone number | OTP request sent (if backend ready) | ☐ |
| Enter valid OTP | Login successful | ☐ |
| Enable biometric | Biometric prompt shows | ☐ |
| Logout and re-open | Biometric unlock works | ☐ |
| If 2FA enabled: Complete MFA | MFA challenge works | ☐ |

**If Auth Backend NOT Ready:**
- OTP request will fail
- App should show error message
- No fake/demo data shown

---

### 5.2 Payments Flow

| Test | Expected Result | Pass? |
|------|-----------------|-------|
| Navigate to payments | If enabled: Payment methods screen | ☐ |
| Add card | Stripe card element works | ☐ |
| Complete checkout | PaymentIntent created | ☐ |

**If Payments Backend NOT Ready:**
- Payment UI hidden or disabled
- "Coming soon" message shown (Sale-Only)
- Cart preserved, checkout blocked

---

### 5.3 Tracking Flow

| Test | Expected Result | Pass? |
|------|-----------------|-------|
| Navigate to tracking | If enabled: Tracking screen | ☐ |
| Active delivery | Live location updates | ☐ |

**If Tracking Backend NOT Ready:**
- Tracking tab shows "Coming soon"
- Static order status card displayed
- No fake/demo tracking data

---

### 5.4 Notifications Flow

| Test | Expected Result | Pass? |
|------|-----------------|-------|
| Navigate to notification settings | If enabled: Settings screen | ☐ |
| Toggle notification types | Preferences saved | ☐ |
| Receive test push | Notification appears | ☐ |

**If Notifications Backend NOT Ready:**
- Settings screen functional but no pushes received
- Clear messaging about notification status

---

## 6) Known Limitations

### 6.1 Backend/Infrastructure Open Points

These are NOT Flutter app issues — they require backend team action:

| ID | Category | Description | Impact | Owner |
|----|----------|-------------|--------|-------|
| **BLK-001** | Payments | Stripe backend keys and webhook not configured | No payment processing | Backend |
| **BLK-002** | Mobility | DW-ALG backend API not deployed | No realtime tracking | Backend |
| **BLK-004** | Release | macOS CodeSign resource fork issues | macOS distribution blocked | Central |
| **GAP-001** | Notifications | FCM backend not configured | No push notifications | Backend |
| **GAP-002** | Auth | 2FA backend rule engine not ready | 2FA UI hidden | Backend |

### 6.2 Client-Side Mitigations

All backend dependencies have client-side mitigations:

| Feature | When Backend Missing | User Experience |
|---------|---------------------|-----------------|
| Payments | Kill-switch triggers | Payment options hidden, cart preserved |
| Tracking | Sale-Only behavior | Tracking shows "Coming soon" |
| Notifications | Sale-Only behavior | Notification settings hidden |
| 2FA | Feature flag off | Standard auth works, no MFA prompt |

### 6.3 P2 Items (Not Blocking Release)

| Item | Status | Notes |
|------|--------|-------|
| Dark Mode | Pending | Theme structure ready, not fully applied |
| Micro-interactions | Pending | Basic animations only |
| Performance budgets in CI | Pending | Manual profiling available |
| Lite Mode | Pending | Design exists, implementation deferred |

---

## 7) Pre-Upload Checklist

Before submitting to app stores:

### Technical Checks

- [ ] All 3 gates pass (analyzer, banned imports, tests)
- [ ] Feature flags configured correctly for production
- [ ] Environment variables set correctly
- [ ] No dead/demo features exposed to user
- [ ] Certificate pinning enabled for production
- [ ] Sentry DSN configured (optional but recommended)

### Business Checks

- [ ] Version number bumped in `pubspec.yaml`
- [ ] CHANGELOG.md updated
- [ ] Privacy Policy URL valid and accessible
- [ ] Terms of Service URL valid and accessible
- [ ] App screenshots updated (if UI changed)
- [ ] Store listing copy updated (if features changed)

### Legal/Compliance Checks

- [ ] GDPR consent flow functional
- [ ] DSR (Data Subject Rights) screens accessible
- [ ] Telemetry consent gate active
- [ ] No tracking before consent

---

## 8) Support Contacts

| Area | Contact | Scope |
|------|---------|-------|
| Flutter App Issues | B-central Cursor | Client-side bugs, build issues |
| Backend Integration | Backend Team | API endpoints, authentication |
| Payments | Commerce Team | Stripe configuration |
| Tracking | Mobility Team | DW-ALG API |
| UX/Design | UX Team | UI/UX issues |

---

## 9) Quick Reference Commands

```bash
# Full validation before release
./tools/validate_release.sh

# Or manually:
flutter clean && flutter pub get && flutter gen-l10n
flutter analyze --no-pub lib
python3 tools/analysis/assert_no_banned_imports.py lib
./tools/tests/run_critical_paths_tests.sh

# Build Android release
flutter build apk --release --dart-define=ENVIRONMENT=production [... other flags]

# Build iOS release
flutter build ipa --release --dart-define=ENVIRONMENT=production [... other flags]

# Run critical tests only
flutter test test/state/auth/ test/state/payments/
```

---

## 10) Exporting the Clean-B Workspace

### Overview

The Clean-B Workspace can be exported as a **standalone, self-contained package** for client delivery. This export includes all necessary code, packages, tools, and documentation to run independently without the mono-repo.

### Export Command

```bash
# Make the script executable (first time only)
chmod +x tools/packaging/export_clean_b_workspace.sh

# Export to default location (dist/clean_b_workspace)
./tools/packaging/export_clean_b_workspace.sh

# Or export to a custom location
./tools/packaging/export_clean_b_workspace.sh /path/to/delivery/clean_b_workspace
```

### What's Included in the Export

| Category | Contents |
|----------|----------|
| **Application** | `lib/`, `test/`, `integration_test/`, `assets/` |
| **Configuration** | `pubspec.yaml`, `analysis_options.yaml`, `l10n.yaml`, `melos.yaml` |
| **Packages** | 30+ packages (auth, payments, mobility, maps, design system, etc.) |
| **Platform** | `android/`, `ios/` (for building) |
| **UI/UX** | `B-ui/`, `B-ux/` |
| **Tools** | `tools/analysis/`, `tools/tests/`, `tools/packaging/` |
| **Documentation** | `docs/reports/` (key delivery documents) |

### What's NOT Included

- Build artifacts (`build/`, `.dart_tool/`)
- CI/CD workflows (`.github/`)
- Backend code (`server/`, `backend/`)
- Legacy/experimental code (`B-wip/`, `legacy/`)
- Analysis reports (`tools/reports/`)

### Post-Export Verification

After exporting, verify the workspace is functional:

```bash
cd /path/to/clean_b_workspace

# 1. Install dependencies
flutter pub get

# 2. Verify analyzer (GATE 1)
flutter analyze --no-pub lib
# Expected: "No issues found!"

# 3. Verify banned imports (GATE 2)
python3 tools/analysis/assert_no_banned_imports.py lib
# Expected: "✅ No banned imports in lib"

# 4. Run critical tests (GATE 3)
./tools/tests/run_critical_paths_tests.sh
# Expected: "[PASS] All critical path tests passed!"
```

### Packaging for Delivery

```bash
# Create a compressed archive
cd dist
tar -czvf clean_b_workspace_v1.0.0.tar.gz clean_b_workspace/

# Or create a zip file
zip -r clean_b_workspace_v1.0.0.zip clean_b_workspace/
```

### Client Usage Options

1. **Run Directly**: Use the exported workspace as-is
2. **Create Git Repo**: Initialize as an independent repository
3. **CI Integration**: Use provided tools in client's CI/CD pipeline

### Related Documents

- `docs/reports/CLEAN_B_WORKSPACE_EXPORT_SPEC_v1.0.0.md` — Full specification
- `tools/reports/clean_b_workspace_manifest.json` — Export manifest (paths list)
- `tools/packaging/export_clean_b_workspace.sh` — Export script

---

## Appendix A: File Manifest

### Key Configuration Files

| File | Purpose |
|------|---------|
| `lib/config/feature_flags.dart` | Runtime feature toggles |
| `lib/config/config_manager.dart` | Environment configuration |
| `pubspec.yaml` | Dependencies and version |
| `l10n.yaml` | Localization configuration |
| `analysis_options.yaml` | Lint rules and DCM config |

### Key Documentation

| File | Purpose |
|------|---------|
| `docs/reports/FEATURE_FLAGS_MATRIX_v1.0.0.md` | Complete flags documentation |
| `docs/reports/PROJECT_STATUS_v3.2.1.md` | Current project status |
| `docs/reports/RELEASE_EXECUTION_PLAN_v2.0.0.md` | Release steps |
| `docs/reports/RISKS_AND_GAPS_REGISTER_v1.0.0.md` | Known risks and blockers |

---

## Appendix B: Change Log

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-11-26 | Initial client delivery checklist created |
| 1.0.1 | 2025-11-26 | Added Section 10: Exporting the Clean-B Workspace (CENT-010) |

---

**Document Status**: FROZEN for Client Handover
**Next Review**: Post-backend integration



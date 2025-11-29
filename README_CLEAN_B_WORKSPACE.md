# Clean-B Workspace — Delivery Ways Client Application

**Version**: 1.0.0  
**Export Date**: 2025-11-26  
**Status**: CLIENT-SIDE READY  

---

## 1) Overview

This is the **Clean-B Workspace** for the Delivery Ways Flutter client application. It represents a **standalone, self-contained** package that can be:

- Built and tested independently without the original mono-repo
- Used as a client delivery package
- Initialized as a separate Git repository if needed

### Key Characteristics

| Feature | Status |
|---------|--------|
| Analyzer Errors | ✅ **0 errors** (info-level only) |
| Banned SDK Imports | ✅ **0 violations** |
| Critical Path Tests | ✅ **79 tests passing** |
| Localization | ✅ EN/DE/AR complete |
| Feature Flags | ✅ 32 flags documented |

### Sale-Only Behavior

This application implements **Sale-Only** behavior: features that require backend services (Payments, Realtime Tracking, Push Notifications) gracefully degrade when those services are unavailable. No fake or demo data is shown to users.

---

## 2) Prerequisites

### Required

| Tool | Version | Notes |
|------|---------|-------|
| Flutter SDK | 3.x.x (≥ 3.3.0) | `flutter --version` |
| Dart SDK | ≥ 3.8.0 | Included with Flutter |
| Python 3 | 3.x | For analysis scripts |

### Optional (for development)

| Tool | Purpose |
|------|---------|
| `melos` | Workspace management (if using mono-repo patterns) |
| `jq` | JSON parsing for export script |

### Verify Installation

```bash
flutter --version
dart --version
python3 --version
```

---

## 3) Initial Setup

### 3.1 Install Dependencies

```bash
# Navigate to workspace root
cd clean_b_workspace

# Install all dependencies
flutter pub get
```

**Expected output:**
- `Got dependencies!`
- Some packages may show "newer versions available" warnings — this is normal

### 3.2 Generate Localizations (if needed)

```bash
flutter gen-l10n
```

---

## 4) Quality Gates

Before building or deploying, verify all gates pass:

### Gate 1: Static Analysis

```bash
flutter analyze --no-pub lib
```

**Expected:** No errors. Info-level warnings (like `deprecated_member_use`) are acceptable.

### Gate 2: Banned Imports Check

```bash
python3 tools/analysis/assert_no_banned_imports.py lib
```

**Expected:**
```
✅ No banned imports in lib
```

This ensures the app doesn't import SDK packages directly (all access goes through shims).

### Gate 3: Critical Path Tests

```bash
./tools/tests/run_critical_paths_tests.sh
```

**Expected:**
```
Total test suites:  4
Passed:             4
Failed:             0

[PASS] All critical path tests passed!
```

**Test Coverage:**
| Suite | Tests |
|-------|-------|
| Passwordless Auth Controller | 24 |
| Two-Factor Auth Controller | 16 |
| Payment Methods Controller | 19 |
| Payments Package | 20 |
| **Total** | **79** |

### Run All Tests (Optional)

```bash
flutter test
```

---

## 5) Building the Application

### 5.1 Android APK (Debug)

```bash
flutter build apk --debug
```

Output: `build/app/outputs/flutter-apk/app-debug.apk`

### 5.2 Android APK (Release)

```bash
flutter build apk --release \
  --dart-define=ENVIRONMENT=production \
  --dart-define=API_BASE_URL=https://api.deliveryways.com \
  --dart-define=ENABLE_PASSWORDLESS_AUTH=true \
  --dart-define=ENABLE_BIOMETRIC_AUTH=true \
  --dart-define=PAYMENTS_ENABLED=false \
  --dart-define=ENABLE_REALTIME_TRACKING=false \
  --dart-define=CERT_PINNING_ENABLED=true
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### 5.3 Android App Bundle (for Play Store)

```bash
flutter build appbundle --release \
  --dart-define=ENVIRONMENT=production \
  # ... same flags as above
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### 5.4 iOS (Debug, no codesign)

```bash
flutter build ios --debug --no-codesign
```

### 5.5 iOS IPA (Release)

```bash
flutter build ipa --release \
  --dart-define=ENVIRONMENT=production \
  # ... same flags as above
```

> **Note:** iOS builds require valid Apple Developer account and provisioning profiles.

---

## 6) Feature Flags

Feature flags are passed via `--dart-define` at build time. See `docs/reports/FEATURE_FLAGS_MATRIX_v1.0.0.md` for complete documentation.

### Quick Reference (Common Flags)

| Flag | Default | Description |
|------|---------|-------------|
| `ENVIRONMENT` | `development` | `development`, `staging`, `production` |
| `API_BASE_URL` | `''` | Backend API base URL |
| `ENABLE_PASSWORDLESS_AUTH` | `true` | Enable phone/OTP login |
| `ENABLE_BIOMETRIC_AUTH` | `true` | Enable fingerprint/Face ID |
| `PAYMENTS_ENABLED` | `true` | Enable payments (requires Stripe) |
| `ENABLE_REALTIME_TRACKING` | `true` | Enable live tracking (requires DW-ALG) |
| `CERT_PINNING_ENABLED` | `false`/`true` | TLS certificate pinning |

### Kill Switches

| Flag | Purpose |
|------|---------|
| `PAYMENTS_FORCE_DISABLED=true` | Emergency disable all payments |
| `REALTIME_TRACKING_FORCE_DISABLED=true` | Emergency disable tracking |
| `TWO_FACTOR_AUTH_FORCE_DISABLED=true` | Emergency disable 2FA |

### Recommended Profiles

See `docs/reports/FEATURE_FLAGS_MATRIX_v1.0.0.md` for:
- **Profile A:** Client Demo (no backend)
- **Profile B:** Staging (test backend)
- **Profile C:** Production (partial backend)
- **Profile D:** Production (full feature)

---

## 7) Project Structure

```
clean_b_workspace/
├── lib/                    # Main application code
│   ├── config/             # Feature flags, config manager
│   ├── screens/            # UI screens
│   ├── state/              # State management (Riverpod)
│   ├── widgets/            # Reusable widgets
│   └── wiring/             # Dependency injection
├── test/                   # Unit and widget tests
├── packages/               # 32 internal packages
│   ├── auth_shims/         # Auth abstraction
│   ├── payments/           # Payment domain
│   ├── mobility_shims/     # Location/tracking abstraction
│   └── ...                 # See pubspec.yaml for full list
├── B-ui/                   # UI components package
├── B-ux/                   # UX components package
├── tools/
│   ├── analysis/           # Code analysis scripts
│   ├── tests/              # Test runners
│   └── packaging/          # Export scripts
├── docs/reports/           # Project documentation
├── android/                # Android platform
├── ios/                    # iOS platform
├── pubspec.yaml            # Dependencies
└── analysis_options.yaml   # Lint rules
```

---

## 8) Documentation

| Document | Description |
|----------|-------------|
| `docs/reports/PROJECT_STATUS_v3.2.1.md` | Current project status and metrics |
| `docs/reports/FEATURE_FLAGS_MATRIX_v1.0.0.md` | Complete flags documentation |
| `docs/reports/CLIENT_DELIVERY_CHECKLIST_v1.0.0.md` | Delivery requirements |
| `docs/reports/CLEAN_B_WORKSPACE_EXPORT_SPEC_v1.0.0.md` | Export specification |
| `docs/reports/RELEASE_EXECUTION_PLAN_v2.0.0.md` | Release steps |
| `docs/reports/RISKS_AND_GAPS_REGISTER_v1.0.0.md` | Known risks and blockers |

---

## 9) Backend Dependencies

This Flutter application is **CLIENT-SIDE READY**. The following backend services are required for full functionality:

| Service | Required For | When Missing |
|---------|--------------|--------------|
| Auth API (`/api/v1/auth/*`) | Phone/OTP login | Login fails with error |
| Stripe Backend | Payment processing | Payments hidden |
| DW-ALG API | Realtime tracking | Tracking shows "Coming soon" |
| FCM Configuration | Push notifications | No pushes received |

See `docs/reports/CLIENT_DELIVERY_CHECKLIST_v1.0.0.md` for detailed backend requirements.

---

## 10) Known Limitations

### Info-Level Analyzer Warnings

The analyzer may report info-level warnings like:
- `deprecated_member_use` (for `withOpacity`)
- `prefer_const_declarations`
- `unnecessary_brace_in_string_interps`

These are informational and do not affect functionality.

### macOS Builds

macOS desktop builds are currently blocked due to CodeSign issues. iOS and Android builds are unaffected.

---

## 11) Quick Commands Reference

```bash
# Setup
flutter pub get

# Quality Gates
flutter analyze --no-pub lib
python3 tools/analysis/assert_no_banned_imports.py lib
./tools/tests/run_critical_paths_tests.sh

# Build
flutter build apk --debug
flutter build apk --release --dart-define=ENVIRONMENT=production

# Test
flutter test
flutter test test/state/auth/
```

---

## 12) Support

| Area | Contact |
|------|---------|
| Flutter App Issues | B-central Cursor |
| Backend Integration | Backend Team |
| Payments Configuration | Commerce Team |
| Tracking/Mobility | Mobility Team |

---

**Document Version**: 1.0.0  
**Last Updated**: 2025-11-26


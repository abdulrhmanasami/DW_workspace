# Clean-B Workspace Export Specification v1.0.0

**Version**: 1.0.0
**Generated**: 2025-11-26
**Audit Cursor**: B-central
**Ticket**: DW-CENTRAL-CLEAN-B-PACKAGE-001

---

## 1) Overview

### Purpose

This specification defines **Clean-B Workspace** — a self-contained, standalone export of the Delivery Ways Flutter client application that can be:

1. **Compressed/copied** as an independent workspace for client delivery
2. **Run standalone** with `flutter analyze` and critical path tests passing
3. **Used as the source of truth** for the Delivery Ways client application

### Key Principles

- **No business logic modifications** — This is a packaging/documentation specification only
- **All dependencies included** — The exported workspace contains all required packages
- **Build-ready** — Can run `flutter pub get`, `flutter analyze`, and tests without external dependencies

---

## 2) Clean-B Workspace Definition

### 2.1 Root Directory Structure

The Clean-B Workspace exports from the mono-repo root with the following structure:

```
clean_b_workspace/
├── lib/                          # Main application code
├── test/                         # Unit and widget tests
├── integration_test/             # Integration tests
├── assets/                       # App assets (certs, rbac, legal)
├── packages/                     # Core packages (shims, implementations)
├── stubs/                        # Stub implementations
├── B-ui/                         # UI components package
├── B-ux/                         # UX components package
├── third_party/                  # Third-party dependencies (dart_code_metrics)
├── tools/                        # Analysis and testing tools
├── docs/                         # Documentation
├── pubspec.yaml                  # Root pubspec
├── analysis_options.yaml         # Lint rules
├── l10n.yaml                     # Localization config
└── melos.yaml                    # Melos workspace config
```

---

## 3) Included Paths

### 3.1 Application Core

| Path | Description |
|------|-------------|
| `lib/` | Main application source code |
| `test/` | Unit and widget tests |
| `integration_test/` | Integration tests |
| `assets/` | Application assets (certs/, rbac/, legal/) |
| `pubspec.yaml` | Root dependency manifest |
| `pubspec.lock` | Locked dependencies |
| `analysis_options.yaml` | Lint and DCM rules |
| `l10n.yaml` | Localization configuration |
| `melos.yaml` | Melos workspace configuration |

### 3.2 Core Packages (packages/)

| Package | Purpose | Critical? |
|---------|---------|-----------|
| `packages/core/` | RBAC, Foundation, Config | ✅ Yes |
| `packages/foundation_shims/` | Telemetry, Consent, ImageCache | ✅ Yes |
| `packages/network_shims/` | HTTP client, TLS pinning | ✅ Yes |
| `packages/auth_shims/` | Auth contracts | ✅ Yes |
| `packages/auth_http_impl/` | Passwordless OTP + 2FA | ✅ Yes |
| `packages/auth_supabase_impl/` | Supabase auth adapter | ✅ Yes |
| `packages/payments/` | Payment domain models | ✅ Yes |
| `packages/payments_shims/` | Gateway abstraction | ✅ Yes |
| `packages/payments_adapter_stripe/` | Stripe adapter | ✅ Yes |
| `packages/mobility_shims/` | Location, Trip tracking | ✅ Yes |
| `packages/mobility_uplink_impl/` | HTTP uplink for location data | ✅ Yes |
| `packages/mobility_stub_impl/` | NoOp mobility fallback | ✅ Yes |
| `packages/mobility_adapter_geolocator/` | Geolocator bridge | ✅ Yes |
| `packages/mobility_adapter_background/` | Background tracking | ✅ Yes |
| `packages/mobility_adapter_geofence/` | Geofencing | ✅ Yes |
| `packages/maps_shims/` | Map abstraction | ✅ Yes |
| `packages/maps_adapter_google/` | Google Maps bridge | ✅ Yes |
| `packages/maps_stub_impl/` | NoOp maps fallback | ✅ Yes |
| `packages/realtime_shims/` | WebSocket abstraction | ✅ Yes |
| `packages/observability_shims/` | Telemetry sink | ✅ Yes |
| `packages/notifications_shims/` | Push notifications | ✅ Yes |
| `packages/accounts_shims/` | DSR, user accounts | ✅ Yes |
| `packages/accounts_stub_impl/` | NoOp accounts fallback | ✅ Yes |
| `packages/dsr_ux_adapter/` | DSR UI bindings | ✅ Yes |
| `packages/privacy/` | Consent management | ✅ Yes |
| `packages/rbac_rest_impl/` | RBAC REST implementation | ✅ Yes |
| `packages/design_system_shims/` | Design system abstraction | ✅ Yes |
| `packages/design_system_components/` | UI primitives | ✅ Yes |
| `packages/design_system_foundation/` | Typography, Colors | ✅ Yes |
| `packages/design_system_stub_impl/` | DS stub implementations | ✅ Yes |

### 3.3 Stub Implementations (stubs/)

| Package | Purpose | Critical? |
|---------|---------|-----------|
| `stubs/device_security_shims/` | Biometric auth (local_auth) | ✅ Yes |

### 3.4 UI/UX Packages (B-*)

| Package | Purpose | Critical? |
|---------|---------|-----------|
| `B-ui/` | UI components (buttons, skeletons, states) | ✅ Yes |
| `B-ux/` | UX components (onboarding, guidance) | ✅ Yes |

### 3.5 Third-Party Dependencies (third_party/)

| Package | Purpose | Critical? |
|---------|---------|-----------|
| `third_party/dart_code_metrics/` | DCM stub for analysis | ✅ Yes |

### 3.6 Tools (tools/)

| Path | Purpose | Critical? |
|------|---------|-----------|
| `tools/analysis/assert_no_banned_imports.py` | Banned imports checker | ✅ Yes |
| `tools/analysis/assert_no_banned_imports.sh` | Banned imports shell wrapper | ✅ Yes |
| `tools/tests/run_critical_paths_tests.sh` | Critical path test runner | ✅ Yes |
| `tools/analysis/*.py` | Analysis scripts | Recommended |
| `tools/analysis/*.sh` | Analysis shell scripts | Recommended |
| `tools/quality/` | Quality gate scripts | Recommended |
| `tools/release/` | Release tools | Optional |
| `tools/packaging/` | Export scripts (including this) | ✅ Yes |

### 3.7 Documentation (docs/)

| Path | Purpose | Critical? |
|------|---------|-----------|
| `docs/reports/PROJECT_STATUS_v3.2.1.md` | Project status | ✅ Yes |
| `docs/reports/FEATURE_FLAGS_MATRIX_v1.0.0.md` | Feature flags documentation | ✅ Yes |
| `docs/reports/CLIENT_DELIVERY_CHECKLIST_v1.0.0.md` | Client delivery checklist | ✅ Yes |
| `docs/reports/RELEASE_EXECUTION_PLAN_v2.0.0.md` | Release plan | ✅ Yes |
| `docs/reports/RISKS_AND_GAPS_REGISTER_v1.0.0.md` | Risks and blockers | ✅ Yes |
| `docs/reports/CLEAN_B_WORKSPACE_EXPORT_SPEC_v1.0.0.md` | This specification | ✅ Yes |
| `docs/CHANGELOG.md` | Change log | Recommended |
| `docs/DEPLOYMENT_GUIDE.md` | Deployment guide | Recommended |
| `docs/PRIVACY_POLICY.md` | Privacy policy | Recommended |
| `docs/ops/` | Operations runbooks | Optional |
| `docs/runbooks/` | Release runbooks | Optional |

---

## 4) Explicitly Excluded Paths

The following paths are **NOT** included in Clean-B Workspace:

### 4.1 Build Artifacts & Generated Files

| Pattern | Reason |
|---------|--------|
| `**/build/` | Build output directories |
| `**/.dart_tool/` | Dart tool cache |
| `**/.packages` | Legacy packages file |
| `**/coverage/` | Test coverage reports |
| `dist/` | Export output directory |

### 4.2 Git & CI Files

| Pattern | Reason |
|---------|--------|
| `.git/` | Git repository data |
| `.github/` | GitHub Actions workflows (CI internal) |
| `.gitignore` | Optional (can be included) |

### 4.3 Backend & Server Code

| Pattern | Reason |
|---------|--------|
| `server/` | Backend server code (if exists) |
| `backend/` | Backend services (if exists) |

### 4.4 Experimental & Legacy Code

| Pattern | Reason |
|---------|--------|
| `scripts/experiments/` | Experimental scripts |
| `legacy/` | Legacy code not in Clean-B |
| `B-wip/` | Work-in-progress (consolidated to B-central) |
| `B-commerce/` | Commerce cursor (separate domain) |
| `B-commerce_legacy/` | Legacy commerce code |
| `B-mobility/` | Mobility cursor (merged to central) |
| `B-central/` | Central cursor working directory |

### 4.5 IDE & Editor Files

| Pattern | Reason |
|---------|--------|
| `.idea/` | IntelliJ IDEA settings |
| `.vscode/` | VS Code settings |
| `*.iml` | IntelliJ module files |
| `.cursor/` | Cursor IDE settings |

### 4.6 Platform Build Directories (if not needed)

| Pattern | Reason |
|---------|--------|
| `android/` | Include for Android builds |
| `ios/` | Include for iOS builds |
| `macos/` | Include for macOS builds (optional) |
| `linux/` | Include for Linux builds (optional) |
| `windows/` | Windows directory (if exists) |
| `web/` | Web directory (if exists) |

> **Note:** Platform directories (android/, ios/) should be included if the client needs to build. Exclude only if delivering pre-built binaries.

### 4.7 Reports & Logs

| Pattern | Reason |
|---------|--------|
| `*.log` | Log files |
| `tools/reports/` | Analysis reports (large, regeneratable) |
| `READY_*` | Ready marker files |
| `*_EXECUTION_REPORT*` | Execution reports |

---

## 5) Export Command Reference

### 5.1 Export Script Location

```
tools/packaging/export_clean_b_workspace.sh
```

### 5.2 Basic Usage

```bash
# Default export to dist/clean_b_workspace
./tools/packaging/export_clean_b_workspace.sh

# Custom export location
./tools/packaging/export_clean_b_workspace.sh /path/to/output
```

### 5.3 Post-Export Verification

```bash
cd /path/to/clean_b_workspace

# 1. Install dependencies
flutter pub get

# 2. Verify analyzer
flutter analyze --no-pub lib
# Expected: "No issues found!"

# 3. Verify banned imports
python3 tools/analysis/assert_no_banned_imports.py lib
# Expected: "✅ No banned imports in lib"

# 4. Run critical tests
./tools/tests/run_critical_paths_tests.sh
# Expected: "[PASS] All critical path tests passed!"
```

---

## 6) Client Delivery Notes

### 6.1 What the Client Receives

1. **Standalone Flutter workspace** — Can run independently without mono-repo
2. **All required packages** — No external mono-repo dependencies
3. **Documentation** — Feature flags, delivery checklist, release plan
4. **Analysis tools** — Banned imports checker, critical path tests

### 6.2 Client Options

1. **Run directly** — Use the exported workspace as-is
2. **Create new Git repo** — Initialize as independent repository
3. **Integrate into CI** — Use provided tools in client's CI/CD

### 6.3 Not Included (Backend Dependencies)

The client is responsible for:

- Backend API deployment (Auth, Payments, Mobility)
- Stripe keys and webhook configuration
- FCM/Push notification configuration
- Sentry/Telemetry DSN setup

See `docs/reports/CLIENT_DELIVERY_CHECKLIST_v1.0.0.md` for backend requirements.

---

## 7) Manifest Reference

The export script uses `tools/reports/clean_b_workspace_manifest.json` for path definitions.

See manifest file for complete include/exclude patterns.

---

## 8) Change Log

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-11-26 | Initial Clean-B Workspace Export Specification |

---

**Document Status**: Active
**Related Documents**:
- `docs/reports/CLIENT_DELIVERY_CHECKLIST_v1.0.0.md`
- `docs/reports/FEATURE_FLAGS_MATRIX_v1.0.0.md`
- `tools/reports/clean_b_workspace_manifest.json`
- `tools/packaging/export_clean_b_workspace.sh`


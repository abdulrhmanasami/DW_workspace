# Track D: Auth & Onboarding Identity Shim Audit & Implementation Plan

**Ticket:** #232 – Track D – Auth & Onboarding Groundwork  
**Date:** 2025-12-04  
**Status:** Analysis Complete ✅  

---

## 1. Current Auth & Identity State in Codebase

### 1.1 Auth Infrastructure Analysis

#### Existing Auth Packages & Shims
- **`auth_shims`** ✅ **Well-Implemented**
  - Complete `AuthService` interface with passwordless OTP + MFA support
  - `AuthSession` model with access/refresh tokens and user profiles
  - `MfaRequirement`, `MfaChallenge`, `MfaVerificationResult` for risk-based MFA
  - `AuthState` enum with authenticated/unauthenticated states
  - `BiometricAuthenticator` contract for device security integration

- **`auth_http_impl`** ✅ **Implemented**
  - `HttpAuthService` with backend integration
  - `HttpAuthBackendClient` for API communication
  - `SecureStorageAuthSessionRepository` for encrypted session storage
  - Rate limiting and cooldown logic (45s between OTP requests, 5 max per session)

- **`accounts_shims`** ✅ **Present**
  - DSR (Data Subject Rights) contracts via `dsr_ux_adapter`
  - `DsrRequestSummary`, `DsrRequestType` (export/erasure) models
  - User account management interfaces

#### Current Auth State Management
- **`lib/state/auth/auth_state.dart`** ⚠️ **Stub Implementation**
  - Simple session-only `AuthState` class (no persistence)
  - Basic `AuthController` with phone sign-in and OTP verification
  - Marked as "Stub implementation" - needs wiring to `auth_shims`

- **`lib/state/auth/passwordless_auth_controller.dart`** ✅ **Advanced Implementation**
  - Full Riverpod-based state management for passwordless flow
  - MFA integration with risk-based evaluation
  - Cooldown/rate limiting and biometric unlock support
  - Feature-flag controlled (`enablePasswordlessAuth`, `enableTwoFactorAuth`)

#### Auth Screens (lib/screens/auth/)
- **`phone_login_screen.dart`** ✅ **Implemented**
  - Phone input with E.164 validation
  - Biometric unlock option
  - Rate limiting UI feedback
  - Feature-flag gated

- **`otp_verification_screen.dart`** ⚠️ **Stub Implementation**
  - Basic OTP input using design system components
  - No real backend integration (uses stub `AuthController`)
  - Simple navigation to AppShell after verification

- **`two_factor_screen.dart`** ✅ **Implemented**
  - MFA challenge UI with multiple method support
  - Integration with `passwordless_auth_controller`
  - Error handling and retry logic

#### Routing & Navigation Integration
- **`lib/router/app_router.dart`** ✅ **Well-Structured**
  - `AuthGateScreen` decides between authenticated AppShell and phone login
  - `OnboardingGateScreen` handles pre-auth onboarding
  - Routes: `/auth/login-phone`, `/auth/otp`, `/auth/two-factor`
  - Feature-flag integration (`enablePasswordlessAuth`)

#### Onboarding Infrastructure
- **`lib/screens/onboarding/onboarding_root_screen.dart`** ✅ **Implemented**
  - 3-screen flow (Ride, Parcels, Food) based on High-Fidelity Mockups
  - PageView with progress indicators
  - Riverpod state management via `onboarding_providers.dart`

### 1.2 Current Auth Flow Architecture

```
App Launch → PrivacyConsentGate → OnboardingGate → AuthGate
                                                          │
                                                          ├── Authenticated → AppShell
                                                          └── Unauthenticated → PhoneLoginScreen
                                                                                    │
                                                                                    ├── OTP Sent → OtpVerificationScreen
                                                                                    └── Verified → AppShell
```

### 1.3 Security & Storage State

#### Secure Storage ✅ **Implemented**
- `FlutterSecureStorage` integration via `auth_http_impl`
- Encrypted session persistence
- Biometric unlock capability via `device_security_shims`

#### Current Security Gaps
- **Token Refresh**: Not implemented in current flow
- **Session Expiry Handling**: Basic expiry checking exists but no auto-refresh
- **Token Rotation**: No rotation logic implemented
- **Identity Shim Layer**: `auth_shims` exists but not fully wired as clean abstraction layer

### 1.4 Gaps vs Manus Requirements

| Manus Requirement | Current State | Gap Analysis |
|------------------|---------------|-------------|
| Identity Shim (Clean Abstraction) | `auth_shims` exists but partially wired | Need full integration as app's only auth interface |
| Token Refresh/Rotation | Basic refresh exists in `auth_shims` | Not wired into app flow, no rotation policy |
| Onboarding Screens (1-5) | Screens 1-3 implemented | Missing Screen 4 (Permissions), Screen 5 (OTP) needs enhancement |
| Auth State Machine | Complex state in `passwordless_auth_controller` | Simple state in `auth_state.dart` - need unification |
| DSR Integration | DSR shims exist | Not integrated into auth/onboarding flow |
| Session Security | Secure storage implemented | Token lifecycle management incomplete |

---

## 2. Track D Requirements from Manus

### 2.1 Core Objectives

Based on `docs/Delivery Ways - Project Development Plan/Track D: Onboarding, Auth, and DSR Implementation.md`:

#### Identity Shim Requirements
- **Clean Abstraction Layer**: Single source of truth for identity operations
- **Token Lifecycle Management**: Secure token storage, refresh, and rotation
- **Backend Integration**: HTTP client with TLS pinning and error handling

#### Onboarding & Auth Flow Requirements
- **Complete Onboarding Flow**: 5 screens (Welcome, Permissions, Preferences, Phone Login, OTP)
- **Professional Auth Experience**: Passwordless OTP with MFA support
- **Session Management**: Persistent secure sessions with biometric unlock

#### DSR (Driver Signup Request) Requirements
- **Driver Onboarding Path**: Separate flow for driver registration
- **Verification System**: Multi-step driver verification process
- **Account Management**: DSR status tracking and management

### 2.2 Technical Requirements

#### Security Requirements
- **Token Rotation**: Automatic token refresh before expiry
- **Secure Storage**: Encrypted session persistence
- **Biometric Integration**: Device unlock capability
- **TLS Pinning**: Certificate validation for backend communication

#### UX Requirements
- **RTL/LTR Support**: Proper text direction for Arabic/English
- **Error States**: Comprehensive error handling and user feedback
- **Loading States**: Smooth transitions and progress indicators
- **Accessibility**: Screen reader support and keyboard navigation

#### Backend Integration Requirements
- **OTP Service**: Rate-limited SMS OTP delivery
- **MFA Engine**: Risk-based multi-factor authentication
- **Session Management**: Secure token issuance and validation
- **DSR Processing**: Driver verification workflow

### 2.3 Success Criteria from Manus
- ✅ Onboarding flow with 5 screens
- ✅ Auth screens fully functional and integrated
- ✅ Identity Shim as clean abstraction layer
- ✅ Token refresh/rotation implemented
- ✅ DSR flow for driver signup
- ✅ All tests pass with RTL/LTR coverage
- ✅ Flutter analyze zero errors

---

## 3. Proposed Identity & Auth Architecture

### 3.1 Identity Layer Architecture

#### Proposed Identity Shim Structure
```
packages/
├── identity_shim/                    # NEW: Unified identity abstraction
│   ├── lib/
│   │   ├── identity_shim.dart        # Public API (no src/ exposure)
│   │   ├── src/
│   │   │   ├── identity_service.dart # Core identity operations
│   │   │   ├── session_manager.dart  # Token lifecycle management
│   │   │   ├── user_identity.dart    # User profile management
│   │   │   └── identity_providers.dart # Riverpod providers
│   │   └── test/
│   └── pubspec.yaml
├── auth_shims/                       # EXISTING: Auth primitives
├── accounts_shims/                   # EXISTING: Account management
└── dsr_ux_adapter/                   # EXISTING: DSR UI bridge
```

#### Identity Shim Public API
```dart
// packages/identity_shim/lib/identity_shim.dart
abstract class IdentityShim {
  // Core identity operations
  Future<AuthResult> authenticate(Credentials credentials);
  Future<void> logout();
  Future<IdentityState> getCurrentIdentity();

  // Token management
  Future<TokenRefreshResult> refreshTokens();
  Future<void> rotateTokens();

  // Session management
  Future<bool> hasValidSession();
  Future<void> clearSession();

  // User profile
  Future<UserProfile> getUserProfile();
  Future<void> updateUserProfile(UserProfileUpdate update);

  // DSR operations (for drivers)
  Future<DsrResult> submitDriverSignup(DsrRequest request);
  Future<DsrStatus> getDriverSignupStatus();

  // Stream of identity state changes
  Stream<IdentityState> get onIdentityChanged;
}
```

### 3.2 Auth Flow State Machine

#### Proposed Auth States
```dart
enum AuthFlowState {
  // Initial states
  unauthenticated,
  onboardingRequired,

  // Onboarding flow
  onboardingWelcome,
  onboardingPermissions,
  onboardingPreferences,

  // Auth flow
  phoneEntry,
  otpPending,
  otpVerifying,

  // MFA states
  mfaRequired,
  mfaVerifying,

  // Final states
  authenticated,
  sessionExpired,
  error,
}
```

#### State Transitions
```
unauthenticated → onboardingRequired → [onboardingWelcome → onboardingPermissions → onboardingPreferences] → phoneEntry → otpPending → otpVerifying → [mfaRequired → mfaVerifying] → authenticated

authenticated → sessionExpired (on token expiry)
authenticated → error (on auth failures)
any state → error (on critical failures)
```

### 3.3 Token Lifecycle & Security

#### Token Management Strategy
- **Access Token**: Short-lived (15-30 minutes), used for API calls
- **Refresh Token**: Long-lived (24-72 hours), used to obtain new access tokens
- **Rotation Policy**: Refresh tokens rotated on each use for enhanced security
- **Storage**: Encrypted via FlutterSecureStorage with biometric protection option

#### Token Refresh Flow
```
API Call → Token Expiring Soon → Background Refresh → New Tokens Stored → Continue API Call
                                                        ↓
                                               Refresh Failed → Logout Flow
```

#### Security Measures
- **TLS Pinning**: Certificate validation for all backend communication
- **Rate Limiting**: OTP requests limited to 5 per session, 45s cooldown
- **Biometric Unlock**: Optional device authentication for session restoration
- **Session Invalidation**: Automatic logout on suspicious activity

### 3.4 DSR (Driver Signup/Verification) Integration

#### DSR Architecture
```
Driver Onboarding Path:
Onboarding (Screens 1-3) → Driver Signup Prompt → DSR Form → Verification Flow

DSR State Management:
dsr_ux_adapter ← Riverpod Providers ← Auth Flow Integration
```

#### Driver vs Customer Flow
- **Customer Flow**: Standard onboarding → Auth → AppShell
- **Driver Flow**: Standard onboarding → Driver signup prompt → DSR → Verification → Auth → AppShell

#### DSR Status Integration
```dart
enum DriverSignupStatus {
  notApplied,      // Default state
  pending,         // Application submitted
  underReview,     // Documents being verified
  approved,        // Can access driver features
  rejected,        // Application denied
  requiresAction,  // Additional documents needed
}
```

---

## 4. Token Lifecycle & Security Considerations

### 4.1 Token Security Implementation

#### Access Token Management
- **Expiry**: 15 minutes for API calls
- **Storage**: Encrypted in secure storage
- **Validation**: Automatic refresh when <5 minutes remaining
- **Rotation**: New access token issued with each refresh

#### Refresh Token Management
- **Expiry**: 24 hours initially, extended on use
- **Storage**: Separate encrypted storage location
- **Rotation**: New refresh token issued on each use
- **Invalidation**: Immediate invalidation on logout/security events

#### Security Headers & Validation
```dart
// Automatic token injection in HTTP requests
class AuthenticatedHttpClient {
  Future<Response> send(Request request) async {
    final tokens = await _tokenManager.getValidTokens();
    request.headers.addAll({
      'Authorization': 'Bearer ${tokens.accessToken}',
      'X-Client-Version': appVersion,
      'X-Device-Id': deviceId,
    });
    return _httpClient.send(request);
  }
}
```

### 4.2 Session Security Measures

#### Biometric Session Protection
- **Optional Enhancement**: Biometric unlock for stored sessions
- **Fallback**: Standard PIN/password if biometrics unavailable
- **Timeout**: Automatic biometric re-verification after inactivity

#### Session Monitoring
- **Activity Tracking**: Monitor session usage patterns
- **Suspicious Activity**: Automatic logout on anomaly detection
- **Device Binding**: Optional session binding to trusted devices

### 4.3 Error Handling & Recovery

#### Token Refresh Failures
```
Refresh Failed → Attempt Retry (1x) → Logout if Still Failed
                                 ↓
                    User Notification → Graceful Logout
```

#### Network Issues
- **Offline Mode**: Allow app usage with cached session (limited features)
- **Reconnection**: Automatic token refresh on network restoration
- **Timeout Handling**: Progressive backoff for retry attempts

---

## 5. DSR / Driver Signup Considerations

### 5.1 DSR Integration Points

#### Onboarding Integration
```dart
// In onboarding completion
if (userSelectedDriverRole) {
  await _dsrService.initiateDriverSignup();
  // Navigate to DSR flow instead of direct auth
} else {
  // Continue to customer auth flow
}
```

#### Auth Flow Integration
- **Pre-Auth DSR**: Driver signup before authentication
- **Post-Auth DSR**: Convert existing customer account to driver
- **Status Tracking**: DSR status visible in profile/account sections

### 5.2 DSR State Management

#### DSR State in Auth Flow
```dart
class AuthState {
  final AuthStatus status;
  final AuthSession? session;
  final DriverSignupStatus driverStatus;  // NEW
  final bool isDriverOnboarding;          // NEW
}
```

#### DSR Flow States
```
Not Applied → Application Started → Documents Submitted → Under Review → Approved/Rejected
```

### 5.3 Driver Verification Workflow

#### Multi-Step Verification
1. **Basic Information**: Name, contact, vehicle details
2. **Document Upload**: License, insurance, vehicle registration
3. **Background Check**: Automated verification processes
4. **Final Approval**: Manual review and activation

#### Document Management
- **Secure Upload**: Encrypted document transmission
- **Status Tracking**: Real-time verification progress
- **Retry Logic**: Failed upload retry with exponential backoff

---

## 6. Proposed Ticket Breakdown for Track D

### D-1: Setup Identity Shim Public API + Basic Auth State Wiring
**Goal:** Establish clean Identity Shim abstraction layer and wire basic auth state management.

**Files to Modify:**
- `packages/identity_shim/` (create new package)
- `lib/state/auth/auth_state.dart` (replace stub with Identity Shim integration)
- `lib/state/infra/auth_providers.dart` (update providers)

**Scope:** Public API definition, basic state management, no UI changes.

**Risks:** Breaking changes to existing auth providers.

---

### D-2: AuthGuard + Enhanced Routing Integration
**Goal:** Implement AuthGuard pattern for route protection and enhance routing logic.

**Files to Modify:**
- `lib/router/app_router.dart` (add AuthGuard wrapper)
- `lib/widgets/rbac_guard.dart` (extend or create auth-specific guard)
- `lib/app_shell/app_shell.dart` (integrate with new auth state)

**Scope:** Route protection, navigation flow updates.

**Risks:** Complex routing logic changes.

---

### D-3: Complete Onboarding Flow (Screens 1-5) + LTR/RTL + Tests
**Goal:** Implement missing onboarding screens with full LTR/RTL support.

**Files to Create:**
- `lib/screens/onboarding/permissions_screen.dart`
- `lib/screens/onboarding/preferences_screen.dart`
- Enhanced `lib/screens/onboarding/onboarding_root_screen.dart`

**Files to Update:**
- `lib/screens/onboarding/welcome_screen.dart` (create if missing)
- `lib/l10n/` (add onboarding strings)

**Scope:** UI implementation, localization, RTL support.

**Risks:** LTR/RTL layout complexity.

---

### D-4: Enhanced OTP Screen + Error States + Integration Tests
**Goal:** Upgrade OTP screen with real backend integration and comprehensive error handling.

**Files to Modify:**
- `lib/screens/auth/otp_verification_screen.dart` (replace stub implementation)
- `lib/screens/auth/phone_login_screen.dart` (enhance error handling)
- `test/ui/auth/` (add integration tests)

**Scope:** Backend integration, error states, testing.

**Risks:** Backend dependency for testing.

---

### D-5: Login/Phone Input Enhancement + Session Storage
**Goal:** Enhance phone login screen with session persistence and biometric integration.

**Files to Modify:**
- `lib/screens/auth/phone_login_screen.dart` (add session restoration)
- `lib/state/auth/passwordless_auth_controller.dart` (enhance session management)

**Scope:** Session persistence, biometric unlock integration.

**Risks:** Secure storage complexity.

---

### D-6: Token Refresh / Session Renewal Implementation
**Goal:** Implement automatic token refresh and rotation policy.

**Files to Create:**
- `packages/identity_shim/src/token_manager.dart`
- `lib/services/token_refresh_service.dart`

**Files to Modify:**
- `lib/state/infra/auth_providers.dart` (add token refresh providers)
- `packages/auth_http_impl/` (enhance token handling)

**Scope:** Background token refresh, rotation logic.

**Risks:** Complex async token management.

---

### D-7: DSR Flow – UI + State Wiring (Driver Signup)
**Goal:** Implement driver signup request flow with UI and state management.

**Files to Create:**
- `lib/screens/dsr/driver_signup_screen.dart`
- `lib/screens/dsr/driver_verification_screen.dart`
- `lib/state/dsr/dsr_providers.dart`

**Files to Modify:**
- `lib/router/app_router.dart` (add DSR routes)
- `lib/screens/onboarding/onboarding_root_screen.dart` (add driver path)

**Scope:** DSR UI, state management, routing.

**Risks:** Complex multi-step flow.

---

### D-8: Hardening & Integration Tests (LTR/RTL Auth Flow)
**Goal:** Comprehensive testing and hardening of complete auth flow.

**Files to Create:**
- `test/ui/auth/auth_flow_integration_test.dart`
- `test/ui/onboarding/onboarding_ltr_rtl_test.dart`
- `test/ui/dsr/dsr_flow_test.dart`

**Files to Modify:**
- `test/ui/app_shell_bottom_nav_test.dart` (update for new auth state)

**Scope:** Integration testing, RTL/LTR coverage, performance validation.

**Risks:** Test complexity and maintenance.

---

## Summary

This plan provides a comprehensive roadmap for implementing Track D with:

1. **Clean Architecture**: Identity Shim as unified abstraction layer
2. **Security-First**: Token rotation, secure storage, biometric integration
3. **Complete UX**: Full onboarding and auth flow with RTL/LTR support
4. **DSR Integration**: Driver signup and verification workflow
5. **Testable Implementation**: 8 focused tickets with clear deliverables

**Estimated Total Effort**: 40-50 hours across 8 tickets
**Risk Level**: Medium (backend dependencies, complex state management)
**Dependencies**: Backend OTP/MFA services, DSR processing API

**Next Steps**: Begin with D-1 (Identity Shim) to establish architectural foundation.

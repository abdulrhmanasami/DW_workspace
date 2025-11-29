# Track D: Onboarding, Auth, and DSR Implementation

## Overview

This document outlines the implementation of Track D: Onboarding, Auth, and Empty States. The goal is to implement a professional onboarding flow, activate authentication screens, and create data subject rights (DSR) screens.

## Current State Analysis

### Existing Infrastructure

1. **Auth Screens:** Existing screens for OTP, 2FA, and phone login
2. **Onboarding:** Onboarding root screen with placeholder implementation
3. **Feature Flags:** System for managing feature availability
4. **Localization:** Support for EN, DE, AR with documented copy

## Implementation Plan

### Phase 1: Enhance Onboarding Flow

**Files:**
- `lib/screens/onboarding/onboarding_root_screen.dart` (update)
- `lib/screens/onboarding/welcome_screen.dart` (create)
- `lib/screens/onboarding/permissions_screen.dart` (create)
- `lib/screens/onboarding/preferences_screen.dart` (create)

### Phase 2: Activate Auth Screens

**Files:**
- `lib/screens/auth/phone_login_screen.dart` (update)
- `lib/screens/auth/otp_verification_screen.dart` (update)
- `lib/screens/auth/two_factor_screen.dart` (update)

### Phase 3: Create Empty States and Error Views

**Files:**
- `lib/screens/empty_states/no_rides_screen.dart` (create)
- `lib/screens/empty_states/no_parcels_screen.dart` (create)
- `lib/screens/empty_states/error_screen.dart` (create)

### Phase 4: Create DSR Screens

**Files:**
- `lib/screens/dsr/dsr_root_screen.dart` (create)
- `lib/screens/dsr/data_export_screen.dart` (create)
- `lib/screens/dsr/data_deletion_screen.dart` (create)

### Phase 5: Update Navigation

Update router to include:
- `/onboarding` - Onboarding flow
- `/auth/phone-login` - Phone login
- `/auth/otp` - OTP verification
- `/auth/2fa` - Two-factor authentication
- `/dsr` - Data subject rights

## Implementation Details

### Onboarding Flow

The onboarding flow consists of:

1. **Welcome Screen**
   - App logo and welcome message
   - Brief description of the app
   - "Get Started" button

2. **Permissions Screen**
   - Location permission request
   - Notification permission request
   - Explanation of why permissions are needed

3. **Preferences Screen**
   - Language selection (EN, DE, AR)
   - Notification preferences
   - Terms and conditions acceptance

### Auth Flow

The auth flow consists of:

1. **Phone Login Screen**
   - Phone number input with country selector
   - Terms acceptance checkbox
   - "Send OTP" button

2. **OTP Verification Screen**
   - OTP input field (6 digits)
   - Resend OTP button with countdown
   - Verification logic

3. **Two-Factor Authentication Screen**
   - 2FA method selection (SMS, Email, Authenticator)
   - 2FA code input
   - Verify button

### Empty States

Empty states for:
- No rides available
- No parcels available
- Network error
- Server error
- No search results

### DSR Screens

Data Subject Rights screens:

1. **DSR Root Screen**
   - Overview of DSR options
   - Data export option
   - Data deletion option
   - Account deactivation option

2. **Data Export Screen**
   - Request data export
   - Export format selection
   - Download exported data
   - Status tracking

3. **Data Deletion Screen**
   - Request data deletion
   - Confirmation dialog
   - Deletion status tracking
   - Account deactivation

## UI Components

### Onboarding Card
- Icon or image
- Title and description
- Action button

### Auth Input
- Phone number input with country selector
- OTP input field
- Password input field

### Empty State Card
- Icon
- Title and description
- Action button (retry, go home, etc.)

### DSR Request Card
- Request type
- Status
- Request date
- Action buttons

## Testing Strategy

1. **Unit Tests:** Test state management providers
2. **Widget Tests:** Test UI components
3. **Integration Tests:** Test onboarding and auth flows
4. **Mock Backend:** Use stub implementations

## Success Criteria

- ✅ Onboarding flow with 3 screens
- ✅ Auth screens activated and functional
- ✅ Empty states for all major features
- ✅ DSR screens with request management
- ✅ All tests pass
- ✅ App builds successfully
- ✅ Uses design system (no direct SDK imports)

## Files to Create

1. `lib/screens/onboarding/welcome_screen.dart`
2. `lib/screens/onboarding/permissions_screen.dart`
3. `lib/screens/onboarding/preferences_screen.dart`
4. `lib/screens/empty_states/no_rides_screen.dart`
5. `lib/screens/empty_states/no_parcels_screen.dart`
6. `lib/screens/empty_states/error_screen.dart`
7. `lib/screens/dsr/dsr_root_screen.dart`
8. `lib/screens/dsr/data_export_screen.dart`
9. `lib/screens/dsr/data_deletion_screen.dart`

## Files to Update

1. `lib/screens/onboarding/onboarding_root_screen.dart` - Implement onboarding flow
2. `lib/screens/auth/phone_login_screen.dart` - Activate phone login
3. `lib/screens/auth/otp_verification_screen.dart` - Activate OTP verification
4. `lib/screens/auth/two_factor_screen.dart` - Activate 2FA
5. `lib/router/app_router.dart` - Add DSR and empty state routes

## Timeline

- **Phase 1:** 2-3 hours (Onboarding screens)
- **Phase 2:** 1-2 hours (Auth screens)
- **Phase 3:** 1-2 hours (Empty states)
- **Phase 4:** 1-2 hours (DSR screens)
- **Phase 5:** 30 minutes (Navigation)
- **Testing:** 1-2 hours

**Total Estimated Time:** 7-11 hours

## Notes

- All changes maintain backward compatibility
- Uses existing design system abstractions
- No direct SDK imports
- Follows design system from Track A
- Implements proper error handling and loading states
- Localization support for EN, DE, AR
- Proper permission handling with explanations

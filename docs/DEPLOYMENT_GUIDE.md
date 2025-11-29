# Deployment Guide - DW-INTEGRATION-E2E+UAT-008

## Overview
This guide covers the deployment and testing procedures for the Delivery Ways E2E+UAT readiness implementation. The release includes comprehensive testing infrastructure for validating production readiness.

## Prerequisites

### System Requirements
- Flutter SDK >= 3.0.0
- Dart SDK >= 2.12.0 (null safety enabled)
- Android SDK (for APK builds)
- Git (for version control)

### Environment Setup
Create a `.env` file in the project root with the following variables:

```env
# Supabase Configuration
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Stripe Configuration (Test Keys Only)
STRIPE_PUBLISHABLE_KEY=pk_test_51YourStripeKeyHere...

# RBAC Service Configuration
RBAC_BASE_URL=https://api.rbac.yourdomain.com

# Telemetry Service Configuration
TELEMETRY_ENDPOINT=https://telemetry.yourdomain.com/webhook
```

## Deployment Steps

### 1. Code Checkout
```bash
git checkout uat/e2e-readiness-008
flutter pub get
```

### 2. Environment Validation
```bash
# Verify environment variables are set
echo $SUPABASE_URL
echo $SUPABASE_ANON_KEY
echo $STRIPE_PUBLISHABLE_KEY
echo $RBAC_BASE_URL
echo $TELEMETRY_ENDPOINT
```

### 3. Pre-deployment Checks

#### Gate A: Code Analysis
```bash
flutter analyze
```
**Expected**: 0 errors (warnings ≤ 10 allowed)

#### Gate B: Build Validation
```bash
flutter build apk --debug
```
**Expected**: Successful build with exit code 0

### 4. Test Execution

#### E2E Service Tests
```bash
flutter test app/test/e2e \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=STRIPE_PUBLISHABLE_KEY=$STRIPE_PUBLISHABLE_KEY \
  --dart-define=RBAC_BASE_URL=$RBAC_BASE_URL \
  --dart-define=TELEMETRY_ENDPOINT=$TELEMETRY_ENDPOINT \
  --reporter expanded | tee tools/reports/E2E_CONSOLE.log
```

#### UI Smoke Tests
```bash
# Ensure Android emulator is running
flutter emulators --launch android_emulator
flutter test integration_test \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=STRIPE_PUBLISHABLE_KEY=$STRIPE_PUBLISHABLE_KEY \
  --dart-define=RBAC_BASE_URL=$RBAC_BASE_URL \
  --dart-define=TELEMETRY_ENDPOINT=$TELEMETRY_ENDPOINT \
  | tee tools/reports/UI_SMOKE_CONSOLE.log
```

### 5. Results Validation

#### Check Test Results
```bash
# View E2E test results
cat tools/reports/E2E_RESULTS.json | jq '.overall_status'

# Check for acceptance signal
ls -la tools/reports/E2E_ACCEPTANCE_SIGNAL
```

#### Gate C: Service Integration
- ✅ Auth: signUp/signIn/signOut/currentUser successful
- ✅ RBAC: authorize() returns correct permissions for User/Admin
- ✅ Payments: pay() succeeds/fails appropriately with PaymentResult
- ✅ Tracking: GeolocationPort emits ≥5 location points
- ✅ Telemetry: Events emitted for auth, payment, screen_view categories

#### Gate D: UI Smoke
- ✅ RBAC blocks admin access for non-admin users
- ✅ Payment flow completes with success/failure indication
- ✅ Map displays route with ≥5 points after tracking
- ✅ No crashes during 2-minute stability test

### 6. Production Build
```bash
# Clean build
flutter clean
flutter pub get

# Production APK
flutter build apk --release

# Optional: Bundle generation
bash scripts/create_delivery.sh
```

## Security Checklist

### 🔐 Secrets Management
- [ ] No hardcoded API keys in source code
- [ ] Environment variables used for all sensitive data
- [ ] Test keys only (no production Stripe keys)
- [ ] Supabase keys are test environment only

### 🛡️ Data Protection
- [ ] GDPR compliance maintained
- [ ] No demo/test user data in production builds
- [ ] Certificate pinning configured
- [ ] TLS 1.3 enforced for all API calls

### 🔒 Access Control
- [ ] RBAC properly restricts admin functions
- [ ] Authentication required for sensitive operations
- [ ] API rate limiting configured
- [ ] Input validation on all user inputs

## Troubleshooting

### Common Issues

#### Build Failures
```bash
# Clear build cache
flutter clean
rm -rf .dart_tool/build/

# Rebuild dependencies
flutter pub get --no-cache
```

#### Test Timeouts
```bash
# Increase test timeout
flutter test --timeout=5m

# Run tests individually
flutter test app/test/e2e/auth_e2e_test.dart
```

#### Environment Issues
```bash
# Validate environment
flutter doctor

# Check pubspec dependencies
flutter pub deps
```

### Logs and Diagnostics
```bash
# View detailed logs
tail -f tools/reports/E2E_CONSOLE.log
tail -f tools/reports/UI_SMOKE_CONSOLE.log

# Check analyzer output
cat tools/reports/ANALYZE_E2E_SNAPSHOT.txt

# Build diagnostics
cat tools/reports/BUILD_DEBUG_E2E.txt
```

## Rollback Procedures

### Emergency Rollback
```bash
# Revert to previous commit
git reset --hard HEAD~1
git push --force-with-lease

# Clean rebuild
flutter clean && flutter pub get
```

### Partial Rollback
```bash
# Remove test files if causing issues
rm -rf app/test/e2e/
rm -rf integration_test/

# Restore original pubspec
git checkout HEAD~1 -- pubspec.yaml
```

## Monitoring and Observability

### Post-deployment Checks
- [ ] App launches without crashes
- [ ] Authentication flows work
- [ ] Payment processing functional
- [ ] GPS tracking operational
- [ ] Telemetry events received

### Performance Benchmarks
- Cold start time: ≤2.0s
- UI frame rate: ≥60fps
- API response time: P95 ≤400ms
- App size: ≤50MB (debug), ≤25MB (release)

## Support Contacts

| Component | Contact | Escalation |
|-----------|---------|------------|
| Authentication | auth-team@deliveryways.com | Lead: @auth-architect |
| Payments | payments-team@deliveryways.com | Lead: @payments-architect |
| RBAC | security-team@deliveryways.com | Lead: @security-architect |
| Tracking | mobility-team@deliveryways.com | Lead: @mobility-architect |
| Telemetry | data-team@deliveryways.com | Lead: @data-architect |

---

**Document Version**: 1.0
**Last Updated**: 2025-11-02
**Approved By**: Delivery Ways Tech Lead
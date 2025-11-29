import 'package:flutter/foundation.dart';

import 'config_manager.dart' as app_cfg;

/// Component: FeatureFlags
/// Created by: Cursor (auto-generated)
/// Purpose: Feature flags for payment system rollout and control
/// Last updated: 2025-01-27

/// Feature flags for controlling payment system and RBAC rollout
class FeatureFlags {
  static const String _paymentsEnabled = 'payments.enabled';
  static const String _applePayEnabled = 'applepay.enabled';
  static const String _googlePayEnabled = 'gpay.enabled';
  static const String _stagingMode = 'staging.mode';
  static const String _productionRollout = 'production.rollout';

  // RBAC Feature Flags (P1)
  static const String _rbacEnforce = 'rbac.enforce';
  static const String _rbacCanaryPercentage = 'rbac.canary.percentage';
  static const String _rbacDenyByDefault = 'rbac.deny.by_default';

  // Payments & RBAC Canonical Enforcement (Ticket A)
  static const String _paymentsRbacCanonicalEnforced =
      'payments.rbac.canonical.enforced';
  static const String _paymentsFallbackLegacy = 'payments.fallback.legacy';

  // Enhanced security validations (Ticket B)
  static const String _paymentsSecurityValidationEnabled =
      'payments.security.validation.enabled';

  // FEATURE-SYNC-R1: Fail-closed feature requirements
  static const String _requiresBackend = 'feature.requires.backend';
  static const String _requiresPayments = 'feature.requires.payments';
  static const String _requiresTelemetry = 'feature.requires.telemetry';
  static const String certPinningFlagKey = 'security.cert_pinning.enabled';

  // Auth Feature Flags (CENT-003 + CENT-004)
  static const String _passwordlessAuthEnabled = 'auth.passwordless.enabled';
  static const String _biometricAuthEnabled = 'auth.biometric.enabled';
  static const String _twoFactorAuthEnabled = 'auth.two_factor.enabled';

  // Mobility Feature Flags (CENT-MOB-TRACKING-001)
  static const String _realtimeTrackingEnabled = 'mobility.realtime.enabled';
  static const String _backgroundTrackingEnabled = 'mobility.background.enabled';

  // Track C - Parcels & Food Verticals (Ticket #40)
  static const String _parcelsMvpEnabled = 'parcels.mvp.enabled';
  static const String _foodMvpEnabled = 'food.mvp.enabled';

  /// Check if payments are enabled (with kill switch)
  static bool get paymentsEnabled {
    // Check kill switch first (highest priority)
    const String forceDisabled = String.fromEnvironment(
      'PAYMENTS_FORCE_DISABLED',
      defaultValue: 'false',
    );
    if (forceDisabled.toLowerCase() == 'true') {
      if (kDebugMode) {
        // TODO: Replace with proper logging: unawaited(print('🚨 PAYMENTS FORCE DISABLED - Kill switch activated');)
      }
      return false;
    }

    // Default to true in debug mode, controlled by environment in production
    if (kDebugMode) return true;

    // In production, check environment variable
    const String envValue = String.fromEnvironment(
      'PAYMENTS_ENABLED',
      defaultValue: 'true',
    );
    return envValue.toLowerCase() == 'true';
  }

  /// Check if Apple Pay is enabled (Phase 1: Disabled)
  static bool get applePayEnabled {
    if (!paymentsEnabled) return false;

    // Phase 1: Apple Pay disabled until client provides merchant accounts
    const String envValue = String.fromEnvironment(
      'APPLE_PAY_ENABLED',
      defaultValue: 'false',
    );
    return envValue.toLowerCase() == 'true';
  }

  /// Check if Google Pay is enabled (Phase 1: Disabled)
  static bool get googlePayEnabled {
    if (!paymentsEnabled) return false;

    // Phase 1: Google Pay disabled until client provides merchant accounts
    const String envValue = String.fromEnvironment(
      'GOOGLE_PAY_ENABLED',
      defaultValue: 'false',
    );
    return envValue.toLowerCase() == 'true';
  }

  /// Check if we're in staging mode
  static bool get isStagingMode {
    const String envValue = String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: 'development',
    );
    return envValue.toLowerCase() == 'staging';
  }

  /// Get production rollout percentage
  static int get productionRolloutPercentage {
    if (isStagingMode) return 100; // Full rollout in staging

    const String envValue = String.fromEnvironment(
      'PRODUCTION_ROLLOUT',
      defaultValue: '0',
    );
    return int.tryParse(envValue) ?? 0;
  }

  /// Check if user should see payments (based on rollout percentage)
  static bool shouldShowPayments(String userId) {
    if (!paymentsEnabled) return false;
    if (isStagingMode) return true;

    // Simple hash-based rollout (0-100%)
    final int hash = userId.hashCode.abs() % 100;
    return hash < productionRolloutPercentage;
  }

  /// Switch between passwordless HTTP auth and legacy Supabase path.
  static bool get enablePasswordlessAuth {
    const String envValue = String.fromEnvironment(
      'ENABLE_PASSWORDLESS_AUTH',
      defaultValue: 'true',
    );
    if (kDebugMode) {
      return envValue.toLowerCase() != 'false';
    }
    return envValue.toLowerCase() == 'true';
  }

  /// Toggle biometric unlock for passwordless auth sessions.
  static bool get enableBiometricAuth {
    const String envValue = String.fromEnvironment(
      'ENABLE_BIOMETRIC_AUTH',
      defaultValue: 'true',
    );
    if (kDebugMode) {
      return envValue.toLowerCase() != 'false';
    }
    return envValue.toLowerCase() == 'true';
  }

  /// Toggle 2FA/MFA for risk-based authentication (CENT-004).
  ///
  /// When false:
  /// - No MFA UI is shown to users
  /// - evaluateMfaRequirement is skipped (returns notRequired)
  /// - This is the Sale-Only behavior: no fake/demo 2FA
  ///
  /// When true AND backend enables MFA:
  /// - MFA flow is activated after primary OTP verification
  /// - User sees TwoFactorScreen for second factor entry
  static bool get enableTwoFactorAuth {
    // Check kill switch first
    const String forceDisabled = String.fromEnvironment(
      'TWO_FACTOR_AUTH_FORCE_DISABLED',
      defaultValue: 'false',
    );
    if (forceDisabled.toLowerCase() == 'true') {
      return false;
    }

    const String envValue = String.fromEnvironment(
      'ENABLE_TWO_FACTOR_AUTH',
      defaultValue: 'false',
    );
    // Default to false - only enable when explicitly configured
    // This follows Sale-Only principle: no 2FA UI without backend support
    return envValue.toLowerCase() == 'true';
  }

  /// Check if realtime tracking is enabled (CENT-MOB-TRACKING-001)
  static bool get enableRealtimeTracking {
    // Check kill switch first
    const String forceDisabled = String.fromEnvironment(
      'REALTIME_TRACKING_FORCE_DISABLED',
      defaultValue: 'false',
    );
    if (forceDisabled.toLowerCase() == 'true') {
      return false;
    }

    const String envValue = String.fromEnvironment(
      'ENABLE_REALTIME_TRACKING',
      defaultValue: 'true',
    );
    return envValue.toLowerCase() == 'true';
  }

  /// Check if background tracking is enabled (CENT-MOB-TRACKING-001)
  static bool get enableBackgroundTracking {
    const String envValue = String.fromEnvironment(
      'ENABLE_BACKGROUND_TRACKING',
      defaultValue: 'true',
    );
    return envValue.toLowerCase() == 'true';
  }

  /// Check if Parcels MVP is enabled (Track C - Ticket #40)
  /// When true: Parcels service card navigates to ParcelsEntryScreen
  /// When false: Shows "coming soon" snackbar
  static bool get enableParcelsMvp {
    const String envValue = String.fromEnvironment(
      'ENABLE_PARCELS_MVP',
      defaultValue: 'true',
    );
    // Default to true in debug mode for development
    if (kDebugMode) {
      return envValue.toLowerCase() != 'false';
    }
    return envValue.toLowerCase() == 'true';
  }

  /// Check if Food MVP is enabled (Track C - Future)
  /// Reserved for future Food vertical implementation
  static bool get enableFoodMvp {
    const String envValue = String.fromEnvironment(
      'ENABLE_FOOD_MVP',
      defaultValue: 'false',
    );
    return envValue.toLowerCase() == 'true';
  }

  /// Get all feature flags as a map for debugging
  static Map<String, dynamic> getAllFlags() {
    return <String, dynamic>{
      _paymentsEnabled: paymentsEnabled,
      _applePayEnabled: applePayEnabled,
      _googlePayEnabled: googlePayEnabled,
      _stagingMode: isStagingMode,
      _productionRollout: productionRolloutPercentage,
      _passwordlessAuthEnabled: enablePasswordlessAuth,
      _biometricAuthEnabled: enableBiometricAuth,
      _twoFactorAuthEnabled: enableTwoFactorAuth,
      _realtimeTrackingEnabled: enableRealtimeTracking,
      _backgroundTrackingEnabled: enableBackgroundTracking,
      _parcelsMvpEnabled: enableParcelsMvp,
      _foodMvpEnabled: enableFoodMvp,
      _rbacEnforce: rbacEnforce,
      _rbacCanaryPercentage: rbacCanaryPercentage,
      _rbacDenyByDefault: rbacDenyByDefault,
      _paymentsRbacCanonicalEnforced: paymentsRbacCanonicalEnforced,
      _paymentsFallbackLegacy: paymentsFallbackLegacy,
      _paymentsSecurityValidationEnabled: paymentsSecurityValidationEnabled,
      _requiresBackend: requiresBackend,
      _requiresPayments: requiresPayments,
      _requiresTelemetry: requiresTelemetry,
      certPinningFlagKey: enableCertPinning,
      'phase': 'feature_sync_r1', // FEATURE-SYNC-R1: Screens + Services
      'payments.force_disabled': _isForceDisabled(),
    };
  }

  /// Check if RBAC is enforced (P1 Rollout)
  static bool get rbacEnforce {
    if (isStagingMode) return true; // Full RBAC in staging

    const String envValue = String.fromEnvironment(
      'RBAC_ENFORCE',
      defaultValue: 'false',
    );
    return envValue.toLowerCase() == 'true';
  }

  /// Get RBAC canary percentage (P1 Rollout)
  static int get rbacCanaryPercentage {
    if (isStagingMode) return 100; // Full rollout in staging

    const String envValue = String.fromEnvironment(
      'RBAC_CANARY_PERCENTAGE',
      defaultValue: '10',
    );
    return int.tryParse(envValue) ?? 10;
  }

  /// Check if RBAC uses deny-by-default policy (P1)
  static bool get rbacDenyByDefault {
    const String envValue = String.fromEnvironment(
      'RBAC_DENY_BY_DEFAULT',
      defaultValue: 'true',
    );
    return envValue.toLowerCase() == 'true';
  }

  /// Check if payments RBAC canonical enforcement is enabled (Ticket A)
  static bool get paymentsRbacCanonicalEnforced {
    const String envValue = String.fromEnvironment(
      'PAYMENTS_RBAC_CANONICAL_ENFORCED',
      defaultValue: 'true',
    );
    return envValue.toLowerCase() == 'true';
  }

  /// Check if payments should fallback to legacy mode (Ticket A)
  static bool get paymentsFallbackLegacy {
    const String envValue = String.fromEnvironment(
      'PAYMENTS_FALLBACK_LEGACY',
      defaultValue: 'false',
    );
    return envValue.toLowerCase() == 'true';
  }

  /// Check if enhanced security validations are enabled (Ticket B)
  static bool get paymentsSecurityValidationEnabled {
    const String envValue = String.fromEnvironment(
      'PAYMENTS_SECURITY_VALIDATION_ENABLED',
      defaultValue: 'true',
    );
    return envValue.toLowerCase() == 'true';
  }

  /// Check if user should be subject to RBAC (based on canary percentage)
  static bool shouldApplyRBAC(String userId) {
    if (!rbacEnforce) return false;
    if (isStagingMode) return true;

    // Simple hash-based rollout (0-100%)
    final int hash = userId.hashCode.abs() % 100;
    return hash < rbacCanaryPercentage;
  }

  /// Check if certificate pinning is enabled
  static bool get enableCertPinning {
    final configValue =
        app_cfg.ConfigManager.instance.getBool(certPinningFlagKey);
    if (configValue != null) {
      return configValue;
    }

    const String envValue = String.fromEnvironment(
      'CERT_PINNING_ENABLED',
      defaultValue: 'false',
    );
    return envValue.toLowerCase() == 'true';
  }

  /// FEATURE-SYNC-R1: Check if feature requires backend availability
  static bool get requiresBackend {
    const String envValue = String.fromEnvironment(
      'FEATURE_REQUIRES_BACKEND',
      defaultValue: 'false',
    );
    return envValue.toLowerCase() == 'true';
  }

  /// FEATURE-SYNC-R1: Check if feature requires payments availability
  static bool get requiresPayments {
    const String envValue = String.fromEnvironment(
      'FEATURE_REQUIRES_PAYMENTS',
      defaultValue: 'false',
    );
    return envValue.toLowerCase() == 'true';
  }

  /// FEATURE-SYNC-R1: Check if feature requires telemetry availability
  static bool get requiresTelemetry {
    const String envValue = String.fromEnvironment(
      'FEATURE_REQUIRES_TELEMETRY',
      defaultValue: 'false',
    );
    return envValue.toLowerCase() == 'true';
  }

  /// Check if payments are force disabled (kill switch)
  static bool _isForceDisabled() {
    const String forceDisabled = String.fromEnvironment(
      'PAYMENTS_FORCE_DISABLED',
      defaultValue: 'false',
    );
    return forceDisabled.toLowerCase() == 'true';
  }

  /// Log feature flags status (debug only)
  static void logFlags() {
    if (kDebugMode) {
      // TODO: Replace with proper logging: unawaited(print('🚩 Feature Flags Status:');)
      getAllFlags().forEach((String key, dynamic value) {
        // TODO: Replace with proper logging: unawaited(print('   $key: $value');)
      });
    }
  }
}

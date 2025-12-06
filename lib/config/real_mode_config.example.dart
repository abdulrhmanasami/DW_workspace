/// Component: Real Mode Configuration
/// Created by: Cursor (auto-generated)
/// Purpose: Configuration constants for REAL MODE services (no secrets)
/// Last updated: 2025-11-02

/// REAL MODE Configuration
/// This file contains configuration constants for real services.
/// Use --dart-define to override these values at runtime.
/// DO NOT include actual secrets in this file.

class RealModeConfig {
  // Supabase Configuration (override with --dart-define=SUPABASE_URL=...)
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // Stripe Configuration (override with --dart-define=STRIPE_PUBLISHABLE_KEY=...)
  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  // RBAC Configuration (override with --dart-define=RBAC_BASE_URL=...)
  static const String rbacBaseUrl = String.fromEnvironment(
    'RBAC_BASE_URL',
    defaultValue: '',
  );

  // Telemetry Configuration (override with --dart-define=TELEMETRY_ENABLED=...)
  static const bool telemetryEnabled = bool.fromEnvironment(
    'TELEMETRY_ENABLED',
    defaultValue: true,
  );

  // Tracking Configuration (override with --dart-define=LOCATION_MOCK_ENABLED=...)
  static const bool locationMockEnabled = bool.fromEnvironment(
    'LOCATION_MOCK_ENABLED',
    defaultValue: false,
  );

  static const int locationUpdateIntervalMs = int.fromEnvironment(
    'LOCATION_UPDATE_INTERVAL',
    defaultValue: 2000,
  );

  // Build Configuration
  static const String buildMode = String.fromEnvironment(
    'BUILD_MODE',
    defaultValue: 'release',
  );

  static const bool splitPerAbi = bool.fromEnvironment(
    'SPLIT_PER_ABI',
    defaultValue: true,
  );

  // REAL MODE flags
  static const bool realServicesEnabled = bool.fromEnvironment(
    'REAL_SERVICES_ENABLED',
    defaultValue: true,
  );

  static const bool mockDataDisabled = bool.fromEnvironment(
    'MOCK_DATA_DISABLED',
    defaultValue: true,
  );

  // Test Data Constants (for REAL MODE testing)
  static const String testUserEmail = 'test@example.com';
  static const String testUserPassword = 'TestPass123!';
  static const String testPaymentAmount = '10.00';
  static const String testCurrency = 'EUR';

  // Test Timeouts (longer for real services)
  static const Duration realServiceTimeout = Duration(seconds: 30);
  static const Duration paymentTimeout = Duration(seconds: 60);
  static const Duration uiTestTimeout = Duration(seconds: 90);

  /// Validate that real mode configuration is properly set
  static bool get isProperlyConfigured {
    return supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty &&
        stripePublishableKey.isNotEmpty &&
        rbacBaseUrl.isNotEmpty;
  }
}

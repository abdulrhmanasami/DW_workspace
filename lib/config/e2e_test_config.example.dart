/// Component: E2E Test Configuration
/// Created by: Cursor (auto-generated)
/// Purpose: Configuration constants for E2E testing (no secrets)
/// Last updated: 2025-11-02

/// E2E Test Configuration
/// This file contains configuration constants for E2E tests.
/// Use --dart-define to override these values at runtime.
/// DO NOT include actual secrets in this file.

class E2ETestConfig {
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

  // Telemetry Configuration
  static const bool telemetryEnabled = bool.fromEnvironment(
    'TELEMETRY_ENABLED',
    defaultValue: false,
  );

  // Tracking Configuration
  static const bool locationMockEnabled = bool.fromEnvironment(
    'LOCATION_MOCK_ENABLED',
    defaultValue: true,
  );

  static const int locationUpdateIntervalMs = int.fromEnvironment(
    'LOCATION_UPDATE_INTERVAL',
    defaultValue: 1000,
  );

  // Test Data Constants
  static const String testUserEmail = 'test@example.com';
  static const String testUserPassword = 'testpass123';
  static const String testPaymentAmount = '10.00';
  static const String testCurrency = 'EUR';

  // Test Timeouts
  static const Duration testTimeout = Duration(seconds: 30);
  static const Duration uiTestTimeout = Duration(seconds: 60);
}

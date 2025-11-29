/// Component: Integration Configuration
/// Created by: Cursor (auto-generated)
/// Purpose: Environment variable configuration for backend integrations
/// Last updated: 2025-11-02

class IntegrationConfig {
  // Supabase Auth Configuration
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  // Stripe Payments Configuration
  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
  );

  // RBAC REST Configuration
  static const String rbacBaseUrl = String.fromEnvironment('RBAC_BASE_URL');
  static const String certPinsJson = String.fromEnvironment(
    'CERT_PINS_JSON',
    defaultValue: '',
  );

  // Validation helpers
  static bool get hasValidSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static bool get hasValidStripeConfig => stripePublishableKey.isNotEmpty;

  static bool get hasValidRbacConfig => rbacBaseUrl.isNotEmpty;

  static bool get isFullyConfigured =>
      hasValidSupabaseConfig && hasValidStripeConfig && hasValidRbacConfig;

  // Configuration summary for debugging
  static Map<String, bool> get configurationStatus => {
    'supabase': hasValidSupabaseConfig,
    'stripe': hasValidStripeConfig,
    'rbac': hasValidRbacConfig,
  };
}

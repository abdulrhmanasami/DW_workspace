/// Component: Service Locator
/// Created by: Cursor (auto-generated)
/// Purpose: Dependency injection container for backend services
/// Last updated: 2025-11-15

import 'package:auth_supabase_impl/auth_supabase_impl.dart';
import 'package:observability_shims/observability_shims.dart';
import 'package:payments/payments.dart';
import 'package:rbac_rest_impl/rbac_rest_impl.dart';
import 'package:core/core.dart';

import 'integration_config.dart';

/// Service locator for dependency injection
class ServiceLocator {
  // Lazy initialization of services
  static AuthRepository? _auth;
  static PaymentService? _payments;
  static RBACClient? _rbac;
  static TelemetryService? _telemetry;

  /// Get authentication service
  static AuthRepository get auth {
    _auth ??= _createSupabaseAuth();
    return _auth!;
  }

  static AuthRepository _createSupabaseAuth() {
    if (!IntegrationConfig.hasValidSupabaseConfig) {
      throw StateError(
        'Supabase not configured. Provide SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define.',
      );
    }
    return AuthRepositorySupabase(
      url: IntegrationConfig.supabaseUrl,
      anonKey: IntegrationConfig.supabaseAnonKey,
    );
  }

  /// Get payment service
  static PaymentService get payments {
    final service = _payments;
    if (service == null) {
      throw StateError(
        'PaymentService not initialized. Call ServiceLocator.ensurePaymentsReady() first.',
      );
    }
    return service;
  }

  /// Ensures payment service is initialized exactly once.
  static Future<void> ensurePaymentsReady() async {
    if (_payments != null) return;
    final cfg = loadPaymentsConfig();
    if (!cfg.isStripeReady) {
      _payments = null;
      return;
    }
    _payments = await getPaymentService(cfg: cfg);
  }

  /// Get RBAC client
  static RBACClient get rbac {
    _rbac ??= RbacRestClient(
      baseUrl: IntegrationConfig.rbacBaseUrl,
      certPinsJson: IntegrationConfig.certPinsJson.isNotEmpty
          ? IntegrationConfig.certPinsJson
          : null,
    );
    return _rbac!;
  }

  /// Get telemetry service
  static TelemetryService get telemetry {
    _telemetry ??= TelemetryNoop();
    return _telemetry!;
  }

  /// Ensure Supabase auth is initialized and ready.
  static Future<void> ensureAuthReady() async {
    _auth ??= _createSupabaseAuth();
  }

  /// Initialize all services (call this at app startup)
  static Future<void> initialize() async {
    await ensureAuthReady();

    // Pre-initialize services to catch configuration issues early
    if (IntegrationConfig.hasValidStripeConfig) {
      await ensurePaymentsReady();
    }

    if (IntegrationConfig.hasValidRbacConfig) {
      rbac;
    }

    telemetry;
  }

  /// Reset all services (useful for testing)
  static void reset() {
    _auth = null;
    _payments = null;
    _rbac = null;
    _telemetry = null;
  }
}

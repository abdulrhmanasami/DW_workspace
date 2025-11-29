/// Riverpod providers for user accounts and identity
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_shims/foundation_shims.dart';

import 'src/accounts_client.dart';
import 'src/accounts_endpoints.dart';
import 'src/models.dart';
import 'src/dsr/dsr_service.dart';
import 'src/dsr/dsr_contracts.dart';
import 'src/dsr/dsr_audit.dart';

/// Provider for current user profile
final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  final client = ref.watch(accountsClientProvider);
  return client.fetchMe();
});

/// Provider for Stripe customer ID (ensures customer exists)
final stripeCustomerIdProvider = FutureProvider<String>((ref) async {
  final profile = await ref.watch(userProfileProvider.future);

  if (profile.stripeCustomerId == null || profile.stripeCustomerId!.isEmpty) {
    final client = ref.watch(accountsClientProvider);
    final created = await client.ensureStripeCustomer();
    return created;
  }

  return profile.stripeCustomerId!;
});

// DSR (Data Subject Rights) providers

/// Provider for DSR service factory
final dsrServiceFactoryProvider = Provider<DsrServiceFactory>((ref) {
  final endpoints = ref.watch(accountsEndpointsProvider);
  final configManager = ref.watch(configManagerProvider);
  final auditSink = ref.watch(dsrAuditSinkProvider);

  // TODO: Get userId from authentication provider
  // For now, using a placeholder - in real implementation this would come from auth
  final userId = 'current_user_id'; // Placeholder - replace with actual user ID

  return DsrServiceFactoryImpl(
    endpoints: endpoints,
    configManager: configManager,
    auditSink: auditSink,
    userId: userId,
  );
});

/// Provider for DSR service
final dsrServiceProvider = Provider<DataSubjectRightsService>((ref) {
  final factory = ref.watch(dsrServiceFactoryProvider);
  return factory.createService();
});

/// Provider for DSR audit sink (configurable by environment)
final dsrAuditSinkProvider = Provider<DsrAuditSink>((ref) {
  final configManager = ref.watch(configManagerProvider);

  // Check if auditing is enabled (default to true for CI/testing)
  final auditEnabledStr =
      configManager.getString('dsr_audit_enabled') ?? 'true';
  final auditEnabled = auditEnabledStr.toLowerCase() == 'true';
  if (!auditEnabled) {
    return const NoOpDsrAuditSink();
  }

  // Choose sink based on environment
  final env = configManager.getString('environment') ?? 'development';

  switch (env.toLowerCase()) {
    case 'ci':
    case 'test':
    case 'staging':
    case 'production':
      // In production-like environments, write to file
      final logPath =
          configManager.getString('dsr_audit_log_path') ??
          'build/dsr_audit.log';
      return FileDsrAuditSink(logPath);

    case 'development':
    case 'debug':
    default:
      // In development, use console output
      return const ConsoleDsrAuditSink();
  }
});

/// Provider for accounts endpoints (needed by DSR factory)
final accountsEndpointsProvider = Provider<AccountsEndpoints>((ref) {
  final configManager = ref.watch(configManagerProvider);
  return AccountsEndpoints.fromConfig(configManager);
});

/// Provider for ConfigManager (from foundation_shims)
final configManagerProvider = Provider<ConfigManager>((ref) {
  return ConfigManager.instance;
});

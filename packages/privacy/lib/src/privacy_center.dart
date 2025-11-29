import 'package:network_shims/network_shims.dart';

import 'data_deletion_service.dart';
import 'dsar/dsar_service.dart';
import 'dsar/dsar_types.dart';
import 'privacy_backend_config.dart';
import 'privacy_policy.dart';

typedef PrivacyPolicyProvider = Future<PrivacyPolicy> Function();

/// High-level facade that exposes Privacy/DSAR operations to the rest of the app.
class PrivacyCenter {
  PrivacyCenter({
    required DSARService dsarService,
    required DataDeletionService deletionService,
    required PrivacyPolicyProvider privacyPolicyProvider,
  })  : _dsarService = dsarService,
        _deletionService = deletionService,
        _privacyPolicyProvider = privacyPolicyProvider;

  final DSARService _dsarService;
  final DataDeletionService _deletionService;
  final PrivacyPolicyProvider _privacyPolicyProvider;

  Future<DSARResponse> submitDSARRequest(DSARRequest request) {
    return _dsarService.submitRequest(request);
  }

  Future<bool> hasConsented(String userId) {
    return _dsarService.hasConsented(userId);
  }

  Future<void> deleteUserData(
    String userId, {
    bool anonymize = false,
    Map<String, dynamic>? metadata,
  }) {
    return _deletionService.deleteUserData(
      userId,
      anonymize: anonymize,
      metadata: metadata,
    );
  }

  Future<List<DataCategory>> getDataCategories(String userId) {
    return _dsarService.listDataCategories(userId);
  }

  Future<List<DataRetentionPeriod>> getRetentionPolicies(String userId) {
    return _dsarService.listRetentionPolicies(userId);
  }

  Future<PrivacyPolicy> getLatestPolicy() {
    return _privacyPolicyProvider();
  }
}

/// Convenience helper that wires a [PrivacyCenter] instance from the given config.
PrivacyCenter createPrivacyCenter({
  required SecureHttpClient client,
  required PrivacyBackendConfig config,
  PrivacyPolicyProvider? policyProvider,
}) {
  final dsarService = DSARService(client: client, config: config);
  final deletionService = DataDeletionService(client: client, config: config);

  Future<PrivacyPolicy> defaultPolicyProvider() async {
    // In absence of a dedicated endpoint we fall back to a static reference.
    return PrivacyPolicy(
      version: '1.0.0',
      publishedAt: DateTime.now().toUtc(),
      contentUrl: config.resolve('/privacy-policy/latest'),
    );
  }

  return PrivacyCenter(
    dsarService: dsarService,
    deletionService: deletionService,
    privacyPolicyProvider: policyProvider ?? defaultPolicyProvider,
  );
}


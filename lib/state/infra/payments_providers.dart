/// Component: Payments Providers
/// Created by: Cursor (auto-generated)
/// Purpose: Runtime configuration providers for payments feature flags
/// Last updated: 2025-11-25 DW-COMMERCE-PHASE4-COM-002

import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_shims/config_manager.dart' as fnd_cfg;
import 'package:payments/payments.dart' as pay;

/// Describes the readiness of the payments runtime configuration.
class PaymentsRuntimeConfigState {
  PaymentsRuntimeConfigState({
    required this.config,
    required this.isComplete,
    required List<String> missingKeys,
  }) : missingKeys = UnmodifiableListView<String>(missingKeys);

  final pay.PaymentsConfig? config;
  final bool isComplete;
  final List<String> missingKeys;
}

const _stripePublishableKeyKeys = <String>[
  'payments.stripe.publishableKey',
  'stripe_publishable_key',
  'STRIPE_PUBLISHABLE_KEY',
];

const _paymentsBackendBaseUrlKeys = <String>[
  'payments.backendBaseUrl',
  'payments_backend_base_url',
  'PAYMENTS_BACKEND_BASE_URL',
];

const _paymentsEnvironmentKeys = <String>[
  'payments.env',
  'payments_env',
  'PAYMENTS_ENV',
];

const _merchantDisplayNameKeys = <String>[
  'payments.merchantDisplayName',
  'stripe_merchant_display_name',
];

const _merchantCountryKeys = <String>[
  'payments.merchantCountry',
  'merchant_country_code',
];

const _merchantCategoryCodeKeys = <String>[
  'payments.merchantCategoryCode',
  'merchant_category_code',
];

const _googlePayEnabledKeys = <String>[
  'payments.googlePayEnabled',
  'stripe_gpay_enabled',
];

const _usePaymentSheetKeys = <String>[
  'payments.usePaymentSheet',
  'payments_use_payment_sheet',
];

/// Provides the current payments configuration snapshot derived from ConfigManager.
final paymentsRuntimeConfigProvider =
    Provider<PaymentsRuntimeConfigState>((ref) {
  final cfgManager = fnd_cfg.ConfigManager.instance;
  final missingKeys = <String>[];

  final publishableKey = _readNonEmpty(cfgManager, _stripePublishableKeyKeys);
  if (publishableKey == null) {
    missingKeys.add(_stripePublishableKeyKeys.first);
  }

  final backendBaseUrlStr =
      _readNonEmpty(cfgManager, _paymentsBackendBaseUrlKeys);
  Uri? backendBaseUrl;
  if (backendBaseUrlStr != null) {
    backendBaseUrl = Uri.tryParse(backendBaseUrlStr);
  }
  if (backendBaseUrl == null) {
    missingKeys.add(_paymentsBackendBaseUrlKeys.first);
  }

  String environment =
      _readNonEmpty(cfgManager, _paymentsEnvironmentKeys) ?? 'test';
  if (environment.isEmpty) {
    environment = 'test';
  }

  final merchantDisplayName =
      _readNonEmpty(cfgManager, _merchantDisplayNameKeys) ??
          'Delivery Ways';
  final merchantCountryCode =
      _readNonEmpty(cfgManager, _merchantCountryKeys) ?? 'US';
  final merchantCategoryCode =
      _readNonEmpty(cfgManager, _merchantCategoryCodeKeys);
  final googlePayEnabled =
      _readBool(cfgManager, _googlePayEnabledKeys, defaultValue: false);
  final usePaymentSheet =
      _readBool(cfgManager, _usePaymentSheetKeys, defaultValue: true);

  if (publishableKey == null || backendBaseUrl == null) {
    return PaymentsRuntimeConfigState(
      config: null,
      isComplete: false,
      missingKeys: missingKeys,
    );
  }

  final config = pay.PaymentsConfig(
    publishableKey: publishableKey,
    merchantCountryCode: merchantCountryCode,
    merchantDisplayName: merchantDisplayName,
    usePaymentSheet: usePaymentSheet,
    environment: environment,
    backendBaseUrl: backendBaseUrl,
    googlePayEnabled: googlePayEnabled,
    merchantCategoryCode: merchantCategoryCode,
  );

  return PaymentsRuntimeConfigState(
    config: config,
    isComplete: missingKeys.isEmpty,
    missingKeys: missingKeys,
  );
});

/// Provider for payments feature flags consumed by the UI.
final paymentsFeatureFlagsProvider = Provider<PaymentsFeatureFlags>((ref) {
  final state = ref.watch(paymentsRuntimeConfigProvider);
  final cfg = state.config;
  return PaymentsFeatureFlags(googlePayEnabled: cfg?.googlePayEnabled ?? false);
});

/// Feature flags for payments functionality
class PaymentsFeatureFlags {
  final bool googlePayEnabled;

  const PaymentsFeatureFlags({required this.googlePayEnabled});
}

/// Customer ID provider - delegates to accounts backend
final customerIdFutureProvider = FutureProvider<String?>((ref) async {
  // TODO: Implement when accounts backend is available
  return null;
});

String? _readNonEmpty(
  fnd_cfg.ConfigManager manager,
  List<String> keys,
) {
  for (final key in keys) {
    final candidate = manager.getString(key);
    if (candidate != null && candidate.trim().isNotEmpty) {
      return candidate.trim();
    }
  }
  return null;
}

bool _readBool(
  fnd_cfg.ConfigManager manager,
  List<String> keys, {
  required bool defaultValue,
}) {
  for (final key in keys) {
    final boolValue = manager.getBool(key);
    if (boolValue != null) {
      return boolValue;
    }
    final stringValue = manager.getString(key);
    if (stringValue != null) {
      final normalized = stringValue.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') {
        return true;
      }
      if (normalized == 'false' || normalized == '0') {
        return false;
      }
    }
  }
  return defaultValue;
}

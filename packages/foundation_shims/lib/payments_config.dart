import 'dart:io' show Platform;

import 'config_manager.dart';

class PaymentsConfig {
  final String publishableKey;
  final String merchantCountryCode;
  final String merchantDisplayName;
  final bool usePaymentSheet;
  final String environment;
  final Uri? backendBaseUrl;
  final bool googlePayEnabled;
  final String? merchantCategoryCode;

  const PaymentsConfig({
    required this.publishableKey,
    required this.merchantCountryCode,
    required this.merchantDisplayName,
    required this.usePaymentSheet,
    required this.environment,
    this.backendBaseUrl,
    this.googlePayEnabled = false,
    this.merchantCategoryCode,
  });

  factory PaymentsConfig.stub() => const PaymentsConfig(
    publishableKey: '',
    merchantCountryCode: 'US',
    merchantDisplayName: 'Delivery Ways',
    usePaymentSheet: false,
    environment: 'stub',
    backendBaseUrl: null,
    googlePayEnabled: false,
  );

  PaymentsConfig copyWith({
    String? publishableKey,
    String? merchantCountryCode,
    String? merchantDisplayName,
    bool? usePaymentSheet,
    String? environment,
    Uri? backendBaseUrl,
    bool? googlePayEnabled,
    String? merchantCategoryCode,
  }) {
    return PaymentsConfig(
      publishableKey: publishableKey ?? this.publishableKey,
      merchantCountryCode: merchantCountryCode ?? this.merchantCountryCode,
      merchantDisplayName: merchantDisplayName ?? this.merchantDisplayName,
      usePaymentSheet: usePaymentSheet ?? this.usePaymentSheet,
      environment: environment ?? this.environment,
      backendBaseUrl: backendBaseUrl ?? this.backendBaseUrl,
      googlePayEnabled: googlePayEnabled ?? this.googlePayEnabled,
      merchantCategoryCode: merchantCategoryCode ?? this.merchantCategoryCode,
    );
  }

  bool get isStripeReady =>
      publishableKey.isNotEmpty &&
      environment.isNotEmpty &&
      backendBaseUrl != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentsConfig &&
        publishableKey == other.publishableKey &&
        merchantCountryCode == other.merchantCountryCode &&
        merchantDisplayName == other.merchantDisplayName &&
        usePaymentSheet == other.usePaymentSheet &&
        environment == other.environment &&
        googlePayEnabled == other.googlePayEnabled &&
        merchantCategoryCode == other.merchantCategoryCode &&
        backendBaseUrl?.toString() == other.backendBaseUrl?.toString();
  }

  @override
  int get hashCode => Object.hash(
    publishableKey,
    merchantCountryCode,
    merchantDisplayName,
    usePaymentSheet,
    environment,
    googlePayEnabled,
    merchantCategoryCode,
    backendBaseUrl?.toString(),
  );

  @override
  String toString() =>
      'PaymentsConfig(env: $environment, publishableKey: ***, base: '
      '${backendBaseUrl?.toString() ?? 'N/A'})';
}

PaymentsConfig loadPaymentsConfig({ConfigManager? manager}) {
  final cfg = manager ?? ConfigManager.instance;

  String _string(String key, {String defaultValue = ''}) =>
      cfg.getString(key, defaultValue: defaultValue) ?? defaultValue;

  bool _flag(String key, {bool defaultValue = false}) {
    final raw = _string(key, defaultValue: defaultValue ? 'true' : 'false');
    return raw == '1' || raw.toLowerCase() == 'true';
  }

  Uri? backendBaseUrl;
  final backendUrlValue = _string('payments_backend_base_url');
  if (backendUrlValue.isNotEmpty) {
    backendBaseUrl = Uri.tryParse(backendUrlValue);
  }

  return PaymentsConfig(
    publishableKey: _string('stripe_publishable_key'),
    merchantCountryCode: _string('merchant_country_code', defaultValue: 'US'),
    merchantDisplayName: _string(
      'stripe_merchant_display_name',
      defaultValue: 'Delivery Ways',
    ),
    usePaymentSheet: _flag('payments_use_payment_sheet', defaultValue: true),
    environment: _string('payments_env', defaultValue: 'test'),
    backendBaseUrl: backendBaseUrl,
    googlePayEnabled: _flag('stripe_gpay_enabled'),
    merchantCategoryCode: _string('merchant_category_code'),
  );
}

/// Load payments config from environment variables (for CI only)
/// This function is intended for use in CI/test environments only
/// and should not be used in production app code.
Future<PaymentsConfig> loadPaymentsConfigFromEnv() async {
  String env(String k) {
    final compileTimeValue = String.fromEnvironment(k, defaultValue: '');
    if (compileTimeValue.isNotEmpty) return compileTimeValue;
    return Platform.environment[k] ?? '';
  }

  final backendUrlStr = env('STRIPE_BACKEND_BASEURL');
  Uri? backendBaseUrl;
  if (backendUrlStr.isNotEmpty) {
    backendBaseUrl = Uri.tryParse(backendUrlStr);
  }

  return PaymentsConfig(
    publishableKey: env('STRIPE_PUBLISHABLE_KEY'),
    merchantCountryCode: env('STRIPE_MERCHANT_COUNTRY'),
    merchantDisplayName: env('STRIPE_MERCHANT_NAME'),
    usePaymentSheet: true,
    environment: env('STRIPE_ENV').isEmpty ? 'test' : env('STRIPE_ENV'),
    backendBaseUrl: backendBaseUrl,
    googlePayEnabled: false,
  );
}

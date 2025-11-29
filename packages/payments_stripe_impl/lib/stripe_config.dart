/// Component: Stripe Configuration
/// Created by: Cursor (auto-generated)
/// Purpose: Stripe configuration management via foundation_shims
/// Last updated: 2025-11-11

import 'package:foundation_shims/foundation_shims.dart';

class StripeConfig {
  final String publishableKey; // من ConfigManager
  final Uri backendBaseUrl; // لطلبات: ephemeral-keys, create-intent
  final String? merchantDisplayName; // اختياري

  // Google Pay settings
  final bool googlePayEnabled; // تفعيل Google Pay (افتراضي false)
  final String merchantCountryCode; // كود البلد (مثال: "DE")
  final String? merchantCategoryCode; // كود الفئة التجارية (اختياري)
  final bool usePaymentSheet;

  const StripeConfig({
    required this.publishableKey,
    required this.backendBaseUrl,
    this.merchantDisplayName,
    this.googlePayEnabled = false,
    required this.merchantCountryCode,
    this.merchantCategoryCode,
    this.usePaymentSheet = true,
  });

  factory StripeConfig.fromConfigManager(ConfigManager configManager) {
    final publishableKey = configManager.getString('stripe_publishable_key');
    if (publishableKey == null || publishableKey.isEmpty) {
      throw StateError('STRIPE_PUBLISHABLE_KEY not configured');
    }

    final backendUrlStr = configManager.getString('payments_backend_base_url');
    if (backendUrlStr == null || backendUrlStr.isEmpty) {
      throw StateError('PAYMENTS_BACKEND_BASE_URL not configured');
    }

    final backendBaseUrl = Uri.parse(backendUrlStr);
    final merchantDisplayName =
        configManager.getString('stripe_merchant_display_name');

    // Google Pay settings
    final googlePayEnabledStr = configManager.getString('stripe_gpay_enabled');
    final googlePayEnabled =
        googlePayEnabledStr == 'true' || googlePayEnabledStr == '1';
    final merchantCountryCode =
        configManager.getString('merchant_country_code') ?? 'US';
    final merchantCategoryCode =
        configManager.getString('merchant_category_code');

    final usePaymentSheetStr =
        configManager.getString('payments_use_payment_sheet') ?? 'true';
    final usePaymentSheet =
        usePaymentSheetStr == 'true' || usePaymentSheetStr == '1';

    return StripeConfig(
      publishableKey: publishableKey,
      backendBaseUrl: backendBaseUrl,
      merchantDisplayName:
          (merchantDisplayName != null && merchantDisplayName.isNotEmpty)
              ? merchantDisplayName
              : null,
      googlePayEnabled: googlePayEnabled,
      merchantCountryCode: merchantCountryCode,
      merchantCategoryCode: merchantCategoryCode,
      usePaymentSheet: usePaymentSheet,
    );
  }
}

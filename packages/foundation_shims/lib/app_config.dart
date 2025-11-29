class AppConfig {
  static bool canUseBackendFeature() => true;
  static bool canUsePaymentFeature() => true;
  static bool canUseTelemetryFeature() => true;
  static String get backendPolicyMessage => 'تم تفعيل مزايا الاتصال بالخادم.';
  static String get paymentsPolicyMessage => 'المدفوعات مفعّلة حسب السياسة.';
  static String get telemetryPolicyMessage => 'التليمترية مفعّلة.';
}

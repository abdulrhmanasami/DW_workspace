/// In-App Hints Registry
/// Created by: Cursor B-ux
/// Purpose: Pre-defined hints for critical screens (Sale-Only compliant)
/// Last updated: 2025-11-25

import 'package:flutter/material.dart';

import 'in_app_hint.dart';

// ============================================================================
// Hint IDs
// ============================================================================

/// Standard hint IDs for the application.
abstract final class InAppHintIds {
  // Auth Screen Hints
  static const String authPhoneExplanation = 'hint_auth_phone';
  static const String authOtpExplanation = 'hint_auth_otp';
  static const String auth2faExplanation = 'hint_auth_2fa';
  static const String authBiometricExplanation = 'hint_auth_biometric';

  // Payments Screen Hints
  static const String paymentsMethodsExplanation = 'hint_payments_methods';
  static const String paymentsSecurityNote = 'hint_payments_security';
  static const String paymentsLimitedAvailability = 'hint_payments_limited';

  // Tracking Screen Hints
  static const String trackingExplanation = 'hint_tracking_explanation';
  static const String trackingUnavailable = 'hint_tracking_unavailable';
  static const String trackingRealtimeNote = 'hint_tracking_realtime';

  // Notifications Screen Hints
  static const String notificationsImportance = 'hint_notifications_importance';
  static const String notificationsPermission = 'hint_notifications_permission';

  // Orders Screen Hints
  static const String ordersFirstOrder = 'hint_orders_first';
  static const String ordersEmpty = 'hint_orders_empty';
}

/// Screen IDs for targeting hints.
abstract final class ScreenIds {
  static const String authPhone = 'screen_auth_phone';
  static const String authOtp = 'screen_auth_otp';
  static const String auth2fa = 'screen_auth_2fa';
  static const String authBiometric = 'screen_auth_biometric';
  static const String paymentMethods = 'screen_payment_methods';
  static const String addPaymentMethod = 'screen_add_payment_method';
  static const String orderTracking = 'screen_order_tracking';
  static const String notificationSettings = 'screen_notification_settings';
  static const String ordersHistory = 'screen_orders_history';
}

// ============================================================================
// Feature Flags for Hints
// ============================================================================

abstract final class HintFeatureFlags {
  static const String enableRealtimeTracking = 'ENABLE_REALTIME_TRACKING';
  static const String enablePayments = 'ENABLE_PAYMENTS';
  static const String enableNotifications = 'ENABLE_NOTIFICATIONS';
  static const String enable2fa = 'ENABLE_TWO_FACTOR_AUTH';
}

// ============================================================================
// Pre-defined Hints
// ============================================================================

/// Auth-related hints.
abstract final class AuthHints {
  /// Explains phone number authentication.
  static const phoneExplanation = InAppHint(
    id: InAppHintIds.authPhoneExplanation,
    titleKey: 'hint_auth_phone_title',
    bodyKey: 'hint_auth_phone_body',
    placement: InAppHintPlacement.topBanner,
    category: InAppHintCategory.security,
    priority: InAppHintPriority.normal,
    trigger: InAppHintTrigger.firstVisit,
    icon: Icons.phone_android_rounded,
    targetScreenId: ScreenIds.authPhone,
    maxShowCount: 1,
  );

  /// Explains OTP verification.
  static const otpExplanation = InAppHint(
    id: InAppHintIds.authOtpExplanation,
    titleKey: 'hint_auth_otp_title',
    bodyKey: 'hint_auth_otp_body',
    placement: InAppHintPlacement.topBanner,
    category: InAppHintCategory.security,
    priority: InAppHintPriority.normal,
    trigger: InAppHintTrigger.firstVisit,
    icon: Icons.sms_rounded,
    targetScreenId: ScreenIds.authOtp,
    maxShowCount: 1,
  );

  /// Explains 2FA importance.
  static const twoFactorExplanation = InAppHint(
    id: InAppHintIds.auth2faExplanation,
    titleKey: 'hint_auth_2fa_title',
    bodyKey: 'hint_auth_2fa_body',
    placement: InAppHintPlacement.topBanner,
    category: InAppHintCategory.security,
    priority: InAppHintPriority.high,
    trigger: InAppHintTrigger.firstVisit,
    icon: Icons.security_rounded,
    targetScreenId: ScreenIds.auth2fa,
    featureFlagName: HintFeatureFlags.enable2fa,
    maxShowCount: 1,
  );

  /// Explains biometric authentication.
  static const biometricExplanation = InAppHint(
    id: InAppHintIds.authBiometricExplanation,
    titleKey: 'hint_auth_biometric_title',
    bodyKey: 'hint_auth_biometric_body',
    placement: InAppHintPlacement.inlineCard,
    category: InAppHintCategory.feature,
    priority: InAppHintPriority.normal,
    trigger: InAppHintTrigger.firstVisit,
    icon: Icons.fingerprint_rounded,
    targetScreenId: ScreenIds.authBiometric,
    maxShowCount: 1,
  );

  static const List<InAppHint> all = [
    phoneExplanation,
    otpExplanation,
    twoFactorExplanation,
    biometricExplanation,
  ];
}

/// Payment-related hints.
abstract final class PaymentHints {
  /// Explains payment methods.
  static const methodsExplanation = InAppHint(
    id: InAppHintIds.paymentsMethodsExplanation,
    titleKey: 'hint_payments_methods_title',
    bodyKey: 'hint_payments_methods_body',
    placement: InAppHintPlacement.topBanner,
    category: InAppHintCategory.feature,
    priority: InAppHintPriority.normal,
    trigger: InAppHintTrigger.firstVisit,
    icon: Icons.credit_card_rounded,
    targetScreenId: ScreenIds.paymentMethods,
    featureFlagName: HintFeatureFlags.enablePayments,
    showOnlyIfBackendAvailable: true, // Sale-Only: only show if payments work
    maxShowCount: 1,
  );

  /// Security note for payment entry.
  static const securityNote = InAppHint(
    id: InAppHintIds.paymentsSecurityNote,
    titleKey: 'hint_payments_security_title',
    bodyKey: 'hint_payments_security_body',
    placement: InAppHintPlacement.inlineCard,
    category: InAppHintCategory.security,
    priority: InAppHintPriority.high,
    trigger: InAppHintTrigger.firstVisit,
    icon: Icons.lock_rounded,
    targetScreenId: ScreenIds.addPaymentMethod,
    featureFlagName: HintFeatureFlags.enablePayments,
    showOnlyIfBackendAvailable: true,
    maxShowCount: 2,
  );

  /// Warning about limited payment availability.
  /// Shown when payments are partially available (Sale-Only compliant).
  static const limitedAvailability = InAppHint(
    id: InAppHintIds.paymentsLimitedAvailability,
    titleKey: 'hint_payments_limited_title',
    bodyKey: 'hint_payments_limited_body',
    placement: InAppHintPlacement.topBanner,
    category: InAppHintCategory.warning,
    priority: InAppHintPriority.high,
    trigger: InAppHintTrigger.conditional,
    icon: Icons.info_outline_rounded,
    targetScreenId: ScreenIds.paymentMethods,
    dismissible: true,
    maxShowCount: 3,
  );

  static const List<InAppHint> all = [
    methodsExplanation,
    securityNote,
    limitedAvailability,
  ];
}

/// Tracking-related hints.
abstract final class TrackingHints {
  /// Explains order tracking feature.
  static const explanation = InAppHint(
    id: InAppHintIds.trackingExplanation,
    titleKey: 'hint_tracking_explanation_title',
    bodyKey: 'hint_tracking_explanation_body',
    placement: InAppHintPlacement.topBanner,
    category: InAppHintCategory.feature,
    priority: InAppHintPriority.normal,
    trigger: InAppHintTrigger.firstVisit,
    icon: Icons.location_on_rounded,
    targetScreenId: ScreenIds.orderTracking,
    featureFlagName: HintFeatureFlags.enableRealtimeTracking,
    showOnlyIfBackendAvailable: true, // Sale-Only: only if tracking works
    maxShowCount: 1,
  );

  /// Shown when tracking is unavailable (Sale-Only).
  static const unavailable = InAppHint(
    id: InAppHintIds.trackingUnavailable,
    titleKey: 'hint_tracking_unavailable_title',
    bodyKey: 'hint_tracking_unavailable_body',
    placement: InAppHintPlacement.inlineCard,
    category: InAppHintCategory.warning,
    priority: InAppHintPriority.high,
    trigger: InAppHintTrigger.conditional,
    icon: Icons.location_off_rounded,
    targetScreenId: ScreenIds.orderTracking,
    // No feature flag - always available when tracking is off
    showOnlyIfBackendAvailable: false,
    dismissible: true,
    maxShowCount: 0, // Show every time when triggered
  );

  /// Note about real-time nature of tracking.
  static const realtimeNote = InAppHint(
    id: InAppHintIds.trackingRealtimeNote,
    titleKey: 'hint_tracking_realtime_title',
    bodyKey: 'hint_tracking_realtime_body',
    placement: InAppHintPlacement.tooltip,
    category: InAppHintCategory.tip,
    priority: InAppHintPriority.low,
    trigger: InAppHintTrigger.firstVisit,
    icon: Icons.update_rounded,
    targetScreenId: ScreenIds.orderTracking,
    targetElementId: 'tracking_map',
    featureFlagName: HintFeatureFlags.enableRealtimeTracking,
    showOnlyIfBackendAvailable: true,
    maxShowCount: 1,
  );

  static const List<InAppHint> all = [
    explanation,
    unavailable,
    realtimeNote,
  ];
}

/// Notification-related hints.
abstract final class NotificationHints {
  /// Explains importance of notifications.
  static const importance = InAppHint(
    id: InAppHintIds.notificationsImportance,
    titleKey: 'hint_notifications_importance_title',
    bodyKey: 'hint_notifications_importance_body',
    placement: InAppHintPlacement.topBanner,
    category: InAppHintCategory.feature,
    priority: InAppHintPriority.normal,
    trigger: InAppHintTrigger.firstVisit,
    icon: Icons.notifications_active_rounded,
    targetScreenId: ScreenIds.notificationSettings,
    featureFlagName: HintFeatureFlags.enableNotifications,
    maxShowCount: 1,
  );

  /// Prompts for notification permission.
  static const permissionPrompt = InAppHint(
    id: InAppHintIds.notificationsPermission,
    titleKey: 'hint_notifications_permission_title',
    bodyKey: 'hint_notifications_permission_body',
    placement: InAppHintPlacement.inlineCard,
    category: InAppHintCategory.permission,
    priority: InAppHintPriority.high,
    trigger: InAppHintTrigger.conditional,
    primaryCtaKey: 'hint_notifications_permission_cta',
    icon: Icons.notifications_none_rounded,
    targetScreenId: ScreenIds.notificationSettings,
    featureFlagName: HintFeatureFlags.enableNotifications,
    dismissible: true,
    maxShowCount: 3,
  );

  static const List<InAppHint> all = [
    importance,
    permissionPrompt,
  ];
}

/// Orders-related hints.
abstract final class OrderHints {
  /// Hint for first order.
  static const firstOrder = InAppHint(
    id: InAppHintIds.ordersFirstOrder,
    titleKey: 'hint_orders_first_title',
    bodyKey: 'hint_orders_first_body',
    placement: InAppHintPlacement.inlineCard,
    category: InAppHintCategory.tip,
    priority: InAppHintPriority.normal,
    trigger: InAppHintTrigger.conditional,
    icon: Icons.shopping_bag_rounded,
    targetScreenId: ScreenIds.ordersHistory,
    maxShowCount: 1,
  );

  /// Empty state hint for no orders.
  static const emptyState = InAppHint(
    id: InAppHintIds.ordersEmpty,
    titleKey: 'hint_orders_empty_title',
    bodyKey: 'hint_orders_empty_body',
    placement: InAppHintPlacement.inlineCard,
    category: InAppHintCategory.tip,
    priority: InAppHintPriority.low,
    trigger: InAppHintTrigger.conditional,
    primaryCtaKey: 'hint_orders_empty_cta',
    icon: Icons.add_shopping_cart_rounded,
    targetScreenId: ScreenIds.ordersHistory,
    maxShowCount: 0, // Show every time when orders are empty
  );

  static const List<InAppHint> all = [
    firstOrder,
    emptyState,
  ];
}

// ============================================================================
// Hints Registry
// ============================================================================

/// Registry of all pre-defined hints.
class InAppHintsRegistry {
  const InAppHintsRegistry._();

  /// All registered hints.
  static final Map<String, InAppHint> _hints = {
    for (final hint in AuthHints.all) hint.id: hint,
    for (final hint in PaymentHints.all) hint.id: hint,
    for (final hint in TrackingHints.all) hint.id: hint,
    for (final hint in NotificationHints.all) hint.id: hint,
    for (final hint in OrderHints.all) hint.id: hint,
  };

  /// Gets a hint by ID.
  static InAppHint? getHint(String hintId) => _hints[hintId];

  /// Gets all hints for a specific screen.
  static List<InAppHint> getHintsForScreen(String screenId) {
    return _hints.values
        .where((hint) => hint.targetScreenId == screenId)
        .toList()
      ..sort((a, b) => a.priority.index.compareTo(b.priority.index));
  }

  /// Gets all hints of a specific category.
  static List<InAppHint> getHintsByCategory(InAppHintCategory category) {
    return _hints.values.where((hint) => hint.category == category).toList();
  }

  /// All hint IDs.
  static List<String> get allHintIds => _hints.keys.toList();

  /// All hints.
  static List<InAppHint> get allHints => _hints.values.toList();

  /// Hints requiring backend availability (Sale-Only relevant).
  static List<InAppHint> get backendDependentHints {
    return _hints.values
        .where((hint) => hint.showOnlyIfBackendAvailable)
        .toList();
  }
}


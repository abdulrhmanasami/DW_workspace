/// Onboarding Feature Flags Bridge
/// Created by: Cursor B-central
/// Purpose: Connect app FeatureFlags to B-ux onboarding feature flags
/// Last updated: 2025-11-26

import 'package:b_ux/onboarding_ux.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/feature_flags.dart';

// ============================================================================
// Feature Flags Bridge Provider
// ============================================================================

/// Provider that bridges app FeatureFlags to B-ux onboarding feature flags.
/// This maps the app's feature flag system to the format expected by B-ux.
final onboardingFeatureFlagsBridgeProvider = Provider<Map<String, bool>>((ref) {
  // Check env var for notifications (matches UX-004 implementation)
  const notificationsEnabled = String.fromEnvironment(
    'ENABLE_NOTIFICATIONS',
    defaultValue: 'true',
  ) != 'false';

  return {
    OnboardingFeatureFlags.enablePasswordlessAuth: FeatureFlags.enablePasswordlessAuth,
    OnboardingFeatureFlags.enableTwoFactorAuth: FeatureFlags.enableTwoFactorAuth,
    OnboardingFeatureFlags.enableRealtimeTracking: FeatureFlags.enableRealtimeTracking,
    OnboardingFeatureFlags.enableNotifications: notificationsEnabled,
    OnboardingFeatureFlags.enablePayments: FeatureFlags.paymentsEnabled,
    OnboardingFeatureFlags.enableBiometricAuth: FeatureFlags.enableBiometricAuth,
  };
});

/// Provider for checking if product onboarding is enabled.
final enableProductOnboardingProvider = Provider<bool>((ref) {
  // Default to true - onboarding should be shown unless explicitly disabled
  const envValue = String.fromEnvironment(
    'ENABLE_PRODUCT_ONBOARDING',
    defaultValue: 'true',
  );
  return envValue.toLowerCase() != 'false';
});

/// Provider that returns the customer onboarding flow with visible steps
/// based on current feature flags.
final visibleCustomerOnboardingFlowProvider = Provider<OnboardingFlow?>((ref) {
  final flow = OnboardingFlowRegistry.getFlow(OnboardingFlowIds.customerV1);
  if (flow == null) return null;

  final flags = ref.watch(onboardingFeatureFlagsBridgeProvider);
  final visibleSteps = flow.getVisibleSteps(flags);

  return flow.copyWith(steps: visibleSteps);
});

/// Provider for checking if a specific onboarding step should be visible.
final isOnboardingStepVisibleProvider =
    Provider.family<bool, String>((ref, stepId) {
  final flags = ref.watch(onboardingFeatureFlagsBridgeProvider);
  final flow = OnboardingFlowRegistry.getFlow(OnboardingFlowIds.customerV1);

  if (flow == null) return false;

  final step = flow.steps.where((s) => s.id == stepId).firstOrNull;
  if (step == null) return false;

  return step.isVisibleWithFlags(flags);
});


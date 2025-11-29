/// Onboarding Flows Configuration
/// Created by: Cursor B-ux
/// Purpose: Default onboarding flows for Customer/Rider, Sale-Only compliant
/// Last updated: 2025-11-25

import 'package:flutter/material.dart';

import 'onboarding_models.dart';

// ============================================================================
// Feature Flag Names (for Sale-Only compliance)
// ============================================================================

/// Known feature flags that affect onboarding content.
abstract final class OnboardingFeatureFlags {
  static const String enablePasswordlessAuth = 'ENABLE_PASSWORDLESS_AUTH';
  static const String enableTwoFactorAuth = 'ENABLE_TWO_FACTOR_AUTH';
  static const String enableRealtimeTracking = 'ENABLE_REALTIME_TRACKING';
  static const String enableNotifications = 'ENABLE_NOTIFICATIONS';
  static const String enablePayments = 'ENABLE_PAYMENTS';
  static const String enableBiometricAuth = 'ENABLE_BIOMETRIC_AUTH';

  /// All feature flags used in onboarding.
  static const List<String> all = [
    enablePasswordlessAuth,
    enableTwoFactorAuth,
    enableRealtimeTracking,
    enableNotifications,
    enablePayments,
    enableBiometricAuth,
  ];
}

// ============================================================================
// Step IDs
// ============================================================================

/// Standard step IDs for onboarding.
abstract final class OnboardingStepIds {
  // Welcome & Introduction
  static const String welcome = 'onb_welcome';
  static const String appIntro = 'onb_app_intro';

  // Super-App Value Props (Ride / Parcels / Food)
  static const String ride = 'onb_ride';
  static const String parcels = 'onb_parcels';
  static const String food = 'onb_food';

  // Features
  static const String ordering = 'onb_ordering';
  static const String tracking = 'onb_tracking';
  static const String payments = 'onb_payments';

  // Security & Privacy
  static const String security = 'onb_security';
  static const String privacy = 'onb_privacy';

  // Permissions & Setup
  static const String notifications = 'onb_notifications';
  static const String location = 'onb_location';

  // Completion
  static const String ready = 'onb_ready';
}

// ============================================================================
// Flow IDs
// ============================================================================

/// Standard flow IDs.
abstract final class OnboardingFlowIds {
  static const String customerV1 = 'customer_v1';
  static const String riderV1 = 'rider_v1';
}

// ============================================================================
// Default Customer Onboarding Flow
// ============================================================================

/// Default onboarding flow for customers.
/// Three-screen flow showcasing the Super-App value props: Ride, Parcels, Food.
/// All text uses conditional language for Sale-Only compliance.
const OnboardingFlow customerOnboardingFlowV1 = OnboardingFlow(
  id: OnboardingFlowIds.customerV1,
  version: 2, // Bumped version for new 3-screen flow
  audience: OnboardingAudience.newUser,
  steps: [
    // Step 1: Ride - Get a Ride, Instantly
    OnboardingStep(
      id: OnboardingStepIds.ride,
      type: OnboardingStepType.featureHighlight,
      titleKey: 'onb_ride_title',
      bodyKey: 'onb_ride_body',
      icon: Icons.directions_car_filled,
      primaryCtaKey: 'onb_cta_next',
      illustrationAsset: 'assets/onboarding/ride.svg',
      conditionallyVisible: false, // Always show
    ),

    // Step 2: Parcels - Deliver Anything, Effortlessly
    OnboardingStep(
      id: OnboardingStepIds.parcels,
      type: OnboardingStepType.featureHighlight,
      titleKey: 'onb_parcels_title',
      bodyKey: 'onb_parcels_body',
      icon: Icons.inventory_2_outlined,
      primaryCtaKey: 'onb_cta_next',
      illustrationAsset: 'assets/onboarding/parcels.svg',
      conditionallyVisible: false, // Always show
    ),

    // Step 3: Food - Your Favorite Food, Delivered
    OnboardingStep(
      id: OnboardingStepIds.food,
      type: OnboardingStepType.featureHighlight,
      titleKey: 'onb_food_title',
      bodyKey: 'onb_food_body',
      icon: Icons.fastfood_outlined,
      primaryCtaKey: 'onb_cta_get_started',
      illustrationAsset: 'assets/onboarding/food.svg',
      conditionallyVisible: false, // Always show
    ),
  ],
);

// ============================================================================
// Default Rider Onboarding Flow
// ============================================================================

/// Default onboarding flow for riders/couriers.
const OnboardingFlow riderOnboardingFlowV1 = OnboardingFlow(
  id: OnboardingFlowIds.riderV1,
  version: 1,
  audience: OnboardingAudience.newUser,
  steps: [
    // Step 1: Welcome
    OnboardingStep(
      id: OnboardingStepIds.welcome,
      type: OnboardingStepType.info,
      titleKey: 'onb_rider_welcome_title',
      bodyKey: 'onb_rider_welcome_body',
      icon: Icons.waving_hand_rounded,
      primaryCtaKey: 'onb_cta_get_started',
      illustrationAsset: 'assets/onboarding/rider_welcome.svg',
      conditionallyVisible: false,
    ),

    // Step 2: How It Works
    OnboardingStep(
      id: OnboardingStepIds.appIntro,
      type: OnboardingStepType.info,
      titleKey: 'onb_rider_how_it_works_title',
      bodyKey: 'onb_rider_how_it_works_body',
      icon: Icons.electric_bike_rounded,
      primaryCtaKey: 'onb_cta_next',
      illustrationAsset: 'assets/onboarding/rider_delivery.svg',
      conditionallyVisible: false,
    ),

    // Step 3: Location Permission
    OnboardingStep(
      id: OnboardingStepIds.location,
      type: OnboardingStepType.permission,
      titleKey: 'onb_rider_location_title',
      bodyKey: 'onb_rider_location_body',
      icon: Icons.my_location_rounded,
      primaryCtaKey: 'onb_cta_enable_location',
      secondaryCtaKey: 'onb_cta_skip',
      illustrationAsset: 'assets/onboarding/location.svg',
      conditionallyVisible: false,
      skipIfConditionMet: 'hasLocationPermission',
    ),

    // Step 4: Security
    OnboardingStep(
      id: OnboardingStepIds.security,
      type: OnboardingStepType.privacySecurity,
      titleKey: 'onb_rider_security_title',
      bodyKey: 'onb_rider_security_body',
      icon: Icons.verified_user_rounded,
      primaryCtaKey: 'onb_cta_next',
      illustrationAsset: 'assets/onboarding/rider_security.svg',
      conditionallyVisible: false,
    ),

    // Step 5: Notifications
    OnboardingStep(
      id: OnboardingStepIds.notifications,
      type: OnboardingStepType.permission,
      titleKey: 'onb_rider_notifications_title',
      bodyKey: 'onb_rider_notifications_body',
      icon: Icons.notifications_active_rounded,
      primaryCtaKey: 'onb_cta_enable_notifications',
      secondaryCtaKey: 'onb_cta_skip',
      illustrationAsset: 'assets/onboarding/notifications.svg',
      featureFlagName: OnboardingFeatureFlags.enableNotifications,
      conditionallyVisible: true,
      skipIfConditionMet: 'hasNotificationPermission',
    ),

    // Step 6: Ready
    OnboardingStep(
      id: OnboardingStepIds.ready,
      type: OnboardingStepType.action,
      titleKey: 'onb_rider_ready_title',
      bodyKey: 'onb_rider_ready_body',
      icon: Icons.check_circle_rounded,
      primaryCtaKey: 'onb_cta_start_delivering',
      illustrationAsset: 'assets/onboarding/rider_ready.svg',
      conditionallyVisible: false,
    ),
  ],
);

// ============================================================================
// Flow Registry
// ============================================================================

/// Registry of all available onboarding flows.
class OnboardingFlowRegistry {
  const OnboardingFlowRegistry._();

  /// All registered flows.
  static const Map<String, OnboardingFlow> flows = {
    OnboardingFlowIds.customerV1: customerOnboardingFlowV1,
    OnboardingFlowIds.riderV1: riderOnboardingFlowV1,
  };

  /// Gets a flow by ID.
  static OnboardingFlow? getFlow(String flowId) => flows[flowId];

  /// Gets the appropriate flow for a given audience.
  static OnboardingFlow? getFlowForAudience(OnboardingAudience audience) {
    for (final flow in flows.values) {
      if (flow.audience == audience) return flow;
    }
    return null;
  }

  /// Gets all flow IDs.
  static List<String> get allFlowIds => flows.keys.toList();

  /// Default flow for new customers.
  static const OnboardingFlow defaultCustomerFlow = customerOnboardingFlowV1;

  /// Default flow for new riders.
  static const OnboardingFlow defaultRiderFlow = riderOnboardingFlowV1;
}


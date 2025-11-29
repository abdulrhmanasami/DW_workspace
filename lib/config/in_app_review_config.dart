/// Configuration for In-App Review feature
/// Component|Service|Provider: InAppReviewConfig
/// Created by: Cursor (auto-generated)
/// Purpose: Configuration management for in-app review prompts
/// Last updated: 2025-11-08

import 'package:flutter/foundation.dart';

/// Configuration class for In-App Review feature flags and settings
class InAppReviewConfig {
  /// Feature flag to enable/disable in-app review prompts
  /// Default: false (disabled for safety)
  static const String inAppReviewEnabledKey = 'INAPPREVIEW_ENABLED';
  static bool get isInAppReviewEnabled {
    const value = String.fromEnvironment(
      inAppReviewEnabledKey,
      defaultValue: 'false',
    );
    return value.toLowerCase() == 'true';
  }

  /// Minimum number of successful sessions before showing review prompt
  /// Variant A: 2 sessions (more aggressive)
  static const int variantAThreshold = 2;

  /// Minimum number of successful sessions before showing review prompt
  /// Variant B: 4 sessions (more conservative)
  static const int variantBThreshold = 4;

  /// Cooldown period between review prompts (in days)
  static const int cooldownDays = 90;

  /// Maximum number of review prompts per user lifetime
  static const int maxPromptsPerUser = 3;

  /// Whether the platform supports in-app reviews
  static bool get isPlatformSupported {
    // iOS and Android support in-app reviews
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
  }

  /// Check if in-app review is fully enabled and supported
  static bool get isFeatureAvailable {
    return isInAppReviewEnabled && isPlatformSupported;
  }

  /// Get session threshold based on A/B test variant
  static int getSessionThresholdForVariant(String variant) {
    switch (variant) {
      case 'A':
        return variantAThreshold;
      case 'B':
        return variantBThreshold;
      default:
        return variantAThreshold; // Default to more aggressive
    }
  }
}

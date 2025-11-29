/// Onboarding UX Models
/// Created by: Cursor B-ux
/// Purpose: Domain models for product onboarding flow (Sale-Only compliant)
/// Last updated: 2025-11-25

import 'package:flutter/material.dart';

// ============================================================================
// Enums
// ============================================================================

/// Target audience for the onboarding flow.
enum OnboardingAudience {
  /// First-time user who has never completed onboarding.
  newUser,

  /// Returning user seeing onboarding after app update.
  returningUser,

  /// User re-watching onboarding from settings.
  manualReview,
}

/// Type of onboarding step.
enum OnboardingStepType {
  /// Informational step explaining a concept.
  info,

  /// Step requesting a system permission.
  permission,

  /// Step highlighting a specific feature.
  featureHighlight,

  /// Step explaining privacy/security.
  privacySecurity,

  /// Step with a call-to-action.
  action,
}

/// Position of the step in the flow.
enum OnboardingStepPosition {
  first,
  middle,
  last,
  only,
}

// ============================================================================
// Step Model
// ============================================================================

/// A single step in the onboarding flow.
@immutable
class OnboardingStep {
  const OnboardingStep({
    required this.id,
    required this.type,
    required this.titleKey,
    required this.bodyKey,
    required this.icon,
    this.primaryCtaKey,
    this.secondaryCtaKey,
    this.requiresBackendFeature = false,
    this.featureFlagName,
    this.illustrationAsset,
    this.lottieAsset,
    this.conditionallyVisible = true,
    this.skipIfConditionMet,
  });

  /// Unique identifier for this step (e.g., "onb_welcome", "onb_tracking").
  final String id;

  /// Type of this onboarding step.
  final OnboardingStepType type;

  /// Localization key for the step title.
  final String titleKey;

  /// Localization key for the step body text.
  final String bodyKey;

  /// Icon to display for this step.
  final IconData icon;

  /// Optional localization key for primary CTA button.
  final String? primaryCtaKey;

  /// Optional localization key for secondary CTA button.
  final String? secondaryCtaKey;

  /// Whether this step describes a feature that requires backend support.
  /// If true, the step text should be conditional/honest about availability.
  final bool requiresBackendFeature;

  /// Name of the feature flag that controls this feature (if applicable).
  /// Used for Sale-Only compliance - step may be hidden or text adjusted
  /// based on flag status.
  final String? featureFlagName;

  /// Optional asset path for illustration image.
  final String? illustrationAsset;

  /// Optional asset path for Lottie animation.
  final String? lottieAsset;

  /// Whether this step is conditionally visible based on feature flags.
  /// If false, step is always shown regardless of feature availability.
  final bool conditionallyVisible;

  /// Callback ID for a condition that, if met, skips this step.
  /// For example: "hasLocationPermission" to skip location request step.
  final String? skipIfConditionMet;

  /// Checks if this step should be visible given feature flag availability.
  bool isVisibleWithFlags(Map<String, bool> flags) {
    if (!conditionallyVisible) return true;
    if (featureFlagName == null) return true;
    return flags[featureFlagName] ?? false;
  }

  OnboardingStep copyWith({
    String? id,
    OnboardingStepType? type,
    String? titleKey,
    String? bodyKey,
    IconData? icon,
    String? primaryCtaKey,
    String? secondaryCtaKey,
    bool? requiresBackendFeature,
    String? featureFlagName,
    String? illustrationAsset,
    String? lottieAsset,
    bool? conditionallyVisible,
    String? skipIfConditionMet,
  }) {
    return OnboardingStep(
      id: id ?? this.id,
      type: type ?? this.type,
      titleKey: titleKey ?? this.titleKey,
      bodyKey: bodyKey ?? this.bodyKey,
      icon: icon ?? this.icon,
      primaryCtaKey: primaryCtaKey ?? this.primaryCtaKey,
      secondaryCtaKey: secondaryCtaKey ?? this.secondaryCtaKey,
      requiresBackendFeature:
          requiresBackendFeature ?? this.requiresBackendFeature,
      featureFlagName: featureFlagName ?? this.featureFlagName,
      illustrationAsset: illustrationAsset ?? this.illustrationAsset,
      lottieAsset: lottieAsset ?? this.lottieAsset,
      conditionallyVisible: conditionallyVisible ?? this.conditionallyVisible,
      skipIfConditionMet: skipIfConditionMet ?? this.skipIfConditionMet,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingStep &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'OnboardingStep($id, $type)';
}

// ============================================================================
// Flow Model
// ============================================================================

/// An onboarding flow containing multiple steps.
@immutable
class OnboardingFlow {
  const OnboardingFlow({
    required this.id,
    required this.version,
    required this.audience,
    required this.steps,
    this.minVersion,
    this.maxVersion,
  });

  /// Unique identifier for this flow (e.g., "customer_v1", "rider_v1").
  final String id;

  /// Version number of this flow (for change detection).
  final int version;

  /// Target audience for this flow.
  final OnboardingAudience audience;

  /// List of steps in this flow.
  final List<OnboardingStep> steps;

  /// Minimum app version that should show this flow.
  final String? minVersion;

  /// Maximum app version that should show this flow.
  final String? maxVersion;

  /// Returns steps filtered by feature flag availability.
  List<OnboardingStep> getVisibleSteps(Map<String, bool> flags) {
    return steps.where((step) => step.isVisibleWithFlags(flags)).toList();
  }

  /// Returns the step at given index, accounting for visibility filters.
  OnboardingStep? getStepAt(int index, Map<String, bool> flags) {
    final visible = getVisibleSteps(flags);
    if (index < 0 || index >= visible.length) return null;
    return visible[index];
  }

  /// Returns total visible step count.
  int visibleStepCount(Map<String, bool> flags) {
    return getVisibleSteps(flags).length;
  }

  /// Determines position of a step in the visible flow.
  OnboardingStepPosition getStepPosition(int index, Map<String, bool> flags) {
    final total = visibleStepCount(flags);
    if (total == 1) return OnboardingStepPosition.only;
    if (index == 0) return OnboardingStepPosition.first;
    if (index == total - 1) return OnboardingStepPosition.last;
    return OnboardingStepPosition.middle;
  }

  OnboardingFlow copyWith({
    String? id,
    int? version,
    OnboardingAudience? audience,
    List<OnboardingStep>? steps,
    String? minVersion,
    String? maxVersion,
  }) {
    return OnboardingFlow(
      id: id ?? this.id,
      version: version ?? this.version,
      audience: audience ?? this.audience,
      steps: steps ?? this.steps,
      minVersion: minVersion ?? this.minVersion,
      maxVersion: maxVersion ?? this.maxVersion,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingFlow &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          version == other.version;

  @override
  int get hashCode => Object.hash(id, version);

  @override
  String toString() => 'OnboardingFlow($id, v$version, ${steps.length} steps)';
}

// ============================================================================
// Completion State
// ============================================================================

/// State of onboarding completion for a user.
@immutable
class OnboardingCompletionState {
  const OnboardingCompletionState({
    required this.flowId,
    required this.completedVersion,
    required this.completedAt,
    this.skippedStepIds = const [],
  });

  const OnboardingCompletionState.notCompleted(this.flowId)
      : completedVersion = 0,
        completedAt = null,
        skippedStepIds = const [];

  /// ID of the flow this state refers to.
  final String flowId;

  /// Version of the flow that was completed.
  final int completedVersion;

  /// When the flow was completed.
  final DateTime? completedAt;

  /// IDs of steps that were skipped.
  final List<String> skippedStepIds;

  /// Whether the user has completed any version of this flow.
  bool get hasCompleted => completedVersion > 0 && completedAt != null;

  /// Whether the user needs to see a newer version of the flow.
  bool needsUpdate(int currentVersion) {
    return currentVersion > completedVersion;
  }

  OnboardingCompletionState copyWith({
    String? flowId,
    int? completedVersion,
    DateTime? completedAt,
    List<String>? skippedStepIds,
  }) {
    return OnboardingCompletionState(
      flowId: flowId ?? this.flowId,
      completedVersion: completedVersion ?? this.completedVersion,
      completedAt: completedAt ?? this.completedAt,
      skippedStepIds: skippedStepIds ?? this.skippedStepIds,
    );
  }

  @override
  String toString() =>
      'OnboardingCompletionState($flowId, v$completedVersion, completed: $hasCompleted)';
}

// ============================================================================
// Progress State
// ============================================================================

/// Current progress through an onboarding flow.
@immutable
class OnboardingProgress {
  const OnboardingProgress({
    required this.flowId,
    required this.currentStepIndex,
    required this.totalSteps,
    this.startedAt,
  });

  const OnboardingProgress.initial(String flowId)
      : flowId = flowId,
        currentStepIndex = 0,
        totalSteps = 0,
        startedAt = null;

  /// ID of the flow being progressed through.
  final String flowId;

  /// Current step index (0-based).
  final int currentStepIndex;

  /// Total number of visible steps.
  final int totalSteps;

  /// When the user started this flow.
  final DateTime? startedAt;

  /// Progress as a fraction (0.0 to 1.0).
  double get progressFraction {
    if (totalSteps <= 1) return currentStepIndex > 0 ? 1.0 : 0.0;
    return currentStepIndex / (totalSteps - 1);
  }

  /// Whether this is the first step.
  bool get isFirstStep => currentStepIndex == 0;

  /// Whether this is the last step.
  bool get isLastStep => currentStepIndex >= totalSteps - 1;

  /// Whether there is a next step.
  bool get hasNextStep => currentStepIndex < totalSteps - 1;

  /// Whether there is a previous step.
  bool get hasPreviousStep => currentStepIndex > 0;

  OnboardingProgress copyWith({
    String? flowId,
    int? currentStepIndex,
    int? totalSteps,
    DateTime? startedAt,
  }) {
    return OnboardingProgress(
      flowId: flowId ?? this.flowId,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      totalSteps: totalSteps ?? this.totalSteps,
      startedAt: startedAt ?? this.startedAt,
    );
  }

  @override
  String toString() =>
      'OnboardingProgress($flowId, step ${currentStepIndex + 1}/$totalSteps)';
}


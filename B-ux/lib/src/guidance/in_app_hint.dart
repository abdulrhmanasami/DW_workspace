/// In-App Guidance Models
/// Created by: Cursor B-ux
/// Purpose: Models for contextual hints, tooltips, and guidance banners
/// Last updated: 2025-11-25

import 'package:flutter/material.dart';

// ============================================================================
// Enums
// ============================================================================

/// Placement style for in-app hints.
enum InAppHintPlacement {
  /// Banner at top of screen.
  topBanner,

  /// Banner at bottom of screen.
  bottomBanner,

  /// Inline card within content.
  inlineCard,

  /// Floating tooltip near an element.
  tooltip,

  /// Modal overlay.
  modal,

  /// Snackbar-style notification.
  snackbar,
}

/// Priority level for hints.
enum InAppHintPriority {
  /// Critical - should be shown immediately.
  critical,

  /// High - show as soon as possible.
  high,

  /// Normal - show when appropriate.
  normal,

  /// Low - show only if no other hints.
  low,
}

/// Category of the hint.
enum InAppHintCategory {
  /// Feature explanation.
  feature,

  /// Permission request explanation.
  permission,

  /// Security/privacy information.
  security,

  /// Tip for better usage.
  tip,

  /// Warning about limitations.
  warning,

  /// Success/completion feedback.
  success,

  /// Error/issue explanation.
  error,
}

/// Trigger for showing a hint.
enum InAppHintTrigger {
  /// Show on first visit to screen.
  firstVisit,

  /// Show on every visit.
  everyVisit,

  /// Show after specific action.
  afterAction,

  /// Show when condition is met.
  conditional,

  /// Show manually (programmatically).
  manual,
}

// ============================================================================
// Hint Model
// ============================================================================

/// An in-app hint or guidance element.
@immutable
class InAppHint {
  const InAppHint({
    required this.id,
    required this.titleKey,
    required this.bodyKey,
    required this.placement,
    this.category = InAppHintCategory.tip,
    this.priority = InAppHintPriority.normal,
    this.trigger = InAppHintTrigger.firstVisit,
    this.dismissible = true,
    this.primaryCtaKey,
    this.secondaryCtaKey,
    this.icon,
    this.targetScreenId,
    this.targetElementId,
    this.featureFlagName,
    this.showOnlyIfBackendAvailable = false,
    this.maxShowCount = 1,
    this.expiresAt,
  });

  /// Unique identifier for this hint.
  final String id;

  /// Localization key for title.
  final String titleKey;

  /// Localization key for body text.
  final String bodyKey;

  /// How this hint should be displayed.
  final InAppHintPlacement placement;

  /// Category of hint content.
  final InAppHintCategory category;

  /// Display priority.
  final InAppHintPriority priority;

  /// When to trigger this hint.
  final InAppHintTrigger trigger;

  /// Whether user can dismiss this hint.
  final bool dismissible;

  /// Optional primary action button label key.
  final String? primaryCtaKey;

  /// Optional secondary action button label key.
  final String? secondaryCtaKey;

  /// Optional icon.
  final IconData? icon;

  /// ID of the screen where this hint should appear.
  final String? targetScreenId;

  /// ID of the element this hint targets (for tooltips).
  final String? targetElementId;

  /// Feature flag that must be enabled to show this hint.
  final String? featureFlagName;

  /// If true, only show when the related backend feature is available.
  /// Used for Sale-Only compliance.
  final bool showOnlyIfBackendAvailable;

  /// Maximum times to show this hint (0 = unlimited).
  final int maxShowCount;

  /// Optional expiration date for time-limited hints.
  final DateTime? expiresAt;

  /// Checks if hint is expired.
  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// Checks if hint should be shown given feature flags.
  bool shouldShow({
    required Map<String, bool> featureFlags,
    required int showCount,
    bool backendAvailable = false,
  }) {
    // Check expiration
    if (isExpired) return false;

    // Check max show count
    if (maxShowCount > 0 && showCount >= maxShowCount) return false;

    // Check feature flag
    if (featureFlagName != null) {
      if (!(featureFlags[featureFlagName] ?? false)) return false;
    }

    // Check backend availability for Sale-Only
    if (showOnlyIfBackendAvailable && !backendAvailable) return false;

    return true;
  }

  InAppHint copyWith({
    String? id,
    String? titleKey,
    String? bodyKey,
    InAppHintPlacement? placement,
    InAppHintCategory? category,
    InAppHintPriority? priority,
    InAppHintTrigger? trigger,
    bool? dismissible,
    String? primaryCtaKey,
    String? secondaryCtaKey,
    IconData? icon,
    String? targetScreenId,
    String? targetElementId,
    String? featureFlagName,
    bool? showOnlyIfBackendAvailable,
    int? maxShowCount,
    DateTime? expiresAt,
  }) {
    return InAppHint(
      id: id ?? this.id,
      titleKey: titleKey ?? this.titleKey,
      bodyKey: bodyKey ?? this.bodyKey,
      placement: placement ?? this.placement,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      trigger: trigger ?? this.trigger,
      dismissible: dismissible ?? this.dismissible,
      primaryCtaKey: primaryCtaKey ?? this.primaryCtaKey,
      secondaryCtaKey: secondaryCtaKey ?? this.secondaryCtaKey,
      icon: icon ?? this.icon,
      targetScreenId: targetScreenId ?? this.targetScreenId,
      targetElementId: targetElementId ?? this.targetElementId,
      featureFlagName: featureFlagName ?? this.featureFlagName,
      showOnlyIfBackendAvailable:
          showOnlyIfBackendAvailable ?? this.showOnlyIfBackendAvailable,
      maxShowCount: maxShowCount ?? this.maxShowCount,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InAppHint && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'InAppHint($id, $placement, $category)';
}

// ============================================================================
// Hint Display State
// ============================================================================

/// State tracking for a hint's display history.
@immutable
class InAppHintDisplayState {
  const InAppHintDisplayState({
    required this.hintId,
    required this.showCount,
    this.lastShownAt,
    this.dismissed = false,
    this.dismissedAt,
  });

  const InAppHintDisplayState.initial(this.hintId)
      : showCount = 0,
        lastShownAt = null,
        dismissed = false,
        dismissedAt = null;

  final String hintId;
  final int showCount;
  final DateTime? lastShownAt;
  final bool dismissed;
  final DateTime? dismissedAt;

  InAppHintDisplayState incrementShowCount() {
    return InAppHintDisplayState(
      hintId: hintId,
      showCount: showCount + 1,
      lastShownAt: DateTime.now(),
      dismissed: dismissed,
      dismissedAt: dismissedAt,
    );
  }

  InAppHintDisplayState markDismissed() {
    return InAppHintDisplayState(
      hintId: hintId,
      showCount: showCount,
      lastShownAt: lastShownAt,
      dismissed: true,
      dismissedAt: DateTime.now(),
    );
  }

  InAppHintDisplayState reset() {
    return InAppHintDisplayState.initial(hintId);
  }
}

// ============================================================================
// Hint Repository Contract
// ============================================================================

/// Repository for persisting hint display state.
abstract class InAppHintStateRepository {
  /// Gets display state for a hint.
  Future<InAppHintDisplayState> getDisplayState(String hintId);

  /// Saves display state.
  Future<void> saveDisplayState(InAppHintDisplayState state);

  /// Marks a hint as shown.
  Future<void> markShown(String hintId);

  /// Marks a hint as dismissed.
  Future<void> markDismissed(String hintId);

  /// Resets all hint states.
  Future<void> resetAll();

  /// Resets state for a specific hint.
  Future<void> resetHint(String hintId);
}

/// No-op implementation for when hints are disabled.
class NoOpInAppHintStateRepository implements InAppHintStateRepository {
  const NoOpInAppHintStateRepository();

  @override
  Future<InAppHintDisplayState> getDisplayState(String hintId) async {
    // Return state that prevents hints from showing
    return InAppHintDisplayState(
      hintId: hintId,
      showCount: 999,
      dismissed: true,
    );
  }

  @override
  Future<void> saveDisplayState(InAppHintDisplayState state) async {}

  @override
  Future<void> markShown(String hintId) async {}

  @override
  Future<void> markDismissed(String hintId) async {}

  @override
  Future<void> resetAll() async {}

  @override
  Future<void> resetHint(String hintId) async {}
}

/// In-memory implementation for testing.
class InMemoryInAppHintStateRepository implements InAppHintStateRepository {
  final Map<String, InAppHintDisplayState> _states = {};

  @override
  Future<InAppHintDisplayState> getDisplayState(String hintId) async {
    return _states[hintId] ?? InAppHintDisplayState.initial(hintId);
  }

  @override
  Future<void> saveDisplayState(InAppHintDisplayState state) async {
    _states[state.hintId] = state;
  }

  @override
  Future<void> markShown(String hintId) async {
    final current = _states[hintId] ?? InAppHintDisplayState.initial(hintId);
    _states[hintId] = current.incrementShowCount();
  }

  @override
  Future<void> markDismissed(String hintId) async {
    final current = _states[hintId] ?? InAppHintDisplayState.initial(hintId);
    _states[hintId] = current.markDismissed();
  }

  @override
  Future<void> resetAll() async {
    _states.clear();
  }

  @override
  Future<void> resetHint(String hintId) async {
    _states.remove(hintId);
  }
}


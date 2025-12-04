/// Onboarding State - Session-level gate state
/// Created by: Ticket #34 - Track D Onboarding Gate
/// Updated by: Ticket #238 - Track D-6 Onboarding Flow
/// Purpose: Manage onboarding completion state with persistent storage via shim
/// Last updated: 2025-12-04

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_shims/foundation_shims.dart';

/// Local provider that wraps the foundation_shims onboardingPrefsServiceProvider
final _onboardingPrefsServiceProvider = Provider<OnboardingPrefs>((ref) {
  // This will use the foundation_shims implementation
  return ref.watch(onboardingPrefsServiceProvider);
});

/// Immutable state for onboarding completion tracking.
///
/// Track D - Ticket #34: Session-level gate only.
/// Persistent storage will be implemented in a future ticket.
@immutable
class OnboardingState {
  const OnboardingState({
    this.hasCompletedOnboarding = false,
  });

  /// Whether the user has completed the onboarding flow in this session.
  final bool hasCompletedOnboarding;

  /// Create a copy with updated values.
  OnboardingState copyWith({
    bool? hasCompletedOnboarding,
  }) {
    return OnboardingState(
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OnboardingState &&
        other.hasCompletedOnboarding == hasCompletedOnboarding;
  }

  @override
  int get hashCode => hasCompletedOnboarding.hashCode;
}

/// Controller for managing onboarding state.
///
/// Track D - Ticket #238: Persistent storage via OnboardingPrefs shim.
/// Integrates with foundation_shims for cross-platform persistence.
class OnboardingController extends StateNotifier<OnboardingState> {
  OnboardingController(this._onboardingPrefs) : super(const OnboardingState()) {
    // Load initial state from persistent storage
    _loadFromStorage();
  }

  final OnboardingPrefs _onboardingPrefs;

  /// Mark onboarding as completed and persist to storage.
  ///
  /// Track D - Ticket #238: Uses OnboardingPrefs shim for persistence.
  Future<void> completeOnboarding() async {
    state = state.copyWith(hasCompletedOnboarding: true);
    await _onboardingPrefs.setCompletedOnboarding(true);
  }

  /// Load onboarding completion state from persistent storage.
  ///
  /// Track D - Ticket #238: Loads from OnboardingPrefs shim.
  Future<void> _loadFromStorage() async {
    final hasCompleted = await _onboardingPrefs.hasCompletedOnboarding();
    if (mounted) {
      state = state.copyWith(hasCompletedOnboarding: hasCompleted);
    }
  }
}

/// Provider for onboarding state management.
///
/// Track D - Ticket #238: Persistent storage via OnboardingPrefs shim.
final onboardingStateProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
  final onboardingPrefs = ref.watch(_onboardingPrefsServiceProvider);
  final controller = OnboardingController(onboardingPrefs);
  return controller;
});


/// Onboarding State - Session-level gate state
/// Created by: Ticket #34 - Track D Onboarding Gate
/// Purpose: Manage onboarding completion state for session-level gate
/// Last updated: 2025-11-28

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
/// Track D - Ticket #34: Session-level gate only.
/// Provides stubs for future persistent storage integration.
class OnboardingController extends StateNotifier<OnboardingState> {
  OnboardingController() : super(const OnboardingState());

  /// Mark onboarding as completed for this session.
  ///
  /// Track D - Ticket #34: Session-level gate only.
  void completeOnboarding() {
    state = state.copyWith(hasCompletedOnboarding: true);
  }

  /// Stub for future persistent loading.
  ///
  /// TODO(Ticket-XX): Load persisted value from storage shim.
  /// For now, we keep default (false) so first session always shows onboarding.
  Future<void> loadFromStorage() async {
    // TODO(Ticket-XX): Load persisted value from storage shim.
    // For now, we keep default (false) so first session always shows onboarding.
  }

  /// Stub for future persistent save.
  ///
  /// TODO(Ticket-XX): Persist completion flag using proper shim.
  Future<void> persistCompletionFlag() async {
    // TODO(Ticket-XX): Persist completion flag using proper shim.
  }
}

/// Provider for onboarding state management.
///
/// Track D - Ticket #34: Session-level gate only.
final onboardingStateProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
  final controller = OnboardingController();
  // Optionally trigger async load later when storage is wired.
  // unawaited(controller.loadFromStorage());
  return controller;
});


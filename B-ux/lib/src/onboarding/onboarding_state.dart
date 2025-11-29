/// Onboarding State Contracts
/// Created by: Cursor B-ux
/// Purpose: Repository contracts and state management for onboarding
/// Last updated: 2025-11-25

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'onboarding_models.dart';
import 'onboarding_flows.dart';

// ============================================================================
// Repository Contracts
// ============================================================================

/// Repository for persisting onboarding completion state.
/// Implementation should use SharedPreferences or SecureStorage.
abstract class OnboardingStateRepository {
  /// Checks if user has completed the given flow.
  Future<bool> hasCompletedFlow(String flowId);

  /// Marks a flow as completed with given version.
  Future<void> markFlowCompleted(String flowId, int version);

  /// Gets the last seen version of a flow.
  Future<int> getSeenVersion(String flowId);

  /// Sets the seen version for a flow.
  Future<void> setSeenVersion(String flowId, int version);

  /// Gets full completion state for a flow.
  Future<OnboardingCompletionState> getCompletionState(String flowId);

  /// Saves completion state.
  Future<void> saveCompletionState(OnboardingCompletionState state);

  /// Resets completion state for a flow (for re-watching).
  Future<void> resetFlow(String flowId);

  /// Resets all onboarding state.
  Future<void> resetAll();
}

// ============================================================================
// No-Op Repository (for disabled state)
// ============================================================================

/// No-op implementation that reports all flows as completed.
/// Used when onboarding feature is disabled.
class NoOpOnboardingStateRepository implements OnboardingStateRepository {
  const NoOpOnboardingStateRepository();

  @override
  Future<bool> hasCompletedFlow(String flowId) async => true;

  @override
  Future<void> markFlowCompleted(String flowId, int version) async {}

  @override
  Future<int> getSeenVersion(String flowId) async => 999;

  @override
  Future<void> setSeenVersion(String flowId, int version) async {}

  @override
  Future<OnboardingCompletionState> getCompletionState(String flowId) async {
    return OnboardingCompletionState(
      flowId: flowId,
      completedVersion: 999,
      completedAt: DateTime.now(),
    );
  }

  @override
  Future<void> saveCompletionState(OnboardingCompletionState state) async {}

  @override
  Future<void> resetFlow(String flowId) async {}

  @override
  Future<void> resetAll() async {}
}

// ============================================================================
// In-Memory Repository (for testing)
// ============================================================================

/// In-memory implementation for testing.
class InMemoryOnboardingStateRepository implements OnboardingStateRepository {
  final Map<String, OnboardingCompletionState> _states = {};

  @override
  Future<bool> hasCompletedFlow(String flowId) async {
    return _states[flowId]?.hasCompleted ?? false;
  }

  @override
  Future<void> markFlowCompleted(String flowId, int version) async {
    _states[flowId] = OnboardingCompletionState(
      flowId: flowId,
      completedVersion: version,
      completedAt: DateTime.now(),
    );
  }

  @override
  Future<int> getSeenVersion(String flowId) async {
    return _states[flowId]?.completedVersion ?? 0;
  }

  @override
  Future<void> setSeenVersion(String flowId, int version) async {
    final existing = _states[flowId];
    _states[flowId] = OnboardingCompletionState(
      flowId: flowId,
      completedVersion: version,
      completedAt: existing?.completedAt,
    );
  }

  @override
  Future<OnboardingCompletionState> getCompletionState(String flowId) async {
    return _states[flowId] ?? OnboardingCompletionState.notCompleted(flowId);
  }

  @override
  Future<void> saveCompletionState(OnboardingCompletionState state) async {
    _states[state.flowId] = state;
  }

  @override
  Future<void> resetFlow(String flowId) async {
    _states.remove(flowId);
  }

  @override
  Future<void> resetAll() async {
    _states.clear();
  }
}

// ============================================================================
// Providers
// ============================================================================

/// Provider for the onboarding state repository.
/// Should be overridden in app wiring with real implementation.
final onboardingStateRepositoryProvider =
    Provider<OnboardingStateRepository>((ref) {
  // Default to no-op; override in ProviderScope
  return const NoOpOnboardingStateRepository();
});

/// Provider for feature flags affecting onboarding.
/// Should be overridden to connect to real feature flag system.
final onboardingFeatureFlagsProvider = Provider<Map<String, bool>>((ref) {
  // Default: all features disabled (Sale-Only safe)
  return {
    OnboardingFeatureFlags.enablePasswordlessAuth: false,
    OnboardingFeatureFlags.enableTwoFactorAuth: false,
    OnboardingFeatureFlags.enableRealtimeTracking: false,
    OnboardingFeatureFlags.enableNotifications: false,
    OnboardingFeatureFlags.enablePayments: false,
    OnboardingFeatureFlags.enableBiometricAuth: false,
  };
});

/// Provider that determines if onboarding should be shown.
final shouldShowOnboardingProvider =
    FutureProvider.family<bool, String>((ref, flowId) async {
  final repository = ref.watch(onboardingStateRepositoryProvider);
  final flow = OnboardingFlowRegistry.getFlow(flowId);

  if (flow == null) return false;

  final state = await repository.getCompletionState(flowId);

  // Show onboarding if not completed or if there's a newer version
  return !state.hasCompleted || state.needsUpdate(flow.version);
});

/// Provider for checking specific flow completion.
final onboardingCompletionStateProvider =
    FutureProvider.family<OnboardingCompletionState, String>(
        (ref, flowId) async {
  final repository = ref.watch(onboardingStateRepositoryProvider);
  return repository.getCompletionState(flowId);
});

/// Provider for getting a flow with visible steps based on feature flags.
final visibleOnboardingFlowProvider =
    Provider.family<OnboardingFlow?, String>((ref, flowId) {
  final flow = OnboardingFlowRegistry.getFlow(flowId);
  if (flow == null) return null;

  final flags = ref.watch(onboardingFeatureFlagsProvider);
  final visibleSteps = flow.getVisibleSteps(flags);

  return flow.copyWith(steps: visibleSteps);
});

// ============================================================================
// Onboarding Controller
// ============================================================================

/// Controller for managing onboarding flow progression.
class OnboardingController extends StateNotifier<OnboardingProgress> {
  OnboardingController({
    required this.flow,
    required this.repository,
    required this.featureFlags,
  }) : super(OnboardingProgress.initial(flow.id)) {
    _initialize();
  }

  final OnboardingFlow flow;
  final OnboardingStateRepository repository;
  final Map<String, bool> featureFlags;

  void _initialize() {
    final visibleSteps = flow.getVisibleSteps(featureFlags);
    state = OnboardingProgress(
      flowId: flow.id,
      currentStepIndex: 0,
      totalSteps: visibleSteps.length,
      startedAt: DateTime.now(),
    );
  }

  /// Gets the current visible step.
  OnboardingStep? get currentStep {
    final visibleSteps = flow.getVisibleSteps(featureFlags);
    if (state.currentStepIndex >= visibleSteps.length) return null;
    return visibleSteps[state.currentStepIndex];
  }

  /// Moves to the next step.
  void next() {
    if (state.hasNextStep) {
      state = state.copyWith(currentStepIndex: state.currentStepIndex + 1);
    }
  }

  /// Moves to the previous step.
  void previous() {
    if (state.hasPreviousStep) {
      state = state.copyWith(currentStepIndex: state.currentStepIndex - 1);
    }
  }

  /// Skips the current step and moves to next.
  void skip() => next();

  /// Jumps to a specific step index.
  void goToStep(int index) {
    final visibleCount = flow.visibleStepCount(featureFlags);
    if (index >= 0 && index < visibleCount) {
      state = state.copyWith(currentStepIndex: index);
    }
  }

  /// Completes the onboarding flow.
  Future<void> complete() async {
    await repository.markFlowCompleted(flow.id, flow.version);
  }

  /// Resets progress to beginning.
  void reset() {
    _initialize();
  }
}

/// Provider for creating an onboarding controller.
final onboardingControllerProvider =
    StateNotifierProvider.family<OnboardingController, OnboardingProgress,
        String>((ref, flowId) {
  final flow = OnboardingFlowRegistry.getFlow(flowId);
  if (flow == null) {
    throw ArgumentError('Unknown onboarding flow: $flowId');
  }

  final repository = ref.watch(onboardingStateRepositoryProvider);
  final flags = ref.watch(onboardingFeatureFlagsProvider);

  return OnboardingController(
    flow: flow,
    repository: repository,
    featureFlags: flags,
  );
});


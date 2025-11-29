/// In-App Guidance Providers
/// Created by: Cursor B-ux
/// Purpose: Riverpod providers for in-app hints and guidance
/// Last updated: 2025-11-25

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'in_app_hint.dart';
import 'in_app_hints_registry.dart';

// ============================================================================
// Repository Provider
// ============================================================================

/// Provider for the hint state repository.
/// Should be overridden in app wiring with real implementation.
final inAppHintStateRepositoryProvider =
    Provider<InAppHintStateRepository>((ref) {
  // Default to no-op; override in ProviderScope
  return const NoOpInAppHintStateRepository();
});

// ============================================================================
// Feature Flags Provider
// ============================================================================

/// Provider for feature flags affecting hints.
/// Should be overridden to connect to real feature flag system.
final hintFeatureFlagsProvider = Provider<Map<String, bool>>((ref) {
  return {
    HintFeatureFlags.enableRealtimeTracking: false,
    HintFeatureFlags.enablePayments: false,
    HintFeatureFlags.enableNotifications: false,
    HintFeatureFlags.enable2fa: false,
  };
});

/// Provider for backend availability status per feature.
final backendAvailabilityProvider = Provider<Map<String, bool>>((ref) {
  // Default: all backends unavailable (Sale-Only safe)
  return {
    'tracking': false,
    'payments': false,
    'notifications': false,
  };
});

// ============================================================================
// Hint Visibility Providers
// ============================================================================

/// Provider that determines if a specific hint should be shown.
final shouldShowHintProvider =
    FutureProvider.family<bool, String>((ref, hintId) async {
  final hint = InAppHintsRegistry.getHint(hintId);
  if (hint == null) return false;

  final repository = ref.watch(inAppHintStateRepositoryProvider);
  final flags = ref.watch(hintFeatureFlagsProvider);
  final backendAvailability = ref.watch(backendAvailabilityProvider);

  final displayState = await repository.getDisplayState(hintId);

  // Check if already dismissed
  if (displayState.dismissed) return false;

  // Determine backend availability for this hint
  bool backendAvailable = true;
  if (hint.showOnlyIfBackendAvailable) {
    // Map feature flag to backend availability
    if (hint.featureFlagName == HintFeatureFlags.enableRealtimeTracking) {
      backendAvailable = backendAvailability['tracking'] ?? false;
    } else if (hint.featureFlagName == HintFeatureFlags.enablePayments) {
      backendAvailable = backendAvailability['payments'] ?? false;
    } else if (hint.featureFlagName == HintFeatureFlags.enableNotifications) {
      backendAvailable = backendAvailability['notifications'] ?? false;
    }
  }

  return hint.shouldShow(
    featureFlags: flags,
    showCount: displayState.showCount,
    backendAvailable: backendAvailable,
  );
});

/// Provider for getting hints to show on a specific screen.
final hintsForScreenProvider =
    FutureProvider.family<List<InAppHint>, String>((ref, screenId) async {
  final hints = InAppHintsRegistry.getHintsForScreen(screenId);
  final visibleHints = <InAppHint>[];

  for (final hint in hints) {
    final shouldShow = await ref.watch(shouldShowHintProvider(hint.id).future);
    if (shouldShow) {
      visibleHints.add(hint);
    }
  }

  // Sort by priority
  visibleHints.sort((a, b) => a.priority.index.compareTo(b.priority.index));

  return visibleHints;
});

/// Provider for the highest priority hint on a screen.
final primaryHintForScreenProvider =
    FutureProvider.family<InAppHint?, String>((ref, screenId) async {
  final hints = await ref.watch(hintsForScreenProvider(screenId).future);
  return hints.isNotEmpty ? hints.first : null;
});

// ============================================================================
// Hint Actions Controller
// ============================================================================

/// Controller for hint display actions.
class InAppHintController extends StateNotifier<Set<String>> {
  InAppHintController(this._repository) : super({});

  final InAppHintStateRepository _repository;

  /// Marks a hint as shown.
  Future<void> markShown(String hintId) async {
    await _repository.markShown(hintId);
    state = {...state, hintId};
  }

  /// Dismisses a hint.
  Future<void> dismiss(String hintId) async {
    await _repository.markDismissed(hintId);
    state = {...state, hintId};
  }

  /// Resets a specific hint.
  Future<void> resetHint(String hintId) async {
    await _repository.resetHint(hintId);
    state = Set.from(state)..remove(hintId);
  }

  /// Resets all hints.
  Future<void> resetAll() async {
    await _repository.resetAll();
    state = {};
  }

  /// Checks if a hint has been interacted with in this session.
  bool hasInteracted(String hintId) => state.contains(hintId);
}

/// Provider for hint controller.
final inAppHintControllerProvider =
    StateNotifierProvider<InAppHintController, Set<String>>((ref) {
  final repository = ref.watch(inAppHintStateRepositoryProvider);
  return InAppHintController(repository);
});

// ============================================================================
// Convenience Providers
// ============================================================================

/// Provider that returns true if any hints are pending for a screen.
final hasHintsForScreenProvider =
    FutureProvider.family<bool, String>((ref, screenId) async {
  final hints = await ref.watch(hintsForScreenProvider(screenId).future);
  return hints.isNotEmpty;
});

/// Provider for hint display state.
final hintDisplayStateProvider =
    FutureProvider.family<InAppHintDisplayState, String>((ref, hintId) async {
  final repository = ref.watch(inAppHintStateRepositoryProvider);
  return repository.getDisplayState(hintId);
});


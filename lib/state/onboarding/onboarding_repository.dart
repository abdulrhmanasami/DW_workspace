/// Onboarding Repository Implementation
/// Created by: Cursor B-central
/// Purpose: SharedPreferences-based onboarding state persistence
/// Last updated: 2025-11-26

import 'package:b_ux/onboarding_ux.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foundation_shims/foundation_shims.dart' show onboardingPrefsServiceProvider;

// ============================================================================
// SharedPreferences Keys
// ============================================================================

/// Key prefixes for onboarding storage.
abstract final class OnboardingStorageKeys {
  static const String _prefix = 'onboarding_';

  static String flowCompleted(String flowId) => '${_prefix}flow_${flowId}_completed';
  static String flowVersion(String flowId) => '${_prefix}flow_${flowId}_version';
  static String flowCompletedAt(String flowId) => '${_prefix}flow_${flowId}_completed_at';
  static String flowSkippedSteps(String flowId) => '${_prefix}flow_${flowId}_skipped';
}

// ============================================================================
// SharedPreferences Implementation
// ============================================================================

/// SharedPreferences-based implementation of OnboardingStateRepository.
class SharedPreferencesOnboardingRepository implements OnboardingStateRepository {
  SharedPreferencesOnboardingRepository(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<bool> hasCompletedFlow(String flowId) async {
    return _prefs.getBool(OnboardingStorageKeys.flowCompleted(flowId)) ?? false;
  }

  @override
  Future<void> markFlowCompleted(String flowId, int version) async {
    await _prefs.setBool(OnboardingStorageKeys.flowCompleted(flowId), true);
    await _prefs.setInt(OnboardingStorageKeys.flowVersion(flowId), version);
    await _prefs.setString(
      OnboardingStorageKeys.flowCompletedAt(flowId),
      DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<int> getSeenVersion(String flowId) async {
    return _prefs.getInt(OnboardingStorageKeys.flowVersion(flowId)) ?? 0;
  }

  @override
  Future<void> setSeenVersion(String flowId, int version) async {
    await _prefs.setInt(OnboardingStorageKeys.flowVersion(flowId), version);
  }

  @override
  Future<OnboardingCompletionState> getCompletionState(String flowId) async {
    final completed = _prefs.getBool(OnboardingStorageKeys.flowCompleted(flowId)) ?? false;
    final version = _prefs.getInt(OnboardingStorageKeys.flowVersion(flowId)) ?? 0;
    final completedAtStr = _prefs.getString(OnboardingStorageKeys.flowCompletedAt(flowId));
    final skippedSteps = _prefs.getStringList(OnboardingStorageKeys.flowSkippedSteps(flowId)) ?? [];

    if (!completed) {
      return OnboardingCompletionState.notCompleted(flowId);
    }

    return OnboardingCompletionState(
      flowId: flowId,
      completedVersion: version,
      completedAt: completedAtStr != null ? DateTime.tryParse(completedAtStr) : null,
      skippedStepIds: skippedSteps,
    );
  }

  @override
  Future<void> saveCompletionState(OnboardingCompletionState state) async {
    await _prefs.setBool(
      OnboardingStorageKeys.flowCompleted(state.flowId),
      state.hasCompleted,
    );
    await _prefs.setInt(
      OnboardingStorageKeys.flowVersion(state.flowId),
      state.completedVersion,
    );
    if (state.completedAt != null) {
      await _prefs.setString(
        OnboardingStorageKeys.flowCompletedAt(state.flowId),
        state.completedAt!.toIso8601String(),
      );
    }
    await _prefs.setStringList(
      OnboardingStorageKeys.flowSkippedSteps(state.flowId),
      state.skippedStepIds,
    );
  }

  @override
  Future<void> resetFlow(String flowId) async {
    await _prefs.remove(OnboardingStorageKeys.flowCompleted(flowId));
    await _prefs.remove(OnboardingStorageKeys.flowVersion(flowId));
    await _prefs.remove(OnboardingStorageKeys.flowCompletedAt(flowId));
    await _prefs.remove(OnboardingStorageKeys.flowSkippedSteps(flowId));
  }

  @override
  Future<void> resetAll() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith('onboarding_'));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
}

// ============================================================================
// Providers
// ============================================================================

/// Provider for SharedPreferences instance.
/// This should be initialized in main() before runApp.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'SharedPreferences must be initialized before use. '
    'Override this provider in ProviderScope with the actual SharedPreferences instance.',
  );
});

/// Provider for the onboarding repository.
final onboardingRepositoryProvider = Provider<OnboardingStateRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SharedPreferencesOnboardingRepository(prefs);
});

/// Provider for customer onboarding flow completion check.
final customerOnboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(onboardingRepositoryProvider);
  return repository.hasCompletedFlow(OnboardingFlowIds.customerV1);
});

/// Provider for customer onboarding completion state.
final customerOnboardingStateProvider =
    FutureProvider<OnboardingCompletionState>((ref) async {
  final repository = ref.watch(onboardingRepositoryProvider);
  return repository.getCompletionState(OnboardingFlowIds.customerV1);
});

/// Provider that determines if onboarding should be shown for customer.
/// Updated to use onboardingPrefsServiceProvider for compatibility.
final shouldShowCustomerOnboardingProvider = FutureProvider<bool>((ref) async {
  final onboardingPrefs = ref.watch(onboardingPrefsServiceProvider);
  final hasCompleted = await onboardingPrefs.hasCompletedOnboarding();
  
  // Show onboarding if not completed
  return !hasCompleted;
});


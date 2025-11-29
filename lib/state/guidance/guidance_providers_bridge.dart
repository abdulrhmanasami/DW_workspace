/// In-App Guidance Providers Bridge
/// Created by: Cursor B-central
/// Purpose: Bridge B-ux guidance providers with app feature flags and backend availability
/// Last updated: 2025-11-26

import 'package:b_ux/guidance_ux.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/feature_flags.dart';
import '../infra/mobility_availability.dart';
import '../onboarding/onboarding_repository.dart';

// ============================================================================
// SharedPreferences Hint Repository
// ============================================================================

/// SharedPreferences-based implementation of InAppHintStateRepository.
class SharedPreferencesHintRepository implements InAppHintStateRepository {
  SharedPreferencesHintRepository(this._prefs);

  final SharedPreferences _prefs;

  static const String _prefix = 'hint_';

  String _showCountKey(String hintId) => '${_prefix}${hintId}_show_count';
  String _lastShownKey(String hintId) => '${_prefix}${hintId}_last_shown';
  String _dismissedKey(String hintId) => '${_prefix}${hintId}_dismissed';
  String _dismissedAtKey(String hintId) => '${_prefix}${hintId}_dismissed_at';

  @override
  Future<InAppHintDisplayState> getDisplayState(String hintId) async {
    final showCount = _prefs.getInt(_showCountKey(hintId)) ?? 0;
    final lastShownStr = _prefs.getString(_lastShownKey(hintId));
    final dismissed = _prefs.getBool(_dismissedKey(hintId)) ?? false;
    final dismissedAtStr = _prefs.getString(_dismissedAtKey(hintId));

    return InAppHintDisplayState(
      hintId: hintId,
      showCount: showCount,
      lastShownAt: lastShownStr != null ? DateTime.tryParse(lastShownStr) : null,
      dismissed: dismissed,
      dismissedAt: dismissedAtStr != null ? DateTime.tryParse(dismissedAtStr) : null,
    );
  }

  @override
  Future<void> saveDisplayState(InAppHintDisplayState state) async {
    await _prefs.setInt(_showCountKey(state.hintId), state.showCount);
    if (state.lastShownAt != null) {
      await _prefs.setString(_lastShownKey(state.hintId), state.lastShownAt!.toIso8601String());
    }
    await _prefs.setBool(_dismissedKey(state.hintId), state.dismissed);
    if (state.dismissedAt != null) {
      await _prefs.setString(_dismissedAtKey(state.hintId), state.dismissedAt!.toIso8601String());
    }
  }

  @override
  Future<void> markShown(String hintId) async {
    final current = await getDisplayState(hintId);
    await saveDisplayState(current.incrementShowCount());
  }

  @override
  Future<void> markDismissed(String hintId) async {
    final current = await getDisplayState(hintId);
    await saveDisplayState(current.markDismissed());
  }

  @override
  Future<void> resetAll() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith(_prefix));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }

  @override
  Future<void> resetHint(String hintId) async {
    await _prefs.remove(_showCountKey(hintId));
    await _prefs.remove(_lastShownKey(hintId));
    await _prefs.remove(_dismissedKey(hintId));
    await _prefs.remove(_dismissedAtKey(hintId));
  }
}

// ============================================================================
// Repository Provider
// ============================================================================

/// Provider for the hint state repository.
final hintStateRepositoryProvider = Provider<InAppHintStateRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SharedPreferencesHintRepository(prefs);
});

// ============================================================================
// Feature Flags Bridge
// ============================================================================

/// Provider that checks if notifications are enabled.
final notificationsEnabledProvider = Provider<bool>((ref) {
  const notificationsEnabled = String.fromEnvironment(
    'ENABLE_NOTIFICATIONS',
    defaultValue: 'true',
  ) != 'false';
  return notificationsEnabled;
});

/// Provider that bridges app feature flags to hint feature flags.
final hintFeatureFlagsBridgeProvider = Provider<Map<String, bool>>((ref) {
  final notificationsEnabled = ref.watch(notificationsEnabledProvider);

  return {
    HintFeatureFlags.enableRealtimeTracking: FeatureFlags.enableRealtimeTracking,
    HintFeatureFlags.enablePayments: FeatureFlags.paymentsEnabled,
    HintFeatureFlags.enableNotifications: notificationsEnabled,
    HintFeatureFlags.enable2fa: FeatureFlags.enableTwoFactorAuth,
  };
});

/// Provider for tracking availability as AsyncValue.
final trackingAvailabilityProvider = FutureProvider<TrackingAvailabilityStatus>((ref) async {
  final service = ref.watch(mobilityAvailabilityServiceProvider);
  final availability = await service.getAvailability();
  return availability.trackingStatus;
});

/// Provider for backend availability per feature.
final backendAvailabilityBridgeProvider = Provider<Map<String, bool>>((ref) {
  // Check real backend availability from app providers
  final trackingAsync = ref.watch(trackingAvailabilityProvider);
  final trackingAvailable = trackingAsync.maybeWhen(
    data: (status) => status == TrackingAvailabilityStatus.available,
    orElse: () => false,
  );

  // Payments availability based on feature flag
  final paymentsAvailable = FeatureFlags.paymentsEnabled;

  // Notifications availability
  final notificationsAvailable = ref.watch(notificationsEnabledProvider);

  return {
    'tracking': trackingAvailable,
    'payments': paymentsAvailable,
    'notifications': notificationsAvailable,
  };
});

// ============================================================================
// Screen-Specific Hint Providers
// ============================================================================

/// Provider for 2FA screen hints.
final auth2faHintsProvider = FutureProvider<List<InAppHint>>((ref) async {
  if (!FeatureFlags.enableTwoFactorAuth) return [];

  final repository = ref.watch(hintStateRepositoryProvider);
  final flags = ref.watch(hintFeatureFlagsBridgeProvider);

  final hints = InAppHintsRegistry.getHintsForScreen(ScreenIds.auth2fa);
  final visibleHints = <InAppHint>[];

  for (final hint in hints) {
    final state = await repository.getDisplayState(hint.id);
    if (state.dismissed) continue;

    if (hint.shouldShow(
      featureFlags: flags,
      showCount: state.showCount,
      backendAvailable: true,
    )) {
      visibleHints.add(hint);
    }
  }

  return visibleHints;
});

/// Provider for payment methods screen hints.
final paymentMethodsHintsProvider = FutureProvider<List<InAppHint>>((ref) async {
  final repository = ref.watch(hintStateRepositoryProvider);
  final flags = ref.watch(hintFeatureFlagsBridgeProvider);
  final backendAvailability = ref.watch(backendAvailabilityBridgeProvider);

  final hints = InAppHintsRegistry.getHintsForScreen(ScreenIds.paymentMethods);
  final visibleHints = <InAppHint>[];

  for (final hint in hints) {
    final state = await repository.getDisplayState(hint.id);
    if (state.dismissed) continue;

    final backendAvailable = hint.showOnlyIfBackendAvailable
        ? (backendAvailability['payments'] ?? false)
        : true;

    if (hint.shouldShow(
      featureFlags: flags,
      showCount: state.showCount,
      backendAvailable: backendAvailable,
    )) {
      visibleHints.add(hint);
    }
  }

  return visibleHints;
});

/// Provider for order tracking screen hints.
final trackingHintsProvider = FutureProvider<List<InAppHint>>((ref) async {
  final repository = ref.watch(hintStateRepositoryProvider);
  final flags = ref.watch(hintFeatureFlagsBridgeProvider);
  final backendAvailability = ref.watch(backendAvailabilityBridgeProvider);

  final hints = InAppHintsRegistry.getHintsForScreen(ScreenIds.orderTracking);
  final visibleHints = <InAppHint>[];

  for (final hint in hints) {
    final state = await repository.getDisplayState(hint.id);
    if (state.dismissed) continue;

    final backendAvailable = hint.showOnlyIfBackendAvailable
        ? (backendAvailability['tracking'] ?? false)
        : true;

    if (hint.shouldShow(
      featureFlags: flags,
      showCount: state.showCount,
      backendAvailable: backendAvailable,
    )) {
      visibleHints.add(hint);
    }
  }

  return visibleHints;
});

/// Provider for notification settings screen hints.
final notificationsHintsProvider = FutureProvider<List<InAppHint>>((ref) async {
  final repository = ref.watch(hintStateRepositoryProvider);
  final flags = ref.watch(hintFeatureFlagsBridgeProvider);
  final backendAvailability = ref.watch(backendAvailabilityBridgeProvider);

  if (!(flags[HintFeatureFlags.enableNotifications] ?? false)) return [];

  final hints = InAppHintsRegistry.getHintsForScreen(ScreenIds.notificationSettings);
  final visibleHints = <InAppHint>[];

  for (final hint in hints) {
    final state = await repository.getDisplayState(hint.id);
    if (state.dismissed) continue;

    final backendAvailable = hint.showOnlyIfBackendAvailable
        ? (backendAvailability['notifications'] ?? false)
        : true;

    if (hint.shouldShow(
      featureFlags: flags,
      showCount: state.showCount,
      backendAvailable: backendAvailable,
    )) {
      visibleHints.add(hint);
    }
  }

  return visibleHints;
});

/// Provider for orders history screen hints (empty state).
final ordersEmptyHintsProvider = FutureProvider<List<InAppHint>>((ref) async {
  final repository = ref.watch(hintStateRepositoryProvider);
  final flags = ref.watch(hintFeatureFlagsBridgeProvider);

  final hints = InAppHintsRegistry.getHintsForScreen(ScreenIds.ordersHistory);
  final visibleHints = <InAppHint>[];

  for (final hint in hints) {
    // Only include the empty state hint
    if (hint.id != InAppHintIds.ordersEmpty) continue;

    final state = await repository.getDisplayState(hint.id);
    if (state.dismissed) continue;

    if (hint.shouldShow(
      featureFlags: flags,
      showCount: state.showCount,
      backendAvailable: true,
    )) {
      visibleHints.add(hint);
    }
  }

  return visibleHints;
});

// ============================================================================
// Hint Controller Provider
// ============================================================================

/// Provider for hint controller to mark hints as shown/dismissed.
final hintControllerProvider =
    StateNotifierProvider<InAppHintController, Set<String>>((ref) {
  final repository = ref.watch(hintStateRepositoryProvider);
  return InAppHintController(repository);
});


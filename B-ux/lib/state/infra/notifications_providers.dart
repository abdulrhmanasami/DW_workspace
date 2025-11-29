/// Notification Preferences Infra Providers
/// Created by: Cursor B-ux
/// Purpose: Riverpod providers for notification preferences with Sale-Only behavior
/// Last updated: 2025-11-25

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notifications_shims/notifications_shims.dart';

export 'package:notifications_shims/notifications_shims.dart'
    show
        NotificationPreferences,
        NotificationPreferencesRepository,
        NotificationChannel,
        NotificationTimeOfDay,
        NoOpNotificationPreferencesRepository,
        InMemoryNotificationPreferencesRepository;

// ============================================================================
// Sale-Only Availability
// ============================================================================

/// Availability status for the notifications feature.
enum NotificationsAvailabilityStatus {
  available,
  temporarilyUnavailable,
  disabledByConfig,
  notSupported,
  checking,
}

/// Immutable snapshot of notifications availability state.
class NotificationsAvailabilityState {
  const NotificationsAvailabilityState({
    required this.status,
    this.lastChecked,
    this.errorMessage,
  });

  const NotificationsAvailabilityState.initial()
      : status = NotificationsAvailabilityStatus.checking,
        lastChecked = null,
        errorMessage = null;

  const NotificationsAvailabilityState.available()
      : status = NotificationsAvailabilityStatus.available,
        lastChecked = null,
        errorMessage = null;

  const NotificationsAvailabilityState.disabled()
      : status = NotificationsAvailabilityStatus.disabledByConfig,
        lastChecked = null,
        errorMessage = null;

  final NotificationsAvailabilityStatus status;
  final DateTime? lastChecked;
  final String? errorMessage;

  bool get isAvailable => status == NotificationsAvailabilityStatus.available;
  bool get isDisabled =>
      status == NotificationsAvailabilityStatus.disabledByConfig;
  bool get isTemporarilyUnavailable =>
      status == NotificationsAvailabilityStatus.temporarilyUnavailable;
  bool get isNotSupported =>
      status == NotificationsAvailabilityStatus.notSupported;
  bool get isChecking => status == NotificationsAvailabilityStatus.checking;
  bool get shouldShowUnavailableMessage => !isAvailable && !isChecking;
}

/// Feature configuration for notifications.
class NotificationsFeatureConfig {
  const NotificationsFeatureConfig._();

  static bool get isEnabled {
    const envValue = String.fromEnvironment(
      'ENABLE_NOTIFICATIONS',
      defaultValue: 'false',
    );
    return envValue.toLowerCase() == 'true';
  }

  static const Duration availabilityCheckTimeout = Duration(seconds: 5);
}

// ============================================================================
// Availability Provider
// ============================================================================

/// Notifier for managing notifications availability state.
class NotificationsAvailabilityNotifier
    extends StateNotifier<NotificationsAvailabilityState> {
  NotificationsAvailabilityNotifier()
      : super(const NotificationsAvailabilityState.initial()) {
    _checkAvailability();
  }

  void _checkAvailability() {
    // Check feature flag first
    if (!NotificationsFeatureConfig.isEnabled) {
      state = const NotificationsAvailabilityState.disabled();
      return;
    }

    // For now, assume available if feature flag is enabled
    // In production, this would check backend availability
    state = NotificationsAvailabilityState(
      status: NotificationsAvailabilityStatus.available,
      lastChecked: DateTime.now(),
    );
  }

  void markAvailable() {
    state = NotificationsAvailabilityState(
      status: NotificationsAvailabilityStatus.available,
      lastChecked: DateTime.now(),
    );
  }

  void markDisabled() {
    state = const NotificationsAvailabilityState.disabled();
  }

  void markTemporarilyUnavailable([String? message]) {
    state = NotificationsAvailabilityState(
      status: NotificationsAvailabilityStatus.temporarilyUnavailable,
      lastChecked: DateTime.now(),
      errorMessage: message,
    );
  }

  Future<void> refresh() async {
    _checkAvailability();
  }
}

/// Provider for notifications availability status.
final notificationsAvailabilityProvider = StateNotifierProvider<
    NotificationsAvailabilityNotifier, NotificationsAvailabilityState>(
  (ref) => NotificationsAvailabilityNotifier(),
);

// ============================================================================
// Disabled Repository (Sale-Only)
// ============================================================================

/// Repository that returns defaults when notifications are disabled.
/// Implements Sale-Only behavior - no fake data, just defaults.
class DisabledNotificationPreferencesRepository
    implements NotificationPreferencesRepository {
  const DisabledNotificationPreferencesRepository();

  @override
  Future<NotificationPreferences> load() async {
    return const NotificationPreferences.defaults();
  }

  @override
  Future<void> save(NotificationPreferences preferences) async {
    // No-op: cannot save when feature is disabled
  }

  @override
  Future<void> updateChannelPreference(
      NotificationChannel channel, bool enabled) async {
    // No-op
  }

  @override
  Future<void> resetToDefaults() async {
    // No-op
  }

  @override
  Future<bool> isChannelEnabled(NotificationChannel channel) async {
    return false; // All channels disabled when feature is disabled
  }
}

// ============================================================================
// Providers
// ============================================================================

/// Provider for the notification preferences repository.
/// Returns appropriate implementation based on availability status.
final notificationPreferencesRepositoryProvider =
    Provider<NotificationPreferencesRepository>((ref) {
  final availability = ref.watch(notificationsAvailabilityProvider);

  if (!availability.isAvailable) {
    return const DisabledNotificationPreferencesRepository();
  }

  // When available, this should be overridden with real implementation
  // via ProviderScope in app wiring
  return const NoOpNotificationPreferencesRepository();
});

/// Provider for loading notification preferences.
final notificationPreferencesProvider =
    FutureProvider<NotificationPreferences>((ref) async {
  final repository = ref.watch(notificationPreferencesRepositoryProvider);
  return repository.load();
});

/// Convenience provider that returns whether notifications feature is available.
final isNotificationsAvailableProvider = Provider<bool>((ref) {
  final availability = ref.watch(notificationsAvailabilityProvider);
  return availability.isAvailable;
});

/// Provider for the unavailability reason message key (l10n).
final notificationsUnavailableReasonKeyProvider = Provider<String?>((ref) {
  final availability = ref.watch(notificationsAvailabilityProvider);

  if (availability.isAvailable || availability.isChecking) {
    return null;
  }

  switch (availability.status) {
    case NotificationsAvailabilityStatus.disabledByConfig:
      return 'notifications_unavailable_disabled';
    case NotificationsAvailabilityStatus.temporarilyUnavailable:
      return 'notifications_unavailable_temporary';
    case NotificationsAvailabilityStatus.notSupported:
      return 'notifications_unavailable_not_supported';
    default:
      return 'notifications_unavailable_generic';
  }
});

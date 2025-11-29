import 'notification_models.dart';

/// Persistence contract for storing user notification preferences.
abstract class NotificationPreferencesRepository {
  Future<NotificationPreferences> load();

  Future<void> save(NotificationPreferences preferences);

  Future<void> updateChannelPreference(
      NotificationChannel channel, bool enabled);

  Future<void> resetToDefaults();

  Future<bool> isChannelEnabled(NotificationChannel channel);
}

/// No-op implementation that always reports enabled preferences.
class NoOpNotificationPreferencesRepository
    implements NotificationPreferencesRepository {
  const NoOpNotificationPreferencesRepository();

  @override
  Future<NotificationPreferences> load() async =>
      const NotificationPreferences.defaults();

  @override
  Future<void> save(NotificationPreferences preferences) async {}

  @override
  Future<void> updateChannelPreference(
      NotificationChannel channel, bool enabled) async {}

  @override
  Future<void> resetToDefaults() async {}

  @override
  Future<bool> isChannelEnabled(NotificationChannel channel) async => true;
}

/// Simple in-memory implementation useful for tests.
class InMemoryNotificationPreferencesRepository
    implements NotificationPreferencesRepository {
  NotificationPreferences _preferences =
      const NotificationPreferences.defaults();

  @override
  Future<NotificationPreferences> load() async => _preferences;

  @override
  Future<void> save(NotificationPreferences preferences) async {
    _preferences = preferences;
  }

  @override
  Future<void> updateChannelPreference(
      NotificationChannel channel, bool enabled) async {
    _preferences = _preferences.copyWith(
      orderStatusUpdatesEnabled: channel == NotificationChannel.orderUpdates
          ? enabled
          : _preferences.orderStatusUpdatesEnabled,
      promotionsEnabled: channel == NotificationChannel.promotions
          ? enabled
          : _preferences.promotionsEnabled,
      systemAlertsEnabled: channel == NotificationChannel.system
          ? enabled
          : _preferences.systemAlertsEnabled,
    );
  }

  @override
  Future<void> resetToDefaults() async {
    _preferences = const NotificationPreferences.defaults();
  }

  @override
  Future<bool> isChannelEnabled(NotificationChannel channel) async {
    return switch (channel) {
      NotificationChannel.orderUpdates =>
        _preferences.orderStatusUpdatesEnabled,
      NotificationChannel.promotions => _preferences.promotionsEnabled,
      NotificationChannel.system => _preferences.systemAlertsEnabled,
    };
  }
}

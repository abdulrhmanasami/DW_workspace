import 'package:notifications_shims/src/notification_models.dart';

/// Abstraction for backend communication related to notifications.
abstract class NotificationsBackendClient {
  Future<void> registerDeviceToken({
    required String token,
    required NotificationDeviceMetadata metadata,
  });

  Future<void> unregisterDeviceToken({
    required String token,
    required NotificationDeviceMetadata metadata,
  });

  Future<void> updateUserNotificationPreferences(
    NotificationPreferences preferences,
  );
}

/// Safe fallback backend client used when networking is unavailable.
class NoOpNotificationsBackendClient implements NotificationsBackendClient {
  const NoOpNotificationsBackendClient();

  @override
  Future<void> registerDeviceToken({
    required String token,
    required NotificationDeviceMetadata metadata,
  }) async {}

  @override
  Future<void> unregisterDeviceToken({
    required String token,
    required NotificationDeviceMetadata metadata,
  }) async {}

  @override
  Future<void> updateUserNotificationPreferences(
    NotificationPreferences preferences,
  ) async {}
}

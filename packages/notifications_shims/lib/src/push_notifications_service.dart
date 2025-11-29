import 'dart:async';

import 'notification_models.dart';

/// Abstract interface for push notification services.
abstract class PushNotificationService {
  /// Initializes the underlying push provider (Firebase/APNs/etc).
  Future<void> init();

  /// Requests user permission to show push notifications.
  Future<NotificationPermissionStatus> requestUserPermission();

  /// Retrieves the current push token if available.
  Future<String?> getFcmToken();

  /// Current permission status without prompting the user.
  Future<NotificationPermissionStatus> getPermissionStatus();

  /// Whether push notifications are supported on the running platform.
  Future<bool> isSupported();

  /// Forces syncing the currently cached token with the backend.
  Future<void> syncTokenWithBackend();

  /// Stream of notifications received while the app is in foreground.
  Stream<IncomingNotification> get onForegroundNotification;

  /// Stream of notifications that opened the app from background/terminated.
  Stream<IncomingNotification> get onNotificationTap;

  /// Releases any allocated resources/listeners.
  Future<void> dispose();
}

/// No-operation implementation for tests or unsupported platforms.
class NoOpPushNotificationService implements PushNotificationService {
  const NoOpPushNotificationService();

  @override
  Future<void> init() async {}

  @override
  Future<NotificationPermissionStatus> requestUserPermission() async =>
      NotificationPermissionStatus.denied;

  @override
  Future<String?> getFcmToken() async => null;

  @override
  Future<NotificationPermissionStatus> getPermissionStatus() async =>
      NotificationPermissionStatus.denied;

  @override
  Future<bool> isSupported() async => false;

  @override
  Future<void> syncTokenWithBackend() async {}

  @override
  Stream<IncomingNotification> get onForegroundNotification =>
      const Stream.empty();

  @override
  Stream<IncomingNotification> get onNotificationTap => const Stream.empty();

  @override
  Future<void> dispose() async {}
}

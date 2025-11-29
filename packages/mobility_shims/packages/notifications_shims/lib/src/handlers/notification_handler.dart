/// Notification handler abstraction
abstract class NotificationHandler {
  Future<void> initialize();
  Future<void> showNotification({
    required final String title,
    required final String body,
    final String? payload,
  });
  Future<void> cancelNotification(final int id);
  Future<void> cancelAllNotifications();
}

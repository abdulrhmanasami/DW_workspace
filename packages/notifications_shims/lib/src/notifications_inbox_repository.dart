import 'dart:async';

import 'notification_models.dart';

/// Storage interface for the notifications inbox.
abstract class NotificationsInboxRepository {
  Future<void> appendFromPayload(IncomingNotification payload);

  Future<List<NotificationEntry>> getNotifications({
    int limit = 50,
    DateTime? since,
  });

  Stream<List<NotificationEntry>> watchNotifications();

  Future<void> markAsRead(NotificationId id);

  Future<void> deleteNotification(NotificationId id);

  Future<void> clearAll();

  Future<int> getUnreadCount();

  Future<void> markAllAsRead();
}

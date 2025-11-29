/// Notification Repositories - Repository contracts for notifications
/// Created by: Cursor B-ux
/// Purpose: Abstract interfaces for notification persistence and retrieval
/// Last updated: 2025-11-25

import 'notification_models.dart';

/// Repository contract for persisting notification preferences.
abstract class NotificationPreferencesRepository {
  /// Load current notification preferences from storage/backend.
  Future<NotificationPreferences> load();

  /// Save notification preferences to storage/backend.
  Future<void> save(NotificationPreferences preferences);
}

/// Repository contract for the notifications inbox.
abstract class NotificationsInboxRepository {
  /// Watch notifications stream for real-time updates.
  Stream<List<NotificationEntry>> watchNotifications();

  /// Get all notifications (one-shot).
  Future<List<NotificationEntry>> getNotifications();

  /// Mark a specific notification as read.
  Future<void> markAsRead(String id);

  /// Mark all notifications as read.
  Future<void> markAllAsRead();

  /// Clear all notifications from inbox.
  Future<void> clearAll();

  /// Delete a specific notification.
  Future<void> deleteNotification(String id);
}

/// Backend client contract for notifications HTTP operations.
/// This is the interface that should be implemented by the actual backend client.
abstract class NotificationsBackendClient {
  /// Fetch notification preferences from backend.
  Future<NotificationPreferences> fetchPreferences();

  /// Update notification preferences on backend.
  Future<void> updatePreferences(NotificationPreferences preferences);

  /// Fetch notification inbox from backend.
  Future<List<NotificationEntry>> fetchInbox();

  /// Mark notification as read on backend.
  Future<void> markNotificationAsRead(String id);

  /// Delete notification on backend.
  Future<void> deleteNotification(String id);

  /// Check if notifications backend is available.
  Future<bool> checkAvailability();
}


/// Notifications UX Aggregate
/// Convenience exports and navigation helpers for Inbox + Preferences flows.

library notifications_ux_providers;

export 'notification_preferences_ux.dart';
export 'notifications_inbox_ux_providers.dart';

/// Destinations exposed to shell/bottom navigation.
enum NotificationsUxDestination {
  inbox,
  preferences,
}

/// Centralized route hints used by navigation layers.
class NotificationsUxRoutes {
  static const String inboxTab = '/hub/inbox';
  static const String notificationSettings = '/settings/notifications';
}


library notifications_ux_providers;

export 'notification_preferences_ux.dart';
export 'notifications_inbox_ux_providers.dart';

/// Destinations exposed to navigation layers.
enum NotificationsUxDestination {
  inbox,
  promotions,
  system,
  preferences,
}

/// Canonical routes for the notifications surfaces.
class NotificationsUxRoutes {
  static const String inbox = '/hub/inbox';
  static const String promotions = '/notifications/promotions';
  static const String systemMessages = '/notifications/system';
  static const String preferences = '/settings/notifications';
}


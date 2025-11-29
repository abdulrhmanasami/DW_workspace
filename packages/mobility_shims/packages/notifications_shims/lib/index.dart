/// Notifications shims for Clean-B architecture
/// Provides abstractions for push notifications and local notifications
///
/// This package is part of the shims layer in Clean-B architecture,
/// providing platform-agnostic notification interfaces.

library notifications_shims;

export 'src/channels/notification_channels.dart' show NotificationChannel;
export 'src/config/notification_config.dart' show NotificationConfig;
export 'src/handlers/notification_handler.dart' show NotificationHandler;
export 'src/payloads/notification_payload.dart' show NotificationPayload;
export 'src/permissions/notification_permissions.dart'
    show NotificationPermissions;
export 'src/subscribe/notification_subscription.dart'
    show NotificationSubscription;
export 'src/token/notification_token.dart' show NotificationToken;

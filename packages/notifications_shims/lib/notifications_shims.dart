// Notifications Shims Library
// Unified exports for notification domain models, contracts, and default implementations

// Core notification models and enums
export 'src/notification_models.dart';

// Backend integration contracts
export 'src/backend/notifications_backend_client.dart'
    show NotificationsBackendClient, NoOpNotificationsBackendClient;

// Service interfaces
export 'src/push_notifications_service.dart'
    show PushNotificationService, NoOpPushNotificationService;

// Preferences repository contracts + canonical no-ops
export 'src/notification_preferences_repository.dart'
    show
        NotificationPreferencesRepository,
        NoOpNotificationPreferencesRepository,
        InMemoryNotificationPreferencesRepository;

// Inbox repository contract
export 'src/notifications_inbox_repository.dart';

// In-app review facades
export 'src/in_app_review/in_app_review.dart';
export 'src/in_app_review/in_app_review_service.dart';

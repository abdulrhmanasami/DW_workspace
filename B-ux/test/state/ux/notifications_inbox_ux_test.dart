/// Notifications Inbox UX Tests
/// Created by: Cursor B-ux
/// Purpose: Unit tests for notifications inbox UX layer with Sale-Only behavior
/// Last updated: 2025-11-25

import 'package:flutter_test/flutter_test.dart';
import 'package:notifications_shims/notifications_shims.dart';

import 'package:delivery_ways_clean/state/infra/notifications_providers.dart';
import 'package:delivery_ways_clean/state/ux/notification_preferences_ux.dart';
import 'package:delivery_ways_clean/state/ux/notifications_inbox_ux_providers.dart';

void main() {
  group('buildNotificationListItems', () {
    test('filters according to preferences and sorts by timestamp descending',
        () {
      final snapshots = [
        NotificationInboxSnapshot(
          id: 'promo-1',
          type: NotificationType.promotion,
          title: 'عرض اليوم',
          subtitle: 'خصم 20%',
          timestamp: DateTime(2025, 1, 3, 10),
          isUnread: true,
          metadata: const {'messageId': 'promo-1'},
        ),
        NotificationInboxSnapshot(
          id: 'order-1',
          type: NotificationType.orderStatusUpdate,
          title: 'تم تجهيز طلبك',
          subtitle: 'في الطريق إليك',
          timestamp: DateTime(2025, 1, 4, 9),
          isUnread: false,
          metadata: const {'orderId': 'order-1'},
        ),
      ];

      final prefs = NotificationPreferencesViewModel(
        orderStatusUpdatesEnabled: true,
        promotionsEnabled: false,
        systemAlertsEnabled: true,
        marketingConsented: true,
        canEditPromotions: true,
        isDoNotDisturbEnabled: false,
        quietHoursWrapsToNextDay: false,
        isAvailable: true,
        availabilityStatus: NotificationsAvailabilityStatus.available,
      );

      final viewModels = buildNotificationListItems(
        snapshots: snapshots,
        preferences: prefs,
      );

      expect(viewModels.length, 1);
      expect(viewModels.first.id, 'order-1');
      expect(viewModels.first.type, NotificationType.orderStatusUpdate);
    });

    test('does not filter when preferences is null', () {
      final snapshots = [
        NotificationInboxSnapshot(
          id: 'promo-1',
          type: NotificationType.promotion,
          title: 'Promo',
          subtitle: 'Discount',
          timestamp: DateTime(2025, 1, 1),
          isUnread: true,
          metadata: const {},
        ),
        NotificationInboxSnapshot(
          id: 'order-1',
          type: NotificationType.orderStatusUpdate,
          title: 'Order',
          subtitle: 'Status',
          timestamp: DateTime(2025, 1, 2),
          isUnread: false,
          metadata: const {},
        ),
      ];

      final viewModels = buildNotificationListItems(
        snapshots: snapshots,
        preferences: null,
      );

      expect(viewModels.length, 2);
    });

    test('does not filter when feature is unavailable (Sale-Only)', () {
      final snapshots = [
        NotificationInboxSnapshot(
          id: 'promo-1',
          type: NotificationType.promotion,
          title: 'Promo',
          subtitle: 'Discount',
          timestamp: DateTime(2025, 1, 1),
          isUnread: true,
          metadata: const {},
        ),
      ];

      final unavailablePrefs = NotificationPreferencesViewModel.unavailable(
        availabilityStatus: NotificationsAvailabilityStatus.disabledByConfig,
      );

      final viewModels = buildNotificationListItems(
        snapshots: snapshots,
        preferences: unavailablePrefs,
      );

      expect(viewModels.length, 1);
    });

    test('sorts by timestamp descending', () {
      final snapshots = [
        NotificationInboxSnapshot(
          id: 'older',
          type: NotificationType.system,
          title: 'Older',
          subtitle: 'Old',
          timestamp: DateTime(2025, 1, 1),
          isUnread: true,
          metadata: const {},
        ),
        NotificationInboxSnapshot(
          id: 'newer',
          type: NotificationType.system,
          title: 'Newer',
          subtitle: 'New',
          timestamp: DateTime(2025, 1, 5),
          isUnread: true,
          metadata: const {},
        ),
      ];

      final viewModels = buildNotificationListItems(
        snapshots: snapshots,
        preferences: null,
      );

      expect(viewModels.first.id, 'newer');
      expect(viewModels.last.id, 'older');
    });
  });

  group('NotificationsEmptyStateViewModel', () {
    test('unavailable factory creates correct state', () {
      final emptyState = NotificationsEmptyStateViewModel.unavailable();

      expect(emptyState.isFeatureAvailable, isFalse);
      expect(emptyState.isEmpty, isTrue);
      expect(emptyState.hasNotifications, isFalse);
      expect(emptyState.titleKey, 'notifications_unavailable_title');
      expect(
          emptyState.descriptionKey, 'notifications_unavailable_description');
      expect(emptyState.primaryAction, isNull);
    });

    test('empty factory creates correct state', () {
      final emptyState = NotificationsEmptyStateViewModel.empty();

      expect(emptyState.isFeatureAvailable, isTrue);
      expect(emptyState.isEmpty, isTrue);
      expect(emptyState.hasNotifications, isFalse);
      expect(emptyState.titleKey, 'notifications_inbox_empty_title');
      expect(emptyState.primaryAction, isA<NotificationActionOpenHome>());
    });

    test('withData factory creates correct state', () {
      final state = NotificationsEmptyStateViewModel.withData(5);

      expect(state.isFeatureAvailable, isTrue);
      expect(state.isEmpty, isFalse);
      expect(state.hasNotifications, isTrue);
      expect(state.totalNotifications, 5);
    });
  });
}

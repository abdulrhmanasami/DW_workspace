/// Notifications Inbox Providers Tests
/// Created by: Cursor B-ux
/// Purpose: Unit tests for notifications inbox infra providers with Sale-Only behavior
/// Last updated: 2025-11-25

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notifications_shims/notifications_shims.dart';

import 'package:delivery_ways_clean/state/infra/notifications_inbox_providers.dart';
import 'package:delivery_ways_clean/state/infra/notifications_providers.dart';

import '../ux/notifications_test_utils.dart';

void main() {
  group('DisabledNotificationsInboxRepository', () {
    test('getNotifications returns empty list', () async {
      const repository = DisabledNotificationsInboxRepository();

      final notifications = await repository.getNotifications();

      expect(notifications, isEmpty);
    });

    test('watchNotifications returns empty stream', () async {
      const repository = DisabledNotificationsInboxRepository();

      final notifications = await repository.watchNotifications().first;

      expect(notifications, isEmpty);
    });

    test('markAsRead is a no-op', () async {
      const repository = DisabledNotificationsInboxRepository();

      // Should not throw
      await repository.markAsRead(const NotificationId('any-id'));
    });

    test('markAllAsRead is a no-op', () async {
      const repository = DisabledNotificationsInboxRepository();

      // Should not throw
      await repository.markAllAsRead();
    });

    test('clearAll is a no-op', () async {
      const repository = DisabledNotificationsInboxRepository();

      // Should not throw
      await repository.clearAll();
    });

    test('deleteNotification is a no-op', () async {
      const repository = DisabledNotificationsInboxRepository();

      // Should not throw
      await repository.deleteNotification(const NotificationId('any-id'));
    });

    test('getUnreadCount returns 0', () async {
      const repository = DisabledNotificationsInboxRepository();

      final count = await repository.getUnreadCount();

      expect(count, 0);
    });
  });

  group('notificationsInboxRepositoryProvider', () {
    test('returns DisabledRepository when unavailable', () {
      final container = ProviderContainer(
        overrides: [
          notificationsAvailabilityProvider.overrideWith(
            (ref) => NotificationsAvailabilityNotifier()..markDisabled(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final repository =
          container.read(notificationsInboxRepositoryProvider);

      expect(repository, isA<DisabledNotificationsInboxRepository>());
    });
  });

  group('notificationsInboxStreamProvider', () {
    test('returns empty stream when unavailable', () async {
      final container = ProviderContainer(
        overrides: [
          notificationsAvailabilityProvider.overrideWith(
            (ref) => NotificationsAvailabilityNotifier()..markDisabled(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifications =
          await container.read(notificationsInboxStreamProvider.future);

      expect(notifications, isEmpty);
    });

    test('streams notifications from repository when available', () async {
      final repository = InMemoryNotificationsInboxRepository(
        initialEntries: [
          buildNotificationEntry(
              id: 'notif-1', type: NotificationType.promotion),
          buildNotificationEntry(id: 'notif-2', type: NotificationType.system),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          notificationsAvailabilityProvider.overrideWith(
            (ref) => NotificationsAvailabilityNotifier()..markAvailable(),
          ),
          notificationsInboxRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final notifications =
          await container.read(notificationsInboxStreamProvider.future);

      expect(notifications, hasLength(2));
      expect(notifications.map((n) => n.id.value),
          containsAll(['notif-1', 'notif-2']));
    });
  });

  group('unreadNotificationsCountProvider', () {
    test('returns 0 when unavailable (Sale-Only)', () {
      final container = ProviderContainer(
        overrides: [
          notificationsAvailabilityProvider.overrideWith(
            (ref) => NotificationsAvailabilityNotifier()..markDisabled(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final count = container.read(unreadNotificationsCountProvider);

      expect(count, 0);
    });

    test('counts unread notifications when available', () async {
      final repository = InMemoryNotificationsInboxRepository(
        initialEntries: [
          buildNotificationEntry(
            id: 'unread-1',
            type: NotificationType.promotion,
            readStatus: NotificationReadStatus.unread,
          ),
          buildNotificationEntry(
            id: 'unread-2',
            type: NotificationType.system,
            readStatus: NotificationReadStatus.unread,
          ),
          buildNotificationEntry(
            id: 'read-1',
            type: NotificationType.orderStatusUpdate,
            readStatus: NotificationReadStatus.read,
          ),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          notificationsAvailabilityProvider.overrideWith(
            (ref) => NotificationsAvailabilityNotifier()..markAvailable(),
          ),
          notificationsInboxRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      // Wait for stream to emit
      await container.read(notificationsInboxStreamProvider.future);

      final count = container.read(unreadNotificationsCountProvider);

      expect(count, 2);
    });
  });
}

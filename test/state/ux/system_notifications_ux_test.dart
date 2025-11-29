import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:delivery_ways_clean/state/infra/notifications_inbox_providers.dart';
import 'package:delivery_ways_clean/state/ux/notifications_inbox_ux_providers.dart';

import 'notifications_test_utils.dart';

void main() {
  group('systemNotificationsUxProvider', () {
    test('returns only system messages sorted by timestamp', () async {
      final latestSystem = buildNotificationViewModel(
        id: 'sys-new',
        type: NotificationType.system,
        timestamp: DateTime(2025, 3, 2),
        metadata: const {'messageId': 'latest'},
      );
      final olderSystem = buildNotificationViewModel(
        id: 'sys-old',
        type: NotificationType.system,
        timestamp: DateTime(2025, 3, 1),
        metadata: const {'messageId': 'older'},
      );
      final promo = buildNotificationViewModel(id: 'promo-1');

      final container = ProviderContainer(
        overrides: [
          notificationsInboxUxProvider.overrideWith(
            (ref) => Stream<List<NotificationListItemViewModel>>.value(
              [promo, olderSystem, latestSystem],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(notificationsInboxUxProvider.future);
      final systemItems = container.read(systemNotificationsUxProvider).requireValue;

      expect(systemItems, hasLength(2));
      expect(systemItems.first.id, 'sys-new');
      expect(systemItems.last.id, 'sys-old');
    });
  });

  group('systemNotificationsEmptyStateProvider', () {
    test('reports empty when no system messages exist', () async {
      final container = ProviderContainer(
        overrides: [
          notificationsInboxUxProvider.overrideWith(
            (ref) => Stream<List<NotificationListItemViewModel>>.value(
              [buildNotificationViewModel(id: 'promo-1')],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(notificationsInboxUxProvider.future);
      final emptyState = container.read(systemNotificationsEmptyStateProvider);

      expect(emptyState.isEmpty, isTrue);
      expect(emptyState.titleKey, 'notifications_system.empty.title');
    });

    test('reports data when system messages are available', () async {
      final container = ProviderContainer(
        overrides: [
          notificationsInboxUxProvider.overrideWith(
            (ref) => Stream<List<NotificationListItemViewModel>>.value(
              [
                buildNotificationViewModel(
                  id: 'sys-1',
                  type: NotificationType.system,
                ),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(notificationsInboxUxProvider.future);
      final emptyState = container.read(systemNotificationsEmptyStateProvider);

      expect(emptyState.hasNotifications, isTrue);
      expect(emptyState.totalNotifications, 1);
    });
  });

  group('systemNotificationDetailUxProvider', () {
    test('resolves system message details by messageId', () async {
      final systemItem = buildNotificationViewModel(
        id: 'sys-10',
        type: NotificationType.system,
        timestamp: DateTime(2025, 3, 1, 12),
        metadata: const {'messageId': 'policy-update'},
        action: const NotificationActionOpenSystemMessage(messageId: 'policy-update'),
      );

      final container = ProviderContainer(
        overrides: [
          notificationsInboxUxProvider.overrideWith(
            (ref) => Stream<List<NotificationListItemViewModel>>.value(
              [systemItem],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final detail = await container.read(systemNotificationDetailUxProvider('policy-update').future);

      expect(detail.id, 'sys-10');
      expect(detail.title, 'title sys-10');
      expect(detail.metadata?['messageId'], 'policy-update');
    });

    test('throws when system message is not found', () async {
      final container = ProviderContainer(
        overrides: [
          notificationsInboxUxProvider.overrideWith(
            (ref) => Stream<List<NotificationListItemViewModel>>.value(
              [
                buildNotificationViewModel(
                  id: 'sys-1',
                  type: NotificationType.system,
                  action: const NotificationActionOpenSystemMessage(messageId: 'sys-1'),
                  metadata: const {'messageId': 'sys-1'},
                ),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(systemNotificationDetailUxProvider('missing').future),
        throwsStateError,
      );
    });
  });

  group('SystemNotificationsUxController', () {
    test('marks system message as read by id', () async {
      final repository = InMemoryNotificationsInboxRepository(
        initialEntries: [
          buildNotificationEntry(id: 'sys-1', type: NotificationType.system),
          buildNotificationEntry(id: 'promo-1', type: NotificationType.promotion),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          notificationsInboxRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(systemNotificationsUxControllerProvider);

      await controller.markSystemMessageAsRead('sys-1');

      expect(repository.markedAsRead, ['sys-1']);
    });

    test('clears only system notifications', () async {
      final repository = InMemoryNotificationsInboxRepository(
        initialEntries: [
          buildNotificationEntry(id: 'sys-1', type: NotificationType.system),
          buildNotificationEntry(id: 'sys-2', type: NotificationType.system),
          buildNotificationEntry(id: 'promo-1', type: NotificationType.promotion),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          notificationsInboxRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(systemNotificationsUxControllerProvider);

      await controller.clearAllSystemMessages();

      expect(repository.deletedNotifications, containsAll(['sys-1', 'sys-2']));
      expect(repository.deletedNotifications.contains('promo-1'), isFalse);
    });
  });
}


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:delivery_ways_clean/state/infra/notifications_inbox_providers.dart';
import 'package:delivery_ways_clean/state/ux/notifications_inbox_ux_providers.dart';

import 'notifications_test_utils.dart';

void main() {
  group('promotionsNotificationsUxProvider', () {
    test('exposes only promotion items sorted by timestamp', () async {
      final olderPromotion = buildNotificationViewModel(
        id: 'promo-older',
        timestamp: DateTime(2025, 2, 10, 9),
      );
      final newerPromotion = buildNotificationViewModel(
        id: 'promo-newer',
        timestamp: DateTime(2025, 2, 11, 9),
      );
      final systemItem = buildNotificationViewModel(
        id: 'sys-1',
        type: NotificationType.system,
        action: const NotificationActionOpenSystemMessage(messageId: 'sys-1'),
        timestamp: DateTime(2025, 2, 12, 9),
      );

      final container = ProviderContainer(
        overrides: [
          notificationsInboxUxProvider.overrideWith(
            (ref) => Stream<List<NotificationListItemViewModel>>.value(
              [
                olderPromotion,
                systemItem,
                newerPromotion,
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(notificationsInboxUxProvider.future);
      final promotions = container.read(promotionsNotificationsUxProvider).requireValue;

      expect(promotions, hasLength(2));
      expect(promotions.first.id, 'promo-newer');
      expect(promotions.last.id, 'promo-older');
      expect(promotions.every((item) => item.type == NotificationType.promotion), isTrue);
    });
  });

  group('promotionsNotificationsEmptyStateProvider', () {
    test('returns empty state when no promotions are available', () async {
      final container = ProviderContainer(
        overrides: [
          notificationsInboxUxProvider.overrideWith(
            (ref) => Stream<List<NotificationListItemViewModel>>.value(
              [
                buildNotificationViewModel(
                  id: 'order-1',
                  type: NotificationType.orderStatus,
                  action: const NotificationActionOpenOrderDetails('order-1'),
                ),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(notificationsInboxUxProvider.future);
      final emptyState = container.read(promotionsNotificationsEmptyStateProvider);

      expect(emptyState.isEmpty, isTrue);
      expect(emptyState.titleKey, 'notifications_promotions.empty.title');
      expect(emptyState.primaryAction, isA<NotificationActionOpenPromotions>());
    });

    test('indicates data when promotions exist', () async {
      final container = ProviderContainer(
        overrides: [
          notificationsInboxUxProvider.overrideWith(
            (ref) => Stream<List<NotificationListItemViewModel>>.value(
              [buildNotificationViewModel(id: 'promo-1'), buildNotificationViewModel(id: 'promo-2')],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(notificationsInboxUxProvider.future);
      final emptyState = container.read(promotionsNotificationsEmptyStateProvider);

      expect(emptyState.hasNotifications, isTrue);
      expect(emptyState.totalNotifications, 2);
    });
  });

  group('PromotionsNotificationsUxController', () {
    test('marks only promotion notifications as read when requested', () async {
      final repository = InMemoryNotificationsInboxRepository(
        initialEntries: [
          buildNotificationEntry(id: 'promo-unread', type: NotificationType.promotion),
          buildNotificationEntry(id: 'system-1', type: NotificationType.system),
        ],
      );
      final container = ProviderContainer(
        overrides: [
          notificationsInboxRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(promotionsNotificationsUxControllerProvider);

      await controller.markAllPromotionsAsRead();

      expect(repository.markedAsRead, ['promo-unread']);
    });

    test('clears only promotion notifications', () async {
      final repository = InMemoryNotificationsInboxRepository(
        initialEntries: [
          buildNotificationEntry(id: 'promo-1', type: NotificationType.promotion),
          buildNotificationEntry(id: 'promo-2', type: NotificationType.promotion),
          buildNotificationEntry(id: 'system-2', type: NotificationType.system),
        ],
      );
      final container = ProviderContainer(
        overrides: [
          notificationsInboxRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(promotionsNotificationsUxControllerProvider);

      await controller.clearAllPromotions();

      expect(repository.deletedNotifications, containsAll(['promo-1', 'promo-2']));
      expect(repository.deletedNotifications.contains('system-2'), isFalse);
    });
  });
}


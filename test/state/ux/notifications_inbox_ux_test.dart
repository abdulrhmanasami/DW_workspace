import 'package:flutter_test/flutter_test.dart';

import 'package:delivery_ways_clean/state/infra/notifications_inbox_providers.dart';
import 'package:delivery_ways_clean/state/ux/notification_preferences_ux.dart';
import 'package:delivery_ways_clean/state/ux/notifications_inbox_ux_providers.dart';

void main() {
  group('buildNotificationListItems', () {
    test('filters according to preferences and sorts by timestamp descending', () {
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
          type: NotificationType.orderStatus,
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
      );

      final viewModels = buildNotificationListItems(
        snapshots: snapshots,
        preferences: prefs,
      );

      expect(viewModels.length, 1);
      expect(viewModels.first.id, 'order-1');
      expect(viewModels.first.type, NotificationType.orderStatus);
    });
  });
}


import 'package:delivery_ways_clean/state/infra/notifications_inbox_providers.dart';
import 'package:delivery_ways_clean/state/ux/notifications_inbox_ux_providers.dart';

class InMemoryNotificationsInboxRepository implements NotificationsInboxRepository {
  InMemoryNotificationsInboxRepository({
    List<NotificationEntry>? initialEntries,
  }) : _entries = List<NotificationEntry>.from(initialEntries ?? const <NotificationEntry>[]);

  final List<NotificationEntry> _entries;
  final List<String> markedAsRead = <String>[];
  final List<String> deletedNotifications = <String>[];

  @override
  Stream<List<NotificationEntry>> watchNotifications() {
    return Stream<List<NotificationEntry>>.value(List<NotificationEntry>.unmodifiable(_entries));
  }

  @override
  Future<List<NotificationEntry>> getNotifications() async {
    return List<NotificationEntry>.unmodifiable(_entries);
  }

  @override
  Future<void> markAsRead(String id) async {
    markedAsRead.add(id);
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index != -1) {
      _entries[index] = _entries[index].copyWith(readStatus: NotificationReadStatus.read);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    for (var i = 0; i < _entries.length; i++) {
      _entries[i] = _entries[i].copyWith(readStatus: NotificationReadStatus.read);
    }
  }

  @override
  Future<void> clearAll() async {
    _entries.clear();
  }

  @override
  Future<void> deleteNotification(String id) async {
    deletedNotifications.add(id);
    _entries.removeWhere((entry) => entry.id == id);
  }
}

NotificationListItemViewModel buildNotificationViewModel({
  required String id,
  NotificationType type = NotificationType.promotion,
  NotificationAction? action,
  DateTime? timestamp,
  bool isUnread = true,
  Map<String, dynamic> metadata = const <String, dynamic>{},
}) {
  final resolvedAction = action ?? _defaultActionForType(type);
  return NotificationListItemViewModel(
    rawId: id,
    id: id,
    title: 'title $id',
    subtitle: 'subtitle $id',
    timestamp: timestamp ?? DateTime(2025, 1, 1),
    isUnread: isUnread,
    type: type,
    action: resolvedAction,
    semanticsLabel: 'title $id',
    metadata: metadata,
  );
}

NotificationEntry buildNotificationEntry({
  required String id,
  required NotificationType type,
  NotificationReadStatus readStatus = NotificationReadStatus.unread,
}) {
  return NotificationEntry(
    id: id,
    type: type,
    title: 'title $id',
    body: 'body $id',
    receivedAt: DateTime(2025, 1, 1),
    readStatus: readStatus,
  );
}

NotificationAction _defaultActionForType(NotificationType type) {
  switch (type) {
    case NotificationType.orderStatus:
      return const NotificationActionOpenOrderDetails('order-id');
    case NotificationType.promotion:
      return const NotificationActionOpenPromotions();
    case NotificationType.system:
      return const NotificationActionOpenSystemMessage(messageId: 'system-message');
  }
}


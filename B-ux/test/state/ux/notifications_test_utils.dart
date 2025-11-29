/// Notifications Test Utils
/// Created by: Cursor B-ux
/// Purpose: Shared test utilities for notifications tests
/// Last updated: 2025-11-25

import 'package:notifications_shims/notifications_shims.dart';
import 'package:delivery_ways_clean/state/ux/notifications_inbox_ux_providers.dart';

/// In-memory repository for testing.
class InMemoryNotificationsInboxRepository
    implements NotificationsInboxRepository {
  InMemoryNotificationsInboxRepository({
    List<NotificationEntry>? initialEntries,
  }) : _entries = List<NotificationEntry>.from(
            initialEntries ?? const <NotificationEntry>[]);

  final List<NotificationEntry> _entries;
  final List<String> markedAsRead = <String>[];
  final List<String> deletedNotifications = <String>[];

  @override
  Future<void> appendFromPayload(IncomingNotification payload) async {
    final entry = NotificationEntry(
      id: NotificationId('test-${DateTime.now().millisecondsSinceEpoch}'),
      type: payload.type,
      channel: payload.channel,
      title: payload.title,
      body: payload.body,
      data: payload.data,
      orderId: payload.orderId,
      receivedAt: payload.receivedAt,
    );
    _entries.add(entry);
  }

  @override
  Stream<List<NotificationEntry>> watchNotifications() {
    return Stream<List<NotificationEntry>>.value(
        List<NotificationEntry>.unmodifiable(_entries));
  }

  @override
  Future<List<NotificationEntry>> getNotifications({
    int limit = 50,
    DateTime? since,
  }) async {
    var result = List<NotificationEntry>.from(_entries);
    if (since != null) {
      result = result.where((e) => e.receivedAt.isAfter(since)).toList();
    }
    if (result.length > limit) {
      result = result.sublist(0, limit);
    }
    return result;
  }

  @override
  Future<void> markAsRead(NotificationId id) async {
    markedAsRead.add(id.value);
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index != -1) {
      _entries[index] = _entries[index].markAsRead(DateTime.now());
    }
  }

  @override
  Future<void> markAllAsRead() async {
    for (var i = 0; i < _entries.length; i++) {
      _entries[i] = _entries[i].markAsRead(DateTime.now());
    }
  }

  @override
  Future<void> clearAll() async {
    _entries.clear();
  }

  @override
  Future<void> deleteNotification(NotificationId id) async {
    deletedNotifications.add(id.value);
    _entries.removeWhere((entry) => entry.id == id);
  }

  @override
  Future<int> getUnreadCount() async {
    return _entries.where((e) => e.isUnread).length;
  }
}

/// Build a notification view model for testing.
NotificationListItemViewModel buildNotificationViewModel({
  required String id,
  NotificationType type = NotificationType.promotion,
  NotificationAction? action,
  DateTime? timestamp,
  bool isUnread = true,
  Map<String, String> metadata = const <String, String>{},
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

NotificationAction _defaultActionForType(NotificationType type) {
  switch (type) {
    case NotificationType.orderStatusUpdate:
      return const NotificationActionOpenOrderDetails('order-id');
    case NotificationType.promotion:
      return const NotificationActionOpenPromotions();
    case NotificationType.system:
      return const NotificationActionOpenSystemMessage(
          messageId: 'system-message');
  }
}

/// Build a notification entry for testing.
NotificationEntry buildNotificationEntry({
  required String id,
  required NotificationType type,
  NotificationReadStatus readStatus = NotificationReadStatus.unread,
  DateTime? receivedAt,
}) {
  return NotificationEntry(
    id: NotificationId(id),
    type: type,
    channel: _channelForType(type),
    title: 'title $id',
    body: 'body $id',
    data: const <String, String>{},
    receivedAt: receivedAt ?? DateTime(2025, 1, 1),
    readStatus: readStatus,
  );
}

NotificationChannel _channelForType(NotificationType type) {
  switch (type) {
    case NotificationType.orderStatusUpdate:
      return NotificationChannel.orderUpdates;
    case NotificationType.promotion:
      return NotificationChannel.promotions;
    case NotificationType.system:
      return NotificationChannel.system;
  }
}

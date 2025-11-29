/// Notifications inbox infra providers and contracts.
/// This file offers light-weight placeholders that mirror the expected
/// contracts from `notifications_shims`. They can be overridden in app wiring
/// with real implementations without touching UX code.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Supported notification categories surfaced to the UX layer.
enum NotificationType {
  orderStatus,
  promotion,
  system,
}

/// Read status for notifications.
enum NotificationReadStatus {
  unread,
  read,
}

/// Minimal snapshot of a notification entry stored in the inbox repository.
@immutable
class NotificationEntry {
  const NotificationEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.receivedAt,
    this.readStatus = NotificationReadStatus.unread,
    this.data = const <String, dynamic>{},
  });

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime receivedAt;
  final NotificationReadStatus readStatus;
  final Map<String, dynamic> data;

  String? get orderId => data['orderId'] as String?;
  String? get messageId => data['messageId'] as String?;

  NotificationEntry copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    DateTime? receivedAt,
    NotificationReadStatus? readStatus,
    Map<String, dynamic>? data,
  }) {
    return NotificationEntry(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      receivedAt: receivedAt ?? this.receivedAt,
      readStatus: readStatus ?? this.readStatus,
      data: data ?? this.data,
    );
  }
}

/// Repository contract surfaced by notifications shims.
abstract class NotificationsInboxRepository {
  Stream<List<NotificationEntry>> watchNotifications();
  Future<List<NotificationEntry>> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> clearAll();
  Future<void> deleteNotification(String id);
}

/// No-op repository used in clean builds until infra wiring is available.
class NoOpNotificationsInboxRepository implements NotificationsInboxRepository {
  const NoOpNotificationsInboxRepository();

  @override
  Future<void> clearAll() async {}

  @override
  Future<List<NotificationEntry>> getNotifications() async {
    return const <NotificationEntry>[];
  }

  @override
  Future<void> markAllAsRead() async {}

  @override
  Future<void> markAsRead(String id) async {}

  @override
  Stream<List<NotificationEntry>> watchNotifications() {
    return Stream<List<NotificationEntry>>.value(const <NotificationEntry>[]);
  }

  @override
  Future<void> deleteNotification(String id) async {}
}

/// Provider exposing the inbox repository.
final notificationsInboxRepositoryProvider = Provider<NotificationsInboxRepository>((ref) {
  return const NoOpNotificationsInboxRepository();
});

/// Convenience provider exposing the repository stream for UI experiments.
final notificationsInboxStreamProvider = StreamProvider<List<NotificationEntry>>((ref) {
  final repository = ref.watch(notificationsInboxRepositoryProvider);
  return repository.watchNotifications();
});


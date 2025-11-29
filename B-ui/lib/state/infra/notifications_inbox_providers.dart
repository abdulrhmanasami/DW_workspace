import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:notifications_shims/notifications_shims.dart';

import 'notifications_providers.dart';

final notificationsInboxRepositoryProvider =
    Provider<NotificationsInboxRepository>((ref) {
      return createLocalNotificationsInboxRepository();
    });

final notificationsInboxStreamProvider =
    StreamProvider<List<NotificationEntry>>((ref) async* {
      final inboxRepo = ref.watch(notificationsInboxRepositoryProvider);
      yield* inboxRepo.watchNotifications();
    });

final unreadNotificationsCountProvider = FutureProvider<int>((ref) {
  final inboxRepo = ref.watch(notificationsInboxRepositoryProvider);
  return inboxRepo.getUnreadCount();
});

final notificationsInboxSyncProvider = Provider<Future<void>>((ref) async {
  final inboxRepo = ref.read(notificationsInboxRepositoryProvider);
  final pushService = ref.read(pushNotificationServiceProvider);

  pushService.onForegroundNotification.listen(inboxRepo.appendFromPayload);
  pushService.onNotificationTap.listen(inboxRepo.appendFromPayload);

  await inboxRepo.getNotifications();
});

final notificationInboxOperationsProvider =
    Provider<NotificationInboxOperations>((ref) {
      final inboxRepo = ref.read(notificationsInboxRepositoryProvider);
      return NotificationInboxOperations._(inboxRepo);
    });

class NotificationInboxOperations {
  NotificationInboxOperations._(this._repository);

  final NotificationsInboxRepository _repository;

  Future<List<NotificationEntry>> getNotifications({
    int limit = 50,
    DateTime? since,
  }) => _repository.getNotifications(limit: limit, since: since);

  Future<void> markAsRead(NotificationId id) => _repository.markAsRead(id);

  Future<void> deleteNotification(NotificationId id) =>
      _repository.deleteNotification(id);

  Future<void> clearAll() => _repository.clearAll();

  Future<void> markAllAsRead() => _repository.markAllAsRead();

  Future<int> getUnreadCount() => _repository.getUnreadCount();
}

NotificationsInboxRepository createLocalNotificationsInboxRepository({
  DateTime Function()? clock,
}) {
  return _InMemoryNotificationsInboxRepository(clock ?? DateTime.now);
}

class _InMemoryNotificationsInboxRepository
    implements NotificationsInboxRepository {
  _InMemoryNotificationsInboxRepository(this._clock);

  final DateTime Function() _clock;
  final List<NotificationEntry> _entries = <NotificationEntry>[];
  final StreamController<List<NotificationEntry>> _controller =
      StreamController<List<NotificationEntry>>.broadcast();

  @override
  Future<void> appendFromPayload(IncomingNotification payload) async {
    final entry = NotificationEntry(
      id: NotificationId(payload.data['id'] ?? _generateId()),
      type: payload.type,
      channel: payload.channel,
      title: payload.title,
      body: payload.body,
      data: payload.data,
      orderId: payload.orderId,
      receivedAt: payload.receivedAt,
    );
    _entries.insert(0, entry);
    _notify();
  }

  @override
  Future<List<NotificationEntry>> getNotifications({
    int limit = 50,
    DateTime? since,
  }) async {
    final entries = List<NotificationEntry>.from(_entries);
    final filtered = since != null
        ? entries.where((entry) => entry.receivedAt.isAfter(since)).toList()
        : entries;
    if (filtered.length <= limit) {
      return filtered;
    }
    return filtered.sublist(0, limit);
  }

  @override
  Stream<List<NotificationEntry>> watchNotifications() async* {
    yield List<NotificationEntry>.from(_entries);
    yield* _controller.stream;
  }

  @override
  Future<void> markAsRead(NotificationId id) async {
    _updateEntry(
      id,
      (entry) => entry.markAsRead(_clock()),
    );
  }

  @override
  Future<void> deleteNotification(NotificationId id) async {
    _entries.removeWhere((entry) => entry.id == id);
    _notify();
  }

  @override
  Future<void> clearAll() async {
    _entries.clear();
    _notify();
  }

  @override
  Future<int> getUnreadCount() async {
    return _entries.where((entry) => entry.isUnread).length;
  }

  @override
  Future<void> markAllAsRead() async {
    final now = _clock();
    for (var i = 0; i < _entries.length; i++) {
      _entries[i] = _entries[i].markAsRead(now);
    }
    _notify();
  }

  void _updateEntry(
    NotificationId id,
    NotificationEntry Function(NotificationEntry entry) transform,
  ) {
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index == -1) {
      return;
    }
    _entries[index] = transform(_entries[index]);
    _notify();
  }

  void _notify() {
    _controller.add(List<NotificationEntry>.from(_entries));
  }

  String _generateId() => _clock().microsecondsSinceEpoch.toString();
}

/// Notifications Inbox UX Providers
/// Builds Inbox presentation models, empty states, and controllers for B-ui.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notifications_shims/notifications_shims.dart';

import '../infra/notifications_inbox_providers.dart';
import 'notification_preferences_ux.dart';

sealed class NotificationAction {
  const NotificationAction({this.analyticsLabel});

  final String? analyticsLabel;
}

class NotificationActionOpenOrderDetails extends NotificationAction {
  const NotificationActionOpenOrderDetails(this.orderId) : super(analyticsLabel: 'open_order_details');

  final String orderId;
}

class NotificationActionOpenPromotions extends NotificationAction {
  const NotificationActionOpenPromotions() : super(analyticsLabel: 'open_promotions');
}

class NotificationActionOpenSystemMessage extends NotificationAction {
  const NotificationActionOpenSystemMessage({this.messageId}) : super(analyticsLabel: 'open_system_message');

  final String? messageId;
}

class NotificationActionOpenSettings extends NotificationAction {
  const NotificationActionOpenSettings() : super(analyticsLabel: 'open_notification_settings');
}

class NotificationActionOpenHome extends NotificationAction {
  const NotificationActionOpenHome() : super(analyticsLabel: 'open_home');
}

@immutable
class NotificationListItemViewModel {
  const NotificationListItemViewModel({
    required this.rawId,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.isUnread,
    required this.type,
    required this.action,
    required this.semanticsLabel,
  });

  final Object rawId;
  final String id;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final bool isUnread;
  final NotificationType type;
  final NotificationAction action;
  final String semanticsLabel;

  NotificationId? get asNotificationId => rawId is NotificationId ? rawId as NotificationId : null;

  NotificationListItemViewModel copyWith({
    Object? rawId,
    String? id,
    String? title,
    String? subtitle,
    DateTime? timestamp,
    bool? isUnread,
    NotificationType? type,
    NotificationAction? action,
    String? semanticsLabel,
  }) {
    return NotificationListItemViewModel(
      rawId: rawId ?? this.rawId,
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      timestamp: timestamp ?? this.timestamp,
      isUnread: isUnread ?? this.isUnread,
      type: type ?? this.type,
      action: action ?? this.action,
      semanticsLabel: semanticsLabel ?? this.semanticsLabel,
    );
  }

  factory NotificationListItemViewModel.fromSnapshot(NotificationInboxSnapshot snapshot) {
    final action = _actionForSnapshot(snapshot);
    final semantics = '${snapshot.title} · ${snapshot.subtitle} · ${snapshot.timestamp.toIso8601String()}';
    return NotificationListItemViewModel(
      rawId: snapshot.backendId,
      id: _stringifyNotificationId(snapshot.backendId),
      title: snapshot.title,
      subtitle: snapshot.subtitle,
      timestamp: snapshot.timestamp,
      isUnread: snapshot.isUnread,
      type: snapshot.type,
      action: action,
      semanticsLabel: semantics,
    );
  }
}

@immutable
class NotificationsEmptyStateViewModel {
  const NotificationsEmptyStateViewModel({
    required this.isEmpty,
    required this.isLoading,
    required this.hasError,
    required this.hasNotifications,
    required this.totalNotifications,
    this.titleKey,
    this.descriptionKey,
    this.primaryAction,
  });

  final bool isEmpty;
  final bool isLoading;
  final bool hasError;
  final bool hasNotifications;
  final int totalNotifications;
  final String? titleKey;
  final String? descriptionKey;
  final NotificationAction? primaryAction;

  factory NotificationsEmptyStateViewModel.loading() => const NotificationsEmptyStateViewModel(
        isEmpty: false,
        isLoading: true,
        hasError: false,
        hasNotifications: false,
        totalNotifications: 0,
      );

  factory NotificationsEmptyStateViewModel.error() => const NotificationsEmptyStateViewModel(
        isEmpty: true,
        isLoading: false,
        hasError: true,
        hasNotifications: false,
        totalNotifications: 0,
        titleKey: 'notifications_inbox.error.title',
        descriptionKey: 'notifications_inbox.error.description',
        primaryAction: NotificationActionOpenHome(),
      );

  factory NotificationsEmptyStateViewModel.empty() => const NotificationsEmptyStateViewModel(
        isEmpty: true,
        isLoading: false,
        hasError: false,
        hasNotifications: false,
        totalNotifications: 0,
        titleKey: 'notifications_inbox.empty.title',
        descriptionKey: 'notifications_inbox.empty.description',
        primaryAction: NotificationActionOpenHome(),
      );

  factory NotificationsEmptyStateViewModel.withData(int total) => NotificationsEmptyStateViewModel(
        isEmpty: false,
        isLoading: false,
        hasError: false,
        hasNotifications: true,
        totalNotifications: total,
        primaryAction: null,
        titleKey: null,
        descriptionKey: null,
      );
}

@immutable
class NotificationInboxSnapshot {
  const NotificationInboxSnapshot({
    required this.backendId,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.type,
    required this.isUnread,
    this.orderId,
    this.actionPayload,
  });

  final Object backendId;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final NotificationType type;
  final bool isUnread;
  final String? orderId;
  final Map<String, dynamic>? actionPayload;

  factory NotificationInboxSnapshot.fromEntry(NotificationEntry entry) {
    return NotificationInboxSnapshot(
      backendId: entry.id,
      title: entry.title,
      subtitle: entry.body,
      timestamp: entry.receivedAt,
      type: entry.type,
      isUnread: entry.readStatus == NotificationReadStatus.unread,
      orderId: _extractOrderId(entry),
      actionPayload: _extractActionPayload(entry),
    );
  }
}

final notificationsInboxUxProvider = StreamProvider<List<NotificationListItemViewModel>>((ref) {
  final repository = ref.watch(notificationsInboxRepositoryProvider);
  final preferencesAsync = ref.watch(notificationPreferencesUxControllerProvider);

  return repository.watchNotifications().map((entries) {
    final snapshots = entries.map(NotificationInboxSnapshot.fromEntry).toList();
    final preferences = preferencesAsync.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    return buildNotificationListItems(
      snapshots: snapshots,
      preferences: preferences,
    );
  }).handleError((error, stackTrace) {
    debugPrint('notificationsInboxUxProvider stream error: $error');
  });
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final inbox = ref.watch(notificationsInboxUxProvider);
  return inbox.maybeWhen(
    data: (items) => items.where((item) => item.isUnread).length,
    orElse: () => 0,
  );
});

final notificationsInboxEmptyStateProvider = Provider<NotificationsEmptyStateViewModel>((ref) {
  final inbox = ref.watch(notificationsInboxUxProvider);

  if (inbox.isLoading) {
    return NotificationsEmptyStateViewModel.loading();
  }

  if (inbox.hasError) {
    return NotificationsEmptyStateViewModel.error();
  }

  final items = inbox.asData?.value ?? const <NotificationListItemViewModel>[];
  if (items.isEmpty) {
    return NotificationsEmptyStateViewModel.empty();
  }

  return NotificationsEmptyStateViewModel.withData(items.length);
});

final promotionsNotificationsUxProvider = Provider<AsyncValue<List<NotificationListItemViewModel>>>((ref) {
  final inbox = ref.watch(notificationsInboxUxProvider);
  return inbox.whenData(
    (items) => _filterByType(items, NotificationType.promotion),
  );
});

final promotionsNotificationsEmptyStateProvider = Provider<NotificationsEmptyStateViewModel>((ref) {
  final promotions = ref.watch(promotionsNotificationsUxProvider);
  return _buildEmptyStateForFilteredList(
    promotions,
    emptyTitleKey: 'notifications_promotions.empty.title',
    emptyDescriptionKey: 'notifications_promotions.empty.description',
    primaryAction: const NotificationActionOpenHome(),
  );
});

final systemNotificationsUxProvider = Provider<AsyncValue<List<NotificationListItemViewModel>>>((ref) {
  final inbox = ref.watch(notificationsInboxUxProvider);
  return inbox.whenData(
    (items) => _filterByType(items, NotificationType.system),
  );
});

final systemNotificationsEmptyStateProvider = Provider<NotificationsEmptyStateViewModel>((ref) {
  final system = ref.watch(systemNotificationsUxProvider);
  return _buildEmptyStateForFilteredList(
    system,
    emptyTitleKey: 'notifications_system.empty.title',
    emptyDescriptionKey: 'notifications_system.empty.description',
  );
});

@immutable
class SystemNotificationDetailViewModel {
  const SystemNotificationDetailViewModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.isUnread,
    this.messageId,
  });

  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isUnread;
  final String? messageId;
}

final systemNotificationDetailUxProvider =
    FutureProvider.family<SystemNotificationDetailViewModel, String>((ref, messageId) async {
  final cached = ref.watch(systemNotificationsUxProvider).maybeWhen(
        data: (value) => value,
        orElse: () => null,
      );

  if (cached != null) {
    final match = _findSystemMessage(cached, messageId);
    if (match != null) {
      return _toSystemDetail(match);
    }
  }

  final latestInbox = await ref.watch(notificationsInboxUxProvider.future);
  final systemItems = _filterByType(latestInbox, NotificationType.system);
  final match = _findSystemMessage(systemItems, messageId);
  if (match == null) {
    throw StateError('System notification with id=$messageId not found');
  }
  return _toSystemDetail(match);
});

class NotificationsInboxUxController extends AsyncNotifier<void> {
  NotificationsInboxRepository get _repository => ref.read(notificationsInboxRepositoryProvider);

  @override
  FutureOr<void> build() {}

  Future<void> markAsRead(NotificationListItemViewModel item) => markAsReadById(item.rawId);

  Future<void> markAsReadById(Object backendId) async {
    final notificationId = _requireNotificationId(backendId);
    state = const AsyncLoading();
    try {
      await _repository.markAsRead(notificationId);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      _logError('markAsRead', error, stackTrace);
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> markAllAsRead() async {
    state = const AsyncLoading();
    try {
      await _repository.markAllAsRead();
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      _logError('markAllAsRead', error, stackTrace);
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> clearAll() async {
    state = const AsyncLoading();
    try {
      await _repository.clearAll();
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      _logError('clearAll', error, stackTrace);
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> clearOlderThan(Duration maxAge) async {
    state = const AsyncLoading();
    try {
      final entries = await _repository.getNotifications();
      final threshold = DateTime.now().subtract(maxAge);
      for (final entry in entries) {
        if (entry.receivedAt.isBefore(threshold)) {
          await _repository.deleteNotification(entry.id);
        }
      }
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      _logError('clearOlderThan', error, stackTrace);
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> deleteNotificationById(Object backendId) async {
    final notificationId = _requireNotificationId(backendId);
    state = const AsyncLoading();
    try {
      await _repository.deleteNotification(notificationId);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      _logError('deleteNotificationById', error, stackTrace);
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> markAllOfTypeAsRead(NotificationType type) async {
    state = const AsyncLoading();
    try {
      final entries = await _repository.getNotifications();
      for (final entry in entries.where(
        (entry) => entry.type == type && entry.readStatus == NotificationReadStatus.unread,
      )) {
        await _repository.markAsRead(entry.id);
      }
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      _logError('markAllOfTypeAsRead', error, stackTrace);
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> clearAllOfType(NotificationType type) async {
    state = const AsyncLoading();
    try {
      final entries = await _repository.getNotifications();
      for (final entry in entries.where((entry) => entry.type == type)) {
        await _repository.deleteNotification(entry.id);
      }
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      _logError('clearAllOfType', error, stackTrace);
      state = AsyncError(error, stackTrace);
    }
  }

  void _logError(String action, Object error, StackTrace stackTrace) {
    debugPrint('NotificationsInboxUxController:$action error=$error stack=$stackTrace');
  }

  NotificationId _requireNotificationId(Object backendId) {
    if (backendId is NotificationId) {
      return backendId;
    }
    return backendId as NotificationId;
  }
}

final notificationsInboxControllerProvider =
    AsyncNotifierProvider<NotificationsInboxUxController, void>(NotificationsInboxUxController.new);

class PromotionsNotificationsUxController {
  const PromotionsNotificationsUxController(this._controller);

  final NotificationsInboxUxController _controller;

  Future<void> markPromotionAsRead(Object backendId) => _controller.markAsReadById(backendId);
  Future<void> markAllPromotionsAsRead() => _controller.markAllOfTypeAsRead(NotificationType.promotion);
  Future<void> clearPromotion(Object backendId) => _controller.deleteNotificationById(backendId);
  Future<void> clearAllPromotions() => _controller.clearAllOfType(NotificationType.promotion);
}

final promotionsNotificationsUxControllerProvider = Provider<PromotionsNotificationsUxController>((ref) {
  final controller = ref.watch(notificationsInboxControllerProvider.notifier);
  return PromotionsNotificationsUxController(controller);
});

class SystemNotificationsUxController {
  const SystemNotificationsUxController(this._controller);

  final NotificationsInboxUxController _controller;

  Future<void> markAllSystemMessagesAsRead() => _controller.markAllOfTypeAsRead(NotificationType.system);
  Future<void> markSystemMessageAsRead(Object backendId) => _controller.markAsReadById(backendId);
  Future<void> clearSystemMessage(Object backendId) => _controller.deleteNotificationById(backendId);
  Future<void> clearAllSystemMessages() => _controller.clearAllOfType(NotificationType.system);
}

final systemNotificationsUxControllerProvider = Provider<SystemNotificationsUxController>((ref) {
  final controller = ref.watch(notificationsInboxControllerProvider.notifier);
  return SystemNotificationsUxController(controller);
});

/// Navigation hint to reach notification settings from Inbox entry points.
final notificationsInboxPreferencesActionProvider = Provider<NotificationAction>((ref) {
  return const NotificationActionOpenSettings();
});

@visibleForTesting
List<NotificationListItemViewModel> buildNotificationListItems({
  required List<NotificationInboxSnapshot> snapshots,
  NotificationPreferencesViewModel? preferences,
}) {
  final filtered = snapshots.where((snapshot) {
    if (preferences == null) return true;
    switch (snapshot.type) {
      case NotificationType.orderStatusUpdate:
        return preferences.orderStatusUpdatesEnabled;
      case NotificationType.promotion:
        return preferences.promotionsEnabled && preferences.canEditPromotions;
      case NotificationType.system:
        return preferences.systemAlertsEnabled;
    }
  }).toList()
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  return filtered.map(NotificationListItemViewModel.fromSnapshot).toList(growable: false);
}

NotificationAction _actionForSnapshot(NotificationInboxSnapshot snapshot) {
  switch (snapshot.type) {
    case NotificationType.orderStatusUpdate:
      if (snapshot.orderId != null && snapshot.orderId!.isNotEmpty) {
        return NotificationActionOpenOrderDetails(snapshot.orderId!);
      }
      return const NotificationActionOpenHome();
    case NotificationType.promotion:
      return const NotificationActionOpenPromotions();
    case NotificationType.system:
      return NotificationActionOpenSystemMessage(messageId: snapshot.actionPayload?['messageId'] as String?);
  }
}

String _stringifyNotificationId(Object backendId) {
  final dynamic candidate = backendId;
  if (candidate is String) {
    return candidate;
  }
  if (candidate is int) {
    return candidate.toString();
  }
  if (candidate is NotificationId) {
    final dynamic value = candidate;
    if (value is String) {
      return value;
    }
  }
  return backendId.toString();
}

String? _extractOrderId(NotificationEntry entry) {
  try {
    final dynamic dynamicEntry = entry;
    final orderId = dynamicEntry.orderId;
    if (orderId is String && orderId.isNotEmpty) {
      return orderId;
    }
  } catch (_) {
    // Optional metadata
  }
  return null;
}

Map<String, dynamic>? _extractActionPayload(NotificationEntry entry) {
  try {
    final dynamic dynamicEntry = entry;
    final payload = dynamicEntry.actionPayload;
    if (payload is Map<String, dynamic>) {
      return payload;
    }
  } catch (_) {
    // Optional metadata
  }
  return null;
}

List<NotificationListItemViewModel> _filterByType(
  List<NotificationListItemViewModel> items,
  NotificationType type,
) {
  if (items.isEmpty) {
    return const <NotificationListItemViewModel>[];
  }
  return _sortByTimestampDesc(items.where((item) => item.type == type).toList());
}

NotificationListItemViewModel? _findSystemMessage(
  List<NotificationListItemViewModel> items,
  String messageId,
) {
  for (final item in items) {
    final candidateId = _systemMessageId(item);
    if (candidateId == messageId || item.id == messageId) {
      return item;
    }
  }
  return null;
}

SystemNotificationDetailViewModel _toSystemDetail(NotificationListItemViewModel source) {
  return SystemNotificationDetailViewModel(
    id: source.id,
    title: source.title,
    body: source.subtitle,
    timestamp: source.timestamp,
    isUnread: source.isUnread,
    messageId: _systemMessageId(source),
  );
}

String? _systemMessageId(NotificationListItemViewModel source) {
  final action = source.action;
  if (action is NotificationActionOpenSystemMessage) {
    return action.messageId ?? source.id;
  }
  return null;
}

NotificationsEmptyStateViewModel _buildEmptyStateForFilteredList(
  AsyncValue<List<NotificationListItemViewModel>> asyncItems, {
  required String emptyTitleKey,
  required String emptyDescriptionKey,
  NotificationAction? primaryAction,
}) {
  if (asyncItems.isLoading) {
    return NotificationsEmptyStateViewModel.loading();
  }

  if (asyncItems.hasError) {
    return NotificationsEmptyStateViewModel.error();
  }

  final items = asyncItems.asData?.value ?? const <NotificationListItemViewModel>[];
  if (items.isEmpty) {
    return NotificationsEmptyStateViewModel(
      isEmpty: true,
      isLoading: false,
      hasError: false,
      hasNotifications: false,
      totalNotifications: 0,
      titleKey: emptyTitleKey,
      descriptionKey: emptyDescriptionKey,
      primaryAction: primaryAction,
    );
  }

  return NotificationsEmptyStateViewModel.withData(items.length);
}

List<NotificationListItemViewModel> _sortByTimestampDesc(List<NotificationListItemViewModel> items) {
  if (items.length <= 1) {
    return items;
  }
  items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return items;
}


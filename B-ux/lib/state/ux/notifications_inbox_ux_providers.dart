/// Notifications Inbox UX Providers
/// Created by: Cursor B-ux
/// Purpose: UX providers for notifications inbox with Sale-Only behavior
/// Last updated: 2025-11-25

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:b_ux/state/infra/notifications_inbox_providers.dart';
import 'package:b_ux/state/infra/notifications_providers.dart';
import 'notification_preferences_ux.dart';

// ============================================================================
// Actions
// ============================================================================

sealed class NotificationAction {
  const NotificationAction({this.analyticsLabel});

  final String? analyticsLabel;
}

class NotificationActionOpenOrderDetails extends NotificationAction {
  const NotificationActionOpenOrderDetails(this.orderId)
      : super(analyticsLabel: 'open_order_details');

  final String orderId;
}

class NotificationActionOpenPromotions extends NotificationAction {
  const NotificationActionOpenPromotions()
      : super(analyticsLabel: 'open_promotions');
}

class NotificationActionOpenSystemMessage extends NotificationAction {
  const NotificationActionOpenSystemMessage({this.messageId})
      : super(analyticsLabel: 'open_system_message');

  final String? messageId;
}

class NotificationActionOpenSettings extends NotificationAction {
  const NotificationActionOpenSettings()
      : super(analyticsLabel: 'open_notification_settings');
}

class NotificationActionOpenHome extends NotificationAction {
  const NotificationActionOpenHome() : super(analyticsLabel: 'open_home');
}

// ============================================================================
// View Models
// ============================================================================

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
    required this.metadata,
  });

  final String rawId;
  final String id;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final bool isUnread;
  final NotificationType type;
  final NotificationAction action;
  final String semanticsLabel;
  final Map<String, String> metadata;

  NotificationListItemViewModel copyWith({
    String? rawId,
    String? id,
    String? title,
    String? subtitle,
    DateTime? timestamp,
    bool? isUnread,
    NotificationType? type,
    NotificationAction? action,
    String? semanticsLabel,
    Map<String, String>? metadata,
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
      metadata: metadata ?? this.metadata,
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
    required this.isFeatureAvailable,
    this.titleKey,
    this.descriptionKey,
    this.primaryAction,
  });

  final bool isEmpty;
  final bool isLoading;
  final bool hasError;
  final bool hasNotifications;
  final int totalNotifications;
  final bool isFeatureAvailable;
  final String? titleKey;
  final String? descriptionKey;
  final NotificationAction? primaryAction;

  factory NotificationsEmptyStateViewModel.loading() =>
      const NotificationsEmptyStateViewModel(
        isEmpty: false,
        isLoading: true,
        hasError: false,
        hasNotifications: false,
        totalNotifications: 0,
        isFeatureAvailable: true,
      );

  factory NotificationsEmptyStateViewModel.error() =>
      const NotificationsEmptyStateViewModel(
        isEmpty: true,
        isLoading: false,
        hasError: true,
        hasNotifications: false,
        totalNotifications: 0,
        isFeatureAvailable: true,
        titleKey: 'notifications_inbox_error_title',
        descriptionKey: 'notifications_inbox_error_description',
        primaryAction: NotificationActionOpenHome(),
      );

  factory NotificationsEmptyStateViewModel.empty() =>
      const NotificationsEmptyStateViewModel(
        isEmpty: true,
        isLoading: false,
        hasError: false,
        hasNotifications: false,
        totalNotifications: 0,
        isFeatureAvailable: true,
        titleKey: 'notifications_inbox_empty_title',
        descriptionKey: 'notifications_inbox_empty_description',
        primaryAction: NotificationActionOpenHome(),
      );

  factory NotificationsEmptyStateViewModel.unavailable() =>
      const NotificationsEmptyStateViewModel(
        isEmpty: true,
        isLoading: false,
        hasError: false,
        hasNotifications: false,
        totalNotifications: 0,
        isFeatureAvailable: false,
        titleKey: 'notifications_unavailable_title',
        descriptionKey: 'notifications_unavailable_description',
        primaryAction: null,
      );

  factory NotificationsEmptyStateViewModel.withData(int total) =>
      NotificationsEmptyStateViewModel(
        isEmpty: false,
        isLoading: false,
        hasError: false,
        hasNotifications: true,
        totalNotifications: total,
        isFeatureAvailable: true,
        primaryAction: null,
      );
}

@immutable
class NotificationInboxSnapshot {
  const NotificationInboxSnapshot({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.isUnread,
    required this.metadata,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final bool isUnread;
  final Map<String, String> metadata;

  factory NotificationInboxSnapshot.fromEntry(NotificationEntry entry) {
    return NotificationInboxSnapshot(
      id: entry.id.value,
      type: entry.type,
      title: entry.title,
      subtitle: entry.body,
      timestamp: entry.receivedAt,
      isUnread: entry.isUnread,
      metadata: entry.data,
    );
  }
}

// ============================================================================
// Providers
// ============================================================================

final notificationsInboxUxProvider =
    StreamProvider<List<NotificationListItemViewModel>>((ref) {
  final availability = ref.watch(notificationsAvailabilityProvider);

  if (!availability.isAvailable) {
    return Stream<List<NotificationListItemViewModel>>.value(
        const <NotificationListItemViewModel>[]);
  }

  final repository = ref.watch(notificationsInboxRepositoryProvider);
  final preferencesAsync =
      ref.watch(notificationPreferencesUxControllerProvider);

  return repository.watchNotifications().map((entries) {
    final snapshots =
        entries.map(NotificationInboxSnapshot.fromEntry).toList();
    final prefs = preferencesAsync.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    return buildNotificationListItems(
      snapshots: snapshots,
      preferences: prefs,
    );
  }).handleError((error, stackTrace) {
    debugPrint('notificationsInboxUxProvider error: $error');
  });
});

final unreadNotificationsUxCountProvider = Provider<int>((ref) {
  final availability = ref.watch(notificationsAvailabilityProvider);

  if (!availability.isAvailable) {
    return 0;
  }

  final inbox = ref.watch(notificationsInboxUxProvider);
  return inbox.maybeWhen(
    data: (items) => items.where((item) => item.isUnread).length,
    orElse: () => 0,
  );
});

final notificationsInboxEmptyStateProvider =
    Provider<NotificationsEmptyStateViewModel>((ref) {
  final availability = ref.watch(notificationsAvailabilityProvider);

  if (!availability.isAvailable) {
    return NotificationsEmptyStateViewModel.unavailable();
  }

  final inbox = ref.watch(notificationsInboxUxProvider);

  if (inbox.isLoading) {
    return NotificationsEmptyStateViewModel.loading();
  }

  if (inbox.hasError) {
    return NotificationsEmptyStateViewModel.error();
  }

  final items =
      inbox.asData?.value ?? const <NotificationListItemViewModel>[];
  if (items.isEmpty) {
    return NotificationsEmptyStateViewModel.empty();
  }

  return NotificationsEmptyStateViewModel.withData(items.length);
});

final promotionsNotificationsUxProvider =
    Provider<AsyncValue<List<NotificationListItemViewModel>>>((ref) {
  final availability = ref.watch(notificationsAvailabilityProvider);

  if (!availability.isAvailable) {
    return const AsyncValue.data(<NotificationListItemViewModel>[]);
  }

  final inbox = ref.watch(notificationsInboxUxProvider);
  return inbox.whenData(
    (items) => _filterByType(items, NotificationType.promotion),
  );
});

final promotionsNotificationsEmptyStateProvider =
    Provider<NotificationsEmptyStateViewModel>((ref) {
  final availability = ref.watch(notificationsAvailabilityProvider);

  if (!availability.isAvailable) {
    return NotificationsEmptyStateViewModel.unavailable();
  }

  final promotions = ref.watch(promotionsNotificationsUxProvider);
  return _buildEmptyStateForFilteredList(
    promotions,
    emptyTitleKey: 'notifications_promotions_empty_title',
    emptyDescriptionKey: 'notifications_promotions_empty_description',
    primaryAction: const NotificationActionOpenPromotions(),
  );
});

final systemNotificationsUxProvider =
    Provider<AsyncValue<List<NotificationListItemViewModel>>>((ref) {
  final availability = ref.watch(notificationsAvailabilityProvider);

  if (!availability.isAvailable) {
    return const AsyncValue.data(<NotificationListItemViewModel>[]);
  }

  final inbox = ref.watch(notificationsInboxUxProvider);
  return inbox.whenData(
    (items) => _filterByType(items, NotificationType.system),
  );
});

final systemNotificationsEmptyStateProvider =
    Provider<NotificationsEmptyStateViewModel>((ref) {
  final availability = ref.watch(notificationsAvailabilityProvider);

  if (!availability.isAvailable) {
    return NotificationsEmptyStateViewModel.unavailable();
  }

  final system = ref.watch(systemNotificationsUxProvider);
  return _buildEmptyStateForFilteredList(
    system,
    emptyTitleKey: 'notifications_system_empty_title',
    emptyDescriptionKey: 'notifications_system_empty_description',
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
    this.metadata,
  });

  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isUnread;
  final Map<String, String>? metadata;
}

final systemNotificationDetailUxProvider =
    FutureProvider.family<SystemNotificationDetailViewModel, String>(
        (ref, messageId) async {
  final availability = ref.watch(notificationsAvailabilityProvider);

  if (!availability.isAvailable) {
    throw StateError('Notifications feature is not available');
  }

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
    throw StateError(
        'System notification with messageId=$messageId not found');
  }
  return _toSystemDetail(match);
});

// ============================================================================
// Controllers
// ============================================================================

class NotificationsInboxUxController extends AsyncNotifier<void> {
  NotificationsInboxRepository get _repository =>
      ref.read(notificationsInboxRepositoryProvider);
  NotificationsAvailabilityState get _availability =>
      ref.read(notificationsAvailabilityProvider);

  @override
  FutureOr<void> build() {}

  Future<void> markAsRead(NotificationListItemViewModel item) =>
      markAsReadById(item.rawId);

  Future<void> markAsReadById(String notificationId) async {
    if (!_availability.isAvailable) return;

    state = const AsyncLoading();
    try {
      await _repository.markAsRead(NotificationId(notificationId));
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      _logError('markAsRead', error, stackTrace);
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> deleteNotificationById(String notificationId) async {
    if (!_availability.isAvailable) return;

    state = const AsyncLoading();
    try {
      await _repository.deleteNotification(NotificationId(notificationId));
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      _logError('deleteNotification', error, stackTrace);
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> markAllAsRead() async {
    if (!_availability.isAvailable) return;

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
    if (!_availability.isAvailable) return;

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
    if (!_availability.isAvailable) return;

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

  Future<void> markAllOfTypeAsRead(NotificationType type) async {
    if (!_availability.isAvailable) return;

    state = const AsyncLoading();
    try {
      final entries = await _repository.getNotifications();
      for (final entry
          in entries.where((e) => e.type == type && e.isUnread)) {
        await _repository.markAsRead(entry.id);
      }
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      _logError('markAllOfTypeAsRead', error, stackTrace);
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> clearAllOfType(NotificationType type) async {
    if (!_availability.isAvailable) return;

    state = const AsyncLoading();
    try {
      final entries = await _repository.getNotifications();
      for (final entry in entries.where((e) => e.type == type)) {
        await _repository.deleteNotification(entry.id);
      }
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      _logError('clearAllOfType', error, stackTrace);
      state = AsyncError(error, stackTrace);
    }
  }

  void _logError(String action, Object error, StackTrace stackTrace) {
    debugPrint(
        'NotificationsInboxUxController.$action error=$error stack=$stackTrace');
  }
}

final notificationsInboxControllerProvider =
    AsyncNotifierProvider<NotificationsInboxUxController, void>(
        NotificationsInboxUxController.new);

class PromotionsNotificationsUxController {
  PromotionsNotificationsUxController(this._controller);

  final NotificationsInboxUxController _controller;

  Future<void> markPromotionAsRead(String notificationId) =>
      _controller.markAsReadById(notificationId);
  Future<void> markAllPromotionsAsRead() =>
      _controller.markAllOfTypeAsRead(NotificationType.promotion);
  Future<void> clearPromotion(String notificationId) =>
      _controller.deleteNotificationById(notificationId);
  Future<void> clearAllPromotions() =>
      _controller.clearAllOfType(NotificationType.promotion);
}

final promotionsNotificationsUxControllerProvider =
    Provider<PromotionsNotificationsUxController>((ref) {
  final controller = ref.watch(notificationsInboxControllerProvider.notifier);
  return PromotionsNotificationsUxController(controller);
});

class SystemNotificationsUxController {
  SystemNotificationsUxController(this._controller);

  final NotificationsInboxUxController _controller;

  Future<void> markSystemMessageAsRead(String notificationId) =>
      _controller.markAsReadById(notificationId);
  Future<void> clearSystemMessage(String notificationId) =>
      _controller.deleteNotificationById(notificationId);
  Future<void> clearAllSystemMessages() =>
      _controller.clearAllOfType(NotificationType.system);
}

final systemNotificationsUxControllerProvider =
    Provider<SystemNotificationsUxController>((ref) {
  final controller = ref.watch(notificationsInboxControllerProvider.notifier);
  return SystemNotificationsUxController(controller);
});

final notificationsInboxPreferencesActionProvider =
    Provider<NotificationAction>((ref) {
  return const NotificationActionOpenSettings();
});

// ============================================================================
// Helpers
// ============================================================================

@visibleForTesting
List<NotificationListItemViewModel> buildNotificationListItems({
  required List<NotificationInboxSnapshot> snapshots,
  NotificationPreferencesViewModel? preferences,
}) {
  final filtered = snapshots.where((snapshot) {
    if (preferences == null) {
      return true;
    }
    if (!preferences.isAvailable) {
      return true;
    }
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

  return filtered.map((snapshot) {
    return NotificationListItemViewModel(
      rawId: snapshot.id,
      id: snapshot.id,
      title: snapshot.title,
      subtitle: snapshot.subtitle,
      timestamp: snapshot.timestamp,
      isUnread: snapshot.isUnread,
      type: snapshot.type,
      action: _actionForSnapshot(snapshot),
      semanticsLabel: '${snapshot.title} · ${snapshot.subtitle}',
      metadata: snapshot.metadata,
    );
  }).toList(growable: false);
}

List<NotificationListItemViewModel> _filterByType(
  List<NotificationListItemViewModel> items,
  NotificationType type,
) {
  return _sortByTimestampDesc(
      items.where((item) => item.type == type).toList());
}

NotificationAction _actionForSnapshot(NotificationInboxSnapshot snapshot) {
  switch (snapshot.type) {
    case NotificationType.orderStatusUpdate:
      final orderId = snapshot.metadata['orderId'];
      if (orderId != null && orderId.isNotEmpty) {
        return NotificationActionOpenOrderDetails(orderId);
      }
      return const NotificationActionOpenHome();
    case NotificationType.promotion:
      return const NotificationActionOpenPromotions();
    case NotificationType.system:
      final messageId = snapshot.metadata['messageId'];
      return NotificationActionOpenSystemMessage(messageId: messageId);
  }
}

NotificationListItemViewModel? _findSystemMessage(
  List<NotificationListItemViewModel> items,
  String messageId,
) {
  for (final item in items) {
    final action = item.action;
    if (action is NotificationActionOpenSystemMessage &&
        action.messageId == messageId) {
      return item;
    }
  }
  return null;
}

SystemNotificationDetailViewModel _toSystemDetail(
    NotificationListItemViewModel source) {
  return SystemNotificationDetailViewModel(
    id: source.id,
    title: source.title,
    body: source.subtitle,
    timestamp: source.timestamp,
    isUnread: source.isUnread,
    metadata: source.metadata.isEmpty ? null : source.metadata,
  );
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

  final items =
      asyncItems.asData?.value ?? const <NotificationListItemViewModel>[];
  if (items.isEmpty) {
    return NotificationsEmptyStateViewModel(
      isEmpty: true,
      isLoading: false,
      hasError: false,
      hasNotifications: false,
      totalNotifications: 0,
      isFeatureAvailable: true,
      titleKey: emptyTitleKey,
      descriptionKey: emptyDescriptionKey,
      primaryAction: primaryAction,
    );
  }

  return NotificationsEmptyStateViewModel.withData(items.length);
}

List<NotificationListItemViewModel> _sortByTimestampDesc(
    List<NotificationListItemViewModel> items) {
  if (items.length <= 1) {
    return items;
  }
  items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return items;
}

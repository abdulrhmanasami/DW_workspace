/// Notifications Inbox Infra Providers
/// Created by: Cursor B-ux
/// Purpose: Riverpod providers for notifications inbox with Sale-Only behavior
/// Last updated: 2025-11-25

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notifications_shims/notifications_shims.dart';

import 'notifications_providers.dart';

export 'package:notifications_shims/notifications_shims.dart'
    show
        NotificationEntry,
        NotificationType,
        NotificationReadStatus,
        NotificationsInboxRepository,
        NotificationId,
        NotificationChannel,
        IncomingNotification;

// ============================================================================
// Disabled Repository (Sale-Only)
// ============================================================================

/// Repository that returns empty state when notifications are disabled.
/// Implements Sale-Only behavior - no fake data.
class DisabledNotificationsInboxRepository
    implements NotificationsInboxRepository {
  const DisabledNotificationsInboxRepository();

  @override
  Future<void> appendFromPayload(IncomingNotification payload) async {
    // No-op: cannot append when feature is disabled
  }

  @override
  Future<List<NotificationEntry>> getNotifications({
    int limit = 50,
    DateTime? since,
  }) async {
    return const <NotificationEntry>[];
  }

  @override
  Stream<List<NotificationEntry>> watchNotifications() {
    return Stream<List<NotificationEntry>>.value(const <NotificationEntry>[]);
  }

  @override
  Future<void> markAsRead(NotificationId id) async {
    // No-op
  }

  @override
  Future<void> deleteNotification(NotificationId id) async {
    // No-op
  }

  @override
  Future<void> clearAll() async {
    // No-op
  }

  @override
  Future<int> getUnreadCount() async {
    return 0;
  }

  @override
  Future<void> markAllAsRead() async {
    // No-op
  }
}

// ============================================================================
// Providers
// ============================================================================

/// Provider exposing the inbox repository.
/// Returns appropriate implementation based on availability status.
final notificationsInboxRepositoryProvider =
    Provider<NotificationsInboxRepository>((ref) {
  final availability = ref.watch(notificationsAvailabilityProvider);

  if (!availability.isAvailable) {
    return const DisabledNotificationsInboxRepository();
  }

  // When available, this should be overridden with real implementation
  // via ProviderScope in app wiring
  return const DisabledNotificationsInboxRepository();
});

/// Stream provider exposing the repository stream for UI.
final notificationsInboxStreamProvider =
    StreamProvider<List<NotificationEntry>>((ref) {
  final availability = ref.watch(notificationsAvailabilityProvider);

  if (!availability.isAvailable) {
    return Stream<List<NotificationEntry>>.value(const <NotificationEntry>[]);
  }

  final repository = ref.watch(notificationsInboxRepositoryProvider);
  return repository.watchNotifications();
});

/// Provider for unread notifications count.
/// Returns 0 if feature is unavailable (Sale-Only).
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final availability = ref.watch(notificationsAvailabilityProvider);

  if (!availability.isAvailable) {
    return 0;
  }

  final inbox = ref.watch(notificationsInboxStreamProvider);
  return inbox.maybeWhen(
    data: (items) => items.where((e) => e.isUnread).length,
    orElse: () => 0,
  );
});

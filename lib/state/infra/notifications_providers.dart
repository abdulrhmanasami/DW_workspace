/// Notification preferences infra providers.
/// These are lightweight placeholders that mimic the repository contract from
/// `notifications_shims` so that UX code can be exercised inside the clean
/// workspace.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Domain snapshot for notification preferences.
@immutable
class NotificationPreferences {
  const NotificationPreferences({
    required this.orderStatusEnabled,
    required this.promotionsEnabled,
    required this.systemEnabled,
    this.quietHoursStart,
    this.quietHoursEnd,
  });

  const NotificationPreferences.allEnabled()
      : orderStatusEnabled = true,
        promotionsEnabled = true,
        systemEnabled = true,
        quietHoursStart = null,
        quietHoursEnd = null;

  final bool orderStatusEnabled;
  final bool promotionsEnabled;
  final bool systemEnabled;
  final TimeOfDay? quietHoursStart;
  final TimeOfDay? quietHoursEnd;

  NotificationPreferences copyWith({
    bool? orderStatusEnabled,
    bool? promotionsEnabled,
    bool? systemEnabled,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
  }) {
    return NotificationPreferences(
      orderStatusEnabled: orderStatusEnabled ?? this.orderStatusEnabled,
      promotionsEnabled: promotionsEnabled ?? this.promotionsEnabled,
      systemEnabled: systemEnabled ?? this.systemEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }
}

/// Repository contract for persisting notification preferences.
abstract class NotificationPreferencesRepository {
  Future<NotificationPreferences> load();
  Future<void> save(NotificationPreferences preferences);
}

/// Local in-memory repository used until the real implementation is wired.
class LocalNotificationPreferencesRepository implements NotificationPreferencesRepository {
  LocalNotificationPreferencesRepository();

  NotificationPreferences _value = const NotificationPreferences.allEnabled();

  @override
  Future<NotificationPreferences> load() async {
    return _value;
  }

  @override
  Future<void> save(NotificationPreferences preferences) async {
    _value = preferences;
  }
}

final notificationPreferencesRepositoryProvider = Provider<NotificationPreferencesRepository>((ref) {
  return LocalNotificationPreferencesRepository();
});

final notificationPreferencesProvider = FutureProvider<NotificationPreferences>((ref) {
  final repository = ref.watch(notificationPreferencesRepositoryProvider);
  return repository.load();
});


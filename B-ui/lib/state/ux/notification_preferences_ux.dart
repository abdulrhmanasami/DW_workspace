/// Notification Preferences UX State
/// Converts domain preferences into presentation models and exposes controllers.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notifications_shims/notifications_shims.dart';

import 'package:b_ui/state/infra/notifications_providers.dart';
import 'package:b_ui/state/infra/telemetry_providers.dart';

typedef UserNotificationPreferences = NotificationPreferences;

@immutable
class NotificationPreferencesViewModel {
  const NotificationPreferencesViewModel({
    required this.orderStatusUpdatesEnabled,
    required this.promotionsEnabled,
    required this.systemAlertsEnabled,
    required this.marketingConsented,
    required this.canEditPromotions,
    required this.isDoNotDisturbEnabled,
    required this.quietHoursWrapsToNextDay,
    this.quietHoursStart,
    this.quietHoursEnd,
    this.quietHoursLabel,
  });

  final bool orderStatusUpdatesEnabled;
  final bool promotionsEnabled;
  final bool systemAlertsEnabled;
  final bool marketingConsented;
  final bool canEditPromotions;
  final bool isDoNotDisturbEnabled;
  final bool quietHoursWrapsToNextDay;
  final TimeOfDay? quietHoursStart;
  final TimeOfDay? quietHoursEnd;
  final String? quietHoursLabel;

  NotificationPreferencesViewModel copyWith({
    bool? orderStatusUpdatesEnabled,
    bool? promotionsEnabled,
    bool? systemAlertsEnabled,
    bool? marketingConsented,
    bool? canEditPromotions,
    bool? isDoNotDisturbEnabled,
    bool? quietHoursWrapsToNextDay,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
    String? quietHoursLabel,
  }) {
    return NotificationPreferencesViewModel(
      orderStatusUpdatesEnabled: orderStatusUpdatesEnabled ?? this.orderStatusUpdatesEnabled,
      promotionsEnabled: promotionsEnabled ?? this.promotionsEnabled,
      systemAlertsEnabled: systemAlertsEnabled ?? this.systemAlertsEnabled,
      marketingConsented: marketingConsented ?? this.marketingConsented,
      canEditPromotions: canEditPromotions ?? this.canEditPromotions,
      isDoNotDisturbEnabled: isDoNotDisturbEnabled ?? this.isDoNotDisturbEnabled,
      quietHoursWrapsToNextDay: quietHoursWrapsToNextDay ?? this.quietHoursWrapsToNextDay,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      quietHoursLabel: quietHoursLabel ?? this.quietHoursLabel,
    );
  }
}

@immutable
class NotificationPreferencesSnapshot {
  const NotificationPreferencesSnapshot({
    required this.orderStatusEnabled,
    required this.promotionsEnabled,
    required this.systemEnabled,
    this.quietHoursStart,
    this.quietHoursEnd,
  });

  final bool orderStatusEnabled;
  final bool promotionsEnabled;
  final bool systemEnabled;
  final TimeOfDay? quietHoursStart;
  final TimeOfDay? quietHoursEnd;

  factory NotificationPreferencesSnapshot.fromDomain(NotificationPreferences prefs) {
    return NotificationPreferencesSnapshot(
      orderStatusEnabled: prefs.orderStatusUpdatesEnabled,
      promotionsEnabled: prefs.promotionsEnabled,
      systemEnabled: prefs.systemAlertsEnabled,
      quietHoursStart: _timeOfDayFromDomain(prefs.quietHoursStart),
      quietHoursEnd: _timeOfDayFromDomain(prefs.quietHoursEnd),
    );
  }

  factory NotificationPreferencesSnapshot.empty() => const NotificationPreferencesSnapshot(
        orderStatusEnabled: true,
        promotionsEnabled: false,
        systemEnabled: true,
      );

  NotificationPreferencesSnapshot copyWith({
    bool? orderStatusEnabled,
    bool? promotionsEnabled,
    bool? systemEnabled,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
  }) {
    return NotificationPreferencesSnapshot(
      orderStatusEnabled: orderStatusEnabled ?? this.orderStatusEnabled,
      promotionsEnabled: promotionsEnabled ?? this.promotionsEnabled,
      systemEnabled: systemEnabled ?? this.systemEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }

  NotificationPreferences applyTo(NotificationPreferences base) {
    return base.copyWith(
      orderStatusUpdatesEnabled: orderStatusEnabled,
      promotionsEnabled: promotionsEnabled,
      systemAlertsEnabled: systemEnabled,
      quietHoursStart: _domainTimeFromTimeOfDay(quietHoursStart),
      quietHoursEnd: _domainTimeFromTimeOfDay(quietHoursEnd),
    );
  }
}

@immutable
class QuietHoursValidationResult {
  const QuietHoursValidationResult(this.isValid, [this.message]);

  final bool isValid;
  final String? message;
}

class QuietHoursValidationException implements Exception {
  QuietHoursValidationException(this.code);

  final String code;

  @override
  String toString() => 'QuietHoursValidationException($code)';
}

final notificationPreferencesUxControllerProvider =
    AsyncNotifierProvider<NotificationPreferencesUxController, NotificationPreferencesViewModel>(
  NotificationPreferencesUxController.new,
);

final notificationPreferencesUxProvider = FutureProvider<NotificationPreferencesViewModel>((ref) async {
  return ref.watch(notificationPreferencesUxControllerProvider.future);
});

class NotificationPreferencesUxController extends AsyncNotifier<NotificationPreferencesViewModel> {
  NotificationPreferencesRepository get _repository => ref.read(notificationPreferencesRepositoryProvider);
  NotificationsBackendClient? get _backendClient => ref.read(notificationsBackendClientProvider);
  TelemetryConsentState get _consent => ref.read(telemetryConsentProvider);

  NotificationPreferences? _lastDomain;
  NotificationPreferencesSnapshot? _snapshot;

  @override
  Future<NotificationPreferencesViewModel> build() async {
    final domain = await _repository.load();
    _lastDomain = domain;
    _snapshot = NotificationPreferencesSnapshot.fromDomain(domain);
    return mapPreferencesSnapshotToViewModel(_snapshot!, _consent.marketingAllowed);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final vm = await build();
      state = AsyncValue.data(vm);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> updateOrderStatus(bool enabled) async {
    final next = (_snapshot ?? NotificationPreferencesSnapshot.empty()).copyWith(orderStatusEnabled: enabled);
    await _persistSnapshot(next);
  }

  Future<void> updatePromotions(bool enabled) async {
    if (!_consent.marketingAllowed) return;
    final next = (_snapshot ?? NotificationPreferencesSnapshot.empty()).copyWith(promotionsEnabled: enabled);
    await _persistSnapshot(next);
  }

  Future<void> updateSystemAlerts(bool enabled) async {
    final next = (_snapshot ?? NotificationPreferencesSnapshot.empty()).copyWith(systemEnabled: enabled);
    await _persistSnapshot(next);
  }

  Future<void> updateQuietHours(TimeOfDay? start, TimeOfDay? end) async {
    final validation = validateQuietHours(start, end);
    if (!validation.isValid) {
      throw QuietHoursValidationException(validation.message ?? 'quiet_hours_invalid');
    }

    final next = (_snapshot ?? NotificationPreferencesSnapshot.empty()).copyWith(
      quietHoursStart: start,
      quietHoursEnd: end,
    );
    await _persistSnapshot(next);
  }

  Future<void> updateFromViewModel(NotificationPreferencesViewModel viewModel) async {
    final marketingAllowed = _consent.marketingAllowed;
    final sanitizedVm = marketingAllowed ? viewModel : viewModel.copyWith(promotionsEnabled: false);
    final snapshot = snapshotFromViewModel(sanitizedVm);
    await _persistSnapshot(snapshot);
  }

  Future<void> _persistSnapshot(NotificationPreferencesSnapshot snapshot) async {
    state = const AsyncLoading();
    try {
      final base = _lastDomain ?? await _repository.load();
      final updatedDomain = snapshot.applyTo(base);
      await _repository.save(updatedDomain);
      _lastDomain = updatedDomain;
      _snapshot = NotificationPreferencesSnapshot.fromDomain(updatedDomain);
      final marketingAllowed = _consent.marketingAllowed;
      final vm = mapPreferencesSnapshotToViewModel(_snapshot!, marketingAllowed);
      state = AsyncValue.data(vm);
      unawaited(_syncRemote(updatedDomain));
    } catch (error, stackTrace) {
      _logError('persistSnapshot', error, stackTrace);
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> _syncRemote(NotificationPreferences prefs) async {
    final client = _backendClient;
    if (client == null) return;

    final dynamic dynamicClient = client;
    try {
      await dynamicClient.syncPreferences(prefs);
      return;
    } catch (_) {
      // Fall back to alternative method name.
    }

    try {
      await dynamicClient.updatePreferences(prefs);
    } catch (error, stackTrace) {
      _logError('syncRemote', error, stackTrace);
    }
  }

  void _logError(String action, Object error, StackTrace stackTrace) {
    debugPrint('NotificationPreferencesUxController:$action error=$error stack=$stackTrace');
  }
}

@visibleForTesting
NotificationPreferencesViewModel mapPreferencesSnapshotToViewModel(
  NotificationPreferencesSnapshot snapshot,
  bool marketingAllowed,
) {
  final quietHoursLabel = formatQuietHoursLabel(snapshot.quietHoursStart, snapshot.quietHoursEnd);
  final wraps = _quietHoursWraps(snapshot.quietHoursStart, snapshot.quietHoursEnd);
  return NotificationPreferencesViewModel(
    orderStatusUpdatesEnabled: snapshot.orderStatusEnabled,
    promotionsEnabled: marketingAllowed ? snapshot.promotionsEnabled : false,
    systemAlertsEnabled: snapshot.systemEnabled,
    marketingConsented: marketingAllowed,
    canEditPromotions: marketingAllowed,
    isDoNotDisturbEnabled: quietHoursLabel != null,
    quietHoursStart: snapshot.quietHoursStart,
    quietHoursEnd: snapshot.quietHoursEnd,
    quietHoursLabel: quietHoursLabel,
    quietHoursWrapsToNextDay: wraps,
  );
}

@visibleForTesting
NotificationPreferencesSnapshot snapshotFromViewModel(NotificationPreferencesViewModel vm) {
  return NotificationPreferencesSnapshot(
    orderStatusEnabled: vm.orderStatusUpdatesEnabled,
    promotionsEnabled: vm.promotionsEnabled,
    systemEnabled: vm.systemAlertsEnabled,
    quietHoursStart: vm.quietHoursStart,
    quietHoursEnd: vm.quietHoursEnd,
  );
}

NotificationTimeOfDay? _domainTimeFromTimeOfDay(TimeOfDay? time) {
  if (time == null) return null;
  return NotificationTimeOfDay(hour: time.hour, minute: time.minute);
}

TimeOfDay? _timeOfDayFromDomain(NotificationTimeOfDay? time) {
  if (time == null) return null;
  return TimeOfDay(hour: time.hour, minute: time.minute);
}

@visibleForTesting
String? formatQuietHoursLabel(TimeOfDay? start, TimeOfDay? end) {
  if (start == null || end == null) {
    return null;
  }
  final startLabel = _formatTime(start);
  final endLabel = _formatTime(end);
  return 'من $startLabel إلى $endLabel';
}

@visibleForTesting
QuietHoursValidationResult validateQuietHours(TimeOfDay? start, TimeOfDay? end) {
  if (start == null && end == null) {
    return const QuietHoursValidationResult(true);
  }

  if (start == null || end == null) {
    return const QuietHoursValidationResult(false, 'quiet_hours_incomplete');
  }

  if (start.hour == end.hour && start.minute == end.minute) {
    return const QuietHoursValidationResult(false, 'quiet_hours_same_time');
  }

  return const QuietHoursValidationResult(true);
}

bool _quietHoursWraps(TimeOfDay? start, TimeOfDay? end) {
  if (start == null || end == null) return false;
  final startMinutes = start.hour * 60 + start.minute;
  final endMinutes = end.hour * 60 + end.minute;
  return startMinutes > endMinutes;
}

String _formatTime(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}


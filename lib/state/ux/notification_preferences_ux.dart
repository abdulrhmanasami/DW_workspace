/// UX layer for notification preferences (toggles + quiet hours).

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:delivery_ways_clean/state/infra/notifications_providers.dart';
import 'package:delivery_ways_clean/state/infra/telemetry_providers.dart';

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
      orderStatusEnabled: prefs.orderStatusEnabled,
      promotionsEnabled: prefs.promotionsEnabled,
      systemEnabled: prefs.systemEnabled,
      quietHoursStart: prefs.quietHoursStart,
      quietHoursEnd: prefs.quietHoursEnd,
    );
  }

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

  NotificationPreferences apply(NotificationPreferences base) {
    return base.copyWith(
      orderStatusEnabled: orderStatusEnabled,
      promotionsEnabled: promotionsEnabled,
      systemEnabled: systemEnabled,
      quietHoursStart: quietHoursStart,
      quietHoursEnd: quietHoursEnd,
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
  TelemetryConsentState get _telemetryConsent => ref.read(telemetryConsentProvider);

  NotificationPreferencesSnapshot? _snapshot;
  NotificationPreferences? _cachedDomain;

  @override
  Future<NotificationPreferencesViewModel> build() async {
    final domain = await _repository.load();
    _cachedDomain = domain;
    _snapshot = NotificationPreferencesSnapshot.fromDomain(domain);
    return mapSnapshotToViewModel(_snapshot!, _telemetryConsent.marketingAllowed);
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
    final current = _snapshot ?? NotificationPreferencesSnapshot.fromDomain(
      _cachedDomain ?? const NotificationPreferences.allEnabled(),
    );
    final next = current.copyWith(orderStatusEnabled: enabled);
    await _persist(next);
  }

  Future<void> updatePromotions(bool enabled) async {
    if (!_telemetryConsent.marketingAllowed) return;
    final current = _snapshot ?? NotificationPreferencesSnapshot.fromDomain(
      _cachedDomain ?? const NotificationPreferences.allEnabled(),
    );
    final next = current.copyWith(promotionsEnabled: enabled);
    await _persist(next);
  }

  Future<void> updateSystemAlerts(bool enabled) async {
    final current = _snapshot ?? NotificationPreferencesSnapshot.fromDomain(
      _cachedDomain ?? const NotificationPreferences.allEnabled(),
    );
    final next = current.copyWith(systemEnabled: enabled);
    await _persist(next);
  }

  Future<void> updateQuietHours(TimeOfDay? start, TimeOfDay? end) async {
    final validation = validateQuietHours(start, end);
    if (!validation.isValid) {
      throw QuietHoursValidationException(validation.message ?? 'quiet_hours_invalid');
    }

    final current = _snapshot ?? NotificationPreferencesSnapshot.fromDomain(
      _cachedDomain ?? const NotificationPreferences.allEnabled(),
    );
    final next = current.copyWith(quietHoursStart: start, quietHoursEnd: end);
    await _persist(next);
  }

  Future<void> updateFromViewModel(NotificationPreferencesViewModel vm) async {
    final marketingAllowed = _telemetryConsent.marketingAllowed;
    final sanitizedVm = marketingAllowed ? vm : vm.copyWith(promotionsEnabled: false);
    final snapshot = NotificationPreferencesSnapshot(
      orderStatusEnabled: sanitizedVm.orderStatusUpdatesEnabled,
      promotionsEnabled: sanitizedVm.promotionsEnabled,
      systemEnabled: sanitizedVm.systemAlertsEnabled,
      quietHoursStart: sanitizedVm.quietHoursStart,
      quietHoursEnd: sanitizedVm.quietHoursEnd,
    );
    await _persist(snapshot);
  }

  Future<void> _persist(NotificationPreferencesSnapshot snapshot) async {
    state = const AsyncLoading();
    try {
      final base = _cachedDomain ?? await _repository.load();
      final updatedDomain = snapshot.apply(base);
      await _repository.save(updatedDomain);
      _cachedDomain = updatedDomain;
      _snapshot = NotificationPreferencesSnapshot.fromDomain(updatedDomain);
      final vm = mapSnapshotToViewModel(
        _snapshot!,
        _telemetryConsent.marketingAllowed,
      );
      state = AsyncValue.data(vm);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}

NotificationPreferencesViewModel mapSnapshotToViewModel(
  NotificationPreferencesSnapshot snapshot,
  bool marketingAllowed,
) {
  final quietHoursLabel = formatQuietHoursLabel(snapshot.quietHoursStart, snapshot.quietHoursEnd);
  final wraps = quietHoursWrapsToNextDay(snapshot.quietHoursStart, snapshot.quietHoursEnd);
  final quietHoursEnabled = quietHoursLabel != null;

  return NotificationPreferencesViewModel(
    orderStatusUpdatesEnabled: snapshot.orderStatusEnabled,
    promotionsEnabled: marketingAllowed ? snapshot.promotionsEnabled : false,
    systemAlertsEnabled: snapshot.systemEnabled,
    marketingConsented: marketingAllowed,
    canEditPromotions: marketingAllowed,
    isDoNotDisturbEnabled: quietHoursEnabled,
    quietHoursWrapsToNextDay: wraps,
    quietHoursStart: snapshot.quietHoursStart,
    quietHoursEnd: snapshot.quietHoursEnd,
    quietHoursLabel: quietHoursLabel,
  );
}

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

String? formatQuietHoursLabel(TimeOfDay? start, TimeOfDay? end) {
  if (start == null || end == null) return null;
  final formattedStart = _formatTime(start);
  final formattedEnd = _formatTime(end);
  return 'من $formattedStart إلى $formattedEnd';
}

bool quietHoursWrapsToNextDay(TimeOfDay? start, TimeOfDay? end) {
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


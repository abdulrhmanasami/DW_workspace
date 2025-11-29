/// Notifications Availability - Status and checks for notification feature
/// Created by: Cursor B-ux
/// Purpose: Sale-Only behavior - availability status for notifications feature
/// Last updated: 2025-11-25

import 'package:flutter/foundation.dart';

/// Availability status for the notifications feature.
/// Used to implement Sale-Only behavior where UI reflects actual availability.
enum NotificationsAvailabilityStatus {
  /// Feature is available and backend is responsive.
  available,

  /// Backend is temporarily unavailable (network error, timeout, etc.).
  temporarilyUnavailable,

  /// Feature is disabled via config/feature flag.
  disabledByConfig,

  /// Platform does not support push notifications.
  notSupported,

  /// Status is being determined.
  checking,
}

/// Immutable snapshot of notifications availability state.
@immutable
class NotificationsAvailabilityState {
  const NotificationsAvailabilityState({
    required this.status,
    this.lastChecked,
    this.errorMessage,
  });

  const NotificationsAvailabilityState.initial()
      : status = NotificationsAvailabilityStatus.checking,
        lastChecked = null,
        errorMessage = null;

  const NotificationsAvailabilityState.available()
      : status = NotificationsAvailabilityStatus.available,
        lastChecked = null,
        errorMessage = null;

  const NotificationsAvailabilityState.disabled()
      : status = NotificationsAvailabilityStatus.disabledByConfig,
        lastChecked = null,
        errorMessage = null;

  final NotificationsAvailabilityStatus status;
  final DateTime? lastChecked;
  final String? errorMessage;

  /// Whether notifications feature is fully available.
  bool get isAvailable => status == NotificationsAvailabilityStatus.available;

  /// Whether the feature is disabled intentionally (not an error).
  bool get isDisabled => status == NotificationsAvailabilityStatus.disabledByConfig;

  /// Whether there's a temporary issue (backend down, network error).
  bool get isTemporarilyUnavailable =>
      status == NotificationsAvailabilityStatus.temporarilyUnavailable;

  /// Whether the platform doesn't support notifications.
  bool get isNotSupported => status == NotificationsAvailabilityStatus.notSupported;

  /// Whether we're still checking availability.
  bool get isChecking => status == NotificationsAvailabilityStatus.checking;

  /// Whether UI should show "unavailable" message (any non-available state).
  bool get shouldShowUnavailableMessage =>
      !isAvailable && !isChecking;

  NotificationsAvailabilityState copyWith({
    NotificationsAvailabilityStatus? status,
    DateTime? lastChecked,
    String? errorMessage,
  }) {
    return NotificationsAvailabilityState(
      status: status ?? this.status,
      lastChecked: lastChecked ?? this.lastChecked,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationsAvailabilityState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          lastChecked == other.lastChecked &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode =>
      status.hashCode ^ lastChecked.hashCode ^ errorMessage.hashCode;
}


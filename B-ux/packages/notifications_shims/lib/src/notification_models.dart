/// Notification Models - Domain models for notifications
/// Created by: Cursor B-ux
/// Purpose: Unified notification models used across the app
/// Last updated: 2025-11-25

import 'package:flutter/material.dart';

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

  const NotificationPreferences.allDisabled()
      : orderStatusEnabled = false,
        promotionsEnabled = false,
        systemEnabled = false,
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPreferences &&
          runtimeType == other.runtimeType &&
          orderStatusEnabled == other.orderStatusEnabled &&
          promotionsEnabled == other.promotionsEnabled &&
          systemEnabled == other.systemEnabled &&
          quietHoursStart == other.quietHoursStart &&
          quietHoursEnd == other.quietHoursEnd;

  @override
  int get hashCode =>
      orderStatusEnabled.hashCode ^
      promotionsEnabled.hashCode ^
      systemEnabled.hashCode ^
      quietHoursStart.hashCode ^
      quietHoursEnd.hashCode;
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          title == other.title &&
          body == other.body &&
          receivedAt == other.receivedAt &&
          readStatus == other.readStatus;

  @override
  int get hashCode =>
      id.hashCode ^
      type.hashCode ^
      title.hashCode ^
      body.hashCode ^
      receivedAt.hashCode ^
      readStatus.hashCode;
}


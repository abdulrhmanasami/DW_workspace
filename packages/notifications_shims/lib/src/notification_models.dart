import 'package:meta/meta.dart';

/// Types of push notifications supported by the application.
enum NotificationType {
  orderStatusUpdate,
  promotion,
  system,
}

/// Logical channels used for categorising notifications.
enum NotificationChannel {
  orderUpdates,
  promotions,
  system,
}

/// Device metadata that accompanies token registration calls.
class NotificationDeviceMetadata {
  const NotificationDeviceMetadata({
    required this.platform,
    required this.appVersion,
    required this.deviceId,
    this.buildNumber,
    this.osVersion,
    this.deviceModel,
    this.locale,
    this.userId,
    this.extra = const <String, Object?>{},
  });

  final String platform;
  final String appVersion;
  final String deviceId;
  final String? buildNumber;
  final String? osVersion;
  final String? deviceModel;
  final String? locale;
  final String? userId;
  final Map<String, Object?> extra;

  Map<String, Object?> toJson() => {
        'platform': platform,
        'appVersion': appVersion,
        'deviceId': deviceId,
        if (buildNumber != null) 'buildNumber': buildNumber,
        if (osVersion != null) 'osVersion': osVersion,
        if (deviceModel != null) 'deviceModel': deviceModel,
        if (locale != null) 'locale': locale,
        if (userId != null) 'userId': userId,
        if (extra.isNotEmpty) 'extra': extra,
      };
}

/// Domain-safe representation of a received push notification.
class IncomingNotification {
  const IncomingNotification({
    required this.type,
    required this.channel,
    required this.title,
    required this.body,
    required this.data,
    required this.receivedAt,
    this.orderId,
  });

  final NotificationType type;
  final NotificationChannel channel;
  final String title;
  final String body;
  final Map<String, String> data;
  final String? orderId;
  final DateTime receivedAt;

  @override
  String toString() {
    return 'IncomingNotification('
        'type: $type, channel: $channel, title: "$title", '
        'orderId: $orderId, receivedAt: $receivedAt)';
  }
}

/// Canonical representation of a 24h time used for quiet-hours windows.
@immutable
class NotificationTimeOfDay {
  const NotificationTimeOfDay({
    required this.hour,
    required this.minute,
  })  : assert(hour >= 0 && hour < 24, 'hour must be between 0 and 23'),
        assert(minute >= 0 && minute < 60, 'minute must be between 0 and 59');

  const NotificationTimeOfDay.midnight()
      : hour = 0,
        minute = 0;

  final int hour;
  final int minute;

  Map<String, int> toJson() => {'hour': hour, 'minute': minute};

  static NotificationTimeOfDay? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final hour = json['hour'] as int?;
    final minute = json['minute'] as int?;
    if (hour == null || minute == null) return null;
    return NotificationTimeOfDay(hour: hour, minute: minute);
  }

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  bool operator ==(Object other) {
    return other is NotificationTimeOfDay &&
        other.hour == hour &&
        other.minute == minute;
  }

  @override
  String toString() => 'NotificationTimeOfDay($hour:$minute)';
}

/// User-configurable notification preferences.
class NotificationPreferences {
  const NotificationPreferences({
    this.orderStatusUpdatesEnabled = true,
    this.promotionsEnabled = true,
    this.systemAlertsEnabled = true,
    this.quietHoursStart,
    this.quietHoursEnd,
  });

  const NotificationPreferences.defaults() : this();

  final bool orderStatusUpdatesEnabled;
  final bool promotionsEnabled;
  final bool systemAlertsEnabled;
  final NotificationTimeOfDay? quietHoursStart;
  final NotificationTimeOfDay? quietHoursEnd;

  NotificationPreferences copyWith({
    bool? orderStatusUpdatesEnabled,
    bool? promotionsEnabled,
    bool? systemAlertsEnabled,
    NotificationTimeOfDay? quietHoursStart,
    NotificationTimeOfDay? quietHoursEnd,
  }) {
    return NotificationPreferences(
      orderStatusUpdatesEnabled:
          orderStatusUpdatesEnabled ?? this.orderStatusUpdatesEnabled,
      promotionsEnabled: promotionsEnabled ?? this.promotionsEnabled,
      systemAlertsEnabled: systemAlertsEnabled ?? this.systemAlertsEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }

  Map<String, dynamic> toJson() => {
        'orderStatusUpdatesEnabled': orderStatusUpdatesEnabled,
        'promotionsEnabled': promotionsEnabled,
        'systemAlertsEnabled': systemAlertsEnabled,
        'quietHoursStart': quietHoursStart?.toJson(),
        'quietHoursEnd': quietHoursEnd?.toJson(),
      };

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      orderStatusUpdatesEnabled:
          json['orderStatusUpdatesEnabled'] as bool? ?? true,
      promotionsEnabled: json['promotionsEnabled'] as bool? ?? true,
      systemAlertsEnabled: json['systemAlertsEnabled'] as bool? ?? true,
      quietHoursStart: NotificationTimeOfDay.fromJson(
          json['quietHoursStart'] as Map<String, dynamic>?),
      quietHoursEnd: NotificationTimeOfDay.fromJson(
          json['quietHoursEnd'] as Map<String, dynamic>?),
    );
  }

  @override
  String toString() {
    return 'NotificationPreferences('
        'orderStatus: $orderStatusUpdatesEnabled, '
        'promotions: $promotionsEnabled, '
        'system: $systemAlertsEnabled, '
        'quietHoursStart: $quietHoursStart, '
        'quietHoursEnd: $quietHoursEnd'
        ')';
  }
}

/// Notification permission status.
enum NotificationPermissionStatus {
  granted,
  denied,
  provisional,
  notDetermined,
}

/// Notification settings for a specific channel.
class NotificationChannelSettings {
  const NotificationChannelSettings({
    required this.channel,
    required this.enabled,
    required this.permission,
  });

  final NotificationChannel channel;
  final bool enabled;
  final NotificationPermissionStatus permission;

  @override
  String toString() {
    return 'NotificationChannelSettings('
        'channel: $channel, enabled: $enabled, permission: $permission)';
  }
}

/// Unique identifier for a notification entry.
class NotificationId {
  const NotificationId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationId &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'NotificationId($value)';
}

/// Read status for notification entries.
enum NotificationReadStatus {
  unread,
  read,
}

/// Complete notification entry for inbox storage.
class NotificationEntry {
  const NotificationEntry({
    required this.id,
    required this.type,
    required this.channel,
    required this.title,
    required this.body,
    required this.data,
    required this.receivedAt,
    this.orderId,
    this.readStatus = NotificationReadStatus.unread,
    this.readAt,
  });

  final NotificationId id;
  final NotificationType type;
  final NotificationChannel channel;
  final String title;
  final String body;
  final Map<String, String> data;
  final String? orderId;
  final DateTime receivedAt;
  final NotificationReadStatus readStatus;
  final DateTime? readAt;

  NotificationEntry markAsRead(DateTime timestamp) {
    if (readStatus == NotificationReadStatus.read) return this;
    return NotificationEntry(
      id: id,
      type: type,
      channel: channel,
      title: title,
      body: body,
      data: data,
      orderId: orderId,
      receivedAt: receivedAt,
      readStatus: NotificationReadStatus.read,
      readAt: timestamp,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id.value,
        'type': type.name,
        'channel': channel.name,
        'title': title,
        'body': body,
        'data': data,
        'orderId': orderId,
        'receivedAt': receivedAt.toIso8601String(),
        'readStatus': readStatus.name,
        'readAt': readAt?.toIso8601String(),
      };

  factory NotificationEntry.fromJson(Map<String, dynamic> json) {
    return NotificationEntry(
      id: NotificationId(json['id'] as String),
      type: NotificationType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => NotificationType.system,
      ),
      channel: NotificationChannel.values.firstWhere(
        (value) => value.name == json['channel'],
        orElse: () => NotificationChannel.system,
      ),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      data: (json['data'] as Map?)?.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          ) ??
          const {},
      orderId: json['orderId'] as String?,
      receivedAt: DateTime.tryParse(json['receivedAt'] as String? ?? '') ??
          DateTime.now().toUtc(),
      readStatus: NotificationReadStatus.values.firstWhere(
        (value) => value.name == json['readStatus'],
        orElse: () => NotificationReadStatus.unread,
      ),
      readAt: (json['readAt'] as String?) != null
          ? DateTime.tryParse(json['readAt'] as String)
          : null,
    );
  }

  bool get isUnread => readStatus == NotificationReadStatus.unread;
  bool get isRead => readStatus == NotificationReadStatus.read;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationEntry &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'NotificationEntry('
        'id: $id, type: $type, channel: $channel, '
        'title: "$title", readStatus: $readStatus, receivedAt: $receivedAt'
        ')';
  }
}

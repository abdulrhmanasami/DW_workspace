/// Notification payload abstraction
class NotificationPayload {
  const NotificationPayload({required this.data, this.action});

  final Map<String, dynamic> data;
  final String? action;
}

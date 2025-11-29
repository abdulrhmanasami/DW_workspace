/// Notification configuration
class NotificationConfig {
  const NotificationConfig({
    this.requestPermissionsOnStart = true,
    this.channels = const <NotificationChannel>[],
  });

  final bool requestPermissionsOnStart;
  final List<NotificationChannel> channels;
}

class NotificationChannel {
  const NotificationChannel({
    required this.id,
    required this.name,
    required this.description,
  });

  final String id;
  final String name;
  final String description;
}

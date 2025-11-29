/// Notification channels abstraction
class NotificationChannel {
  const NotificationChannel({
    required this.id,
    required this.name,
    required this.description,
    this.importance = NotificationImportance.normal,
    this.sound = true,
    this.vibration = true,
  });

  final String id;
  final String name;
  final String description;
  final NotificationImportance importance;
  final bool sound;
  final bool vibration;
}

enum NotificationImportance { low, normal, high, max }

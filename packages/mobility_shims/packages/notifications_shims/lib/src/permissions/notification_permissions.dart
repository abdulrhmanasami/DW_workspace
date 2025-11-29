/// Notification permissions abstraction
abstract class NotificationPermissions {
  Future<bool> requestPermissions();
  Future<bool> checkPermissions();
  Future<void> openSettings();
}

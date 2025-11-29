/// Notification token abstraction
abstract class NotificationToken {
  Future<String?> getToken();
  Future<void> deleteToken();
  Stream<String?> get onTokenRefresh;
}

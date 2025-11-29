/// Notification subscription abstraction
abstract class NotificationSubscription {
  Future<void> subscribeToTopic(final String topic);
  Future<void> unsubscribeFromTopic(final String topic);
  Future<List<String>> getSubscribedTopics();
}

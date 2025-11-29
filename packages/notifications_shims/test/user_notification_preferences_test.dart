import 'package:notifications_shims/notifications_shims.dart';
import 'package:test/test.dart';

void main() {
  group('NotificationPreferences', () {
    test('defaults enable all notification types', () {
      const prefs = NotificationPreferences.defaults();
      expect(prefs.orderStatusUpdatesEnabled, isTrue);
      expect(prefs.promotionsEnabled, isTrue);
      expect(prefs.systemAlertsEnabled, isTrue);
      expect(prefs.quietHoursStart, isNull);
      expect(prefs.quietHoursEnd, isNull);
    });

    test('copyWith overrides individual fields', () {
      const prefs = NotificationPreferences.defaults();
      final updated = prefs.copyWith(
        promotionsEnabled: false,
        quietHoursStart: const NotificationTimeOfDay(hour: 22, minute: 0),
        quietHoursEnd: const NotificationTimeOfDay(hour: 7, minute: 30),
      );

      expect(updated.promotionsEnabled, isFalse);
      expect(updated.orderStatusUpdatesEnabled, isTrue);
      expect(
        updated.quietHoursStart,
        const NotificationTimeOfDay(hour: 22, minute: 0),
      );
      expect(
        updated.quietHoursEnd,
        const NotificationTimeOfDay(hour: 7, minute: 30),
      );
    });

    test('serializes and deserializes correctly', () {
      const prefs = NotificationPreferences(
        orderStatusUpdatesEnabled: false,
        promotionsEnabled: true,
        systemAlertsEnabled: false,
        quietHoursStart: NotificationTimeOfDay(hour: 21, minute: 45),
        quietHoursEnd: NotificationTimeOfDay(hour: 6, minute: 15),
      );

      final restored = NotificationPreferences.fromJson(prefs.toJson());
      expect(restored.orderStatusUpdatesEnabled, isFalse);
      expect(restored.promotionsEnabled, isTrue);
      expect(restored.systemAlertsEnabled, isFalse);
      expect(restored.quietHoursStart, prefs.quietHoursStart);
      expect(restored.quietHoursEnd, prefs.quietHoursEnd);
    });
  });
}

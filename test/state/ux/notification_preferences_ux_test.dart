import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:delivery_ways_clean/state/ux/notification_preferences_ux.dart';

void main() {
  test('mapSnapshotToViewModel respects marketing consent and quiet hours label', () {
    const snapshot = NotificationPreferencesSnapshot(
      orderStatusEnabled: true,
      promotionsEnabled: true,
      systemEnabled: true,
      quietHoursStart: TimeOfDay(hour: 22, minute: 0),
      quietHoursEnd: TimeOfDay(hour: 7, minute: 0),
    );

    final vm = mapSnapshotToViewModel(snapshot, false);

    expect(vm.promotionsEnabled, isFalse);
    expect(vm.isDoNotDisturbEnabled, isTrue);
    expect(vm.quietHoursLabel, 'من 22:00 إلى 07:00');
    expect(vm.quietHoursWrapsToNextDay, isTrue);
  });

  test('validateQuietHours fails when times are identical', () {
    const time = TimeOfDay(hour: 9, minute: 30);
    final result = validateQuietHours(time, time);

    expect(result.isValid, isFalse);
    expect(result.message, 'quiet_hours_same_time');
  });
}


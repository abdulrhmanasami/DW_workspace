/// Notification Preferences UX Tests
/// Created by: Cursor B-ux
/// Purpose: Unit tests for notification preferences UX layer with Sale-Only behavior
/// Last updated: 2025-11-25

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:delivery_ways_clean/state/infra/notifications_providers.dart';
import 'package:delivery_ways_clean/state/ux/notification_preferences_ux.dart';

void main() {
  group('mapSnapshotToViewModel', () {
    test('respects marketing consent and quiet hours label', () {
      const snapshot = NotificationPreferencesSnapshot(
        orderStatusEnabled: true,
        promotionsEnabled: true,
        systemEnabled: true,
        quietHoursStart: TimeOfDay(hour: 22, minute: 0),
        quietHoursEnd: TimeOfDay(hour: 7, minute: 0),
      );

      final vm = mapSnapshotToViewModel(
        snapshot,
        false, // marketing not allowed
        NotificationsAvailabilityStatus.available,
      );

      expect(vm.promotionsEnabled, isFalse);
      expect(vm.isDoNotDisturbEnabled, isTrue);
      expect(vm.quietHoursLabel, 'من 22:00 إلى 07:00');
      expect(vm.quietHoursWrapsToNextDay, isTrue);
      expect(vm.isAvailable, isTrue);
    });

    test('includes availability status in view model', () {
      const snapshot = NotificationPreferencesSnapshot(
        orderStatusEnabled: true,
        promotionsEnabled: true,
        systemEnabled: true,
      );

      final vm = mapSnapshotToViewModel(
        snapshot,
        true,
        NotificationsAvailabilityStatus.available,
      );

      expect(vm.isAvailable, isTrue);
      expect(vm.availabilityStatus, NotificationsAvailabilityStatus.available);
    });
  });

  group('validateQuietHours', () {
    test('fails when times are identical', () {
      const time = TimeOfDay(hour: 9, minute: 30);
      final result = validateQuietHours(time, time);

      expect(result.isValid, isFalse);
      expect(result.message, 'quiet_hours_same_time');
    });

    test('passes when both times are null', () {
      final result = validateQuietHours(null, null);

      expect(result.isValid, isTrue);
    });

    test('fails when only start is provided', () {
      final result =
          validateQuietHours(const TimeOfDay(hour: 22, minute: 0), null);

      expect(result.isValid, isFalse);
      expect(result.message, 'quiet_hours_incomplete');
    });

    test('passes when valid times are provided', () {
      final result = validateQuietHours(
        const TimeOfDay(hour: 22, minute: 0),
        const TimeOfDay(hour: 7, minute: 0),
      );

      expect(result.isValid, isTrue);
    });
  });

  group('NotificationPreferencesViewModel.unavailable', () {
    test('creates unavailable view model with all features disabled', () {
      final vm = NotificationPreferencesViewModel.unavailable(
        availabilityStatus: NotificationsAvailabilityStatus.disabledByConfig,
        unavailableReasonKey: 'notifications_unavailable_disabled',
      );

      expect(vm.isAvailable, isFalse);
      expect(vm.orderStatusUpdatesEnabled, isFalse);
      expect(vm.promotionsEnabled, isFalse);
      expect(vm.systemAlertsEnabled, isFalse);
      expect(vm.canEditPromotions, isFalse);
      expect(vm.unavailableReasonKey, 'notifications_unavailable_disabled');
      expect(vm.availabilityStatus,
          NotificationsAvailabilityStatus.disabledByConfig);
    });
  });

  group('formatQuietHoursLabel', () {
    test('returns null when start is null', () {
      expect(formatQuietHoursLabel(null, const TimeOfDay(hour: 7, minute: 0)),
          isNull);
    });

    test('returns null when end is null', () {
      expect(formatQuietHoursLabel(const TimeOfDay(hour: 22, minute: 0), null),
          isNull);
    });

    test('formats label correctly', () {
      final label = formatQuietHoursLabel(
        const TimeOfDay(hour: 22, minute: 30),
        const TimeOfDay(hour: 7, minute: 15),
      );
      expect(label, 'من 22:30 إلى 07:15');
    });
  });

  group('quietHoursWrapsToNextDay', () {
    test('returns true when start is after end', () {
      expect(
        quietHoursWrapsToNextDay(
          const TimeOfDay(hour: 22, minute: 0),
          const TimeOfDay(hour: 7, minute: 0),
        ),
        isTrue,
      );
    });

    test('returns false when start is before end', () {
      expect(
        quietHoursWrapsToNextDay(
          const TimeOfDay(hour: 8, minute: 0),
          const TimeOfDay(hour: 18, minute: 0),
        ),
        isFalse,
      );
    });

    test('returns false when either is null', () {
      expect(
          quietHoursWrapsToNextDay(null, const TimeOfDay(hour: 7, minute: 0)),
          isFalse);
      expect(
          quietHoursWrapsToNextDay(const TimeOfDay(hour: 22, minute: 0), null),
          isFalse);
    });
  });
}

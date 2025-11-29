/// Notifications Providers Tests
/// Created by: Cursor B-ux
/// Purpose: Unit tests for notification preferences infra providers with Sale-Only behavior
/// Last updated: 2025-11-25

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notifications_shims/notifications_shims.dart';

import 'package:delivery_ways_clean/state/infra/notifications_providers.dart';

void main() {
  group('NotificationsAvailabilityNotifier', () {
    test('markAvailable sets status to available', () {
      final notifier = NotificationsAvailabilityNotifier();
      notifier.markAvailable();

      expect(notifier.state.status, NotificationsAvailabilityStatus.available);
      expect(notifier.state.isAvailable, isTrue);
      expect(notifier.state.lastChecked, isNotNull);
    });

    test('markDisabled sets status to disabledByConfig', () {
      final notifier = NotificationsAvailabilityNotifier();
      notifier.markDisabled();

      expect(notifier.state.status,
          NotificationsAvailabilityStatus.disabledByConfig);
      expect(notifier.state.isDisabled, isTrue);
      expect(notifier.state.shouldShowUnavailableMessage, isTrue);
    });

    test('markTemporarilyUnavailable sets status correctly', () {
      final notifier = NotificationsAvailabilityNotifier();
      notifier.markTemporarilyUnavailable('Backend error');

      expect(notifier.state.status,
          NotificationsAvailabilityStatus.temporarilyUnavailable);
      expect(notifier.state.isTemporarilyUnavailable, isTrue);
      expect(notifier.state.errorMessage, 'Backend error');
    });
  });

  group('DisabledNotificationPreferencesRepository', () {
    test('load returns default preferences', () async {
      const repository = DisabledNotificationPreferencesRepository();

      final prefs = await repository.load();

      expect(prefs.orderStatusUpdatesEnabled, isTrue); // defaults() has true
      expect(prefs.promotionsEnabled, isTrue);
      expect(prefs.systemAlertsEnabled, isTrue);
    });

    test('save is a no-op', () async {
      const repository = DisabledNotificationPreferencesRepository();

      // Should not throw
      await repository.save(const NotificationPreferences.defaults());
    });

    test('isChannelEnabled always returns false when disabled', () async {
      const repository = DisabledNotificationPreferencesRepository();

      expect(
          await repository
              .isChannelEnabled(NotificationChannel.orderUpdates),
          isFalse);
      expect(
          await repository.isChannelEnabled(NotificationChannel.promotions),
          isFalse);
      expect(await repository.isChannelEnabled(NotificationChannel.system),
          isFalse);
    });
  });

  group('notificationPreferencesRepositoryProvider', () {
    test('returns DisabledRepository when unavailable', () async {
      final container = ProviderContainer(
        overrides: [
          notificationsAvailabilityProvider.overrideWith(
            (ref) => NotificationsAvailabilityNotifier()..markDisabled(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final repository =
          container.read(notificationPreferencesRepositoryProvider);

      expect(repository, isA<DisabledNotificationPreferencesRepository>());
    });
  });

  group('notificationPreferencesProvider', () {
    test('loads preferences from repository', () async {
      final container = ProviderContainer(
        overrides: [
          notificationsAvailabilityProvider.overrideWith(
            (ref) => NotificationsAvailabilityNotifier()..markAvailable(),
          ),
          notificationPreferencesRepositoryProvider.overrideWithValue(
            const NoOpNotificationPreferencesRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final prefs =
          await container.read(notificationPreferencesProvider.future);

      expect(prefs.orderStatusUpdatesEnabled, isTrue);
      expect(prefs.promotionsEnabled, isTrue);
      expect(prefs.systemAlertsEnabled, isTrue);
    });
  });

  group('isNotificationsAvailableProvider', () {
    test('returns true when available', () {
      final container = ProviderContainer(
        overrides: [
          notificationsAvailabilityProvider.overrideWith(
            (ref) => NotificationsAvailabilityNotifier()..markAvailable(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final isAvailable = container.read(isNotificationsAvailableProvider);

      expect(isAvailable, isTrue);
    });

    test('returns false when disabled', () {
      final container = ProviderContainer(
        overrides: [
          notificationsAvailabilityProvider.overrideWith(
            (ref) => NotificationsAvailabilityNotifier()..markDisabled(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final isAvailable = container.read(isNotificationsAvailableProvider);

      expect(isAvailable, isFalse);
    });
  });

  group('notificationsUnavailableReasonKeyProvider', () {
    test('returns null when available', () {
      final container = ProviderContainer(
        overrides: [
          notificationsAvailabilityProvider.overrideWith(
            (ref) => NotificationsAvailabilityNotifier()..markAvailable(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final reasonKey =
          container.read(notificationsUnavailableReasonKeyProvider);

      expect(reasonKey, isNull);
    });

    test('returns disabled key when disabledByConfig', () {
      final container = ProviderContainer(
        overrides: [
          notificationsAvailabilityProvider.overrideWith(
            (ref) => NotificationsAvailabilityNotifier()..markDisabled(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final reasonKey =
          container.read(notificationsUnavailableReasonKeyProvider);

      expect(reasonKey, 'notifications_unavailable_disabled');
    });
  });
}

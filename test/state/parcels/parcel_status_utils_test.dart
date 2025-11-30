/// Parcel Status Utils Unit Tests - Track C Ticket #78, #81
/// Purpose: Test isParcelStatusTerminal, isParcelStatusUserCancellable, and localizedParcelStatus* functions
/// Created by: Track C - Ticket #78
/// Updated by: Track C - Ticket #81 (isParcelStatusUserCancellable tests)
/// Last updated: 2025-11-29

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parcels_shims/parcels_shims.dart' show ParcelStatus;

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/state/parcels/parcel_status_utils.dart';

void main() {
  // =========================================================================
  // isParcelStatusTerminal Tests
  // =========================================================================
  group('isParcelStatusTerminal', () {
    test('returns true for delivered status', () {
      expect(isParcelStatusTerminal(ParcelStatus.delivered), isTrue);
    });

    test('returns true for cancelled status', () {
      expect(isParcelStatusTerminal(ParcelStatus.cancelled), isTrue);
    });

    test('returns true for failed status', () {
      expect(isParcelStatusTerminal(ParcelStatus.failed), isTrue);
    });

    test('returns false for draft status', () {
      expect(isParcelStatusTerminal(ParcelStatus.draft), isFalse);
    });

    test('returns false for quoting status', () {
      expect(isParcelStatusTerminal(ParcelStatus.quoting), isFalse);
    });

    test('returns false for scheduled status', () {
      expect(isParcelStatusTerminal(ParcelStatus.scheduled), isFalse);
    });

    test('returns false for pickupPending status', () {
      expect(isParcelStatusTerminal(ParcelStatus.pickupPending), isFalse);
    });

    test('returns false for pickedUp status', () {
      expect(isParcelStatusTerminal(ParcelStatus.pickedUp), isFalse);
    });

    test('returns false for inTransit status', () {
      expect(isParcelStatusTerminal(ParcelStatus.inTransit), isFalse);
    });

    test('all active statuses return false', () {
      final activeStatuses = [
        ParcelStatus.draft,
        ParcelStatus.quoting,
        ParcelStatus.scheduled,
        ParcelStatus.pickupPending,
        ParcelStatus.pickedUp,
        ParcelStatus.inTransit,
      ];

      for (final status in activeStatuses) {
        expect(
          isParcelStatusTerminal(status),
          isFalse,
          reason: '$status should not be terminal',
        );
      }
    });

    test('all terminal statuses return true', () {
      final terminalStatuses = [
        ParcelStatus.delivered,
        ParcelStatus.cancelled,
        ParcelStatus.failed,
      ];

      for (final status in terminalStatuses) {
        expect(
          isParcelStatusTerminal(status),
          isTrue,
          reason: '$status should be terminal',
        );
      }
    });
  });

  // =========================================================================
  // isParcelStatusUserCancellable Tests (Track C - Ticket #81)
  // =========================================================================
  group('isParcelStatusUserCancellable', () {
    test('returns false for terminal statuses', () {
      expect(isParcelStatusUserCancellable(ParcelStatus.delivered), isFalse);
      expect(isParcelStatusUserCancellable(ParcelStatus.cancelled), isFalse);
      expect(isParcelStatusUserCancellable(ParcelStatus.failed), isFalse);
    });

    test('returns false for pickedUp status', () {
      expect(isParcelStatusUserCancellable(ParcelStatus.pickedUp), isFalse);
    });

    test('returns false for inTransit status', () {
      expect(isParcelStatusUserCancellable(ParcelStatus.inTransit), isFalse);
    });

    test('returns true for draft status', () {
      expect(isParcelStatusUserCancellable(ParcelStatus.draft), isTrue);
    });

    test('returns true for quoting status', () {
      expect(isParcelStatusUserCancellable(ParcelStatus.quoting), isTrue);
    });

    test('returns true for scheduled status', () {
      expect(isParcelStatusUserCancellable(ParcelStatus.scheduled), isTrue);
    });

    test('returns true for pickupPending status', () {
      expect(isParcelStatusUserCancellable(ParcelStatus.pickupPending), isTrue);
    });

    test('all pre-pickup statuses are cancellable', () {
      final preCancellableStatuses = [
        ParcelStatus.draft,
        ParcelStatus.quoting,
        ParcelStatus.scheduled,
        ParcelStatus.pickupPending,
      ];

      for (final status in preCancellableStatuses) {
        expect(
          isParcelStatusUserCancellable(status),
          isTrue,
          reason: '$status should be cancellable',
        );
      }
    });

    test('all post-pickup and terminal statuses are NOT cancellable', () {
      final nonCancellableStatuses = [
        ParcelStatus.pickedUp,
        ParcelStatus.inTransit,
        ParcelStatus.delivered,
        ParcelStatus.cancelled,
        ParcelStatus.failed,
      ];

      for (final status in nonCancellableStatuses) {
        expect(
          isParcelStatusUserCancellable(status),
          isFalse,
          reason: '$status should NOT be cancellable',
        );
      }
    });
  });

  // =========================================================================
  // localizedParcelStatusShort Tests (Short Labels)
  // =========================================================================
  group('localizedParcelStatusShort', () {
    testWidgets('returns EN labels correctly', (WidgetTester tester) async {
      late AppLocalizations l10n;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context)!;
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Test each status
      expect(localizedParcelStatusShort(l10n, ParcelStatus.scheduled), 'Scheduled');
      expect(localizedParcelStatusShort(l10n, ParcelStatus.pickupPending), 'Pickup pending');
      expect(localizedParcelStatusShort(l10n, ParcelStatus.pickedUp), 'Picked up');
      expect(localizedParcelStatusShort(l10n, ParcelStatus.inTransit), 'In transit');
      expect(localizedParcelStatusShort(l10n, ParcelStatus.delivered), 'Delivered');
      expect(localizedParcelStatusShort(l10n, ParcelStatus.cancelled), 'Cancelled');
      expect(localizedParcelStatusShort(l10n, ParcelStatus.failed), 'Failed');
    });

    testWidgets('returns AR labels correctly', (WidgetTester tester) async {
      late AppLocalizations l10n;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ar')],
          home: Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context)!;
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Test key statuses in Arabic
      expect(localizedParcelStatusShort(l10n, ParcelStatus.inTransit), 'في الطريق');
      expect(localizedParcelStatusShort(l10n, ParcelStatus.delivered), 'تم التسليم');
    });

    testWidgets('returns DE labels correctly', (WidgetTester tester) async {
      late AppLocalizations l10n;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('de'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('de')],
          home: Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context)!;
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Test key statuses in German
      expect(localizedParcelStatusShort(l10n, ParcelStatus.inTransit), 'Unterwegs');
      expect(localizedParcelStatusShort(l10n, ParcelStatus.delivered), 'Zugestellt');
    });

    test('returns fallback when l10n is null', () {
      expect(localizedParcelStatusShort(null, ParcelStatus.draft), 'Draft');
      expect(localizedParcelStatusShort(null, ParcelStatus.quoting), 'Quoting');
      expect(localizedParcelStatusShort(null, ParcelStatus.scheduled), 'Scheduled');
      expect(localizedParcelStatusShort(null, ParcelStatus.pickupPending), 'Pickup pending');
      expect(localizedParcelStatusShort(null, ParcelStatus.pickedUp), 'Picked up');
      expect(localizedParcelStatusShort(null, ParcelStatus.inTransit), 'In transit');
      expect(localizedParcelStatusShort(null, ParcelStatus.delivered), 'Delivered');
      expect(localizedParcelStatusShort(null, ParcelStatus.cancelled), 'Cancelled');
      expect(localizedParcelStatusShort(null, ParcelStatus.failed), 'Failed');
    });
  });

  // =========================================================================
  // localizedParcelStatusLong Tests (Verbose Labels)
  // =========================================================================
  group('localizedParcelStatusLong', () {
    testWidgets('returns EN verbose labels correctly', (WidgetTester tester) async {
      late AppLocalizations l10n;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context)!;
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Test each status - verbose labels
      expect(localizedParcelStatusLong(l10n, ParcelStatus.draft), 'Preparing your shipment...');
      expect(localizedParcelStatusLong(l10n, ParcelStatus.quoting), 'Preparing your shipment...');
      expect(localizedParcelStatusLong(l10n, ParcelStatus.scheduled), 'Pickup scheduled');
      expect(localizedParcelStatusLong(l10n, ParcelStatus.pickupPending), 'Waiting for pickup');
      expect(localizedParcelStatusLong(l10n, ParcelStatus.pickedUp), 'Picked up');
      expect(localizedParcelStatusLong(l10n, ParcelStatus.inTransit), 'In transit');
      expect(localizedParcelStatusLong(l10n, ParcelStatus.delivered), 'Delivered');
      expect(localizedParcelStatusLong(l10n, ParcelStatus.cancelled), 'Shipment cancelled');
      expect(localizedParcelStatusLong(l10n, ParcelStatus.failed), 'Delivery failed');
    });

    testWidgets('returns AR verbose labels correctly', (WidgetTester tester) async {
      late AppLocalizations l10n;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ar')],
          home: Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context)!;
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Test key statuses in Arabic - verbose
      expect(localizedParcelStatusLong(l10n, ParcelStatus.inTransit), 'قيد النقل');
      expect(localizedParcelStatusLong(l10n, ParcelStatus.delivered), 'تم التسليم');
    });

    testWidgets('returns DE verbose labels correctly', (WidgetTester tester) async {
      late AppLocalizations l10n;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('de'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('de')],
          home: Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context)!;
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Test key statuses in German - verbose
      expect(localizedParcelStatusLong(l10n, ParcelStatus.inTransit), 'Unterwegs');
      expect(localizedParcelStatusLong(l10n, ParcelStatus.delivered), 'Zugestellt');
    });
  });

  // =========================================================================
  // Integration Tests - Ensure consistency
  // =========================================================================
  group('Parcel Status Utils Integration', () {
    test('terminal statuses have both short and long labels', () {
      final terminalStatuses = [
        ParcelStatus.delivered,
        ParcelStatus.cancelled,
        ParcelStatus.failed,
      ];

      for (final status in terminalStatuses) {
        // Ensure fallback works
        final shortLabel = localizedParcelStatusShort(null, status);
        expect(shortLabel, isNotEmpty, reason: '$status should have a short label');
      }
    });

    test('active statuses have both short and long labels', () {
      final activeStatuses = [
        ParcelStatus.draft,
        ParcelStatus.quoting,
        ParcelStatus.scheduled,
        ParcelStatus.pickupPending,
        ParcelStatus.pickedUp,
        ParcelStatus.inTransit,
      ];

      for (final status in activeStatuses) {
        // Ensure fallback works
        final shortLabel = localizedParcelStatusShort(null, status);
        expect(shortLabel, isNotEmpty, reason: '$status should have a short label');
      }
    });
  });
}


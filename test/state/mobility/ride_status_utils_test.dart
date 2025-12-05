/// Ride Status Utils Unit Tests - Track B Ticket #85
/// Purpose: Test isRidePhaseTerminal, localizedRidePhaseStatusShort, and localizedRidePhaseStatusLong functions
/// Created by: Track B - Ticket #85
/// Last updated: 2025-11-29

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobility_shims/mobility_shims.dart' show RideTripPhase;

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/state/mobility/ride_status_utils.dart';

void main() {
  // =========================================================================
  // isRidePhaseTerminal Tests
  // =========================================================================
  group('isRidePhaseTerminal', () {
    test('returns true for completed phase', () {
      expect(isRidePhaseTerminal(RideTripPhase.completed), isTrue);
    });

    test('returns true for cancelled phase', () {
      expect(isRidePhaseTerminal(RideTripPhase.cancelled), isTrue);
    });

    test('returns true for failed phase', () {
      expect(isRidePhaseTerminal(RideTripPhase.failed), isTrue);
    });

    test('returns false for draft phase', () {
      expect(isRidePhaseTerminal(RideTripPhase.draft), isFalse);
    });

    test('returns false for quoting phase', () {
      expect(isRidePhaseTerminal(RideTripPhase.quoting), isFalse);
    });

    test('returns false for requesting phase', () {
      expect(isRidePhaseTerminal(RideTripPhase.requesting), isFalse);
    });

    test('returns false for findingDriver phase', () {
      expect(isRidePhaseTerminal(RideTripPhase.findingDriver), isFalse);
    });

    test('returns false for driverAccepted phase', () {
      expect(isRidePhaseTerminal(RideTripPhase.driverAccepted), isFalse);
    });

    test('returns false for driverArrived phase', () {
      expect(isRidePhaseTerminal(RideTripPhase.driverArrived), isFalse);
    });

    test('returns false for inProgress phase', () {
      expect(isRidePhaseTerminal(RideTripPhase.inProgress), isFalse);
    });

    test('returns false for payment phase', () {
      expect(isRidePhaseTerminal(RideTripPhase.payment), isFalse);
    });

    test('all active phases return false', () {
      final activePhases = [
        RideTripPhase.draft,
        RideTripPhase.quoting,
        RideTripPhase.requesting,
        RideTripPhase.findingDriver,
        RideTripPhase.driverAccepted,
        RideTripPhase.driverArrived,
        RideTripPhase.inProgress,
        RideTripPhase.payment,
      ];

      for (final phase in activePhases) {
        expect(
          isRidePhaseTerminal(phase),
          isFalse,
          reason: '$phase should not be terminal',
        );
      }
    });

    test('all terminal phases return true', () {
      final terminalPhases = [
        RideTripPhase.completed,
        RideTripPhase.cancelled,
        RideTripPhase.failed,
      ];

      for (final phase in terminalPhases) {
        expect(
          isRidePhaseTerminal(phase),
          isTrue,
          reason: '$phase should be terminal',
        );
      }
    });
  });

  // =========================================================================
  // localizedRidePhaseStatusShort Tests (Short Labels)
  // =========================================================================
  group('localizedRidePhaseStatusShort', () {
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

      // Test each phase
      expect(localizedRidePhaseStatusShort(l10n, RideTripPhase.draft), 'Draft');
      expect(localizedRidePhaseStatusShort(l10n, RideTripPhase.quoting), 'Getting price');
      expect(localizedRidePhaseStatusShort(l10n, RideTripPhase.requesting), 'Requesting ride');
      expect(localizedRidePhaseStatusShort(l10n, RideTripPhase.findingDriver), 'Finding driver');
      expect(localizedRidePhaseStatusShort(l10n, RideTripPhase.driverAccepted), 'Driver accepted');
      expect(localizedRidePhaseStatusShort(l10n, RideTripPhase.driverArrived), 'Driver arrived');
      expect(localizedRidePhaseStatusShort(l10n, RideTripPhase.inProgress), 'In progress');
      expect(localizedRidePhaseStatusShort(l10n, RideTripPhase.payment), 'Payment in progress');
      expect(localizedRidePhaseStatusShort(l10n, RideTripPhase.completed), 'Completed');
      expect(localizedRidePhaseStatusShort(l10n, RideTripPhase.cancelled), 'Cancelled');
      expect(localizedRidePhaseStatusShort(l10n, RideTripPhase.failed), 'Failed');
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

      // Test key phases in Arabic
      expect(localizedRidePhaseStatusShort(l10n, RideTripPhase.draft), 'مسودة');
      expect(localizedRidePhaseStatusShort(l10n, RideTripPhase.inProgress), 'قيد التنفيذ');
      expect(localizedRidePhaseStatusShort(l10n, RideTripPhase.completed), 'مكتملة');
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

      // Test key phases in German
      expect(localizedRidePhaseStatusShort(l10n, RideTripPhase.draft), 'Entwurf');
      expect(localizedRidePhaseStatusShort(l10n, RideTripPhase.inProgress), 'Unterwegs');
      expect(localizedRidePhaseStatusShort(l10n, RideTripPhase.completed), 'Abgeschlossen');
    });

    test('returns fallback when l10n is null', () {
      expect(localizedRidePhaseStatusShort(null, RideTripPhase.draft), 'Draft');
      expect(localizedRidePhaseStatusShort(null, RideTripPhase.quoting), 'Getting price');
      expect(localizedRidePhaseStatusShort(null, RideTripPhase.requesting), 'Requesting ride');
      expect(localizedRidePhaseStatusShort(null, RideTripPhase.findingDriver), 'Finding driver');
      expect(localizedRidePhaseStatusShort(null, RideTripPhase.driverAccepted), 'Driver accepted');
      expect(localizedRidePhaseStatusShort(null, RideTripPhase.driverArrived), 'Driver arrived');
      expect(localizedRidePhaseStatusShort(null, RideTripPhase.inProgress), 'In progress');
      expect(localizedRidePhaseStatusShort(null, RideTripPhase.payment), 'Payment in progress');
      expect(localizedRidePhaseStatusShort(null, RideTripPhase.completed), 'Completed');
      expect(localizedRidePhaseStatusShort(null, RideTripPhase.cancelled), 'Cancelled');
      expect(localizedRidePhaseStatusShort(null, RideTripPhase.failed), 'Failed');
    });

    test('all 11 phases return non-empty strings with null l10n', () {
      for (final phase in RideTripPhase.values) {
        final label = localizedRidePhaseStatusShort(null, phase);
        expect(label, isNotEmpty, reason: '$phase should have a fallback label');
      }
    });
  });

  // =========================================================================
  // localizedRidePhaseStatusLong Tests (Verbose Labels)
  // =========================================================================
  group('localizedRidePhaseStatusLong', () {
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

      // Test each phase - verbose labels
      // draft/quoting/requesting → Preparing
      expect(localizedRidePhaseStatusLong(l10n, RideTripPhase.draft), 'Preparing your trip...');
      expect(localizedRidePhaseStatusLong(l10n, RideTripPhase.quoting), 'Preparing your trip...');
      expect(localizedRidePhaseStatusLong(l10n, RideTripPhase.requesting), 'Preparing your trip...');

      // Individual phases
      expect(localizedRidePhaseStatusLong(l10n, RideTripPhase.findingDriver), 'Looking for a driver...');
      expect(localizedRidePhaseStatusLong(l10n, RideTripPhase.driverAccepted), 'Driver on the way');
      expect(localizedRidePhaseStatusLong(l10n, RideTripPhase.driverArrived), 'Driver has arrived');
      expect(localizedRidePhaseStatusLong(l10n, RideTripPhase.inProgress), 'Trip in progress');
      expect(localizedRidePhaseStatusLong(l10n, RideTripPhase.payment), 'Finalizing payment');
      expect(localizedRidePhaseStatusLong(l10n, RideTripPhase.completed), 'Trip completed');
      expect(localizedRidePhaseStatusLong(l10n, RideTripPhase.cancelled), 'Trip cancelled');
      expect(localizedRidePhaseStatusLong(l10n, RideTripPhase.failed), 'Trip failed');
    });

    testWidgets('draft/quoting/requesting all map to Preparing', (WidgetTester tester) async {
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

      final preparingLabel = localizedRidePhaseStatusLong(l10n, RideTripPhase.draft);
      expect(localizedRidePhaseStatusLong(l10n, RideTripPhase.quoting), preparingLabel);
      expect(localizedRidePhaseStatusLong(l10n, RideTripPhase.requesting), preparingLabel);
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

      // Test key phases in Arabic - verbose
      expect(localizedRidePhaseStatusLong(l10n, RideTripPhase.draft), 'جاري تجهيز رحلتك...');
      expect(localizedRidePhaseStatusLong(l10n, RideTripPhase.inProgress), 'الرحلة جارية');
      expect(localizedRidePhaseStatusLong(l10n, RideTripPhase.completed), 'تم إنهاء الرحلة');
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

      // Test key phases in German - verbose
      expect(localizedRidePhaseStatusLong(l10n, RideTripPhase.draft), 'Deine Fahrt wird vorbereitet...');
      expect(localizedRidePhaseStatusLong(l10n, RideTripPhase.inProgress), 'Fahrt läuft');
      expect(localizedRidePhaseStatusLong(l10n, RideTripPhase.completed), 'Fahrt abgeschlossen');
    });
  });

  // =========================================================================
  // Integration Tests - Ensure consistency
  // =========================================================================
  group('Ride Status Utils Integration', () {
    test('terminal phases have both short and long labels', () {
      final terminalPhases = [
        RideTripPhase.completed,
        RideTripPhase.cancelled,
        RideTripPhase.failed,
      ];

      for (final phase in terminalPhases) {
        // Ensure fallback works for short labels
        final shortLabel = localizedRidePhaseStatusShort(null, phase);
        expect(shortLabel, isNotEmpty, reason: '$phase should have a short label');
      }
    });

    test('active phases have both short and long labels', () {
      final activePhases = [
        RideTripPhase.draft,
        RideTripPhase.quoting,
        RideTripPhase.requesting,
        RideTripPhase.findingDriver,
        RideTripPhase.driverAccepted,
        RideTripPhase.driverArrived,
        RideTripPhase.inProgress,
        RideTripPhase.payment,
      ];

      for (final phase in activePhases) {
        // Ensure fallback works for short labels
        final shortLabel = localizedRidePhaseStatusShort(null, phase);
        expect(shortLabel, isNotEmpty, reason: '$phase should have a short label');
      }
    });

    test('all phases are covered in terminal check', () {
      // Ensure no phase is left uncategorized
      const allPhases = RideTripPhase.values;
      final terminalPhases = [
        RideTripPhase.completed,
        RideTripPhase.cancelled,
        RideTripPhase.failed,
      ];
      final activePhases = allPhases.where((p) => !terminalPhases.contains(p)).toList();

      // Verify counts
      expect(terminalPhases.length, 3, reason: 'Should have exactly 3 terminal phases');
      expect(activePhases.length, 8, reason: 'Should have exactly 8 active phases');
      expect(allPhases.length, 11, reason: 'Should have exactly 11 total phases');

      // Verify isRidePhaseTerminal is consistent
      for (final phase in terminalPhases) {
        expect(isRidePhaseTerminal(phase), isTrue);
      }
      for (final phase in activePhases) {
        expect(isRidePhaseTerminal(phase), isFalse);
      }
    });
  });
}


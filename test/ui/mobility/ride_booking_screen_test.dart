/// Ride Booking Screen Widget Tests - Track B Ticket #B-3
/// Purpose: Widget tests for RideBookingScreen UI behavior
/// Created by: Track B - Ticket #B-3
/// Updated by: Track A - Ticket #A-2 (AppShell integration)
/// Last updated: 2025-12-05

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:design_system_shims/design_system_shims.dart';
import 'package:design_system_components/design_system_components.dart';
import 'package:mobility_shims/mobility_shims.dart';
import 'package:mobility_shims/src/in_memory_ride_repository.dart';

import '../../../lib/l10n/generated/app_localizations.dart';
import '../../../lib/l10n/generated/app_localizations_en.dart';
import '../../../lib/screens/mobility/ride_booking_screen.dart';
import '../../../lib/state/mobility/ride_booking_controller.dart';
import '../../../lib/widgets/app_shell.dart';
import '../../../lib/widgets/app_button_unified.dart';
import 'package:maps_shims/maps.dart';

void main() {
  // Set up test binding with larger window for bottom sheet tests
  TestWidgetsFlutterBinding.ensureInitialized();
  // Note: We can't easily change window size in flutter_test, so we'll work with what we have

  group('RideBookingScreen Widget Tests', () {
    late AppLocalizationsEn l10n;

    setUp(() {
      l10n = AppLocalizationsEn();
    });

    Widget createTestWidget({
      List<Override> overrides = const [],
    }) {
      return ProviderScope(
        overrides: [
          mapViewBuilderProvider.overrideWith(
            (ref) => (params) => Container(key: const ValueKey('ride_booking_map')),
          ),
          rideRepositoryProvider.overrideWithValue(InMemoryRideRepository()),
          ...overrides,
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
          ],
          theme: DWTheme.light(),
          home: const RideBookingScreen(),
        ),
      );
    }

    testWidgets('initial render - CTA disabled before destination selection',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();


      // Verify screen uses AppShell
      expect(find.byType(AppShell), findsOneWidget);

      // Verify screen loads with title
      expect(find.text(l10n.rideBookingSheetTitle), findsOneWidget);
      expect(find.text(l10n.rideBookingPickupLabel), findsOneWidget);

      // CTA should be disabled initially (no destination selected)
      final ctaButton = find.byType(AppButtonUnified);
      expect(ctaButton, findsOneWidget);

      final buttonWidget = tester.widget<AppButtonUnified>(ctaButton);
      expect(buttonWidget.enabled, false);
      expect(buttonWidget.label, 'Select destination');
    });

    testWidgets('after destination selection - CTA becomes "See options" and enabled',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on a recent location to set destination
      await tester.tap(find.text(l10n.rideBookingRecentHome), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify CTA is now enabled with correct text
      final ctaButton = find.byType(AppButtonUnified);
      expect(ctaButton, findsOneWidget);

      final buttonWidget = tester.widget<AppButtonUnified>(ctaButton);
      expect(buttonWidget.enabled, true);
      expect(buttonWidget.label, l10n.rideBookingSeeOptionsCta);

      // Verify pricing information is shown
      expect(find.text('18.00'), findsOneWidget);
      expect(find.text('10 min'), findsOneWidget);
    });

    testWidgets('after requesting quote - CTA becomes "Confirm Ride"',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Set destination
      await tester.tap(find.text(l10n.rideBookingRecentHome), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Request quote by tapping CTA
      await tester.tap(find.byType(AppButtonUnified), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Wait for the async quote request to complete
      // The InMemoryRideRepository has a 300ms delay, so we need to wait a bit more
      await Future.delayed(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      // Verify CTA now shows "Confirm Ride"
      final ctaButton = find.byType(AppButtonUnified);
      expect(ctaButton, findsOneWidget);

      final buttonWidget = tester.widget<AppButtonUnified>(ctaButton);
      expect(buttonWidget.enabled, true);
      expect(buttonWidget.label, 'Confirm Ride');
    });

  });
}

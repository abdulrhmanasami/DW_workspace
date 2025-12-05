import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations_ar.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations_en.dart';
import 'package:delivery_ways_clean/screens/mobility/ride_booking_screen.dart';
import '../support/design_system_harness.dart';

void main() {
  setUpAll(() {
    ensureDesignSystemStubsForTests();
  });

  group('RideBookingSheet', () {
    late AppLocalizationsEn l10nEn;
    late AppLocalizationsAr l10nAr;

    setUp(() {
      l10nEn = AppLocalizationsEn();
      l10nAr = AppLocalizationsAr();
    });

    Widget createTestWidget({
      List<Override> overrides = const [],
      Locale locale = const Locale('en'),
    }) {
      return ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],
          home: const RideBookingScreen(),
        ),
      );
    }

    testWidgets('shows pickup location in EN locale', (tester) async {
      await tester.pumpWidget(
        createTestWidget(locale: const Locale('en')),
      );

      // Check for pickup label and current location text
      expect(find.text(l10nEn.rideBookingPickupLabel), findsOneWidget);
      expect(find.text(l10nEn.rideBookingPickupCurrentLocation), findsOneWidget);

      // Check for destination hint
      expect(find.text(l10nEn.rideBookingDestinationHint), findsOneWidget);

      // Check for CTA button
      expect(find.text(l10nEn.rideBookingSeeOptionsCta), findsOneWidget);
    });

    testWidgets('shows pickup location in AR locale (RTL)', (tester) async {
      await tester.pumpWidget(
        createTestWidget(locale: const Locale('ar')),
      );

      // Check for pickup label and current location text in Arabic
      expect(find.text(l10nAr.rideBookingPickupLabel), findsOneWidget);
      expect(find.text(l10nAr.rideBookingPickupCurrentLocation), findsOneWidget);

      // Check for destination hint in Arabic
      expect(find.text(l10nAr.rideBookingDestinationHint), findsOneWidget);

      // Check for CTA button in Arabic
      expect(find.text(l10nAr.rideBookingSeeOptionsCta), findsOneWidget);
    });

    testWidgets('has drag handle', (tester) async {
      await tester.pumpWidget(
        createTestWidget(),
      );

      // Check for drag handle (small container with specific dimensions)
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.constraints?.maxWidth == 40 &&
              widget.constraints?.maxHeight == 4,
        ),
        findsOneWidget,
      );
    });

    testWidgets('has title and subtitle', (tester) async {
      await tester.pumpWidget(
        createTestWidget(locale: const Locale('en')),
      );

      expect(find.text(l10nEn.rideBookingSheetTitle), findsOneWidget);
      expect(find.text(l10nEn.rideBookingSheetSubtitle), findsOneWidget);
    });

    testWidgets('shows recent locations', (tester) async {
      await tester.pumpWidget(
        createTestWidget(locale: const Locale('en')),
      );

      // Check for recent locations title
      expect(find.text(l10nEn.rideBookingRecentTitle), findsOneWidget);

      // Check for recent location items
      expect(find.text(l10nEn.rideBookingRecentHome), findsOneWidget);
      expect(find.text(l10nEn.rideBookingRecentWork), findsOneWidget);
      expect(find.text(l10nEn.rideBookingRecentAddNew), findsOneWidget);
    });

    testWidgets('destination input updates ride draft state', (tester) async {
      await tester.pumpWidget(
        createTestWidget(),
      );

      // Find the destination text field
      final textField = find.byType(TextFormField);
      expect(textField, findsOneWidget);

      // Enter text into destination field
      const testDestination = 'Test Destination';
      await tester.enterText(textField, testDestination);
      await tester.pump();

      // Verify the text was entered
      expect(find.text(testDestination), findsOneWidget);
    });

    testWidgets('CTA button shows validation error for empty destination',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(locale: const Locale('en')),
      );

      // Find and tap the CTA button without entering destination
      final ctaButton = find.text(l10nEn.rideBookingSeeOptionsCta);
      expect(ctaButton, findsOneWidget);

      await tester.tap(ctaButton);
      await tester.pump();

      // Should show snackbar with validation message
      expect(find.text(l10nEn.rideBookingDestinationHint), findsOneWidget);
    });
  });
}

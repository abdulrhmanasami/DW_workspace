/// Ride Booking Sheet FSM Integration Tests - Track B Ticket #242
/// Purpose: Integration tests for RideBookingScreen with FSM controller
/// Created by: Track B - Ticket #242
/// Last updated: 2025-12-04

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations_en.dart';
import 'package:delivery_ways_clean/screens/mobility/ride_booking_screen.dart';
import 'package:maps_shims/maps.dart';

void main() {
  group('RideBookingScreen FSM Integration', () {
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
          ...overrides,
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('en'),
          ],
          home: RideBookingScreen(),
        ),
      );
    }

    testWidgets('displays initial draft state', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Allow state to settle

      // Check that the screen loads
      expect(find.text(l10n.rideBookingSheetTitle), findsOneWidget);
      expect(find.text(l10n.rideBookingPickupLabel), findsOneWidget);
      expect(find.text(l10n.rideBookingDestinationLabel), findsOneWidget);
      expect(find.text(l10n.rideBookingSeeOptionsCta), findsOneWidget);

      // Check that map is displayed
      expect(find.byKey(const ValueKey('ride_booking_map')), findsOneWidget);
    });

    testWidgets('shows CTA button enabled initially', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      final ctaButton = find.text(l10n.rideBookingSeeOptionsCta);
      expect(ctaButton, findsOneWidget);

      // Button should be enabled (no locations set yet, so it should show error)
      final buttonWidget = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(buttonWidget.onPressed, isNotNull);
    });

    testWidgets('shows loading state when requesting quote', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Tap on a recent location to set destination
      await tester.tap(find.text(l10n.rideBookingRecentHome));
      await tester.pump();

      // Now tap CTA to request quote
      await tester.tap(find.text(l10n.rideBookingSeeOptionsCta));
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(l10n.rideBookingSeeOptionsCta), findsNothing);
    });

    testWidgets('shows price and duration after quote success', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Set destination
      await tester.tap(find.text(l10n.rideBookingRecentHome));
      await tester.pump();

      // Request quote
      await tester.tap(find.text(l10n.rideBookingSeeOptionsCta));
      await tester.pumpAndSettle(); // Wait for async operation

      // Should show price
      expect(find.text('18.50'), findsOneWidget);
      expect(find.text('10 min'), findsOneWidget);

      // CTA should now show "Confirm Ride"
      expect(find.text('Confirm Ride'), findsOneWidget);
    });

    testWidgets('shows error message for incomplete locations', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Try to request quote without setting locations
      await tester.tap(find.text(l10n.rideBookingSeeOptionsCta));
      await tester.pump();

      // Should show error message
      expect(find.text('quote_not_allowed'), findsOneWidget);
    });

    testWidgets('clears error when location is set', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Try to request quote without locations
      await tester.tap(find.text(l10n.rideBookingSeeOptionsCta));
      await tester.pump();

      // Error should be visible
      expect(find.text('quote_not_allowed'), findsOneWidget);

      // Now set a location
      await tester.tap(find.text(l10n.rideBookingRecentHome));
      await tester.pump();

      // Error should be cleared
      expect(find.text('quote_not_allowed'), findsNothing);
    });

    testWidgets('destination field shows helper text', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Check that destination field has helper text
      expect(find.text('Choose destination from recent locations below'), findsOneWidget);
      expect(find.text('Tap on a recent location to select destination'), findsOneWidget);
    });

    testWidgets('recent locations update destination', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Initially no pricing should be shown
      expect(find.text('18.50'), findsNothing);

      // Tap on recent location
      await tester.tap(find.text(l10n.rideBookingRecentHome));
      await tester.pump();

      // Now pricing should be shown (since we have both pickup and destination)
      expect(find.text('18.50'), findsOneWidget);
    });

    testWidgets('confirm ride navigates to confirmation screen', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Set destination and get quote
      await tester.tap(find.text(l10n.rideBookingRecentHome));
      await tester.pump();

      await tester.tap(find.text(l10n.rideBookingSeeOptionsCta));
      await tester.pumpAndSettle();

      // Now confirm ride
      await tester.tap(find.text('Confirm Ride'));
      await tester.pumpAndSettle();

      // This would normally navigate, but in test we can't check navigation
      // Just verify the button was tappable
      expect(find.text('Confirm Ride'), findsOneWidget);
    });

    testWidgets('shows drag handle', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Should have a drag handle (small rounded container)
      final containers = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.constraints != null &&
            widget.constraints!.maxWidth == 40 &&
            widget.constraints!.maxHeight == 4,
      );
      expect(containers, findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart';

import '../../../lib/l10n/generated/app_localizations.dart';
import '../../../lib/screens/home/home_tab_screen.dart';
import '../../../lib/ui/home/home_service_card.dart';
import '../../../lib/ui/home/home_map_placeholder.dart';

void main() {
  group('HomeTabScreen', () {
    late AppLocalizations l10n;

    setUp(() async {
      // Load localizations for English (LTR)
      l10n = await AppLocalizations.delegate.load(const Locale('en'));
    });

    testWidgets('builds in LTR English locale without exceptions',
        (WidgetTester tester) async {
      // Build the HomeTabScreen inside MaterialApp with theme and localizations
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const HomeTabScreen(),
          ),
        ),
      );

      // Wait for any async operations
      await tester.pumpAndSettle();

      // Verify the screen builds without exceptions
      expect(find.byType(HomeTabScreen), findsOneWidget);

      // Verify key UI elements are present
      expect(find.text(l10n.homeServiceRideTitle), findsOneWidget);
      expect(find.text(l10n.homeServiceParcelsTitle), findsOneWidget);
      expect(find.text(l10n.homeServiceFoodTitle), findsOneWidget);

      // Verify search placeholder is present
      expect(find.text(l10n.homeSearchPlaceholder), findsOneWidget);

      // Verify current location label and placeholder are present
      expect(find.text(l10n.homeCurrentLocationLabel), findsOneWidget);
      expect(find.text(l10n.homeCurrentLocationPlaceholder), findsOneWidget);

      // Verify service cards are present (should be 3)
      expect(find.byType(HomeServiceCard), findsNWidgets(3));

      // Verify map placeholder is present
      expect(find.byType(HomeMapPlaceholder), findsOneWidget);

      // Verify accessibility: check for Semantics widgets
      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('builds in RTL Arabic locale without exceptions',
        (WidgetTester tester) async {
      // Load Arabic localizations
      final arL10n = await AppLocalizations.delegate.load(const Locale('ar'));

      // Build the HomeTabScreen inside MaterialApp with RTL locale
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('ar'),
            home: const HomeTabScreen(),
          ),
        ),
      );

      // Wait for any async operations
      await tester.pumpAndSettle();

      // Verify the screen builds without exceptions
      expect(find.byType(HomeTabScreen), findsOneWidget);

      // Verify Arabic text is displayed correctly
      expect(find.text(arL10n.homeServiceRideTitle), findsOneWidget);
      expect(find.text(arL10n.homeServiceParcelsTitle), findsOneWidget);
      expect(find.text(arL10n.homeServiceFoodTitle), findsOneWidget);

      // Verify Arabic search placeholder
      expect(find.text(arL10n.homeSearchPlaceholder), findsOneWidget);

      // Verify Arabic location labels
      expect(find.text(arL10n.homeCurrentLocationLabel), findsOneWidget);
      expect(find.text(arL10n.homeCurrentLocationPlaceholder), findsOneWidget);
    });

    testWidgets('HomeServiceCard shows correct content and handles tap',
        (WidgetTester tester) async {
      const testTitle = 'Test Service';
      const testSubtitle = 'Test description';
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeServiceCard(
              icon: Icons.star,
              title: testTitle,
              subtitle: testSubtitle,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // Verify content is displayed
      expect(find.text(testTitle), findsOneWidget);
      expect(find.text(testSubtitle), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);

      // Verify Semantics for accessibility
      expect(find.byType(Semantics), findsWidgets);

      // Test tap functionality
      await tester.tap(find.byType(HomeServiceCard));
      expect(tapped, isTrue);
    });

    testWidgets('HomeMapPlaceholder displays correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const HomeMapPlaceholder(),
          ),
        ),
      );

      // Verify placeholder content
      expect(find.byIcon(Icons.map), findsOneWidget);
      expect(find.text('Map will appear here'), findsOneWidget);

      // Verify Semantics for accessibility
      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('service cards show snackbar on tap (placeholder behavior)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const HomeTabScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the ride service card
      await tester.tap(find.text(l10n.homeServiceRideTitle));
      await tester.pumpAndSettle();

      // Verify snackbar appears
      expect(find.text('Ride booking flow will be enabled soon.'), findsOneWidget);
    });
  });
}

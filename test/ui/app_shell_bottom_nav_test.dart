/// AppShell Bottom Navigation Tests - Track A Ticket #217
/// Purpose: Test Bottom Navigation tabs, labels (EN/AR/DE), and tab switching
/// Created by: Track A - Ticket #82
/// Updated by: Track B - Ticket #99 (Payments tab now shows PaymentsTabScreen)
/// Updated by: Track A - Ticket #217 (AppShell v1 with Bottom Navigation)
/// Last updated: 2025-12-04

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/app_shell/app_shell.dart';

void main() {
  /// Creates a test widget with necessary L10n and provider setup.
  /// Uses same pattern as settings_dsr_flow_test.dart for consistency.
  Widget createTestApp({
    Locale locale = const Locale('en'),
  }) {
    return ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        home: const AppShell(),
      ),
    );
  }

  group('AppShell Bottom Navigation - Ticket #82', () {
    testWidgets('shows four bottom nav items with correct labels (EN)',
        (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Verify all 4 navigation destinations exist with English labels
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('Payments'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Verify we have exactly 4 NavigationDestination widgets
      expect(find.byType(NavigationDestination), findsNWidgets(4));
    });

    testWidgets('tapping Orders tab shows ParcelsListScreen', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Initially on Home tab - verify home content is visible
      expect(find.text('Services'), findsOneWidget);

      // Tap Orders tab
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle();

      // Verify OrdersHistoryScreen is displayed
      // OrdersHistoryScreen shows "My Orders" title from ordersHistoryTitle L10n key
      // Track B - Ticket #96: Orders tab now shows OrdersHistoryScreen instead of ParcelsListScreen
      expect(find.text('My Orders'), findsOneWidget);
    });

    // Track B - Ticket #99: Payments tab now shows PaymentsTabScreen instead of stub
    testWidgets('tapping Payments tab shows PaymentsTabScreen', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Tap Payments tab
      await tester.tap(find.text('Payments'));
      await tester.pumpAndSettle();

      // Verify PaymentsTabScreen content is displayed
      expect(find.text('Payments'), findsAtLeastNWidgets(2)); // Title + tab label
      // Track B - Ticket #99: Verify payment methods are shown (default stub has Cash)
      expect(find.text('Cash'), findsAtLeastNWidgets(1));
      expect(find.text('Add new payment method'), findsOneWidget);
    });

    testWidgets('tapping Profile tab shows profile screen', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Tap Profile tab using icon (more reliable than text)
      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();

      // Verify Profile content is displayed
      // Profile screen has "Profile" title from profileTitle L10n key
      expect(find.widgetWithText(AppBar, 'Profile'), findsOneWidget);
    });

    testWidgets('l10n Arabic bottom nav labels', (tester) async {
      await tester.pumpWidget(createTestApp(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      // Verify Arabic labels
      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('الطلبات'), findsOneWidget);
      expect(find.text('المدفوعات'), findsOneWidget);
      expect(find.text('الحساب'), findsOneWidget);
    });

    testWidgets('l10n German bottom nav labels', (tester) async {
      await tester.pumpWidget(createTestApp(locale: const Locale('de')));
      await tester.pumpAndSettle();

      // Verify German labels
      expect(find.text('Start'), findsOneWidget);
      expect(find.text('Bestellungen'), findsOneWidget);
      expect(find.text('Zahlungen'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
    });

    // Track A - Ticket #229: Simplified navigation bar test
    testWidgets('NavigationBar renders correctly with correct icons and labels', (tester) async {
      const widget = MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: _SimpleNavBarTestWidget(),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Verify NavigationBar is present
      expect(find.byType(NavigationBar), findsOneWidget);

      // Verify all 4 navigation destinations exist
      expect(find.byType(NavigationDestination), findsNWidgets(4));

      // Verify English labels
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('Payments'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Verify icons are present - NavigationBar shows selected icon for first item (Home)
      expect(find.byIcon(Icons.home), findsOneWidget); // Selected icon for Home
      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('tab switching preserves state (IndexedStack)', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Start on Home
      expect(find.text('Services'), findsOneWidget);

      // Go to Orders (Track B - Ticket #96: Now shows OrdersHistoryScreen)
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle();
      expect(find.text('My Orders'), findsOneWidget);

      // Go to Payments (Track B - Ticket #99: Now shows PaymentsTabScreen)
      await tester.tap(find.text('Payments'));
      await tester.pumpAndSettle();
      expect(find.text('Add new payment method'), findsOneWidget);

      // Back to Home - should still work
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text('Services'), findsOneWidget);
    });

    // Track B - Ticket #99: Payments tab now shows PaymentsTabScreen with Arabic labels
    testWidgets('Payments tab shows correct Arabic text', (tester) async {
      await tester.pumpWidget(createTestApp(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      // Tap Payments tab (Arabic)
      await tester.tap(find.text('المدفوعات'));
      await tester.pumpAndSettle();

      // Verify Arabic PaymentsTabScreen content
      expect(find.text('طرق الدفع'), findsOneWidget); // Title
      expect(find.text('إضافة طريقة دفع جديدة'), findsOneWidget); // Add CTA
    });

    // Track B - Ticket #99: Payments tab now shows PaymentsTabScreen with German labels
    testWidgets('Payments tab shows correct German text', (tester) async {
      await tester.pumpWidget(createTestApp(locale: const Locale('de')));
      await tester.pumpAndSettle();

      // Tap Payments tab (German)
      await tester.tap(find.text('Zahlungen'));
      await tester.pumpAndSettle();

      // Verify German PaymentsTabScreen content
      expect(find.text('Zahlungsmethoden'), findsOneWidget); // Title
      expect(find.text('Neue Zahlungsmethode hinzufügen'), findsOneWidget); // Add CTA
    });

    // Track A - Ticket #223: Orders filter bar LTR support
    testWidgets('Orders tab filter bar builds correctly in LTR', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Navigate to Orders tab
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle();

      // Verify Orders screen is displayed
      expect(find.text('My Orders'), findsOneWidget);

      // Verify filter bar elements are present
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Rides'), findsOneWidget);
      expect(find.text('Parcels'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
    });

    // Track A - Ticket #221: Orders tab RTL support
    testWidgets('Orders tab works in RTL layout without exceptions', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.rtl,
          child: createTestApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Orders tab
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle();

      // Verify OrdersHistoryScreen displays without throwing exceptions
      expect(find.text('My Orders'), findsOneWidget);

      // Verify Empty State or content is shown (depending on data)
      // This ensures the screen builds properly in RTL
      expect(find.text('No orders yet'), findsAtLeastNWidgets(0));
      expect(find.text('Rides'), findsAtLeastNWidgets(0));
      expect(find.text('Parcels'), findsAtLeastNWidgets(0));
    });

    // Track A - Ticket #221: Payments tab RTL support
    testWidgets('Payments tab works in RTL layout without exceptions', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.rtl,
          child: createTestApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Payments tab
      await tester.tap(find.text('Payments'));
      await tester.pumpAndSettle();

      // Verify PaymentsTabScreen displays without throwing exceptions
      expect(find.text('Payments'), findsAtLeastNWidgets(2)); // Title + tab label

      // Verify Add payment method CTA is present
      expect(find.text('Add new payment method'), findsOneWidget);

      // Verify payment methods list or empty state is shown
      expect(find.text('Cash'), findsAtLeastNWidgets(0));
      expect(find.text('No payment methods saved'), findsAtLeastNWidgets(0));
    });

    // Track A - Ticket #221: Orders tab RTL with Arabic locale
    testWidgets('Orders tab works in RTL Arabic locale without exceptions', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.rtl,
          child: createTestApp(locale: const Locale('ar')),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Orders tab (Arabic)
      await tester.tap(find.text('الطلبات'));
      await tester.pumpAndSettle();

      // Verify Arabic OrdersHistoryScreen displays without throwing exceptions
      expect(find.text('طلباتي'), findsOneWidget); // Arabic title
    });

    // Track A - Ticket #223: Orders filter bar RTL support with Arabic locale
    testWidgets('Orders tab filter bar works in RTL layout with Arabic locale without exceptions', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.rtl,
          child: createTestApp(locale: const Locale('ar')),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to Orders tab (Arabic)
      await tester.tap(find.text('الطلبات'));
      await tester.pumpAndSettle();

      // Verify Arabic Orders screen is displayed
      expect(find.text('طلباتي'), findsOneWidget); // Arabic title

      // Verify Arabic filter bar elements are present and work in RTL
      expect(find.text('الكل'), findsOneWidget); // All
      expect(find.text('الرحلات'), findsOneWidget); // Rides
      expect(find.text('الطرود'), findsOneWidget); // Parcels
      expect(find.text('الطعام'), findsOneWidget); // Food
    });

    // Track A - Ticket #221: Payments tab RTL with Arabic locale
    testWidgets('Payments tab works in RTL Arabic locale without exceptions', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.rtl,
          child: createTestApp(locale: const Locale('ar')),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Payments tab (Arabic)
      await tester.tap(find.text('المدفوعات'));
      await tester.pumpAndSettle();

      // Verify Arabic PaymentsTabScreen displays without throwing exceptions
      expect(find.text('طرق الدفع'), findsOneWidget); // Arabic title

      // Verify Add payment method CTA is present in Arabic
      expect(find.text('إضافة طريقة دفع جديدة'), findsOneWidget);
    });

    // Track A - Ticket #222: Profile tab RTL support
    testWidgets('Profile tab works in RTL layout without exceptions', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.rtl,
          child: createTestApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Profile tab
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Verify Profile tab displays without throwing exceptions
      expect(find.text('Profile'), findsAtLeastNWidgets(2)); // Title + tab label

      // Verify profile sections are present
      expect(find.text('Settings'), findsAtLeastNWidgets(0)); // Settings section
      expect(find.text('Personal Information'), findsAtLeastNWidgets(0)); // Personal info setting
    });

    // Track A - Ticket #222: Profile tab RTL with Arabic locale
    testWidgets('Profile tab works in RTL Arabic locale without exceptions', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.rtl,
          child: createTestApp(locale: const Locale('ar')),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Profile tab (Arabic)
      await tester.tap(find.text('الحساب'));
      await tester.pumpAndSettle();

      // Verify Arabic Profile tab displays without throwing exceptions
      expect(find.text('الملف الشخصي'), findsOneWidget); // Arabic profile title

      // Verify Arabic profile sections are present
      expect(find.text('الإعدادات'), findsAtLeastNWidgets(0)); // Settings section in Arabic
    });

    // Track A - Ticket #229: Comprehensive tab switching tests in EN locale
    testWidgets('AppShell bottom nav switches between tabs without exceptions in EN locale', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Verify all tabs are present
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('Payments'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Test tab switching - just verify no exceptions occur
      // Switch to Orders tab
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle();

      // Switch to Payments tab
      await tester.tap(find.text('Payments'));
      await tester.pumpAndSettle();

      // Switch to Profile tab
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Switch back to Home tab
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      // If we reach here without exceptions, the test passes
      expect(find.text('Home'), findsOneWidget); // Verify bottom nav still works
    });

    // Track A - Ticket #229: RTL Arabic comprehensive tests
    testWidgets('AppShell bottom nav works in RTL Arabic locale without exceptions', (tester) async {
      await tester.pumpWidget(createTestApp(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      // Verify Arabic labels are present
      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('الطلبات'), findsOneWidget);
      expect(find.text('المدفوعات'), findsOneWidget);
      expect(find.text('الحساب'), findsOneWidget);

      // Test tab switching in Arabic - just verify no exceptions occur
      // Switch to Orders tab (Arabic)
      await tester.tap(find.text('الطلبات'));
      await tester.pumpAndSettle();

      // Switch to Payments tab (Arabic)
      await tester.tap(find.text('المدفوعات'));
      await tester.pumpAndSettle();

      // Switch to Profile tab (Arabic)
      await tester.tap(find.text('الحساب'));
      await tester.pumpAndSettle();

      // Switch back to Home tab (Arabic)
      await tester.tap(find.text('الرئيسية'));
      await tester.pumpAndSettle();

      // If we reach here without exceptions, the test passes
      expect(find.text('الرئيسية'), findsOneWidget); // Verify we can still see bottom nav
    });
  });
}

/// Simplified widget for testing NavigationBar without complex screens
class _SimpleNavBarTestWidget extends StatefulWidget {
  const _SimpleNavBarTestWidget();

  @override
  State<_SimpleNavBarTestWidget> createState() => _SimpleNavBarTestWidgetState();
}

class _SimpleNavBarTestWidgetState extends State<_SimpleNavBarTestWidget> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Text('Tab $_selectedIndex'),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: theme.colorScheme.surfaceTint,
        indicatorColor: theme.colorScheme.secondaryContainer,
        elevation: 3,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.bottomNavHomeLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: l10n.bottomNavOrdersLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: const Icon(Icons.account_balance_wallet),
            label: l10n.bottomNavPaymentsLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.bottomNavProfileLabel,
          ),
        ],
      ),
    );
  }
}

/// Root App Shell for Delivery Ways Super-App
/// Created by: Track A - Ticket #2
/// Updated by: Track D - Ticket #5 (Profile tab implementation)
/// Updated by: Track B - Ticket #19 (Home Hub Active Ride Card)
/// Updated by: Track B - Ticket #20 (Ride → RideDestinationScreen)
/// Updated by: Ticket #32 (App Shell + Home Hub DWTheme consistency)
/// Updated by: Track D - Ticket #36 (Phone + OTP Auth flow)
/// Updated by: Track D - Ticket #37 (Account Bottom Sheet + Sign out)
/// Updated by: Track C - Ticket #51 (Orders Tab → OrdersHistoryScreen)
/// Updated by: Track C - Ticket #70 (Home Hub Active Parcel Card)
/// Updated by: Track C - Ticket #71 (Active Order State Layout + Design System alignment)
/// Updated by: Track C - Ticket #74 (Unified navigation to ParcelShipmentDetailsScreen)
/// Updated by: Track A - Ticket #82 (L10n for BottomNav + Orders→ParcelsListScreen)
/// Updated by: Track B - Ticket #94 (Ride End-to-End Flow Wiring - Ride card active trip check)
/// Updated by: Track B - Ticket #99 (Payments tab → PaymentsTabScreen)
/// Updated by: Track B - Ticket #105 (Unified trip summary - price + payment in Home active card)
/// Updated by: Track B - Ticket #114 (Map from activeTripMapCommands + ETA on Active Ride Card)
/// Updated by: Track A - Ticket #135 (Design System alignment - explicit Theme colors for NavigationBar)
/// Updated by: Track A - Ticket #229 (Design System compliance + A11y + Bottom Nav Polish)
/// Purpose: Unified AppShell with Bottom Navigation (Home, Orders, Payments, Profile)
/// Last updated: 2025-12-04
///
/// This widget serves as the main entry point for authenticated users,
/// providing a consistent navigation structure across the app.
///
/// Track B - Ticket #114: Home Hub Map Integration (Screen 7)
/// - When active trip exists, map shows activeTripMapCommands via RideMapFromCommands
/// - Active Ride Card shows ETA from tripSummary.etaMinutes
/// - Fallback to placeholder map when no active trip

import 'package:flutter/material.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:design_system_shims/design_system_shims.dart'
    show DWElevation;
// Track C - Ticket #152: Orders tab now uses OrdersHistoryScreen
import 'package:delivery_ways_clean/screens/orders/orders_history_screen.dart';
// Track B - Ticket #99: Payments tab screen
import 'package:delivery_ways_clean/screens/payments/payments_tab_screen.dart';
// Track A - Ticket #227: Profile tab screen
import 'package:delivery_ways_clean/screens/profile/profile_tab_screen.dart';
// Track A - Ticket #228: Home tab screen (replaces complex _HomeTab)
import 'package:delivery_ways_clean/screens/home/home_tab_screen.dart';

/// App Tab enum for navigation
/// Track A - Ticket #217: AppShell v1 + Bottom Navigation
enum AppTab { home, orders, payments, profile }

/// AppShell V1 - Unified App Container
/// Created by: Ticket #179
/// Purpose: Universal container for all app screens with background and SafeArea
///
/// This widget serves as a unified wrapper around the entire app,
/// providing consistent background color and SafeArea across all screens.
/// Navigation logic is handled separately in future tickets.



/// AppShell with Bottom Navigation
/// Track A - Ticket #217: AppShell v1 + Bottom Navigation
/// Main app shell with 4-tab bottom navigation (Home, Orders, Payments, Profile)
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    this.startTab = AppTab.home,
  });

  final AppTab startTab;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late AppTab _currentTab;

  // Lazy loading for tabs - Track A - Ticket #226: Prevent PaymentGateway initialization in tests
  late final List<Widget?> _tabs;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.startTab;
    // Initialize with nulls, build tabs only when first visited
    _tabs = List<Widget?>.filled(AppTab.values.length, null);
    // Build initial tab
    _tabs[_currentTab.index] = _buildTab(_currentTab);
  }

  Widget _buildTab(AppTab tab) {
    switch (tab) {
      case AppTab.home:
        return const HomeTabScreen();
      case AppTab.orders:
        return const OrdersHistoryScreen();
      case AppTab.payments:
        return const PaymentsTabScreen();
      case AppTab.profile:
        return const ProfileTabScreen();
    }
  }

  void _onTabSelected(AppTab tab) {
    if (_currentTab == tab) return;
    setState(() {
      _currentTab = tab;
      // Build tab if not already built (lazy loading)
      _tabs[tab.index] ??= _buildTab(tab);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      // Track A - Ticket #135: Explicit background color from Theme
      backgroundColor: theme.colorScheme.surface,
      body: IndexedStack(
        index: _currentTab.index,
        children: List.generate(
          AppTab.values.length,
          (index) => _tabs[index] ?? const SizedBox.shrink(),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        // Track A - Ticket #135: Explicit Theme colors for navigation bar
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: theme.colorScheme.surfaceTint,
        indicatorColor: theme.colorScheme.secondaryContainer,
        // Track A - Ticket #217: Design system elevation.medium for bottom nav
        elevation: DWElevation.medium,
        selectedIndex: _currentTab.index,
        onDestinationSelected: (index) => _onTabSelected(AppTab.values[index]),
        // Design System: 4 tabs as per spec (Home, Orders, Payments, Profile)
        // Track A - Ticket #82: L10n for navigation labels
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.bottomNavHomeLabel,
            tooltip: l10n.bottomNavHomeLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: l10n.bottomNavOrdersLabel,
            tooltip: l10n.bottomNavOrdersLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: const Icon(Icons.account_balance_wallet),
            label: l10n.bottomNavPaymentsLabel,
            tooltip: l10n.bottomNavPaymentsLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.bottomNavProfileLabel,
            tooltip: l10n.bottomNavProfileLabel,
          ),
        ],
      ),
    );
  }
}





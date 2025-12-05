import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents a navigation item for the bottom navigation bar.
class AppNavItem {
  final String label;
  final IconData icon;
  final String route;

  const AppNavItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}

/// Unified App Shell providing a consistent scaffold:
/// - AppBar (اختياري)
/// - BottomNav (اختياري)
/// - SafeArea + padding موحّد
class AppShell extends ConsumerWidget {
  const AppShell({
    super.key,
    required this.body,
    this.title,
    this.navItems,
    this.selectedNavIndex,
    this.onNavItemTapped,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.showAppBar = true,
    this.showBottomNav = false,
    this.safeArea = true,
    this.bodyPadding,
  });

  /// Optional title for the AppBar.
  final String? title;

  /// Main body content.
  final Widget body;

  /// Optional bottom navigation items.
  final List<AppNavItem>? navItems;

  /// Currently selected bottom nav index.
  final int? selectedNavIndex;

  /// Callback when a bottom nav item is tapped.
  final ValueChanged<int>? onNavItemTapped;

  /// Floating action button and location.
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// AppBar visibility and bottom nav visibility.
  final bool showAppBar;
  final bool showBottomNav;

  /// Whether to wrap body in SafeArea.
  final bool safeArea;

  /// Optional padding for the body.
  final EdgeInsets? bodyPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // DWTheme يطبّق من الأعلى (main.dart)، هنا نستخدم ThemeData الحالي
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    // AppBar موحّد (لو ما في custom)
    final AppBar? effectiveAppBar;
    if (!showAppBar || title == null) {
      effectiveAppBar = null;
    } else {
      effectiveAppBar = AppBar(
        title: Text(
          title!,
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        centerTitle: true,
      );
    }

    // BottomNav موحّد (لو عندنا navItems)
    final Widget? effectiveBottomNav;
    if (showBottomNav && navItems != null && navItems!.isNotEmpty) {
      final currentIndex = selectedNavIndex ?? 0;
      effectiveBottomNav = NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          if (index != currentIndex) {
            onNavItemTapped?.call(index);
          }
        },
        destinations: [
          for (final item in navItems!)
            NavigationDestination(
              icon: Icon(item.icon),
              label: item.label,
            ),
        ],
      );
    } else {
      effectiveBottomNav = null;
    }

    // Body مع padding و SafeArea موحّد
    Widget effectiveBody = body;
    if (bodyPadding != null) {
      effectiveBody = Padding(
        padding: bodyPadding!,
        child: effectiveBody,
      );
    }
    if (safeArea) {
      effectiveBody = SafeArea(child: effectiveBody);
    }

    return Scaffold(
      appBar: effectiveAppBar,
      body: effectiveBody,
      bottomNavigationBar: effectiveBottomNav,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      backgroundColor: colorScheme.surface,
    );
  }
}

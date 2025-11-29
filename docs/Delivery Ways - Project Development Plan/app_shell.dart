import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart';

/// Component: Unified App Shell
/// Created by: Track A - Design System Implementation
/// Purpose: Provides consistent app structure with unified theming
/// Last updated: 2025-11-27

/// Represents the navigation item for bottom navigation
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

/// Unified App Shell providing consistent app structure
class AppShell extends ConsumerWidget {
  final String? title;
  final Widget body;
  final List<AppNavItem>? navItems;
  final int? selectedNavIndex;
  final Function(int)? onNavItemTapped;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final PreferredSizeWidget? appBar;
  final bool showAppBar;
  final bool showBottomNav;
  final Color? backgroundColor;
  final EdgeInsets? bodyPadding;
  final bool safeArea;

  const AppShell({
    super.key,
    this.title,
    required this.body,
    this.navItems,
    this.selectedNavIndex,
    this.onNavItemTapped,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.appBar,
    this.showAppBar = true,
    this.showBottomNav = true,
    this.backgroundColor,
    this.bodyPadding,
    this.safeArea = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);

    // Build default AppBar if title is provided and no custom appBar
    final effectiveAppBar = appBar ??
        (showAppBar && title != null
            ? AppBar(
                title: Text(title!),
                elevation: 0,
                backgroundColor: theme.colors.surface,
                foregroundColor: theme.colors.onSurface,
              )
            : null);

    // Build bottom navigation if navItems provided
    final effectiveBottomNav = showBottomNav && navItems != null && navItems!.isNotEmpty
        ? _buildBottomNav(theme, navItems!, selectedNavIndex ?? 0, onNavItemTapped)
        : null;

    // Build body with optional padding and safe area
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
      body: Container(
        color: backgroundColor ?? theme.colors.background,
        child: effectiveBody,
      ),
      bottomNavigationBar: effectiveBottomNav,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }

  /// Build bottom navigation bar
  Widget _buildBottomNav(
    AppThemeData theme,
    List<AppNavItem> items,
    int selectedIndex,
    Function(int)? onTapped,
  ) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTapped,
      type: BottomNavigationBarType.fixed,
      backgroundColor: theme.colors.surface,
      selectedItemColor: theme.colors.primary,
      unselectedItemColor: theme.colors.onSurface.withValues(alpha: 0.6),
      elevation: 8,
      items: items
          .map((item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.label,
              ))
          .toList(),
    );
  }
}

/// Simple AppBar builder for consistent styling
class AppBarBuilder {
  static AppBar buildDefault({
    required String title,
    required AppThemeData theme,
    List<Widget>? actions,
    bool centerTitle = false,
    VoidCallback? onBackPressed,
  }) {
    return AppBar(
      title: Text(
        title,
        style: theme.typography.headline6.copyWith(
          color: theme.colors.onSurface,
        ),
      ),
      elevation: 0,
      backgroundColor: theme.colors.surface,
      foregroundColor: theme.colors.onSurface,
      centerTitle: centerTitle,
      actions: actions,
      leading: onBackPressed != null
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed,
            )
          : null,
    );
  }
}

/// Bottom navigation item builder
class BottomNavBuilder {
  static List<AppNavItem> buildDefaultItems() {
    return const [
      AppNavItem(
        label: 'Home',
        icon: Icons.home_outlined,
        route: '/',
      ),
      AppNavItem(
        label: 'Orders',
        icon: Icons.shopping_bag_outlined,
        route: '/orders',
      ),
      AppNavItem(
        label: 'Payments',
        icon: Icons.payment_outlined,
        route: '/payment',
      ),
      AppNavItem(
        label: 'Profile',
        icon: Icons.person_outlined,
        route: '/profile',
      ),
    ];
  }
}

/// DWAppShell - Unified Scaffold wrapper for Delivery Ways screens
/// Created by: Track A - Ticket #134
/// Purpose: Scaffold موحّد يعتمد على DWTheme/Design Tokens لمسارات Ride/Parcels/Food.
///
/// This widget provides:
/// - Consistent background color from Design System (colorScheme.surface)
/// - Standard padding (DWSpacing.md = 16pt)
/// - Optional SafeArea wrapping
/// - Passthrough for appBar, bottomNavigationBar, floatingActionButton
///
/// Usage:
/// ```dart
/// DWAppShell(
///   appBar: AppBar(title: Text('Screen Title')),
///   body: MyScreenContent(),
/// )
/// ```

import 'package:flutter/material.dart';
import 'package:design_system_shims/design_system_shims.dart';

/// DWAppShell
/// Scaffold موحّد يعتمد على DWTheme/Design Tokens لمسارات Ride/Parcels/Food.
/// Track A – App Shell (Ticket #134)
class DWAppShell extends StatelessWidget {
  /// The app bar to display at the top of the scaffold.
  final PreferredSizeWidget? appBar;

  /// The primary content of the scaffold.
  final Widget body;

  /// A bottom navigation bar to display at the bottom of the scaffold.
  final Widget? bottomNavigationBar;

  /// A floating action button to display over the body.
  final Widget? floatingActionButton;

  /// Whether to wrap the body in a SafeArea widget.
  /// Defaults to true.
  final bool useSafeArea;

  /// Whether to extend the body behind the app bar.
  /// Useful for screens with map backgrounds.
  /// Defaults to false.
  final bool extendBodyBehindAppBar;

  /// Whether to apply the standard padding to the body.
  /// Set to false for full-bleed content like maps.
  /// Defaults to true.
  final bool applyPadding;

  const DWAppShell({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.useSafeArea = true,
    this.extendBodyBehindAppBar = false,
    this.applyPadding = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget content = body;

    // Apply standard padding if requested
    // DS: space.md (16pt) for horizontal and vertical padding
    if (applyPadding) {
      content = Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DWSpacing.md,
          vertical: DWSpacing.md,
        ),
        child: content,
      );
    }

    // Wrap in SafeArea if requested
    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      // DS: color.surface.default (was color.background.default, now deprecated)
      backgroundColor: colorScheme.surface,
      appBar: appBar,
      body: content,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart';

/// Component: Unified Card Component
/// Created by: Track A - Design System Implementation
/// Purpose: Consistent card styling across the app
/// Last updated: 2025-11-27

/// Unified card component with consistent styling
class AppCardUnified extends ConsumerWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final BorderSide? borderSide;

  const AppCardUnified({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.borderSide,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);

    final effectivePadding = padding ?? EdgeInsets.all(theme.spacing.md);
    final effectiveElevation = elevation ?? 1;
    final effectiveBorderRadius = borderRadius ??
        BorderRadius.circular(theme.spacing.mediumRadius);
    final effectiveBackgroundColor = backgroundColor ?? theme.colors.surface;

    final card = Card(
      elevation: effectiveElevation,
      shape: RoundedRectangleBorder(
        borderRadius: effectiveBorderRadius,
        side: borderSide ?? BorderSide.none,
      ),
      color: effectiveBackgroundColor,
      child: Padding(
        padding: effectivePadding,
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: effectiveBorderRadius,
        child: card,
      );
    }

    return card;
  }
}

/// Convenience factory methods for common card types
class AppCard {
  /// Standard card with default styling
  static Widget standard({
    required Widget child,
    EdgeInsets? padding,
    VoidCallback? onTap,
  }) {
    return AppCardUnified(
      padding: padding,
      onTap: onTap,
      child: child,
    );
  }

  /// Elevated card with higher elevation
  static Widget elevated({
    required Widget child,
    EdgeInsets? padding,
    VoidCallback? onTap,
  }) {
    return AppCardUnified(
      padding: padding,
      onTap: onTap,
      elevation: 4,
      child: child,
    );
  }

  /// Outlined card with border instead of elevation
  static Widget outlined({
    required Widget child,
    EdgeInsets? padding,
    VoidCallback? onTap,
    Color? borderColor,
  }) {
    return Consumer(
      builder: (context, ref, _) {
        final theme = ref.watch(appThemeProvider);
        return AppCardUnified(
          padding: padding,
          onTap: onTap,
          elevation: 0,
          borderSide: BorderSide(
            color: borderColor ?? theme.colors.outline,
            width: 1,
          ),
          child: child,
        );
      },
    );
  }

  /// Filled card with colored background
  static Widget filled({
    required Widget child,
    required Color backgroundColor,
    EdgeInsets? padding,
    VoidCallback? onTap,
  }) {
    return AppCardUnified(
      padding: padding,
      onTap: onTap,
      backgroundColor: backgroundColor,
      elevation: 0,
      child: child,
    );
  }
}

/// List card for displaying list items
class AppListCard extends ConsumerWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isSelected;

  const AppListCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);

    return AppCardUnified(
      onTap: onTap,
      backgroundColor: isSelected
          ? theme.colors.primary.withValues(alpha: 0.1)
          : theme.colors.surface,
      borderSide: isSelected
          ? BorderSide(color: theme.colors.primary, width: 1.5)
          : null,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            SizedBox(width: theme.spacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.typography.subtitle1.copyWith(
                    color: theme.colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: theme.spacing.xs),
                  Text(
                    subtitle!,
                    style: theme.typography.body2.copyWith(
                      color: theme.colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: theme.spacing.md),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Grid card for displaying grid items
class AppGridCard extends ConsumerWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? iconColor;

  const AppGridCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);

    return AppCardUnified(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 40,
            color: iconColor ?? theme.colors.primary,
          ),
          SizedBox(height: theme.spacing.md),
          Text(
            title,
            style: theme.typography.subtitle2.copyWith(
              color: theme.colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            SizedBox(height: theme.spacing.xs),
            Text(
              subtitle!,
              style: theme.typography.caption.copyWith(
                color: theme.colors.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// DwCard - Design System Card Atom
/// Created by: Cursor B-ux
/// Purpose: Standardized card container using design tokens
/// Last updated: 2025-11-11

import 'package:flutter/material.dart';
import 'package:design_system_components/src/internal/tokens_bridge.dart';

/// Card elevation levels
enum DwCardElevation { none, low, medium, high }

/// Standardized card atom using design tokens
class DwCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final DwCardElevation elevation;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final VoidCallback? onTap;

  const DwCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation = DwCardElevation.low,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? _getDefaultPadding(),
      margin: margin ?? _getDefaultMargin(),
      decoration: BoxDecoration(
        color: backgroundColor ?? TokensBridge.colors.surface,
        borderRadius:
            borderRadius ??
            BorderRadius.circular(TokensBridge.spacing.mediumRadius),
        border: border,
        boxShadow: _getShadow(),
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius:
            borderRadius ??
            BorderRadius.circular(TokensBridge.spacing.mediumRadius),
        child: card,
      );
    }

    return card;
  }

  EdgeInsets _getDefaultPadding() {
    return EdgeInsets.all(TokensBridge.spacing.md);
  }

  EdgeInsets _getDefaultMargin() {
    return EdgeInsets.all(TokensBridge.spacing.xs);
  }

  List<BoxShadow>? _getShadow() {
    switch (elevation) {
      case DwCardElevation.none:
        return null;
      case DwCardElevation.low:
        return TokensBridge.shadows.elevation1;
      case DwCardElevation.medium:
        return TokensBridge.shadows.elevation2;
      case DwCardElevation.high:
        return TokensBridge.shadows.elevation4;
    }
  }
}

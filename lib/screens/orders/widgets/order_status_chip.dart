/// Order Status Chip Widget
/// Created by: Track B - Ticket #126
/// Updated by: Track B - Ticket #127 (Added Semantics for accessibility)
/// Purpose: Unified status chip for Orders History cards (Rides, Parcels)
/// Last updated: 2025-12-01

import 'package:design_system_shims/design_system_shims.dart';
import 'package:flutter/material.dart';

/// Semantic tone for order status visualization.
///
/// Maps to specific color combinations in the design system:
/// - [success]: Completed/delivered states (green tones)
/// - [warning]: Pending/waiting states (amber/orange tones)
/// - [error]: Cancelled/failed states (red tones)
/// - [info]: In-progress/neutral states (blue/gray tones)
enum OrderStatusTone {
  success,
  warning,
  error,
  info,
}

/// Presentation model for order status display.
///
/// Decouples domain status enums from UI rendering by providing:
/// - [label]: Localized text to display inside the chip
/// - [tone]: Semantic color mapping for visual feedback
///
/// Usage:
/// ```dart
/// final status = OrderStatusUiModel(
///   label: l10n.ordersRideStatusCompleted,
///   tone: OrderStatusTone.success,
/// );
/// ```
class OrderStatusUiModel {
  const OrderStatusUiModel({
    required this.label,
    required this.tone,
  });

  /// Localized status label to display.
  final String label;

  /// Semantic tone for color mapping.
  final OrderStatusTone tone;
}

/// A compact chip widget displaying order status.
///
/// Implements the `Utility/Chip` design token with:
/// - Rounded corners (pill shape)
/// - Semantic background and foreground colors based on [tone]
/// - Small label text with medium weight
/// - Accessibility: Semantics label for screen readers
///
/// Track B - Ticket #126: Created for Orders History status display.
/// Track B - Ticket #127: Added Semantics wrapper for accessibility.
class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({
    super.key,
    required this.status,
  });

  /// The status model containing label and tone.
  final OrderStatusUiModel status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final (Color bg, Color fg) = _resolveColors(colorScheme);

    // Track B - Ticket #127: Wrap in Semantics for screen reader accessibility
    return Semantics(
      label: status.label,
      // Exclude the child Text from semantics to avoid duplication
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DWSpacing.xs,
          vertical: DWSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: bg,
          // Pill shape - using large value for fully rounded ends
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          status.label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: fg,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Resolves background and foreground colors based on the status tone.
  (Color, Color) _resolveColors(ColorScheme colorScheme) {
    return switch (status.tone) {
      OrderStatusTone.success => (
          colorScheme.tertiary.withValues(alpha: 0.12),
          colorScheme.tertiary,
        ),
      OrderStatusTone.warning => (
          colorScheme.secondary.withValues(alpha: 0.12),
          colorScheme.secondary,
        ),
      OrderStatusTone.error => (
          colorScheme.error.withValues(alpha: 0.12),
          colorScheme.error,
        ),
      OrderStatusTone.info => (
          colorScheme.primary.withValues(alpha: 0.12),
          colorScheme.primary,
        ),
    };
  }
}


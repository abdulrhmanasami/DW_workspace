/// Orders History Filter Bar Widget
/// Created by: Track B - Ticket #125
/// Purpose: Segmented Control for filtering orders by type (All/Rides/Parcels/Food)
/// Design System: Implements Segmented Control per mockups Screen 15
/// Last updated: 2025-12-01

import 'package:design_system_shims/design_system_shims.dart';
import 'package:flutter/material.dart';

/// Filter enum for orders list - exported for use in tests
enum OrdersHistoryFilter {
  all,
  rides,
  parcels,
  food,
}

/// Segmented Control for filtering orders history.
///
/// Follows Design System specifications:
/// - Uses `color.surface.elevated` for background
/// - Uses `color.primary.base` for selected state
/// - Minimum touch target of 44x44 for accessibility
/// - Selected segment has primary color, unselected uses secondary text color
///
/// Track B - Ticket #125
class OrdersHistoryFilterBar extends StatelessWidget {
  const OrdersHistoryFilterBar({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
    required this.labels,
    this.showFoodFilter = true,
  });

  /// Currently selected filter
  final OrdersHistoryFilter currentFilter;

  /// Callback when filter changes
  final ValueChanged<OrdersHistoryFilter> onFilterChanged;

  /// Labels for each filter tab
  final OrdersHistoryFilterLabels labels;

  /// Whether to show the Food filter (controlled by feature flag)
  final bool showFoodFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final filters = <OrdersHistoryFilter>[
      OrdersHistoryFilter.all,
      OrdersHistoryFilter.rides,
      OrdersHistoryFilter.parcels,
      if (showFoodFilter) OrdersHistoryFilter.food,
    ];

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: DWSpacing.md,
        vertical: DWSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(DWRadius.md),
      ),
      padding: const EdgeInsets.all(DWSpacing.xxs),
      child: Row(
        children: filters.map((filter) {
          final isSelected = currentFilter == filter;
          final label = _labelFor(filter);

          return Expanded(
            child: GestureDetector(
              onTap: () => onFilterChanged(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                constraints: const BoxConstraints(
                  minHeight: 44, // Accessibility: minimum touch target
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(DWRadius.sm),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _labelFor(OrdersHistoryFilter filter) {
    switch (filter) {
      case OrdersHistoryFilter.all:
        return labels.all;
      case OrdersHistoryFilter.rides:
        return labels.rides;
      case OrdersHistoryFilter.parcels:
        return labels.parcels;
      case OrdersHistoryFilter.food:
        return labels.food;
    }
  }
}

/// Labels for the filter bar tabs
class OrdersHistoryFilterLabels {
  const OrdersHistoryFilterLabels({
    required this.all,
    required this.rides,
    required this.parcels,
    required this.food,
  });

  final String all;
  final String rides;
  final String parcels;
  final String food;
}


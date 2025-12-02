/// Ride Quote Options Sheet - Track B Ticket #140
/// Purpose: Display RideQuoteOption list in a professional UI
/// Created by: Track B - Ticket #140
/// Last updated: 2025-12-02
///
/// This widget presents ride pricing options from RideQuote
/// in a reusable format (bottom sheet or standalone widget).
/// Uses Design System tokens throughout.

import 'package:flutter/material.dart';
import 'package:design_system_shims/design_system_shims.dart';
import 'package:mobility_shims/mobility_shims.dart';

/// Main widget for displaying ride quote options.
///
/// Can be used as a bottom sheet or standalone widget.
/// Displays a list of [RideQuoteOption] with selection capability.
class RideQuoteOptionsSheet extends StatelessWidget {
  const RideQuoteOptionsSheet({
    super.key,
    required this.quote,
    this.selectedOption,
    required this.onOptionSelected,
    this.onClose,
    this.showHandle = true,
  });

  /// The quote containing available options.
  final RideQuote quote;

  /// Currently selected option (if any).
  final RideQuoteOption? selectedOption;

  /// Callback when an option is selected.
  final ValueChanged<RideQuoteOption> onOptionSelected;

  /// Optional callback when sheet is closed.
  final VoidCallback? onClose;

  /// Whether to show the drag handle (for bottom sheet).
  final bool showHandle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(DWRadius.lg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle (for bottom sheet)
          if (showHandle)
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(
                  top: DWSpacing.sm,
                  bottom: DWSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: colors.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(DWRadius.sm),
                ),
              ),
            ),

          // Header with title and close button
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DWSpacing.lg,
              vertical: DWSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Choose your ride',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (onClose != null)
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Options list
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(DWSpacing.md),
              itemCount: quote.options.length,
              separatorBuilder: (_, __) => const SizedBox(height: DWSpacing.sm),
              itemBuilder: (context, index) {
                final option = quote.options[index];
                final isSelected = option.id == selectedOption?.id;

                return _RideQuoteOptionTile(
                  option: option,
                  isSelected: isSelected,
                  isRecommended: option.isRecommended,
                  onTap: () => onOptionSelected(option),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual option tile widget.
class _RideQuoteOptionTile extends StatelessWidget {
  const _RideQuoteOptionTile({
    required this.option,
    required this.isSelected,
    required this.isRecommended,
    required this.onTap,
  });

  final RideQuoteOption option;
  final bool isSelected;
  final bool isRecommended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final backgroundColor = isSelected
        ? colors.primaryContainer
        : colors.surface;
    final borderColor = isSelected
        ? colors.primary
        : colors.outline.withValues(alpha: 0.3);

    return InkWell(
      borderRadius: BorderRadius.circular(DWRadius.md),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(DWSpacing.md),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(DWRadius.md),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // Vehicle icon
            Icon(
              _getVehicleIcon(option.category),
              size: 32,
              color: isSelected ? colors.primary : colors.onSurfaceVariant,
            ),
            const SizedBox(width: DWSpacing.md),

            // Option details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with recommended badge
                  Row(
                    children: [
                      Text(
                        option.displayName,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: DWSpacing.xs),
                        _RecommendedBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: DWSpacing.xxs),
                  
                  // Category description
                  Text(
                    _getCategoryDescription(option.category),
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: DWSpacing.xxs),
                  
                  // ETA
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        size: 14,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: DWSpacing.xxs),
                      Text(
                        '${option.etaMinutes} min',
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: DWSpacing.sm),

            // Price and selection indicator
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Price
                Text(
                  '${option.formattedPrice} ${option.currencyCode}',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? colors.primary : null,
                  ),
                ),
                const SizedBox(height: DWSpacing.xxs),
                
                // Selection indicator
                Icon(
                  isSelected 
                      ? Icons.radio_button_checked 
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: isSelected ? colors.primary : colors.onSurfaceVariant,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Returns appropriate icon for vehicle category.
  IconData _getVehicleIcon(RideVehicleCategory category) {
    switch (category) {
      case RideVehicleCategory.economy:
        return Icons.directions_car_outlined;
      case RideVehicleCategory.xl:
        return Icons.airport_shuttle_outlined;
      case RideVehicleCategory.premium:
        return Icons.directions_car_filled;
    }
  }

  /// Returns description for vehicle category.
  String _getCategoryDescription(RideVehicleCategory category) {
    switch (category) {
      case RideVehicleCategory.economy:
        return 'Affordable everyday rides';
      case RideVehicleCategory.xl:
        return 'Extra space for groups';
      case RideVehicleCategory.premium:
        return 'Premium comfort';
    }
  }
}

/// Recommended badge widget.
class _RecommendedBadge extends StatelessWidget {
  const _RecommendedBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DWSpacing.xs,
        vertical: DWSpacing.xxs / 2,
      ),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(DWRadius.xs),
      ),
      child: Text(
        'Recommended',
        style: theme.textTheme.labelSmall?.copyWith(
          color: colors.onSecondaryContainer,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}

/// Helper function to show the quote options sheet as a modal bottom sheet.
Future<RideQuoteOption?> showRideQuoteOptionsSheet({
  required BuildContext context,
  required RideQuote quote,
  RideQuoteOption? selectedOption,
}) async {
  return await showModalBottomSheet<RideQuoteOption>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (context) {
      return RideQuoteOptionsSheet(
        quote: quote,
        selectedOption: selectedOption,
        onOptionSelected: (option) {
          Navigator.of(context).pop(option);
        },
        onClose: () {
          Navigator.of(context).pop();
        },
      );
    },
  );
}

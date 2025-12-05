import 'package:flutter/material.dart';
import 'package:design_system_shims/design_system_shims.dart';

/// Card widget for displaying payment methods following Card/Generic design system spec.
/// Created by: Track A - Ticket #225
/// Updated by: Track E - Ticket E-1 (Added isSelected for selection indicator)
/// Purpose: Unified card for payment methods in Payments screen (Screen 16)
///
/// Design System Alignment:
/// - Uses colorScheme.surface for background
/// - DWRadius.sm for border radius
/// - DWSpacing tokens for padding and margins
/// - Proper touch target (≥44px)
/// - Semantics for accessibility
/// - Track E - Ticket E-1: Selection indicator (check icon)
class PaymentMethodCard extends StatelessWidget {
  const PaymentMethodCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isDefault = false,
    this.isSelected = false,
    this.defaultLabel = 'Default',
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDefault;
  /// Track E - Ticket E-1: Whether this card is currently selected
  final bool isSelected;
  /// Localized label for the default badge
  final String defaultLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '$title, $subtitle${isDefault ? ", $defaultLabel" : ""}${isSelected ? ", Selected" : ""}',
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: DWSpacing.sm),
          padding: const EdgeInsets.all(DWSpacing.md),
          decoration: BoxDecoration(
            color: isSelected 
                ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(DWRadius.sm),
            boxShadow: kElevationToShadow[isSelected ? 2 : 1],
            border: isSelected
                ? Border.all(color: colorScheme.primary, width: 2)
                : null,
          ),
          child: Row(
            children: [
              Icon(icon, size: 24.0, color: colorScheme.primary),
              const SizedBox(width: DWSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: DWSpacing.xs),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isDefault) ...[
                const SizedBox(width: DWSpacing.sm),
                _DefaultChip(
                  textTheme: textTheme,
                  colorScheme: colorScheme,
                  label: defaultLabel,
                ),
              ],
              // Track E - Ticket E-1: Selection indicator
              if (isSelected) ...[
                const SizedBox(width: DWSpacing.sm),
                Icon(
                  Icons.check_circle,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Default badge chip for payment methods
class _DefaultChip extends StatelessWidget {
  const _DefaultChip({
    required this.textTheme,
    required this.colorScheme,
    required this.label,
  });

  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DWSpacing.xs,
        vertical: DWSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DWRadius.xs),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: colorScheme.primary,
        ),
      ),
    );
  }
}

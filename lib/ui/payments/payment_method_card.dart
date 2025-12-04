import 'package:flutter/material.dart';
import 'package:design_system_shims/design_system_shims.dart';

/// Card widget for displaying payment methods following Card/Generic design system spec.
/// Created by: Track A - Ticket #225
/// Purpose: Unified card for payment methods in Payments screen (Screen 16)
///
/// Design System Alignment:
/// - Uses colorScheme.surface for background
/// - DWRadius.sm for border radius
/// - DWSpacing tokens for padding and margins
/// - Proper touch target (≥44px)
/// - Semantics for accessibility
class PaymentMethodCard extends StatelessWidget {
  const PaymentMethodCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isDefault = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDefault;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Semantics(
      button: true,
      label: '$title, $subtitle${isDefault ? ", Default" : ""}',
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: DWSpacing.sm),
          padding: const EdgeInsets.all(DWSpacing.md),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(DWRadius.sm),
            boxShadow: kElevationToShadow[1],
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
                      style: textTheme.titleMedium,
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
                const SizedBox(width: DWSpacing.md),
                _DefaultChip(textTheme: textTheme, colorScheme: colorScheme),
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
  });

  final TextTheme textTheme;
  final ColorScheme colorScheme;

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
        'Default',
        style: textTheme.labelSmall?.copyWith(
          color: colorScheme.primary,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:design_system_shims/design_system_shims.dart';

/// Service types for OrderCard - unified representation
enum OrderServiceType {
  ride,
  parcel,
  food,
}

/// Status chip configuration for different order statuses
class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DWSpacing.sm,
        vertical: DWSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(DWRadius.sm),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Service icon widget for OrderCard
class _ServiceIcon extends StatelessWidget {
  const _ServiceIcon({
    required this.serviceType,
  });

  final OrderServiceType serviceType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final (icon, backgroundColor) = switch (serviceType) {
      OrderServiceType.ride => (
          Icons.directions_car_outlined,
          colorScheme.primary.withValues(alpha: 0.12)
        ),
      OrderServiceType.parcel => (
          Icons.local_shipping_outlined,
          colorScheme.primaryContainer
        ),
      OrderServiceType.food => (
          Icons.restaurant_outlined,
          colorScheme.secondary.withValues(alpha: 0.12)
        ),
    };

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(DWRadius.sm),
      ),
      child: Icon(
        icon,
        color: serviceType == OrderServiceType.parcel
            ? colorScheme.onPrimaryContainer
            : colorScheme.primary,
        size: 24,
      ),
    );
  }
}

/// Unified Order Card widget following Design System specifications
/// Displays service icon, title, subtitle, status chip, and price in a consistent layout
class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.serviceType,
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.priceLabel,
    this.onTap,
  });

  final OrderServiceType serviceType;
  final String title;
  final String subtitle;
  final String statusLabel;
  final String priceLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final statusColor = switch (serviceType) {
      OrderServiceType.ride => colorScheme.primary,
      OrderServiceType.parcel => colorScheme.primary,
      OrderServiceType.food => colorScheme.secondary,
    };

    return Semantics(
      label: '$serviceType, $statusLabel, $subtitle, $priceLabel',
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DWRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(DWSpacing.md),
          margin: const EdgeInsets.only(bottom: DWSpacing.sm),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(DWRadius.lg),
            // Using standard elevation shadow from Material Design
            boxShadow: kElevationToShadow[1],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service icon
              _ServiceIcon(serviceType: serviceType),
              const SizedBox(width: DWSpacing.md),

              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + status chip row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: DWSpacing.xs),
                        _StatusChip(
                          label: statusLabel,
                          color: statusColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: DWSpacing.xxs),
                    // Subtitle
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: DWSpacing.md),

              // Price on the right
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    priceLabel,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

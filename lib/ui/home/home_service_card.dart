import 'package:flutter/material.dart';
import 'package:design_system_shims/design_system_shims.dart';

/// Service card widget for Home Hub services (Ride, Parcels, Food).
/// Created by: Track A - Ticket #228
/// Purpose: UI-only card component for Home Hub services following Card/Service design spec.
///
/// Design System Alignment:
/// - Uses colorScheme.surface for background
/// - DWRadius.lg for border radius (service card style)
/// - DWSpacing tokens for padding and margins
/// - Proper touch target (≥44px via InkWell)
/// - Semantics for accessibility
class HomeServiceCard extends StatelessWidget {
  const HomeServiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Semantics(
      button: true,
      label: '$title. $subtitle',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DWRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(DWSpacing.md),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(DWRadius.lg),
            boxShadow: kElevationToShadow[1],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 32.0,
                color: colorScheme.primary,
              ),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

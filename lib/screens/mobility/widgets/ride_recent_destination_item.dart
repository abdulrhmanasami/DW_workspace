/// Ride Recent Destination Item Widget
/// Shared widget for displaying recent destinations in both HomeHub and RideDestinationScreen
/// Ticket #191: HomeHub Recent Destinations UX Parity V1
/// Created by: Extracted from RideDestinationScreen _RecentLocationCard

import 'package:flutter/material.dart';
import 'package:mobility_shims/mobility_shims.dart';

/// Shared widget for recent destination/location items
/// Used in both HomeHub and RideDestinationScreen for consistency
class RideRecentDestinationItem extends StatelessWidget {
  const RideRecentDestinationItem({
    super.key,
    required this.label,
    this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper function to get appropriate icon for different place types
/// Shared logic for determining icons based on MobilityPlaceType and ID
IconData getMobilityPlaceIcon(MobilityPlaceType type, [String? id]) {
  if (id == 'home') return Icons.home_outlined;
  if (id == 'work') return Icons.work_outline;

  switch (type) {
    case MobilityPlaceType.currentLocation:
      return Icons.my_location;
    case MobilityPlaceType.saved:
      return Icons.bookmark_outline;
    case MobilityPlaceType.recent:
      return Icons.history;
    case MobilityPlaceType.searchResult:
      return Icons.place_outlined;
    case MobilityPlaceType.other:
      return Icons.location_on_outlined;
  }
}

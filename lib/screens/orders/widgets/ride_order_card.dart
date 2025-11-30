/// Ride Order Card Widget
/// Created by: Track B - Ticket #96
/// Purpose: Display a ride order item in the orders history list
/// Last updated: 2025-11-30

import 'package:design_system_shims/design_system_shims.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobility_shims/mobility_shims.dart' show RideTripPhase;

import '../../../l10n/generated/app_localizations.dart';
import '../../../state/mobility/ride_trip_session.dart';

/// Card widget for displaying a ride order in the history list.
///
/// Shows:
/// - Title: "Ride to {destination}"
/// - Subtitle: Status + Date/Time
/// - Status chip (Completed/Cancelled/Failed)
/// - Amount (if available)
///
/// Track B - Ticket #96
class RideOrderCard extends StatelessWidget {
  const RideOrderCard({
    super.key,
    required this.entry,
    this.l10n,
    this.onTap,
  });

  final RideHistoryEntry entry;
  final AppLocalizations? l10n;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    // Build title
    final destination = entry.destinationLabel.isNotEmpty
        ? entry.destinationLabel
        : '...';
    final title = l10n?.ordersRideItemTitleToDestination(destination) ??
        'Ride to $destination';

    // Build status label
    final statusLabel = _statusLabel(entry.trip.phase, l10n);
    final statusColor = _statusColor(entry.trip.phase, colorScheme);

    // Format date/time
    final dateFormatter = DateFormat('dd MMM, h:mm a');
    final formattedDate = dateFormatter.format(entry.completedAt);
    final subtitle = '$statusLabel · $formattedDate';

    return Card(
      margin: const EdgeInsets.only(bottom: DWSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DWRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(DWSpacing.md),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(DWRadius.sm),
                ),
                child: Icon(
                  _phaseIcon(entry.trip.phase),
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: DWSpacing.sm),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: DWSpacing.xxs),

                    // Subtitle
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Amount (if available)
              if (entry.amountFormatted != null) ...[
                const SizedBox(width: DWSpacing.sm),
                Text(
                  entry.amountFormatted!,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              // Status chip
              const SizedBox(width: DWSpacing.sm),
              _StatusChip(
                label: statusLabel,
                color: statusColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(RideTripPhase phase, AppLocalizations? l10n) {
    switch (phase) {
      case RideTripPhase.completed:
        return l10n?.ordersRideStatusCompleted ?? 'Completed';
      case RideTripPhase.cancelled:
        return l10n?.ordersRideStatusCancelled ?? 'Cancelled';
      case RideTripPhase.failed:
        return l10n?.ordersRideStatusFailed ?? 'Failed';
      default:
        return phase.name;
    }
  }

  Color _statusColor(RideTripPhase phase, ColorScheme colorScheme) {
    switch (phase) {
      case RideTripPhase.completed:
        return colorScheme.tertiary;
      case RideTripPhase.cancelled:
      case RideTripPhase.failed:
        return colorScheme.error;
      default:
        return colorScheme.primary;
    }
  }

  IconData _phaseIcon(RideTripPhase phase) {
    switch (phase) {
      case RideTripPhase.completed:
        return Icons.check_circle;
      case RideTripPhase.cancelled:
        return Icons.cancel;
      case RideTripPhase.failed:
        return Icons.error;
      default:
        return Icons.directions_car;
    }
  }
}

/// Small status chip widget
class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DWSpacing.xs,
        vertical: DWSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
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


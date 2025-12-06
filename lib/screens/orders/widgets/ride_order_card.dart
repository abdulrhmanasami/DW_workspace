/// Ride Order Card Widget
/// Created by: Track B - Ticket #96
/// Updated by: Track B - Ticket #108 (Extended display with service name, origin, payment)
/// Updated by: Track B - Ticket #124 (Display driver rating if available)
/// Updated by: Track B - Ticket #126 (Use unified OrderStatusChip)
/// Updated by: Track B - Ticket #127 (Semantics for service icon accessibility)
/// Purpose: Display a ride order item in the orders history list
/// Last updated: 2025-12-01

import 'package:design_system_shims/design_system_shims.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobility_shims/mobility_shims.dart' show RideTripPhase;

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/state/mobility/ride_trip_session.dart';
import 'order_status_chip.dart';

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

    // Build title - Track B - Ticket #108: Show service name if available
    final destination = entry.destinationLabel.isNotEmpty
        ? entry.destinationLabel
        : '...';
    final serviceName = entry.serviceName;
    final String title;
    if (serviceName != null && serviceName.isNotEmpty) {
      title = l10n?.ordersRideItemTitleWithService(serviceName, destination) ??
          '$serviceName to $destination';
    } else {
      title = l10n?.ordersRideItemTitleToDestination(destination) ??
          'Ride to $destination';
    }

    // Build status UI model for chip and subtitle
    // Track B - Ticket #126: Use unified mapping
    final statusUiModel = _mapRidePhaseToUiModel(entry.trip.phase, l10n);
    final statusColor = _statusColor(entry.trip.phase, colorScheme);

    // Format date/time
    final dateFormatter = DateFormat('dd MMM, h:mm a');
    final formattedDate = dateFormatter.format(entry.completedAt);
    
    // Track B - Ticket #108: Build subtitle with origin if available
    final origin = entry.originLabel;
    String subtitle;
    if (origin != null && origin.isNotEmpty) {
      subtitle = l10n?.ordersRideItemSubtitleWithOrigin(origin, formattedDate) ??
          'From $origin · $formattedDate';
    } else {
      subtitle = '${statusUiModel.label} · $formattedDate';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: DWSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DWRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(DWSpacing.md),
          child: Row(
            children: [
              // Icon - Track B - Ticket #127: Semantics for accessibility
              Semantics(
                label: l10n?.ordersServiceRideSemanticLabel ?? 'Ride order',
                excludeSemantics: true,
                child: Container(
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
              ),
              const SizedBox(width: DWSpacing.sm),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title (with service name)
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: DWSpacing.xxs),

                    // Subtitle (with origin)
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Track B - Ticket #108: Show payment method if available
                    if (entry.paymentMethodLabel != null) ...[
                      const SizedBox(height: DWSpacing.xxs),
                      Row(
                        children: [
                          Icon(
                            Icons.payment,
                            size: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            entry.paymentMethodLabel!,
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                    // Track B - Ticket #124: Show driver rating if available
                    if (entry.driverRating != null) ...[
                      const SizedBox(height: DWSpacing.xxs),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            entry.driverRating!.toStringAsFixed(1),
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
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

              // Status chip - Track B - Ticket #126: Use unified OrderStatusChip
              const SizedBox(width: DWSpacing.sm),
              OrderStatusChip(status: statusUiModel),
            ],
          ),
        ),
      ),
    );
  }

  /// Maps a ride phase to the unified OrderStatusUiModel.
  ///
  /// Track B - Ticket #126: Centralized mapping for consistent status display.
  OrderStatusUiModel _mapRidePhaseToUiModel(
    RideTripPhase phase,
    AppLocalizations? l10n,
  ) {
    switch (phase) {
      case RideTripPhase.completed:
        return OrderStatusUiModel(
          label: l10n?.ordersRideStatusCompleted ?? 'Completed',
          tone: OrderStatusTone.success,
        );
      case RideTripPhase.cancelled:
        return OrderStatusUiModel(
          label: l10n?.ordersRideStatusCancelled ?? 'Cancelled',
          tone: OrderStatusTone.error,
        );
      case RideTripPhase.failed:
        return OrderStatusUiModel(
          label: l10n?.ordersRideStatusFailed ?? 'Failed',
          tone: OrderStatusTone.error,
        );
      // Active/in-progress phases
      case RideTripPhase.findingDriver:
      case RideTripPhase.driverAccepted:
      case RideTripPhase.driverArrived:
      case RideTripPhase.inProgress:
      case RideTripPhase.payment:
        return OrderStatusUiModel(
          label: l10n?.rideStatusShortInProgress ?? 'In progress',
          tone: OrderStatusTone.info,
        );
      // Early phases (draft, quoting, requesting)
      default:
        return OrderStatusUiModel(
          label: phase.name,
          tone: OrderStatusTone.warning,
        );
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


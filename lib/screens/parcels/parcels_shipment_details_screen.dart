import 'package:design_system_shims/design_system_shims.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parcels_shims/parcels_shims.dart';

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/widgets/dw_app_shell.dart';

/// Track C - Ticket #151: Parcels Shipment Details Screen
/// Shows full details of a ParcelShipment using domain model from parcels_shims.
class ParcelsShipmentDetailsScreen extends ConsumerWidget {
  const ParcelsShipmentDetailsScreen({
    required this.shipment,
    super.key,
  });

  final ParcelShipment shipment;

  static const String routeName = '/parcels/shipment-details';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return DWAppShell(
      appBar: AppBar(
        title: Text(
          l10n?.parcelsShipmentDetailsTitle ?? 'Shipment details',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DWSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderSection(
                shipment: shipment,
                l10n: l10n,
              ),
              const SizedBox(height: DWSpacing.lg),
              _RouteSection(
                shipment: shipment,
                l10n: l10n,
              ),
              const SizedBox(height: DWSpacing.lg),
              _ContactsSection(
                shipment: shipment,
                l10n: l10n,
              ),
              const SizedBox(height: DWSpacing.lg),
              _DetailsSection(
                shipment: shipment,
                l10n: l10n,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Header section showing status, ID, date, and price
class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.shipment,
    this.l10n,
  });

  final ParcelShipment shipment;
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final statusLabel = _mapStatusToLabel(l10n, shipment.status);
    final statusColor = _getStatusColor(shipment.status, colorScheme);

    // Format shipment ID (show last 6 characters)
    final displayId = shipment.id.length > 6
        ? shipment.id.substring(shipment.id.length - 6)
        : shipment.id;

    // Format date simply for now
    final createdDateText = _formatDate(shipment.createdAt);

    final totalPriceText = (shipment.estimatedPrice != null &&
            shipment.currencyCode != null)
        ? '${shipment.estimatedPrice!.toStringAsFixed(2)} ${shipment.currencyCode}'
        : null;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DWRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DWSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status chip
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DWSpacing.sm,
                vertical: DWSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DWRadius.sm),
              ),
              child: Text(
                statusLabel,
                style: textTheme.labelMedium?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: DWSpacing.sm),
            Text(
              'Shipment #$displayId',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DWSpacing.xs),
            Text(
              createdDateText,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (totalPriceText != null) ...[
              const SizedBox(height: DWSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n?.commonTotalLabel ?? 'Total',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    totalPriceText,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _mapStatusToLabel(AppLocalizations? l10n, ParcelShipmentStatus status) {
    switch (status) {
      case ParcelShipmentStatus.created:
        return l10n?.parcelsShipmentStatusCreated ?? 'Created';
      case ParcelShipmentStatus.inTransit:
        return l10n?.parcelsShipmentStatusInTransit ?? 'In Transit';
      case ParcelShipmentStatus.delivered:
        return l10n?.parcelsShipmentStatusDelivered ?? 'Delivered';
      case ParcelShipmentStatus.cancelled:
        return l10n?.parcelsShipmentStatusCancelled ?? 'Cancelled';
    }
  }

  Color _getStatusColor(ParcelShipmentStatus status, ColorScheme colorScheme) {
    switch (status) {
      case ParcelShipmentStatus.created:
        return colorScheme.secondary;
      case ParcelShipmentStatus.inTransit:
        return colorScheme.primary;
      case ParcelShipmentStatus.delivered:
        return Colors.green;
      case ParcelShipmentStatus.cancelled:
        return colorScheme.error;
    }
  }

  String _formatDate(DateTime date) {
    // Simple format for now - can be improved with intl package later
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

/// Route section showing pickup and dropoff addresses
class _RouteSection extends StatelessWidget {
  const _RouteSection({
    required this.shipment,
    this.l10n,
  });

  final ParcelShipment shipment;
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DWRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DWSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.parcelsShipmentDetailsRouteSectionTitle ?? 'Route',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DWSpacing.md),
            // Pickup address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on,
                    size: 18,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: DWSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.parcelsShipmentDetailsPickupLabel ?? 'Pickup',
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: DWSpacing.xs),
                      Text(
                        shipment.pickupAddress.label,
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Divider with arrow
            Padding(
              padding: const EdgeInsets.symmetric(vertical: DWSpacing.sm),
              child: Row(
                children: [
                  const SizedBox(width: 16), // Half of icon container width
                  Icon(
                    Icons.south,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
            // Dropoff address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.flag,
                    size: 18,
                    color: colorScheme.onTertiaryContainer,
                  ),
                ),
                const SizedBox(width: DWSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.parcelsShipmentDetailsDropoffLabel ?? 'Dropoff',
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: DWSpacing.xs),
                      Text(
                        shipment.dropoffAddress.label,
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Contacts section showing sender and receiver details
class _ContactsSection extends StatelessWidget {
  const _ContactsSection({
    required this.shipment,
    this.l10n,
  });

  final ParcelShipment shipment;
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DWRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DWSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.parcelsShipmentDetailsContactsSectionTitle ?? 'Contacts',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DWSpacing.md),
            // Sender
            _ContactItem(
              label: l10n?.parcelsShipmentDetailsSenderLabel ?? 'Sender',
              name: shipment.sender.name,
              phone: shipment.sender.phone,
              icon: Icons.person_outline,
              iconColor: colorScheme.primary,
            ),
            const SizedBox(height: DWSpacing.md),
            // Receiver
            _ContactItem(
              label: l10n?.parcelsShipmentDetailsReceiverLabel ?? 'Receiver',
              name: shipment.receiver.name,
              phone: shipment.receiver.phone,
              icon: Icons.person,
              iconColor: colorScheme.tertiary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual contact item widget
class _ContactItem extends StatelessWidget {
  const _ContactItem({
    required this.label,
    required this.name,
    required this.phone,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final String name;
  final String phone;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
        ),
        const SizedBox(width: DWSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: DWSpacing.xs),
              Text(
                name,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                phone,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Details section showing parcel specifications
class _DetailsSection extends StatelessWidget {
  const _DetailsSection({
    required this.shipment,
    this.l10n,
  });

  final ParcelShipment shipment;
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DWRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DWSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.parcelsShipmentDetailsDetailsSectionTitle ?? 'Parcel details',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DWSpacing.md),
            // Service type
            if (shipment.serviceType != null) ...[
              _DetailRow(
                label: l10n?.parcelsShipmentDetailsServiceTypeLabel ?? 'Service type',
                value: _mapServiceType(shipment.serviceType!, l10n),
                icon: Icons.speed,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              const SizedBox(height: DWSpacing.sm),
            ],
            // Weight
            if (shipment.weightKg != null) ...[
              _DetailRow(
                label: l10n?.parcelsShipmentDetailsWeightLabel ?? 'Weight',
                value: '${shipment.weightKg} kg',
                icon: Icons.fitness_center,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              const SizedBox(height: DWSpacing.sm),
            ],
            // Size
            if (shipment.sizeLabel != null) ...[
              _DetailRow(
                label: l10n?.parcelsShipmentDetailsSizeLabel ?? 'Size',
                value: shipment.sizeLabel!,
                icon: Icons.aspect_ratio,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              const SizedBox(height: DWSpacing.sm),
            ],
            // Notes
            if (shipment.notes != null && shipment.notes!.isNotEmpty) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.note,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: DWSpacing.xs),
                      Text(
                        l10n?.parcelsShipmentDetailsNotesLabel ?? 'Notes',
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DWSpacing.xs),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(DWSpacing.sm),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(DWRadius.md),
                    ),
                    child: Text(
                      shipment.notes!,
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _mapServiceType(String serviceType, AppLocalizations? l10n) {
    switch (serviceType.toLowerCase()) {
      case 'express':
        return l10n?.parcelsCreateShipmentServiceTypeExpress ?? 'Express';
      case 'standard':
        return l10n?.parcelsCreateShipmentServiceTypeStandard ?? 'Standard';
      default:
        return serviceType;
    }
  }
}

/// Detail row widget for displaying label-value pairs
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.colorScheme,
    required this.textTheme,
  });

  final String label;
  final String value;
  final IconData icon;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: DWSpacing.xs),
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

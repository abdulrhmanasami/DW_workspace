import 'package:design_system_shims/design_system_shims.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parcels_shims/parcels_shims.dart';

import 'package:delivery_ways_clean/state/parcels/parcel_shipments_providers.dart';
import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/widgets/dw_app_shell.dart';
import 'package:delivery_ways_clean/router/app_router.dart';

/// Track C - Ticket #149: Parcels Shipments List Screen (Screen 12)
/// Displays list of all shipments with real data from parcels_shims.
class ParcelsShipmentsListScreen extends ConsumerWidget {
  const ParcelsShipmentsListScreen({
    super.key,
    this.onCreateShipment,
  });

  static const String routeName = '/parcels/shipments';

  /// Callback يُستدعى عند الضغط على زر إنشاء شحنة جديدة.
  /// التذكرة الحالية لا تربطه بنافيجيشن محدد؛ هذا يحصل في تذكرة لاحقة.
  final VoidCallback? onCreateShipment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final shipmentsAsync = ref.watch(parcelShipmentsStreamProvider);

    return DWAppShell(
      appBar: AppBar(
        title: Text(
          l10n?.parcelsShipmentsTitle ?? 'My Shipments',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n?.parcelsShipmentsNewShipmentTooltip ?? 'New shipment',
            onPressed: onCreateShipment,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(DWSpacing.md),
        child: shipmentsAsync.when(
          loading: () => const _ShipmentsLoading(),
          error: (error, stack) => _ShipmentsError(
            message: error.toString(),
            l10n: l10n,
          ),
          data: (shipments) {
            if (shipments.isEmpty) {
              return _ShipmentsEmpty(
                title: l10n?.parcelsShipmentsEmptyTitle ?? 'No shipments yet',
                description: l10n?.parcelsShipmentsEmptyDescription ?? 
                    'You don\'t have any shipments yet. Create your first shipment to start sending parcels.',
                onCreateFirst: onCreateShipment,
                ctaLabel: l10n?.parcelsShipmentsEmptyCta ?? 'Create first shipment',
              );
            }
            return ListView.separated(
              itemCount: shipments.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: DWSpacing.sm),
              itemBuilder: (context, index) {
                final shipment = shipments[index];
                return _ShipmentCard(
                  shipment: shipment,
                  l10n: l10n,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      RoutePaths.parcelsShipmentDetails,
                      arguments: shipment,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Loading state widget
class _ShipmentsLoading extends StatelessWidget {
  const _ShipmentsLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

/// Empty state widget following Design System patterns
class _ShipmentsEmpty extends StatelessWidget {
  const _ShipmentsEmpty({
    required this.title,
    required this.description,
    required this.ctaLabel,
    this.onCreateFirst,
  });

  final String title;
  final String description;
  final String ctaLabel;
  final VoidCallback? onCreateFirst;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DWSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 72,
              color: colorScheme.outline,
            ),
            const SizedBox(height: DWSpacing.lg),
            Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DWSpacing.sm),
            Text(
              description,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DWSpacing.xl),
            if (onCreateFirst != null)
              DWButton.primary(
                label: ctaLabel,
                onPressed: onCreateFirst,
              ),
          ],
        ),
      ),
    );
  }
}

/// Error state widget
class _ShipmentsError extends StatelessWidget {
  const _ShipmentsError({required this.message, this.l10n});

  final String message;
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DWSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: DWSpacing.lg),
            Text(
              l10n?.parcelsShipmentsErrorTitle ?? 'Something went wrong',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: DWSpacing.sm),
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shipment card widget following Card/Order pattern from Design System
class _ShipmentCard extends StatelessWidget {
  const _ShipmentCard({
    required this.shipment,
    this.l10n,
    this.onTap,
  });

  final ParcelShipment shipment;
  final AppLocalizations? l10n;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Format date
    final dateStr = _formatDate(shipment.createdAt);

    // Get status label
    final statusLabel = _getStatusLabel(shipment.status, l10n);
    final statusColor = _getStatusColor(shipment.status, colorScheme);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DWRadius.lg),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(DWRadius.lg),
        onTap: onTap ?? () {
          debugPrint('Tapped on shipment: ${shipment.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(DWSpacing.md),
          child: Row(
            children: [
              // Service icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(DWRadius.md),
                ),
                child: Icon(
                  Icons.local_shipping,
                  color: colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: DWSpacing.md),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row with status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'To ${shipment.receiver.name}',
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: DWSpacing.sm),
                        // Status chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DWSpacing.sm,
                            vertical: DWSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(DWRadius.sm),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            statusLabel,
                            style: textTheme.labelSmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DWSpacing.xs),
                    
                    // Address
                    Text(
                      '${shipment.pickupAddress.label} → ${shipment.dropoffAddress.label}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: DWSpacing.xs),
                    
                    // Date and price row
                    Row(
                      children: [
                        // Date
                        Text(
                          dateStr,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                        // Price if available
                        if (shipment.estimatedPrice != null && 
                            shipment.currencyCode != null) ...[
                          const Spacer(),
                          Text(
                            '${shipment.estimatedPrice!.toStringAsFixed(2)} ${shipment.currencyCode}',
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ],
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

  String _formatDate(DateTime date) {
    // Simple date formatting - can be enhanced with intl package later
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _getStatusLabel(ParcelShipmentStatus status, AppLocalizations? l10n) {
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
}

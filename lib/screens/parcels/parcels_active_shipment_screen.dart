/// Parcels Active Shipment Screen (Stub)
/// Created by: Track C - Ticket #70
/// Updated by: Track C - Ticket #71 (Design System alignment)
/// Purpose: Display active parcel shipment tracking (Stub for now)
/// Last updated: 2025-11-29
///
/// Design System Alignment (Ticket #71):
/// - AppBar: Navigation/AppBar style with type.headline.h2 (titleMedium)
/// - Map placeholder: surfaceContainerHighest background, radius.md
/// - Info card: Card/Generic style (radius.md, elevation.medium)
/// - EmptyState: secondaryContainer for info banner
///
/// TODO(Track C): Replace this stub with full tracking implementation
/// showing real-time parcel status, map, and delivery details.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart'
    show DWSpacing, DWRadius;

import '../../l10n/generated/app_localizations.dart';
import '../../state/parcels/parcel_orders_state.dart';

/// Screen that displays the active parcel shipment details.
/// Track C - Ticket #70: Stub implementation - will be replaced with full tracking.
/// Track C - Ticket #71: Aligned with Design System tokens.
class ParcelsActiveShipmentScreen extends ConsumerWidget {
  const ParcelsActiveShipmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    final parcelOrdersState = ref.watch(parcelOrdersProvider);
    final activeParcel = parcelOrdersState.activeParcel;

    return Scaffold(
      // AppBar uses Navigation/AppBar style from DWTheme
      // Title: type.headline.h2 (mapped to titleMedium in AppBarTheme)
      appBar: AppBar(
        title: Text(l10n.parcelsActiveShipmentTitle),
      ),
      body: SafeArea(
        child: activeParcel == null
            ? _NoActiveParcelState(
                l10n: l10n,
                textTheme: textTheme,
                colorScheme: colorScheme,
              )
            : _ActiveParcelContent(
                parcelId: activeParcel.id,
                status: activeParcel.status.name,
                destination: activeParcel.dropoffAddress.label,
                l10n: l10n,
                textTheme: textTheme,
                colorScheme: colorScheme,
              ),
      ),
    );
  }
}

class _NoActiveParcelState extends StatelessWidget {
  const _NoActiveParcelState({
    required this.l10n,
    required this.textTheme,
    required this.colorScheme,
  });

  final AppLocalizations l10n;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DWSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: DWSpacing.md),
            Text(
              l10n.parcelsActiveShipmentNoActiveTitle,
              style: textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DWSpacing.xs),
            Text(
              l10n.parcelsActiveShipmentNoActiveSubtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DWSpacing.lg),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.back),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveParcelContent extends StatelessWidget {
  const _ActiveParcelContent({
    required this.parcelId,
    required this.status,
    required this.destination,
    required this.l10n,
    required this.textTheme,
    required this.colorScheme,
  });

  final String parcelId;
  final String status;
  final String destination;
  final AppLocalizations l10n;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DWSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Map placeholder
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(DWRadius.md),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map_outlined,
                      size: 48,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: DWSpacing.xs),
                    Text(
                      l10n.parcelsActiveShipmentMapStub,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: DWSpacing.lg),

          // Shipment info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(DWSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_shipping_outlined,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: DWSpacing.sm),
                      Expanded(
                        child: Text(
                          l10n.parcelsActiveShipmentStatusLabel(status),
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (destination.isNotEmpty) ...[
                    const SizedBox(height: DWSpacing.sm),
                    Text(
                      l10n.homeActiveParcelSubtitleToDestination(destination),
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: DWSpacing.sm),
                  Text(
                    l10n.parcelsActiveShipmentIdLabel(parcelId),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: DWSpacing.lg),

          // TODO notice
          Container(
            padding: const EdgeInsets.all(DWSpacing.md),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(DWRadius.sm),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: colorScheme.onSecondaryContainer,
                  size: 20,
                ),
                const SizedBox(width: DWSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.parcelsActiveShipmentStubNote,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


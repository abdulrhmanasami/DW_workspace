/// Parcel Shipment Details Screen
/// Created by: Track C - Ticket #47
/// Updated by: Track C - Ticket #50 (Parcels Pricing Integration - price display)
/// Updated by: Track C - Ticket #74 (MVP UI + Map Stub + Home Hub navigation unification)
/// Updated by: Track C - Ticket #81 (Cancel Flow + ConsumerWidget)
/// Purpose: Display full details of a parcel shipment with tracking stub.
/// Accessed from: Home Hub Active Parcel Card, Parcels List items.
/// Last updated: 2025-11-29

import 'package:design_system_shims/design_system_shims.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parcels_shims/parcels_shims.dart';

import '../../l10n/generated/app_localizations.dart';
// Track C - Ticket #78: Unified parcel status helpers
// Track C - Ticket #81: isParcelStatusUserCancellable for cancel button visibility
import '../../state/parcels/parcel_status_utils.dart';
import '../../state/parcels/parcel_orders_state.dart';

/// Screen to display detailed information about a parcel shipment.
/// Accessed by tapping a shipment card in My Shipments list.
///
/// Track C - Ticket #81: Changed from StatelessWidget to ConsumerWidget
/// to support Cancel Flow with Riverpod state updates.
class ParcelShipmentDetailsScreen extends ConsumerWidget {
  const ParcelShipmentDetailsScreen({
    super.key,
    required this.parcel,
  });

  final Parcel parcel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final shortId = _shortParcelId(parcel.id);

    // Track C - Ticket #81: Check if cancel is allowed
    final canCancel = isParcelStatusUserCancellable(parcel.status);

    return Scaffold(
      appBar: AppBar(
        // Track C - Ticket #74: Use parcelsActiveShipmentTitle for unified naming
        title: Text(l10n?.parcelsActiveShipmentTitle ?? 'Active shipment'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DWSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ParcelSummarySection(
                parcel: parcel,
                shortId: shortId,
              ),
              const SizedBox(height: DWSpacing.lg),
              // Track C - Ticket #74: Map Stub Section for future live tracking
              _ParcelMapStubSection(),
              const SizedBox(height: DWSpacing.lg),
              _ParcelRouteSection(parcel: parcel),
              const SizedBox(height: DWSpacing.lg),
              _ParcelAddressSection(parcel: parcel),
              const SizedBox(height: DWSpacing.lg),
              _ParcelMetaSection(parcel: parcel),
            ],
          ),
        ),
      ),
      // Track C - Ticket #81: Cancel button in bottomNavigationBar
      bottomNavigationBar: canCancel
          ? SafeArea(
              minimum: const EdgeInsets.all(DWSpacing.md),
              child: OutlinedButton(
                onPressed: () => _onCancelPressed(context, ref),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                child: Text(
                  l10n?.parcelsDetailsCancelShipmentCta ?? 'Cancel shipment',
                ),
              ),
            )
          : null,
    );
  }

  /// Shorten parcel ID to last 6 characters.
  String _shortParcelId(String fullId) {
    if (fullId.length <= 6) return fullId;
    return fullId.substring(fullId.length - 6);
  }

  /// Track C - Ticket #81: Handle cancel button press with confirmation dialog.
  Future<void> _onCancelPressed(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);

    final shouldCancel = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: Text(
                l10n?.parcelsCancelDialogTitle ?? 'Cancel this shipment?',
              ),
              content: Text(
                l10n?.parcelsCancelDialogSubtitle ??
                    'If you cancel now, this shipment will be stopped and will no longer appear as active.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(
                    l10n?.parcelsCancelDialogDismissCta ?? 'Keep shipment',
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: Text(
                    l10n?.parcelsCancelDialogConfirmCta ?? 'Yes, cancel',
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldCancel) return;

    // Update state
    ref.read(parcelOrdersProvider.notifier).cancelParcel(parcelId: parcel.id);

    // Show feedback
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.parcelsCancelSuccessMessage ?? 'Shipment has been cancelled.',
          ),
        ),
      );
    }
  }
}

/// Summary section showing ID, status chip, and creation date.
class _ParcelSummarySection extends StatelessWidget {
  const _ParcelSummarySection({
    required this.parcel,
    required this.shortId,
  });

  final Parcel parcel;
  final String shortId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    final createdAtText = _formatDateTime(parcel.createdAt);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(DWSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ID + Status chip row
            Row(
              children: [
                Text(
                  '#$shortId',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: DWSpacing.sm),
                _ParcelStatusChip(status: parcel.status),
              ],
            ),
            const SizedBox(height: DWSpacing.xs),
            Text(
              l10n?.parcelsShipmentDetailsCreatedAt(createdAtText) ??
                  'Created on $createdAtText',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Format DateTime for display.
  String _formatDateTime(DateTime dateTime) {
    final year = dateTime.year.toString();
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
  }
}

/// Status chip widget using same mapping as ParcelsEntryScreen.
class _ParcelStatusChip extends StatelessWidget {
  const _ParcelStatusChip({required this.status});

  final ParcelStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Track C - Ticket #78: Use unified parcel status helper
    final label = localizedParcelStatusShort(l10n, status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DWSpacing.sm,
        vertical: DWSpacing.xs,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DWRadius.lg),
        color: colorScheme.surfaceContainerHighest,
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Map Stub Section showing placeholder for future live tracking.
/// Track C - Ticket #74: MVP tracking UI with L10n stub texts.
class _ParcelMapStubSection extends StatelessWidget {
  const _ParcelMapStubSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DWRadius.md),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.map_outlined,
                size: 40,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: DWSpacing.sm),
              Text(
                l10n?.parcelsActiveShipmentMapStub ?? 'Map tracking (coming soon)',
                style: textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DWSpacing.xs),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: DWSpacing.lg),
                child: Text(
                  l10n?.parcelsActiveShipmentStubNote ??
                      'Full tracking will be available in a future update.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Route section showing Pickup → Dropoff.
class _ParcelRouteSection extends StatelessWidget {
  const _ParcelRouteSection({required this.parcel});

  final Parcel parcel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    final pickupLabel = parcel.pickupAddress.label;
    final dropoffLabel = parcel.dropoffAddress.label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.parcelsShipmentDetailsRouteSectionTitle ?? 'Route',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: DWSpacing.sm),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(DWSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RouteRow(
                  icon: Icons.location_on_outlined,
                  label: l10n?.parcelsShipmentDetailsPickupLabel ?? 'Pickup',
                  value: pickupLabel,
                ),
                const SizedBox(height: DWSpacing.sm),
                _RouteRow(
                  icon: Icons.flag_outlined,
                  label: l10n?.parcelsShipmentDetailsDropoffLabel ?? 'Drop-off',
                  value: dropoffLabel,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Row widget for route display.
class _RouteRow extends StatelessWidget {
  const _RouteRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: colorScheme.primary,
        ),
        const SizedBox(width: DWSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Address details section showing pickup and dropoff addresses.
class _ParcelAddressSection extends StatelessWidget {
  const _ParcelAddressSection({required this.parcel});

  final Parcel parcel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.parcelsShipmentDetailsAddressSectionTitle ?? 'Addresses',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: DWSpacing.sm),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(DWSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _KeyValueRow(
                  label:
                      l10n?.parcelsShipmentDetailsSenderLabel ?? 'From (Sender)',
                  value: _formatAddress(parcel.pickupAddress),
                ),
                const SizedBox(height: DWSpacing.sm),
                _KeyValueRow(
                  label: l10n?.parcelsShipmentDetailsReceiverLabel ??
                      'To (Receiver)',
                  value: _formatAddress(parcel.dropoffAddress),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Format address for display, using available fields.
  String _formatAddress(ParcelAddress address) {
    final parts = <String>[];

    if (address.streetLine1 != null && address.streetLine1!.isNotEmpty) {
      parts.add(address.streetLine1!);
    } else if (address.label.isNotEmpty) {
      parts.add(address.label);
    }

    if (address.streetLine2 != null && address.streetLine2!.isNotEmpty) {
      parts.add(address.streetLine2!);
    }

    if (address.city != null && address.city!.isNotEmpty) {
      parts.add(address.city!);
    }

    if (address.region != null && address.region!.isNotEmpty) {
      parts.add(address.region!);
    }

    if (address.postalCode != null && address.postalCode!.isNotEmpty) {
      parts.add(address.postalCode!);
    }

    return parts.isNotEmpty ? parts.join(', ') : address.label;
  }
}

/// Meta section showing weight, size, service type, notes, and price.
/// Track C - Ticket #50: Now displays price.
class _ParcelMetaSection extends StatelessWidget {
  const _ParcelMetaSection({required this.parcel});

  final Parcel parcel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    final details = parcel.details;
    final weightText = details.weightKg != null
        ? '${details.weightKg} kg'
        : l10n?.parcelsShipmentDetailsNotAvailable ?? 'N/A';
    final sizeText = _sizeLabel(details.size, l10n);
    final notes = details.description;

    // Track C - Ticket #50: Extract price for display
    final price = parcel.price;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.parcelsShipmentDetailsMetaSectionTitle ?? 'Parcel details',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: DWSpacing.sm),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(DWSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Track C - Ticket #50: Display price first (prominent position)
                if (price != null) ...[
                  _KeyValueRow(
                    label: l10n?.parcelsDetailsPriceLabel ?? 'Price',
                    value: _formatPrice(price),
                    valueColor: colorScheme.primary,
                  ),
                  const SizedBox(height: DWSpacing.sm),
                ],
                _KeyValueRow(
                  label: l10n?.parcelsShipmentDetailsWeightLabel ?? 'Weight',
                  value: weightText,
                ),
                const SizedBox(height: DWSpacing.sm),
                _KeyValueRow(
                  label: l10n?.parcelsShipmentDetailsSizeLabel ?? 'Size',
                  value: sizeText,
                ),
                if (notes != null && notes.isNotEmpty) ...[
                  const SizedBox(height: DWSpacing.sm),
                  _KeyValueRow(
                    label: l10n?.parcelsShipmentDetailsNotesLabel ?? 'Notes',
                    value: notes,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Get localized size label.
  String _sizeLabel(ParcelSize size, AppLocalizations? l10n) {
    switch (size) {
      case ParcelSize.small:
        return l10n?.parcelsShipmentDetailsSizeSmall ?? 'Small';
      case ParcelSize.medium:
        return l10n?.parcelsShipmentDetailsSizeMedium ?? 'Medium';
      case ParcelSize.large:
        return l10n?.parcelsShipmentDetailsSizeLarge ?? 'Large';
      case ParcelSize.oversize:
        return l10n?.parcelsShipmentDetailsSizeOversize ?? 'Oversize';
    }
  }

  /// Format price for UI display.
  /// Track C - Ticket #50: UI formatting only, not domain logic.
  String _formatPrice(ParcelPrice price) {
    return '${price.totalAmount.toStringAsFixed(2)} ${price.currencyCode}';
  }
}

/// Key-value row widget for displaying labeled data.
/// Track C - Ticket #50: Added optional valueColor for price highlighting.
class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: DWSpacing.sm),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              color: valueColor,
              fontWeight: valueColor != null ? FontWeight.w600 : null,
            ),
          ),
        ),
      ],
    );
  }
}


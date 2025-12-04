/// Ride Booking Screen - Track B Ticket #6
/// Purpose: UI-only Booking Sheet for Ride vertical
/// Created by: Track B - Ticket #6
/// Updated by: Track B - Ticket #9 (RideDraftUiState integration)
/// Last updated: 2025-11-28
///
/// This screen provides the initial Ride booking interface with:
/// - Map stub (placeholder for future maps_shims integration)
/// - Bottom Sheet with pickup/destination inputs
/// - Recent locations list
///
/// NOTE: This is UI only - no FSM, Fare Engine, or Backend integration.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../router/app_router.dart';
import '../../state/mobility/ride_booking_controller.dart';

/// RideBookingScreen - Main entry point for Ride booking flow
class RideBookingScreen extends ConsumerWidget {
  const RideBookingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.rideBookingTitle,
          style: textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Map stub (background)
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.only(bottom: 200), // Space for the Sheet
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.map_outlined,
                        size: 64, color: colorScheme.onSurfaceVariant),
                    const SizedBox(height: 8),
                    Text(
                      l10n.rideBookingMapStubLabel,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Booking Sheet (Bottom)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(DWRadius.lg),
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                    color: colorScheme.shadow.withValues(alpha: 0.1),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(
                DWSpacing.lg,
                DWSpacing.sm,
                DWSpacing.lg,
                DWSpacing.lg,
              ),
              child: const _RideBookingSheetContent(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom Sheet content with pickup, destination, and recent locations
class _RideBookingSheetContent extends ConsumerStatefulWidget {
  const _RideBookingSheetContent();

  @override
  ConsumerState<_RideBookingSheetContent> createState() =>
      _RideBookingSheetContentState();
}

class _RideBookingSheetContentState
    extends ConsumerState<_RideBookingSheetContent> {
  late TextEditingController _destinationController;

  @override
  void initState() {
    super.initState();
    // Start a new ride request when the screen opens
    final controller = ref.read(rideBookingControllerProvider.notifier);
    controller.startNewRide();
    _destinationController = TextEditingController();
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final bookingState = ref.watch(rideBookingControllerProvider);
    final bookingController = ref.read(rideBookingControllerProvider.notifier);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        // Drag handle
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: DWSpacing.sm),
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(DWRadius.sm),
            ),
          ),
        ),

        // Title
        Text(
          l10n.rideBookingSheetTitle,
          style: textTheme.headlineSmall,
        ),
        const SizedBox(height: DWSpacing.xxs),

        // Subtitle
        Text(
          l10n.rideBookingSheetSubtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: DWSpacing.md),

        // Pickup (Current Location - non editable)
        Text(
          l10n.rideBookingPickupLabel,
          style: textTheme.labelMedium,
        ),
        const SizedBox(height: DWSpacing.xxs),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DWSpacing.md,
            vertical: DWSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(DWRadius.md),
          ),
          child: Row(
            children: [
              Icon(Icons.my_location, color: colorScheme.primary),
              const SizedBox(width: DWSpacing.xs),
              Expanded(
                child: Text(
                  l10n.rideBookingPickupCurrentLocation,
                  style: textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DWSpacing.md),

        // Destination input
        Text(
          l10n.rideBookingDestinationLabel,
          style: textTheme.labelMedium,
        ),
        const SizedBox(height: DWSpacing.xxs),
        TextFormField(
          controller: _destinationController,
          enabled: false, // Disabled in this ticket - use recent locations
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Choose destination from recent locations below',
            helperText: 'Tap on a recent location to select destination',
            helperStyle: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: DWSpacing.md),

        // Price and duration display (when quote is available)
        if (bookingState.hasQuote && bookingState.formattedPrice != null)
          Container(
            padding: const EdgeInsets.all(DWSpacing.md),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DWRadius.md),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  bookingState.formattedPrice!,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                if (bookingState.formattedDuration != null) ...[
                  const SizedBox(width: DWSpacing.sm),
                  Text(
                    '•',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: DWSpacing.sm),
                  Text(
                    bookingState.formattedDuration!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        if (bookingState.hasQuote) const SizedBox(height: DWSpacing.md),

        // Error message display
        if (bookingState.lastErrorMessage != null)
          Container(
            padding: const EdgeInsets.all(DWSpacing.sm),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(DWRadius.md),
            ),
            child: Text(
              bookingState.lastErrorMessage!,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        if (bookingState.lastErrorMessage != null) const SizedBox(height: DWSpacing.md),

        // Recent locations
        Text(
          l10n.rideBookingRecentTitle,
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: DWSpacing.xs),
        _RecentLocationTile(
          icon: Icons.home_outlined,
          title: l10n.rideBookingRecentHome,
          subtitle: l10n.rideBookingRecentHomeSubtitle,
        ),
        _RecentLocationTile(
          icon: Icons.work_outline,
          title: l10n.rideBookingRecentWork,
          subtitle: l10n.rideBookingRecentWorkSubtitle,
        ),
        _RecentLocationTile(
          icon: Icons.add_location_alt_outlined,
          title: l10n.rideBookingRecentAddNew,
          subtitle: l10n.rideBookingRecentAddNewSubtitle,
        ),
        const SizedBox(height: DWSpacing.md),
        // See options CTA button (Track B - Ticket #7)
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: bookingState.isRequestingQuote
                ? null
                : () async {
                    if (bookingState.hasQuote) {
                      // If we already have a quote, confirm the ride
                      await bookingController.confirmRide();
                      if (context.mounted) {
                        Navigator.of(context).pushNamed(RoutePaths.rideConfirmation);
                      }
                    } else {
                      // Request a quote first
                      await bookingController.requestQuoteIfPossible();
                    }
                  },
            child: bookingState.isRequestingQuote
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    bookingState.hasQuote
                        ? 'Confirm Ride' // TODO: Use L10n key
                        : l10n.rideBookingSeeOptionsCta,
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                  ),
          ),
        ),
      ],
    ),
    );
  }
}

/// Recent location list tile widget
class _RecentLocationTile extends StatelessWidget {
  const _RecentLocationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: DWSpacing.xxs),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DWRadius.md),
      ),
      child: ListTile(
        leading: Icon(icon, color: colorScheme.primary),
        title: Text(title, style: textTheme.bodyLarge),
        subtitle: Text(
          subtitle,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        onTap: () {
          // For now, just show that tapping works
          // In a real implementation, this would use a callback or provider
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Selected: $title')),
          );
        },
      ),
    );
  }
}


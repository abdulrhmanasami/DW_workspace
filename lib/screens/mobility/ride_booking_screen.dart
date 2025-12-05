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
import 'package:maps_shims/maps.dart';
import 'package:mobility_shims/mobility_shims.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../router/app_router.dart';
import '../../state/mobility/ride_booking_controller.dart';
import '../../state/mobility/ride_booking_state.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/app_button_unified.dart';

/// Key for ride booking map widget (for testing)
const rideBookingMapKey = ValueKey('ride_booking_map');

/// RideBookingScreen - Main entry point for Ride booking flow
class RideBookingScreen extends ConsumerWidget {
  const RideBookingScreen({super.key});

  Widget _buildMapView(WidgetRef ref) {
    final buildMap = ref.watch(mapViewBuilderProvider);
    final bookingState = ref.watch(rideBookingControllerProvider);

    // Determine camera position: use pickup location if available, otherwise default to Riyadh
    final MapCamera initialCameraPosition;
    if (bookingState.ride?.pickup?.location != null) {
      final pickupLocation = bookingState.ride!.pickup!.location!;
      initialCameraPosition = MapCamera(
        target: MapPoint(
          latitude: pickupLocation.latitude,
          longitude: pickupLocation.longitude,
        ),
        zoom: 15.0,
      );
    } else {
      // Default to Riyadh
      initialCameraPosition = MapCamera(
        target: MapPoint(
          latitude: 24.7136,
          longitude: 46.6753,
        ),
        zoom: 12.0,
      );
    }

    return Container(
      key: rideBookingMapKey,
      child: buildMap(
        MapViewParams(
          initialCameraPosition: initialCameraPosition,
          onMapReady: (_) {
            // Map is ready - could add markers here if needed
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return AppShell(
      showBottomNav: false,
      showAppBar: true,
      title: l10n.rideBookingTitle,
      safeArea: false,
      body: SafeArea(
        child: Stack(
        children: [
          // Map view (background)
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.only(bottom: 200), // Space for the Sheet
              child: _buildMapView(ref),
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

  String _primaryCtaLabel(RideBookingState state, AppLocalizations l10n) {
    if (state.isLoading) {
      return '...'; // Loading state - text won't be visible due to progress indicator
    }

    if (state.canConfirmRide) {
      return 'Confirm Ride'; // TODO: Use L10n key when available
    }

    if (state.canRequestQuote) {
      return l10n.rideBookingSeeOptionsCta;
    }

    // Default state before locations are complete
    return 'Select destination'; // TODO: Use L10n key when available
  }

  bool _primaryCtaEnabled(RideBookingState state) {
    if (state.isLoading) return false;
    return state.canConfirmRide || state.canRequestQuote;
  }

  void _onPrimaryCtaPressed(RideBookingState state, RideBookingController controller) async {
    if (state.isLoading) return;

    if (state.canConfirmRide) {
      await controller.confirmRide();
      if (!mounted) return;
      Navigator.of(context).pushNamed(RoutePaths.rideConfirmation);
      return;
    }

    if (state.canRequestQuote) {
      await controller.requestQuoteIfPossible();
      return;
    }

    // In other states, do nothing (button should be disabled)
  }

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
          onTap: () => bookingController.updateDestination(
            MobilityPlace.saved(id: 'home', label: l10n.rideBookingRecentHome),
          ),
        ),
        _RecentLocationTile(
          icon: Icons.work_outline,
          title: l10n.rideBookingRecentWork,
          subtitle: l10n.rideBookingRecentWorkSubtitle,
          onTap: () => bookingController.updateDestination(
            MobilityPlace.saved(id: 'work', label: l10n.rideBookingRecentWork),
          ),
        ),
        _RecentLocationTile(
          icon: Icons.add_location_alt_outlined,
          title: l10n.rideBookingRecentAddNew,
          subtitle: l10n.rideBookingRecentAddNewSubtitle,
          onTap: () {
            // TODO: Navigate to location picker screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add new location - not implemented yet')),
            );
          },
        ),
        const SizedBox(height: DWSpacing.md),
        // Primary CTA button
        AppButtonUnified.primary(
          label: _primaryCtaLabel(bookingState, l10n),
          onPressed: _primaryCtaEnabled(bookingState)
              ? () => _onPrimaryCtaPressed(bookingState, bookingController)
              : null,
          isLoading: bookingState.isLoading,
          fullWidth: true,
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
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: DWSpacing.xxs),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(DWRadius.md)),
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
        onTap: onTap,
      ),
    );
  }
}


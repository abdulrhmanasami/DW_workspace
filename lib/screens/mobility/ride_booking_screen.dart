/// Ride Booking Screen - Track B Ticket #6
/// Purpose: UI-only Booking Sheet for Ride vertical
/// Created by: Track B - Ticket #6
/// Updated by: Track B - Ticket #9 (RideDraftUiState integration)
/// Updated by: Track B - Ticket B-3 (Auto-navigation via ref.listen)
/// Last updated: 2025-12-05
///
/// This screen provides the initial Ride booking interface with:
/// - Map stub (placeholder for future maps_shims integration)
/// - Bottom Sheet with pickup/destination inputs
/// - Recent locations list
///
/// Track B - Ticket B-3: Added ref.listen for automatic navigation
/// when ride status transitions to findingDriver/driverAccepted.
///
/// NOTE: This is UI only - no FSM, Fare Engine, or Backend integration.

import 'package:design_system_components/design_system_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart';
import 'package:maps_shims/maps.dart' as maps;
import 'package:mobility_shims/mobility_shims.dart' as mobility;

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/router/app_router.dart';
import 'package:delivery_ways_clean/state/mobility/ride_booking_controller.dart';
import 'package:delivery_ways_clean/state/mobility/ride_booking_state.dart';
import 'package:delivery_ways_clean/widgets/app_shell.dart';
import 'package:delivery_ways_clean/widgets/app_button_unified.dart';
import 'package:delivery_ways_clean/screens/mobility/ride_destination_search_screen.dart';
import 'ride_quote_options_sheet.dart';

/// Key for ride booking map widget (for testing)
const rideBookingMapKey = ValueKey('ride_booking_map');

/// RideBookingScreen - Main entry point for Ride booking flow
class RideBookingScreen extends ConsumerStatefulWidget {
  const RideBookingScreen({super.key});

  @override
  ConsumerState<RideBookingScreen> createState() => _RideBookingScreenState();
}

class _RideBookingScreenState extends ConsumerState<RideBookingScreen> {
  bool _mapReady = false;
  bool _requestingPermission = false;
  maps.MapController? _mapController;
  mobility.LocationPoint? _userLocation;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _requestingPermission = true;
      _locationError = null;
    });

    final location = ref.read(mobility.locationProvider);
    final booking = ref.read(rideBookingControllerProvider.notifier);

    try {
      final permission = await location.requestPermission();
      if (permission != mobility.PermissionStatus.granted) {
        setState(() {
          _locationError = 'location_permission_denied';
        });
        return;
      }

      final current = await location.getCurrent();
      setState(() {
        _userLocation = current;
      });

      await booking.initialize();
      _moveCameraToUser();
    } catch (_) {
      setState(() {
        _locationError = 'location_error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _requestingPermission = false;
        });
      }
    }
  }

  void _moveCameraToUser() {
    if (!_mapReady || _mapController == null || _userLocation == null) return;
    _mapController!.moveCamera(
      maps.MapCamera(
        target: maps.MapPoint(
          latitude: _userLocation!.latitude,
          longitude: _userLocation!.longitude,
        ),
        zoom: 15.0,
      ),
    );
  }

  Future<void> _openDestinationSearch() async {
    final result = await Navigator.of(context).push<RideDestinationSearchResult>(
      MaterialPageRoute(
        builder: (_) => const RideDestinationSearchScreen(),
      ),
    );
    if (!mounted) return;
    if (result != null) {
      await ref
          .read(rideBookingControllerProvider.notifier)
          .updateDestination(result.place);
      _moveCameraToRoute();
    }
  }

  void _moveCameraToRoute() {
    final polylines = ref.read(rideBookingControllerProvider).polylines;
    if (!_mapReady || _mapController == null || polylines == null || polylines.isEmpty) return;
    final points = polylines.first.points;
    if (points.isEmpty) return;
    final avgLat =
        points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
    final avgLng =
        points.map((p) => p.longitude).reduce((a, b) => a + b) / points.length;
    _mapController!.moveCamera(
      maps.MapCamera(
        target: maps.MapPoint(latitude: avgLat, longitude: avgLng),
        zoom: 13.5,
      ),
    );
  }

  Widget _buildMapView(WidgetRef ref) {
    final buildMap = ref.watch(maps.mapViewBuilderProvider);
    final bookingState = ref.watch(rideBookingControllerProvider);

    // Determine camera position, markers, and polylines based on booking state
    final maps.MapCamera initialCameraPosition;
    final List<maps.MapMarker> markers = [];
    final List<maps.MapPolyline> polylines = bookingState.polylines ?? [];

    if (bookingState.hasValidLocations) {
      final pickup = bookingState.ride!.pickup!;
      final destination = bookingState.ride!.destination!;

      // Add pickup marker
      if (pickup.location != null) {
        markers.add(maps.MapMarker(
          id: const maps.MapMarkerId('pickup'),
          position: maps.GeoPoint(pickup.location!.latitude, pickup.location!.longitude),
          label: pickup.label,
        ));
      }

      // Add destination marker
      if (destination.location != null) {
        markers.add(maps.MapMarker(
          id: const maps.MapMarkerId('destination'),
          position: maps.GeoPoint(destination.location!.latitude, destination.location!.longitude),
          label: destination.label,
        ));
      }

      // Set camera to show both locations with route
      if (pickup.location != null && destination.location != null) {
        // Calculate center point
        final centerLat = (pickup.location!.latitude + destination.location!.latitude) / 2;
        final centerLng = (pickup.location!.longitude + destination.location!.longitude) / 2;

        // Calculate zoom level based on distance (simple approximation)
        final latDiff = (pickup.location!.latitude - destination.location!.latitude).abs();
        final lngDiff = (pickup.location!.longitude - destination.location!.longitude).abs();
        final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;
        final zoom = maxDiff > 0.01 ? 13.0 : 14.0; // Zoom out for longer distances

        initialCameraPosition = maps.MapCamera(
          target: maps.MapPoint(latitude: centerLat, longitude: centerLng),
          zoom: zoom,
        );
      } else if (pickup.location != null) {
        initialCameraPosition = maps.MapCamera(
          target: maps.MapPoint(
            latitude: pickup.location!.latitude,
            longitude: pickup.location!.longitude,
          ),
          zoom: 15.0,
        );
      } else {
        // Fallback to Riyadh
        initialCameraPosition = maps.MapCamera(
          target: maps.MapPoint(
            latitude: 24.7136,
            longitude: 46.6753,
          ),
          zoom: 12.0,
        );
      }
    } else if (bookingState.ride?.pickup?.location != null) {
      // Only pickup available
      final pickupLocation = bookingState.ride!.pickup!.location!;
      initialCameraPosition = maps.MapCamera(
        target: maps.MapPoint(
          latitude: pickupLocation.latitude,
          longitude: pickupLocation.longitude,
        ),
        zoom: 15.0,
      );

      // Add pickup marker
      markers.add(maps.MapMarker(
        id: const maps.MapMarkerId('pickup'),
        position: maps.GeoPoint(pickupLocation.latitude, pickupLocation.longitude),
        label: bookingState.ride!.pickup!.label,
      ));
    } else {
      // Default to Riyadh
      initialCameraPosition = maps.MapCamera(
        target: maps.MapPoint(
          latitude: 24.7136,
          longitude: 46.6753,
        ),
        zoom: 12.0,
      );
    }

    // Update live polylines/markers when state changes after map is ready
    if (_mapReady && _mapController != null) {
      _mapController!.setMarkers(markers);
      _mapController!.setPolylines(polylines);
      _moveCameraToRoute();
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _mapReady ? 1 : 0.4,
      child: Container(
        key: rideBookingMapKey,
        color: Colors.black12,
        child: buildMap(
          maps.MapViewParams(
            initialCameraPosition: initialCameraPosition,
            onMapReady: (controller) {
              _mapController = controller;
              setState(() => _mapReady = true);

              if (markers.isNotEmpty) {
                controller.setMarkers(markers);
              }
              if (polylines.isNotEmpty) {
                controller.setPolylines(polylines);
              }
              _moveCameraToUser();
              _moveCameraToRoute();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheet(WidgetRef ref, AppLocalizations l10n) {
    final bookingState = ref.watch(rideBookingControllerProvider);
    final bookingController = ref.read(rideBookingControllerProvider.notifier);

    // If we have quotes available, show the quote options sheet
    if (bookingState.hasQuotes) {
      return RideQuoteOptionsSheet(
        quote: bookingState.quotes!,
        selectedOption: bookingState.selectedQuote,
        onOptionSelected: bookingController.selectQuote,
        l10n: l10n,
        showHandle: true,
      );
    }

    // Otherwise, show the regular booking sheet
    final theme = Theme.of(ref.context);
    final colorScheme = theme.colorScheme;

    return Container(
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
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

            // Loading / permission overlay
            if (_requestingPermission || !_mapReady)
              const Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black12,
                    ),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),

            // Location error banner
            if (_locationError != null)
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Material(
                  color: Colors.red.shade600,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _locationError!,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),

            // Floating back button
            Positioned(
              top: 16,
              left: 16,
              child: DwIconButton(
                icon: Icons.arrow_back,
                tooltip: l10n.commonBack,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            // Destination search entry
            Positioned(
              top: 16,
              left: 72,
              right: 16,
              child: GestureDetector(
                onTap: _openDestinationSearch,
                child: AbsorbPointer(
                  child: DwInput(
                    label: l10n.rideBookingDestinationLabel,
                    hint: 'Where to?',
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
            ),

            // Booking Sheet (Bottom)
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildBottomSheet(ref, l10n),
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

    if (state.hasQuotes && state.selectedQuote != null) {
      return 'Confirm Ride'; // User has selected a quote, can now confirm
    }

    if (state.canRequestQuote) {
      return l10n.rideBookingSeeOptionsCta;
    }

    // Default state before locations are complete
    return 'Select destination'; // TODO: Use L10n key when available
  }

  bool _primaryCtaEnabled(RideBookingState state) {
    if (state.isLoading) return false;
    return state.canConfirmRide || state.canRequestQuote || (state.hasQuotes && state.selectedQuote != null);
  }

  void _onPrimaryCtaPressed(RideBookingState state, RideBookingController controller) async {
    if (state.isLoading) return;

    if (state.canConfirmRide) {
      // Track B - Ticket B-3: Just call confirmRide, navigation is handled by ref.listen
      await controller.confirmRide();
      return;
    }

    if (state.hasQuotes && state.selectedQuote != null) {
      // Track B - Ticket B-3: User has selected a quote, confirm the ride
      // Navigation to tracking screen is handled by ref.listen when status becomes findingDriver
      await controller.confirmRide();
      return;
    }

    if (state.canRequestQuote) {
      await controller.requestQuoteIfPossible();
      return;
    }

    // In other states, do nothing (button should be disabled)
  }

  /// Track B - Bug Fix: Flag to prevent duplicate listener registration.
  bool _hasSetupListener = false;

  @override
  void initState() {
    super.initState();
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

    // Track B - Bug Fix: Setup listener only once to prevent duplicate callbacks.
    // ref.listen in build() can cause multiple registrations on rebuilds.
    if (!_hasSetupListener) {
      _hasSetupListener = true;
      ref.listen<RideBookingState>(rideBookingControllerProvider, (previous, next) {
        // Navigate to tracking screen when ride enters findingDriver state
        // (only if we weren't already in that state to prevent double navigation)
        if (previous?.status != mobility.RideStatus.findingDriver &&
            next.status == mobility.RideStatus.findingDriver) {
          // Bug Fix: Check mounted before navigation to avoid errors on disposed widget
          if (!mounted) return;
          Navigator.of(context).pushNamed(RoutePaths.rideConfirmation);
        }
      });
    }

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
        GestureDetector(
          onTap: () async {
            final result = await Navigator.of(context).push<RideDestinationSearchResult>(
              MaterialPageRoute(
                builder: (_) => const RideDestinationSearchScreen(),
              ),
            );
            if (result != null && mounted) {
              _destinationController.text = result.place.label;
              await ref.read(rideBookingControllerProvider.notifier).updateDestination(result.place);
            }
          },
          child: AbsorbPointer(
            child: DwInput(
              controller: _destinationController,
              label: l10n.rideBookingDestinationLabel,
              hint: 'Where to?',
              prefixIcon: const Icon(Icons.search),
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
          onTap: () async {
            await bookingController.updateDestination(
              mobility.MobilityPlace.saved(id: 'home', label: l10n.rideBookingRecentHome),
            );
          },
        ),
        _RecentLocationTile(
          icon: Icons.work_outline,
          title: l10n.rideBookingRecentWork,
          subtitle: l10n.rideBookingRecentWorkSubtitle,
          onTap: () async {
            await bookingController.updateDestination(
              mobility.MobilityPlace.saved(id: 'work', label: l10n.rideBookingRecentWork),
            );
          },
        ),
        _RecentLocationTile(
          icon: Icons.add_location_alt_outlined,
          title: l10n.rideBookingRecentAddNew,
          subtitle: l10n.rideBookingRecentAddNewSubtitle,
          onTap: () async {
            // Navigate to destination selection screen
            final result = await Navigator.of(context).pushNamed(
              RoutePaths.rideDestination,
              arguments: true, // returnResult = true
            );
            if (result is mobility.MobilityPlace && mounted) {
              // Update destination in controller
              final controller = ref.read(rideBookingControllerProvider.notifier);
              await controller.updateDestination(result);
            }
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


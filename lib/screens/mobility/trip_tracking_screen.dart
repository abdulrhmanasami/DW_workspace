/// Trip Tracking Screen - Track B Ticket B-4
/// Purpose: Trip tracking UI connected to RideBookingState/FSM
/// Created by: Track B - Ticket B-4
/// Updated by: Track B - Ticket B-3 (Driver matching simulation)
/// Last updated: 2025-12-05
///
/// Screen for tracking active rides after confirmation.
/// Shows real-time status (findingDriver, inProgress, completed, cancelled)
/// and provides actions like cancel or done.
///
/// Track B - Ticket B-3: This screen now automatically starts driver
/// matching simulation when opened in findingDriver state.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart';
import 'package:maps_shims/maps.dart';
import 'package:mobility_shims/mobility_shims.dart';

import '../../router/app_router.dart';
import '../../state/mobility/ride_booking_controller.dart';
import '../../state/mobility/ride_booking_state.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/app_button_unified.dart';
import '../../widgets/app_card_unified.dart';

/// Key for trip tracking map widget (for testing)
const tripTrackingMapKey = ValueKey('trip_tracking_map');

/// TripTrackingScreen - Real-time ride tracking after confirmation
///
/// Track B - Ticket B-3: Updated to use ConsumerStatefulWidget for
/// automatic driver matching simulation on screen mount.
class TripTrackingScreen extends ConsumerStatefulWidget {
  const TripTrackingScreen({super.key});

  @override
  ConsumerState<TripTrackingScreen> createState() => _TripTrackingScreenState();
}

class _TripTrackingScreenState extends ConsumerState<TripTrackingScreen> {
  bool _simulationStarted = false;

  @override
  void initState() {
    super.initState();
    // Track B - Ticket B-3: Start driver simulation after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startDriverSimulationIfNeeded();
    });
  }

  /// Starts driver simulation if the ride is in findingDriver state.
  void _startDriverSimulationIfNeeded() {
    if (_simulationStarted) return;
    
    final state = ref.read(rideBookingControllerProvider);
    if (state.status == RideStatus.findingDriver) {
      _simulationStarted = true;
      ref.read(rideBookingControllerProvider.notifier).simulateDriverMatch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookingState = ref.watch(rideBookingControllerProvider);
    final bookingController =
        ref.read(rideBookingControllerProvider.notifier);

    // Track B - Ticket B-3: Listen for completion and navigate to summary
    ref.listen<RideBookingState>(rideBookingControllerProvider, (previous, next) {
      if (previous?.status != RideStatus.completed && 
          next.status == RideStatus.completed) {
        // Navigate to trip summary when ride completes
        Navigator.of(context).pushReplacementNamed(RoutePaths.rideTripSummary);
      }
    });

    return AppShell(
      showBottomNav: false,
      showAppBar: true,
      title: 'Track your ride',
      safeArea: false,
      body: SafeArea(
        child: Column(
          children: [
            _buildMapView(theme, bookingState),
            Expanded(
              child: _TripTrackingPanel(
                state: bookingState,
                controller: bookingController,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView(ThemeData theme, RideBookingState bookingState) {
    final buildMap = ref.watch(mapViewBuilderProvider);
    final state = bookingState;

    // Determine camera position and markers based on ride state
    final MapCamera initialCameraPosition;
    final List<MapMarker> markers = [];

    if (state.hasValidLocations) {
      final pickup = state.ride!.pickup!;
      final destination = state.ride!.destination!;

      // Add pickup marker
      if (pickup.location != null) {
        markers.add(MapMarker(
          id: const MapMarkerId('pickup'),
          position: GeoPoint(pickup.location!.latitude, pickup.location!.longitude),
          label: pickup.label,
        ));
      }

      // Add destination marker
      if (destination.location != null) {
        markers.add(MapMarker(
          id: const MapMarkerId('destination'),
          position: GeoPoint(destination.location!.latitude, destination.location!.longitude),
          label: destination.label,
        ));
      }

      // Set camera to show both pickup and destination
      if (pickup.location != null && destination.location != null) {
        // For simplicity, focus on pickup for now
        initialCameraPosition = MapCamera(
          target: MapPoint(
            latitude: pickup.location!.latitude,
            longitude: pickup.location!.longitude,
          ),
          zoom: 13.0, // Zoom out to show both points
        );
      } else if (pickup.location != null) {
        initialCameraPosition = MapCamera(
          target: MapPoint(
            latitude: pickup.location!.latitude,
            longitude: pickup.location!.longitude,
          ),
          zoom: 15.0,
        );
      } else if (destination.location != null) {
        initialCameraPosition = MapCamera(
          target: MapPoint(
            latitude: destination.location!.latitude,
            longitude: destination.location!.longitude,
          ),
          zoom: 15.0,
        );
      } else {
        // Fallback to Riyadh
        initialCameraPosition = MapCamera(
          target: MapPoint(latitude: 24.7136, longitude: 46.6753),
          zoom: 12.0,
        );
      }
    } else {
      // No valid locations, show default
      initialCameraPosition = MapCamera(
        target: MapPoint(latitude: 24.7136, longitude: 46.6753),
        zoom: 12.0,
      );
    }

    return Container(
      key: tripTrackingMapKey,
      height: 260,
      margin: const EdgeInsets.all(DWSpacing.md),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DWRadius.lg),
        child: buildMap(
          MapViewParams(
            initialCameraPosition: initialCameraPosition,
            onMapReady: (controller) {
              // Set markers when map is ready
              if (markers.isNotEmpty) {
                controller.setMarkers(markers);
              }
            },
          ),
        ),
      ),
    );
  }
}

class _TripTrackingPanel extends StatelessWidget {
  const _TripTrackingPanel({
    required this.state,
    required this.controller,
  });

  final RideBookingState state;
  final RideBookingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = state.status;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(DWSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStatusHeader(theme, status),
              const SizedBox(height: DWSpacing.md),
              _buildTripSummary(theme),
              if (state.status == RideStatus.completed) ...[
                const SizedBox(height: DWSpacing.lg),
                _buildRatingSection(theme),
              ],
              const SizedBox(height: DWSpacing.lg),
              if (state.errorMessage != null) ...[
                Text(
                  state.errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: DWSpacing.md),
              ],
              const SizedBox(height: DWSpacing.xl),
              _buildPrimaryActions(context, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeader(ThemeData theme, RideStatus? status) {
    final title = _statusTitle(status);
    final subtitle = _statusSubtitle(status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: DWSpacing.xs),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTripSummary(ThemeData theme) {
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return AppCardUnified(
      variant: AppCardVariant.elevated,
      padding: const EdgeInsets.all(DWSpacing.md),
      child: Row(
        children: [
          Icon(
            Icons.directions_car,
            size: 24,
            color: colorScheme.primary,
          ),
          const SizedBox(width: DWSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.formattedPrice != null)
                  Text(
                    state.formattedPrice!,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                if (state.formattedDuration != null) ...[
                  const SizedBox(height: DWSpacing.xs),
                  Text(
                    state.formattedDuration!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(ThemeData theme) {
    final currentRating = state.rating ?? 0;
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How was your trip?',
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: DWSpacing.sm),
        Row(
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            final isFilled = starIndex <= currentRating;

            return IconButton(
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              onPressed: () {
                controller.submitRating(rating: starIndex);
              },
              icon: Icon(
                isFilled ? Icons.star : Icons.star_border,
              ),
              color: isFilled
                  ? colorScheme.primary
                  : colorScheme.outline,
            );
          }),
        ),
        if (state.hasSubmittedRating) ...[
          const SizedBox(height: DWSpacing.xs),
          Text(
            'Thanks for your feedback!',
            style: textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  Widget _buildPrimaryActions(BuildContext context, ThemeData theme) {
    final canCancel = state.canCancel &&
        state.status != RideStatus.completed &&
        state.status != RideStatus.cancelled;

    final isCompleted = state.status == RideStatus.completed;
    final isInProgress = state.status == RideStatus.inProgress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Track B - Ticket B-3: Show "Complete Trip" button during inProgress
        if (isInProgress)
          AppButtonUnified.primary(
            label: 'Complete Trip',
            onPressed: () => _completeTrip(),
            fullWidth: true,
          ),
        if (isInProgress) const SizedBox(height: DWSpacing.sm),
        
        // Cancel or Done button
        if (isCompleted)
          AppButtonUnified.primary(
            label: 'Done',
            onPressed: () => Navigator.of(context).pop(),
            fullWidth: true,
          )
        else
          AppButtonUnified.secondary(
            label: 'Cancel ride',
            onPressed: canCancel ? () => _cancelRide() : null,
            fullWidth: true,
          ),
      ],
    );
  }

  void _completeTrip() async {
    await controller.simulateTripCompletion();
  }

  void _cancelRide() async {
    await controller.cancelRide();
    // لا يوجد navigation هنا؛ فقط نحدّث الحالة.
    // الانتقال خارج الشاشة يكون من الـ Router في تذكرة لاحقة.
  }

  String _statusTitle(RideStatus? status) {
    switch (status) {
      case RideStatus.findingDriver:
        return 'Looking for a driver';
      case RideStatus.driverAccepted:
        return 'Driver is on the way';
      case RideStatus.driverArrived:
        return 'Driver has arrived';
      case RideStatus.inProgress:
        return 'Trip in progress';
      case RideStatus.payment:
        return 'Processing payment';
      case RideStatus.completed:
        return 'Trip completed';
      case RideStatus.cancelled:
        return 'Trip cancelled';
      default:
        return 'Preparing your trip';
    }
  }

  String? _statusSubtitle(RideStatus? status) {
    switch (status) {
      case RideStatus.findingDriver:
        return 'We\'re matching you with the best nearby driver.';
      case RideStatus.driverAccepted:
        return 'Your driver is heading to pick you up.';
      case RideStatus.driverArrived:
        return 'Your driver is waiting at the pickup location.';
      case RideStatus.inProgress:
        return 'Sit tight, you\'re on your way to your destination.';
      case RideStatus.payment:
        return 'Finalizing your trip payment.';
      case RideStatus.completed:
        return 'Review your trip details and get ready for the next one.';
      case RideStatus.cancelled:
        return 'Your trip has been cancelled.';
      default:
        return null;
    }
  }
}

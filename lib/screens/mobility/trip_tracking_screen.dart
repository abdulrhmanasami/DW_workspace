/// Trip Tracking Screen - Track B Ticket B-4
/// Purpose: Trip tracking UI connected to RideBookingState/FSM
/// Created by: Track B - Ticket B-4
/// Last updated: 2025-12-04
///
/// Screen for tracking active rides after confirmation.
/// Shows real-time status (findingDriver, inProgress, completed, cancelled)
/// and provides actions like cancel or done.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart';
import 'package:maps_shims/maps.dart';
import 'package:mobility_shims/mobility_shims.dart';

import '../../state/mobility/ride_booking_controller.dart';
import '../../state/mobility/ride_booking_state.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/app_button_unified.dart';
import '../../widgets/app_card_unified.dart';

/// Key for trip tracking map widget (for testing)
const tripTrackingMapKey = ValueKey('trip_tracking_map');

class TripTrackingScreen extends ConsumerWidget {
  const TripTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bookingState = ref.watch(rideBookingControllerProvider);
    final bookingController =
        ref.read(rideBookingControllerProvider.notifier);

    return AppShell(
      showBottomNav: false,
      showAppBar: true,
      title: 'Track your ride',
      safeArea: false,
      body: SafeArea(
        child: Column(
          children: [
            _buildMapView(theme, bookingState, ref),
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

  Widget _buildMapView(ThemeData theme, RideBookingState state, WidgetRef ref) {
    final buildMap = ref.watch(mapViewBuilderProvider);

    // Determine camera position and markers based on ride state
    final MapCamera initialCameraPosition;
    final List<MapMarker> markers = [];

    if (state.hasValidLocations) {
      final pickup = state.ride!.pickup!;
      final destination = state.ride!.destination!;

      // Add pickup marker
      if (pickup.location != null) {
        markers.add(MapMarker(
          id: MapMarkerId('pickup'),
          position: GeoPoint(pickup.location!.latitude, pickup.location!.longitude),
          label: pickup.label,
        ));
      }

      // Add destination marker
      if (destination.location != null) {
        markers.add(MapMarker(
          id: MapMarkerId('destination'),
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
      margin: EdgeInsets.all(DWSpacing.md),
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
          padding: EdgeInsets.all(DWSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStatusHeader(theme, status),
              SizedBox(height: DWSpacing.md),
              _buildTripSummary(theme),
              if (state.status == RideStatus.completed) ...[
                SizedBox(height: DWSpacing.lg),
                _buildRatingSection(theme),
              ],
              SizedBox(height: DWSpacing.lg),
              if (state.errorMessage != null) ...[
                Text(
                  state.errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                SizedBox(height: DWSpacing.md),
              ],
              SizedBox(height: DWSpacing.xl),
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
          SizedBox(height: DWSpacing.xs),
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

    final label = isCompleted ? 'Done' : 'Cancel ride';
    final onPressed = isCompleted
        ? () => Navigator.of(context).pop()
        : (canCancel ? () => _cancelRide() : null);

    // لو احتجنا تمييز style بين الحالتين:
    final button = isCompleted
        ? AppButtonUnified.primary(
            label: label,
            onPressed: onPressed,
            fullWidth: true,
          )
        : AppButtonUnified.secondary(
            label: label,
            onPressed: onPressed,
            fullWidth: true,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        button,
      ],
    );
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
      case RideStatus.inProgress:
        return 'Your ride is on the way';
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
      case RideStatus.inProgress:
        return 'Sit tight, your driver is heading to your destination.';
      case RideStatus.completed:
        return 'Review your trip details and get ready for the next one.';
      case RideStatus.cancelled:
        return 'Your trip has been cancelled.';
      default:
        return null;
    }
  }
}

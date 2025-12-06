/// Trip Tracking Screen - Track B Ticket B-4
/// Purpose: Trip tracking UI connected to RideBookingState/FSM
/// Created by: Track B - Ticket B-4
/// Updated by: Track B - Ticket B-3 (Driver matching simulation)
/// Updated by: Track B - Ticket B-3 (Live driver location on map)
/// Updated by: Track B - Ticket B-4 (ETA, Driver Card enhancements, Navigation Guard)
/// Last updated: 2025-12-05
///
/// Screen for tracking active rides after confirmation.
/// Shows real-time status (findingDriver, inProgress, completed, cancelled)
/// and provides actions like cancel or done.
///
/// Track B - Ticket B-3: This screen now:
/// - Automatically starts driver matching simulation when opened
/// - Shows driver marker on map with live location updates
/// - Displays driver info (name, car) when driver is assigned
///
/// Track B - Ticket B-4: This screen now:
/// - Shows dynamic ETA that updates with driver movement
/// - Enhanced driver card with avatar, rating, and call button
/// - Navigation guard to prevent accidental back navigation during active trip

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/design_system_shims.dart';
import 'package:maps_shims/maps.dart';
import 'package:mobility_shims/mobility_shims.dart';

import 'package:delivery_ways_clean/router/app_router.dart';
import 'package:delivery_ways_clean/state/mobility/ride_booking_controller.dart';
import 'package:delivery_ways_clean/state/mobility/ride_booking_state.dart';
import 'package:delivery_ways_clean/widgets/app_shell.dart';
import 'package:delivery_ways_clean/widgets/app_button_unified.dart';
import 'package:delivery_ways_clean/widgets/app_card_unified.dart';

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
  
  /// Track B - Bug Fix: Flag to prevent duplicate listener registration.
  bool _hasSetupListener = false;
  
  /// Track B - Ticket B-4: Map controller reference for camera animation
  MapController? _mapController;

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

  /// Track B - Ticket B-4: Moves camera to follow driver position smoothly.
  /// Shows both driver and relevant point (pickup or destination) in view.
  void _animateCameraToDriver(RideBookingState state) {
    if (_mapController == null || !state.hasDriverLocation) return;
    
    final driverLoc = state.driverLocation!;
    
    // Determine target based on ride status
    final targetLat = state.status == RideStatus.inProgress
        ? state.ride?.destination?.location?.latitude
        : state.ride?.pickup?.location?.latitude;
    final targetLng = state.status == RideStatus.inProgress
        ? state.ride?.destination?.location?.longitude
        : state.ride?.pickup?.location?.longitude;

    if (targetLat != null && targetLng != null) {
      // Calculate center point between driver and target
      final centerLat = (driverLoc.latitude + targetLat) / 2;
      final centerLng = (driverLoc.longitude + targetLng) / 2;
      
      // Move camera to show both points
      _mapController!.moveCamera(
        MapCamera(
          target: MapPoint(latitude: centerLat, longitude: centerLng),
          zoom: 14.0, // Zoom level that typically fits both points
        ),
      );
    } else {
      // Just follow the driver
      _mapController!.moveCamera(
        MapCamera(
          target: MapPoint(
            latitude: driverLoc.latitude,
            longitude: driverLoc.longitude,
          ),
          zoom: 15.0,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookingState = ref.watch(rideBookingControllerProvider);
    final bookingController =
        ref.read(rideBookingControllerProvider.notifier);

    // Track B - Bug Fix: Setup listener only once to prevent duplicate callbacks.
    // ref.listen in build() can cause multiple registrations on rebuilds.
    if (!_hasSetupListener) {
      _hasSetupListener = true;
      ref.listen<RideBookingState>(rideBookingControllerProvider, (previous, next) {
        // Bug Fix: Check mounted before any context-dependent operations
        if (!mounted) return;
        
        if (previous?.status != RideStatus.completed && 
            next.status == RideStatus.completed) {
          // Navigate to trip summary when ride completes
          Navigator.of(context).pushReplacementNamed(RoutePaths.rideTripSummary);
        }
        
        // Track B - Ticket B-4: Animate camera to follow driver when location updates
        if (previous?.driverLocation != next.driverLocation && 
            next.hasDriverLocation &&
            _mapController != null) {
          _animateCameraToDriver(next);
        }
      });
    }

    // Track B - Ticket B-4: Determine if navigation should be blocked
    final isActiveTripInProgress = bookingState.status == RideStatus.findingDriver ||
        bookingState.status == RideStatus.driverAccepted ||
        bookingState.status == RideStatus.driverArrived ||
        bookingState.status == RideStatus.inProgress;

    // Track B - Ticket B-4: Wrap with PopScope for navigation guard
    return PopScope(
      canPop: !isActiveTripInProgress,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        // Show confirmation dialog when user tries to go back during active trip
        await _showCancelConfirmationDialog(context, bookingController);
      },
      child: AppShell(
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
      ),
    );
  }

  /// Track B - Ticket B-4: Shows confirmation dialog when user tries to go back
  Future<void> _showCancelConfirmationDialog(
    BuildContext context,
    RideBookingController controller,
  ) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trip in progress'),
        content: const Text(
          'Your trip is currently in progress. Do you want to cancel it?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continue Trip'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Cancel Trip'),
          ),
        ],
      ),
    );

    if (shouldCancel == true && context.mounted) {
      await controller.cancelRide();
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Widget _buildMapView(ThemeData theme, RideBookingState bookingState) {
    final buildMap = ref.watch(mapViewBuilderProvider);
    final state = bookingState;

    // Determine camera position and markers based on ride state
    final MapCamera initialCameraPosition;
    final List<MapMarker> markers = [];
    final List<MapPolyline> polylines = [];

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

      // Track B - Ticket B-3: Add driver marker when driver location is available
      if (state.hasDriverLocation) {
        final driverLoc = state.driverLocation!;
        markers.add(MapMarker(
          id: const MapMarkerId('driver'),
          position: GeoPoint(driverLoc.latitude, driverLoc.longitude),
          label: state.driverName ?? 'Driver',
        ));
      }

      // Track B - Ticket B-3: Create route polyline from pickup to destination
      if (pickup.location != null && destination.location != null) {
        polylines.add(MapPolyline(
          id: const MapPolylineId('route'),
          points: [
            GeoPoint(pickup.location!.latitude, pickup.location!.longitude),
            GeoPoint(destination.location!.latitude, destination.location!.longitude),
          ],
        ));
      }

      // Set camera - focus on driver if available, otherwise pickup
      if (state.hasDriverLocation) {
        // Track B - Ticket B-3: Follow driver during active tracking
        initialCameraPosition = MapCamera(
          target: MapPoint(
            latitude: state.driverLocation!.latitude,
            longitude: state.driverLocation!.longitude,
          ),
          zoom: 15.0,
        );
      } else if (pickup.location != null && destination.location != null) {
        // Calculate center between pickup and destination
        final centerLat = (pickup.location!.latitude + destination.location!.latitude) / 2;
        final centerLng = (pickup.location!.longitude + destination.location!.longitude) / 2;
        initialCameraPosition = MapCamera(
          target: MapPoint(latitude: centerLat, longitude: centerLng),
          zoom: 13.0,
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
              // Track B - Ticket B-4: Store controller reference for camera animation
              _mapController = controller;
              
              // Set markers when map is ready
              if (markers.isNotEmpty) {
                controller.setMarkers(markers);
              }
              // Track B - Ticket B-3: Set route polylines
              if (polylines.isNotEmpty) {
                controller.setPolylines(polylines);
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
              // Track B - Ticket B-3: Show driver info when available
              _buildDriverInfoCard(theme),
              if (state.hasDriverInfo) const SizedBox(height: DWSpacing.md),
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

  /// Track B - Ticket B-3 & B-4: Shows enhanced driver info card when driver is assigned.
  /// Track B-4: Added avatar, rating stars, and functional call button with console log.
  Widget _buildDriverInfoCard(ThemeData theme) {
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    if (!state.hasDriverInfo) return const SizedBox.shrink();

    return AppCardUnified(
      variant: AppCardVariant.elevated,
      padding: const EdgeInsets.all(DWSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Track B-4: ETA Banner at top of card
          if (state.hasEta) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: DWSpacing.sm,
                horizontal: DWSpacing.md,
              ),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(DWRadius.md),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: DWSpacing.xs),
                  Text(
                    state.formattedEta!,
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DWSpacing.md),
          ],
          // Driver info row
          Row(
            children: [
              // Track B-4: Enhanced driver avatar with placeholder or image
              _buildDriverAvatar(colorScheme),
              const SizedBox(width: DWSpacing.md),
              // Driver info with rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.driverName != null)
                      Text(
                        state.driverName!,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    // Track B-4: Driver rating stars
                    if (state.hasDriverRating) ...[
                      const SizedBox(height: DWSpacing.xxs),
                      _buildDriverRating(colorScheme, textTheme),
                    ],
                    if (state.driverCarInfo != null) ...[
                      const SizedBox(height: DWSpacing.xxs),
                      Text(
                        state.driverCarInfo!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Track B-4: Call button with console log
              _buildCallButton(colorScheme),
            ],
          ),
        ],
      ),
    );
  }

  /// Track B - Ticket B-4: Builds driver avatar with placeholder.
  Widget _buildDriverAvatar(ColorScheme colorScheme) {
    // For now, use a placeholder avatar. In production, this would load
    // from state.driverAvatarUrl using a NetworkImage.
    return CircleAvatar(
      radius: 28,
      backgroundColor: colorScheme.primaryContainer,
      child: Icon(
        Icons.person,
        color: colorScheme.onPrimaryContainer,
        size: 32,
      ),
    );
  }

  /// Track B - Ticket B-4: Builds driver rating display with stars.
  Widget _buildDriverRating(ColorScheme colorScheme, TextTheme textTheme) {
    final rating = state.driverRating ?? 0.0;
    final fullStars = rating.floor();
    final hasHalfStar = (rating - fullStars) >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Rating number
        Text(
          state.formattedDriverRating!,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: DWSpacing.xxs),
        // Star icons
        ...List.generate(5, (index) {
          if (index < fullStars) {
            return const Icon(Icons.star, size: 16, color: Colors.amber);
          } else if (index == fullStars && hasHalfStar) {
            return const Icon(Icons.star_half, size: 16, color: Colors.amber);
          } else {
            return Icon(Icons.star_border, size: 16, color: Colors.amber.shade200);
          }
        }),
      ],
    );
  }

  /// Track B - Ticket B-4: Builds call button with console output.
  Widget _buildCallButton(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(DWRadius.circle),
      ),
      child: IconButton(
        icon: Icon(Icons.phone, color: colorScheme.primary),
        onPressed: () {
          // Track B-4: Print to console as per ticket requirements
          debugPrint('[Track B-4] Call button pressed - Calling driver: ${state.driverName}');
        },
        tooltip: 'Call driver',
      ),
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

/// Ride Active Trip Screen - Track B Ticket #15 (Updated: Ticket #22)
/// Purpose: Display active trip status with real map and driver card
/// Created by: Track B - Ticket #15
/// Updated by: Track B - Ticket #22 (Polished UI, real Map, FSM-wired Cancel)
/// Last updated: 2025-11-28
///
/// This screen shows the active trip interface (Screen 10 in Hi-Fi Mockups):
/// - Map background via maps_shims (showing pickup/destination markers)
/// - Bottom Driver Card with Status/ETA, driver info, and Cancel action
/// - Cancel Ride functionality wired to FSM
///
/// NOTE: Driver details are mock placeholders until backend integration.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Shims only - no direct SDKs
import 'package:maps_shims/maps_shims.dart';
import 'package:mobility_shims/mobility_shims.dart';
import 'package:design_system_shims/design_system_shims.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../router/app_router.dart';
import '../../state/mobility/ride_draft_state.dart';
import '../../state/mobility/ride_trip_session.dart';
import '../../state/mobility/ride_quote_controller.dart';

/// Active Trip Screen - Shows trip status, map, and driver card (Screen 10)
class RideActiveTripScreen extends ConsumerWidget {
  const RideActiveTripScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // Listen for phase changes to navigate to Trip Summary when completed
    // Track B - Ticket #23
    ref.listen<RideTripSessionUiState>(
      rideTripSessionProvider,
      (previous, next) {
        final prevPhase = previous?.activeTrip?.phase;
        final nextPhase = next.activeTrip?.phase;

        // When trip transitions to completed -> open summary screen
        if (prevPhase != RideTripPhase.completed &&
            nextPhase == RideTripPhase.completed) {
          if (context.mounted) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context)
                  .pushReplacementNamed(RoutePaths.rideTripSummary);
            } else {
              Navigator.of(context).pushNamed(RoutePaths.rideTripSummary);
            }
          }
        }
      },
    );

    // Watch providers
    final tripSession = ref.watch(rideTripSessionProvider);
    final activeTrip = tripSession.activeTrip;
    final rideDraft = ref.watch(rideDraftProvider);
    final quoteState = ref.watch(rideQuoteControllerProvider);

    final destination = rideDraft.destinationQuery.trim();
    final quote = quoteState.quote;

    // Derive selected option from quote
    final selectedOptionId = rideDraft.selectedOptionId;
    final selectedOption = quote == null
        ? null
        : (selectedOptionId != null
            ? quote.optionById(selectedOptionId) ?? quote.recommendedOption
            : quote.recommendedOption);

    // No active trip fallback
    if (activeTrip == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.rideActiveNoTripTitle,
            style: textTheme.titleLarge,
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.directions_car_outlined,
                size: 64,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.rideActiveNoTripBody,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              DWButton.primary(
                label: l10n.rideActiveGoBackCta,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back,
              color: colorScheme.onSurface,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: Text(
            l10n.rideActiveAppBarTitle,
            style: textTheme.titleMedium,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Map background with route (Track B - Ticket #28)
          Positioned.fill(
            child: _ActiveTripMap(
              activeTrip: activeTrip,
              pickupPlace: rideDraft.pickupPlace,
              destinationPlace: rideDraft.destinationPlace,
            ),
          ),

          // Bottom Driver Card
          Align(
            alignment: Alignment.bottomCenter,
            child: _ActiveDriverCard(
              activeTrip: activeTrip,
              destination: destination,
              selectedOption: selectedOption,
            ),
          ),
        ],
      ),
    );
  }
}

/// Map widget for active trip using maps_shims and RideMapConfig (Track B - Ticket #28)
class _ActiveTripMap extends StatelessWidget {
  const _ActiveTripMap({
    required this.activeTrip,
    required this.pickupPlace,
    required this.destinationPlace,
  });

  final RideTripState activeTrip;
  final MobilityPlace? pickupPlace;
  final MobilityPlace? destinationPlace;

  @override
  Widget build(BuildContext context) {
    // Mock driver location (would be real-time from backend in production)
    // Place driver slightly offset from pickup for visual effect
    final pickupLocation = pickupPlace?.location;
    LocationPoint? mockDriverLocation;
    
    if (pickupLocation != null && _shouldShowDriverMarker(activeTrip.phase)) {
      mockDriverLocation = LocationPoint(
        latitude: pickupLocation.latitude,
        longitude: pickupLocation.longitude + 0.005,
        accuracyMeters: 10,
        timestamp: DateTime.now(),
      );
    }

    // Build map config using domain helper (Track B - Ticket #28)
    final mapConfig = buildActiveTripMap(
      activeTrip: activeTrip,
      pickup: pickupPlace,
      destination: destinationPlace,
      driverLocation: mockDriverLocation,
    );

    return MapWidget(
      initialPosition: mapConfig.cameraTarget,
      markers: mapConfig.markers,
      polylines: mapConfig.polylines,
    );
  }

  bool _shouldShowDriverMarker(RideTripPhase phase) {
    return phase == RideTripPhase.driverAccepted ||
        phase == RideTripPhase.driverArrived ||
        phase == RideTripPhase.inProgress;
  }
}

/// Bottom card showing driver info, status/ETA, and actions
class _ActiveDriverCard extends ConsumerWidget {
  const _ActiveDriverCard({
    required this.activeTrip,
    required this.destination,
    required this.selectedOption,
  });

  final RideTripState activeTrip;
  final String destination;
  final RideQuoteOption? selectedOption;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // Generate headline
    final headline = _activeTripHeadline(
      l10n: l10n,
      activeTripPhase: activeTrip.phase,
      selectedOption: selectedOption,
    );

    final subtitle = destination.isEmpty
        ? ''
        : l10n.rideActiveDestinationLabel(destination);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, -4),
            color: colorScheme.shadow.withValues(alpha: 0.15),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),

              // Status/ETA headline
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _phaseColor(colorScheme, activeTrip.phase)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _phaseIcon(activeTrip.phase),
                      color: _phaseColor(colorScheme, activeTrip.phase),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          headline,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: colorScheme.error,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  subtitle,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Driver info card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    // Driver avatar
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Icon(
                        Icons.person,
                        color: colorScheme.onPrimaryContainer,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Driver details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ahmad M.', // TODO: Real driver name from backend
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '4.9', // TODO: Real rating from backend
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: colorScheme.onSurfaceVariant,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Toyota Camry', // TODO: Real car model
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // License plate badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                      child: Text(
                        'ABC 1234', // TODO: Real plate from backend
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Cancel ride button (secondary action - Track B #22, Ticket #25)
              SizedBox(
                width: double.infinity,
                child: DWButton.tertiary(
                  label: l10n.rideActiveCancelTripCta,
                  onPressed: () => _onCancelRide(context, ref),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onCancelRide(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final tripController = ref.read(rideTripSessionProvider.notifier);

    // Call FSM cancel method (Track B - Ticket #22)
    final success = await tripController.cancelActiveTrip();

    if (success) {
      // Navigate back to Home – Active Ride Card will disappear automatically
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } else {
      // Show error snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.rideActiveCancelErrorGeneric)),
        );
      }
    }
  }
}

// ============================================================================
// Helper Functions (shared with app_shell for consistency)
// ============================================================================

/// Generates the main headline for the active trip card based on phase
String _activeTripHeadline({
  required AppLocalizations l10n,
  required RideTripPhase activeTripPhase,
  required RideQuoteOption? selectedOption,
}) {
  final etaMinutes = selectedOption?.etaMinutes;

  switch (activeTripPhase) {
    case RideTripPhase.findingDriver:
      return l10n.rideActiveHeadlineFindingDriver;
    case RideTripPhase.driverAccepted:
      if (etaMinutes != null) {
        return l10n.rideActiveHeadlineDriverEta(etaMinutes.toString());
      }
      return l10n.rideActiveHeadlineDriverOnTheWay;
    case RideTripPhase.driverArrived:
      return l10n.rideActiveHeadlineDriverArrived;
    case RideTripPhase.inProgress:
      return l10n.rideActiveHeadlineInProgress;
    case RideTripPhase.payment:
      return l10n.rideActiveHeadlinePayment;
    case RideTripPhase.completed:
      return l10n.rideActiveHeadlineCompleted;
    case RideTripPhase.cancelled:
      return l10n.rideActiveHeadlineCancelled;
    case RideTripPhase.failed:
      return l10n.rideActiveHeadlineFailed;
    case RideTripPhase.draft:
    case RideTripPhase.quoting:
    case RideTripPhase.requesting:
      return l10n.rideActiveHeadlinePreparing;
  }
}

/// Returns an appropriate icon for the given trip phase
IconData _phaseIcon(RideTripPhase phase) {
  switch (phase) {
    case RideTripPhase.draft:
      return Icons.edit_note;
    case RideTripPhase.quoting:
      return Icons.request_quote;
    case RideTripPhase.requesting:
      return Icons.hourglass_top;
    case RideTripPhase.findingDriver:
      return Icons.search;
    case RideTripPhase.driverAccepted:
      return Icons.check_circle;
    case RideTripPhase.driverArrived:
      return Icons.local_taxi;
    case RideTripPhase.inProgress:
      return Icons.directions_car;
    case RideTripPhase.payment:
      return Icons.payment;
    case RideTripPhase.completed:
      return Icons.done_all;
    case RideTripPhase.cancelled:
      return Icons.cancel;
    case RideTripPhase.failed:
      return Icons.error;
  }
}

/// Returns an appropriate background color for the phase indicator
Color _phaseColor(ColorScheme colorScheme, RideTripPhase phase) {
  switch (phase) {
    case RideTripPhase.draft:
    case RideTripPhase.quoting:
    case RideTripPhase.requesting:
      return colorScheme.secondary;
    case RideTripPhase.findingDriver:
      return colorScheme.tertiary;
    case RideTripPhase.driverAccepted:
    case RideTripPhase.driverArrived:
      return colorScheme.primary;
    case RideTripPhase.inProgress:
      return colorScheme.primary;
    case RideTripPhase.payment:
      return colorScheme.tertiary;
    case RideTripPhase.completed:
      return Colors.green;
    case RideTripPhase.cancelled:
      return colorScheme.error;
    case RideTripPhase.failed:
      return colorScheme.error;
  }
}

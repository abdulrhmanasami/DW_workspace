/// Ride Active Trip Screen - Track B Ticket #15 (Updated: Ticket #22, #62, #64, #67, #68, #88, #89, #95)
/// Purpose: Display active trip status with real map and driver card
/// Created by: Track B - Ticket #15
/// Updated by: Track B - Ticket #22 (Polished UI, real Map, FSM-wired Cancel)
/// Updated by: Track B - Ticket #62 (End Trip debug CTA)
/// Updated by: Track B - Ticket #64 (Debug FSM transition buttons)
/// Updated by: Track B - Ticket #67 (Cancel ride confirmation dialog)
/// Updated by: Track B - Ticket #68 (Contact driver + Share trip actions)
/// Updated by: Track B - Ticket #88 (Design System alignment + DWSpacing/DWRadius)
/// Updated by: Track B - Ticket #89 (FSM Integration + Domain Helpers)
/// Updated by: Track B - Ticket #95 (Terminal UI for cancelled/failed + isCancellable guard)
/// Last updated: 2025-11-30
///
/// This screen shows the active trip interface (Screen 10 in Hi-Fi Mockups):
/// - Map background via maps_shims (showing pickup/destination markers)
/// - Bottom Driver Card with Status/ETA, driver info, and Cancel action
/// - Cancel Ride functionality wired to FSM
/// - Contact driver and Share trip actions (Ticket #68)
///
/// NOTE: Driver details are mock placeholders until backend integration.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
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

    // No active trip fallback (Design Tokens - Ticket #88)
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
              SizedBox(height: DWSpacing.md), // DS: 16pt
              Text(
                l10n.rideActiveNoTripBody,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: DWSpacing.lg), // DS: 24pt
              DWButton.primary(
                label: l10n.rideActiveGoBackCta,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      );
    }

    // Track B - Ticket #95: Terminal phase UI for cancelled/failed
    // Track B - Ticket #96: Archive trip to history before clearing
    if (activeTrip.phase.isTerminal &&
        activeTrip.phase != RideTripPhase.completed) {
      return _TerminalTripStateView(
        phase: activeTrip.phase,
        destination: rideDraft.destinationQuery.trim(),
        onBackToHome: () {
          // Archive trip to history before clearing (Ticket #96)
          final controller = ref.read(rideTripSessionProvider.notifier);
          controller.archiveTrip(
            destinationLabel: rideDraft.destinationQuery.isNotEmpty
                ? rideDraft.destinationQuery
                : (rideDraft.destinationPlace?.label ?? ''),
          );
          controller.clear();
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        onRequestNewRide: () {
          // Archive trip to history before clearing (Ticket #96)
          final controller = ref.read(rideTripSessionProvider.notifier);
          controller.archiveTrip(
            destinationLabel: rideDraft.destinationQuery.isNotEmpty
                ? rideDraft.destinationQuery
                : (rideDraft.destinationPlace?.label ?? ''),
          );
          controller.clear();
          Navigator.of(context).pushReplacementNamed(RoutePaths.rideDestination);
        },
      );
    }

    // Design Tokens (Track B - Ticket #88)
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: colorScheme.surface.withValues(alpha: 0), // DS: transparent
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(DWSpacing.xs), // DS: 8pt
            decoration: BoxDecoration(
              color: colorScheme.surface, // DS: color.surface.default
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: DWSpacing.xs, // DS: 8pt
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back,
              color: colorScheme.onSurface, // DS: color.text.primary
              size: 20,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
          padding: EdgeInsets.symmetric(
            horizontal: DWSpacing.md, // DS: 16pt
            vertical: DWSpacing.xs, // DS: 8pt
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface, // DS: color.surface.default
            borderRadius: BorderRadius.circular(DWRadius.lg), // DS: 24pt
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: DWSpacing.xs, // DS: 8pt
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

  /// Uses domain helper to determine if driver marker should be shown.
  /// Track B - Ticket #89: FSM Integration
  bool _shouldShowDriverMarker(RideTripPhase phase) {
    // Driver marker shown when trip is "active" (driver involved)
    // Using domain helper: isActiveTrip covers findingDriver, driverAccepted, 
    // driverArrived, inProgress. We exclude findingDriver for marker.
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

    // Design Tokens (Track B - Ticket #88)
    return Container(
      margin: EdgeInsets.all(DWSpacing.md), // DS: 16pt
      decoration: BoxDecoration(
        color: colorScheme.surface, // DS: color.surface.default
        borderRadius: BorderRadius.circular(DWRadius.lg), // DS: 24pt
        boxShadow: [
          BoxShadow(
            blurRadius: DWSpacing.md, // DS: 16pt
            offset: const Offset(0, -4),
            color: colorScheme.shadow.withValues(alpha: 0.15),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            DWSpacing.lg, // DS: 24pt - left
            DWSpacing.lg, // DS: 24pt - top
            DWSpacing.lg, // DS: 24pt - right
            DWSpacing.lg, // DS: 24pt - bottom
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: DWSpacing.md), // DS: 16pt
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(DWRadius.circle), // DS: pill
                  ),
                ),
              ),

              // Status/ETA headline (type.headline.h2 style)
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(DWSpacing.sm), // DS: 12pt
                    decoration: BoxDecoration(
                      color: _phaseColor(colorScheme, activeTrip.phase)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(DWRadius.md), // DS: 12pt
                    ),
                    child: Icon(
                      _phaseIcon(activeTrip.phase),
                      color: _phaseColor(colorScheme, activeTrip.phase),
                      size: 24,
                    ),
                  ),
                  SizedBox(width: DWSpacing.sm), // DS: 12pt
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // DS: type.headline.h2 (24pt Bold)
                        Text(
                          headline,
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (subtitle.isNotEmpty) ...[
                          SizedBox(height: DWSpacing.xxs), // DS: 4pt
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: colorScheme.error, // DS: color.state.error
                              ),
                              SizedBox(width: DWSpacing.xxs), // DS: 4pt
                              Expanded(
                                // DS: type.body.regular (14pt)
                                child: Text(
                                  subtitle,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant, // DS: color.text.secondary
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

              SizedBox(height: DWSpacing.lg), // DS: 24pt

              // Driver info card (elevated surface)
              Container(
                padding: EdgeInsets.all(DWSpacing.sm), // DS: 12pt
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest, // DS: color.surface.elevated
                  borderRadius: BorderRadius.circular(DWRadius.md), // DS: 12pt
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
                    SizedBox(width: DWSpacing.sm), // DS: 12pt

                    // Driver details (type.title.default + type.subtitle.default)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // DS: type.title.default (18pt Medium)
                          Text(
                            'Ahmad M.', // TODO: Real driver name from domain model
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: DWSpacing.xxs), // DS: 4pt
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 16,
                                color: colorScheme.tertiary, // DS: use theme tertiary
                              ),
                              SizedBox(width: DWSpacing.xxs), // DS: 4pt
                              // DS: type.body.regular (14pt)
                              Text(
                                '4.9', // TODO: Real rating from domain model
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: DWSpacing.sm), // DS: 12pt
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: colorScheme.onSurfaceVariant,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: DWSpacing.sm), // DS: 12pt
                              Expanded(
                                // DS: type.subtitle.default (16pt)
                                child: Text(
                                  'Toyota Camry', // TODO: Real car model from domain
                                  style: textTheme.titleSmall?.copyWith(
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
                      padding: EdgeInsets.symmetric(
                        horizontal: DWSpacing.sm, // DS: 12pt
                        vertical: DWSpacing.xxs + 2, // DS: ~6pt
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(DWRadius.sm), // DS: 8pt
                        border: Border.all(
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                      child: Text(
                        'ABC 1234', // TODO: Real plate from domain model
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: DWSpacing.lg), // DS: 24pt

            // Primary action buttons row - Tertiary style (Track B - Ticket #68, #88)
            Row(
              children: [
                // Contact driver button (Button/Tertiary)
                Expanded(
                  child: DWButton.tertiary(
                    label: l10n.rideActiveContactDriverCta,
                    onPressed: () => _onContactDriver(context, ref),
                  ),
                ),
                SizedBox(width: DWSpacing.xs), // DS: 8pt
                // Share trip button (Button/Tertiary)
                Expanded(
                  child: DWButton.tertiary(
                    label: l10n.rideActiveShareTripCta,
                    onPressed: () => _onShareTrip(context, ref),
                  ),
                ),
              ],
            ),

            SizedBox(height: DWSpacing.sm), // DS: 12pt

            // Secondary action buttons row (Ticket #62, #67, #88, #95)
            Row(
              children: [
                // Cancel ride button (Button/Tertiary - Track B #22, Ticket #67, #95)
                // Only enabled when phase.isCancellable is true
                Expanded(
                  child: DWButton.tertiary(
                    label: l10n.rideActiveCancelTripCta,
                    onPressed: activeTrip.phase.isCancellable
                        ? () => _onCancelRide(context, ref)
                        : null,
                  ),
                ),
                SizedBox(width: DWSpacing.sm), // DS: 12pt
                // End trip button (Debug/Stub CTA - Ticket #62)
                Expanded(
                  child: DWButton.secondary(
                    label: l10n.rideSummaryEndTripDebugCta,
                    onPressed: () => _onEndTrip(context, ref),
                  ),
                ),
              ],
            ),

            // Debug FSM transition buttons (Ticket #64)
            // Only shown in debug mode for testing FSM transitions
            if (kDebugMode) ...[
              SizedBox(height: DWSpacing.md), // DS: 16pt
              _DebugFsmButtons(
                activeTrip: activeTrip,
                l10n: l10n,
              ),
            ],
          ],
          ),
        ),
      ),
    );
  }

  /// Cancel ride flow with confirmation dialog (Track B - Ticket #67, #95)
  ///
  /// Shows a confirmation dialog before cancelling the ride.
  /// If confirmed, cancels the trip via FSM. The UI will rebuild automatically
  /// showing the Terminal UI for cancelled state (Ticket #95).
  Future<void> _onCancelRide(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Show confirmation dialog (Track B - Ticket #67)
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.rideCancelDialogTitle),
          content: Text(l10n.rideCancelDialogMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.rideCancelDialogKeepRideCta),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              child: Text(l10n.rideCancelDialogConfirmCta),
            ),
          ],
        );
      },
    );

    // User dismissed dialog or chose to keep ride
    if (shouldCancel != true) return;

    // Call FSM cancel method (Track B - Ticket #22, #95)
    final tripController = ref.read(rideTripSessionProvider.notifier);
    final success = await tripController.cancelActiveTrip();

    if (success) {
      // Ticket #95: Don't navigate away. The widget will rebuild
      // automatically showing _TerminalTripStateView for cancelled phase.
      // User can then choose "Back to home" or "Request new ride".
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.rideCancelSuccessSnackbar)),
        );
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

  /// Stub: End trip and navigate to summary (Ticket #62)
  /// This is a Debug/Stub CTA that simulates trip completion.
  /// In production, trip completion will be triggered by the FSM when
  /// the driver marks the trip as completed.
  void _onEndTrip(BuildContext context, WidgetRef ref) {
    final tripController = ref.read(rideTripSessionProvider.notifier);
    
    // Simulate trip completion by applying the complete event
    // Note: FSM requires going through payment phase first, then complete
    tripController.applyEvent(RideTripEvent.startPayment);
    tripController.applyEvent(RideTripEvent.complete);
    
    // Navigation to summary screen is handled by the listener in build()
    // which watches for phase transition to completed
  }

  /// Contact driver flow (Track B - Ticket #68)
  ///
  /// Shows a bottom sheet with driver contact options.
  /// For now, uses mock driver phone. Later can be wired to real data.
  Future<void> _onContactDriver(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Mock driver phone - in production this would come from activeTrip/backend
    // Using the mock driver name "Ahmad M." from the UI, phone is mock too
    const mockDriverPhone = '+966500000000';
    final driverPhone = mockDriverPhone;

    if (!context.mounted) return;

    // Design Tokens (Track B - Ticket #88)
    await showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DWRadius.lg)), // DS: 24pt
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: DWSpacing.md, // DS: 16pt
              vertical: DWSpacing.sm, // DS: 12pt
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: DWSpacing.sm), // DS: 12pt
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(DWRadius.circle), // DS: pill
                  ),
                ),
                // Phone number option
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: Text(driverPhone),
                  subtitle: Text(l10n.rideActiveContactDriverCta),
                  onTap: () {
                    // Stub: In this phase we don't activate real calling (NoOp)
                    // Can be wired to url_launcher via Shim later.
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.rideActiveContactNoPhoneError),
                      ),
                    );
                  },
                ),
                // Copy phone number option
                ListTile(
                  leading: const Icon(Icons.copy_outlined),
                  title: Text('Copy phone number'),
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: driverPhone));
                    Navigator.of(ctx).pop();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.rideActiveShareTripCopied)),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Share trip status flow (Track B - Ticket #68)
  ///
  /// Builds a localized share message from current trip data and
  /// copies it to the clipboard. Later, this can be wired to a Share Shim.
  Future<void> _onShareTrip(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final rideDraft = ref.read(rideDraftProvider);

    if (!context.mounted) return;

    try {
      final destinationLabel = rideDraft.destinationQuery;
      const stubLink = 'https://deliveryways.app/trip/demo123'; // Stub/NoOp link

      final message = l10n.rideActiveShareMessageTemplate(
        destinationLabel.isEmpty ? '...' : destinationLabel,
        stubLink,
      );

      await Clipboard.setData(ClipboardData(text: message));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.rideActiveShareTripCopied)),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.rideActiveShareGenericError)),
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

/// Returns a localized status label for the given FSM phase (Track B - Ticket #66)
///
/// This function maps [RideTripPhase] to L10n status labels (`rideStatus*` keys)
/// for displaying a simple, unified status text on [RideActiveTripScreen].
String _rideStatusLabel(AppLocalizations l10n, RideTripPhase? phase) {
  switch (phase) {
    case RideTripPhase.findingDriver:
      return l10n.rideStatusFindingDriver;
    case RideTripPhase.driverAccepted:
      return l10n.rideStatusDriverAccepted;
    case RideTripPhase.driverArrived:
      return l10n.rideStatusDriverArrived;
    case RideTripPhase.inProgress:
      return l10n.rideStatusInProgress;
    case RideTripPhase.payment:
      return l10n.rideStatusPaymentPending;
    case RideTripPhase.completed:
      return l10n.rideStatusCompleted;
    default:
      return l10n.rideStatusUnknown;
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
/// Uses Design System colors from theme (Track B - Ticket #88)
Color _phaseColor(ColorScheme colorScheme, RideTripPhase phase) {
  switch (phase) {
    case RideTripPhase.draft:
    case RideTripPhase.quoting:
    case RideTripPhase.requesting:
      return colorScheme.secondary; // DS: color.secondary.base
    case RideTripPhase.findingDriver:
      return colorScheme.tertiary; // DS: color.state.success
    case RideTripPhase.driverAccepted:
    case RideTripPhase.driverArrived:
      return colorScheme.primary; // DS: color.primary.base
    case RideTripPhase.inProgress:
      return colorScheme.primary; // DS: color.primary.base
    case RideTripPhase.payment:
      return colorScheme.tertiary; // DS: color.state.success
    case RideTripPhase.completed:
      return colorScheme.tertiary; // DS: color.state.success (instead of hardcoded green)
    case RideTripPhase.cancelled:
      return colorScheme.error; // DS: color.state.error
    case RideTripPhase.failed:
      return colorScheme.error; // DS: color.state.error
  }
}

// ============================================================================
// Debug FSM Buttons (Track B - Ticket #64)
// ============================================================================

/// Debug buttons for testing FSM phase transitions manually.
///
/// Only shown when [kDebugMode] is true.
/// Each button applies the appropriate [RideTripEvent] to advance the FSM.
class _DebugFsmButtons extends ConsumerWidget {
  const _DebugFsmButtons({
    required this.activeTrip,
    required this.l10n,
  });

  final RideTripState activeTrip;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final phase = activeTrip.phase;

    // Build list of available debug actions based on current phase
    final actions = <_DebugAction>[];

    switch (phase) {
      case RideTripPhase.findingDriver:
        actions.add(_DebugAction(
          label: l10n.rideDebugDriverFound,
          event: RideTripEvent.driverAccepted,
          color: colorScheme.primary,
        ));
      case RideTripPhase.driverAccepted:
        actions.add(_DebugAction(
          label: l10n.rideDebugDriverArrived,
          event: RideTripEvent.driverArrived,
          color: colorScheme.primary,
        ));
      case RideTripPhase.driverArrived:
        actions.add(_DebugAction(
          label: l10n.rideDebugStartTrip,
          event: RideTripEvent.startTrip,
          color: colorScheme.tertiary,
        ));
      case RideTripPhase.inProgress:
        actions.add(_DebugAction(
          label: l10n.rideDebugCompleteTrip,
          event: RideTripEvent.startPayment,
          color: Colors.green,
          chainedEvent: RideTripEvent.complete,
        ));
      case RideTripPhase.payment:
        actions.add(_DebugAction(
          label: l10n.rideDebugConfirmPayment,
          event: RideTripEvent.complete,
          color: Colors.green,
        ));
      default:
        // No debug actions for other phases
        break;
    }

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    // Design Tokens (Track B - Ticket #88)
    return Container(
      padding: EdgeInsets.all(DWSpacing.sm), // DS: 12pt
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(DWRadius.md), // DS: 12pt
        border: Border.all(
          color: colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bug_report,
                size: 16,
                color: colorScheme.error,
              ),
              SizedBox(width: DWSpacing.xxs + 2), // ~6pt
              Text(
                l10n.rideDebugFsmTitle,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: DWSpacing.xs), // DS: 8pt
          Text(
            l10n.rideDebugCurrentPhase(phase.name),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: DWSpacing.sm), // DS: 12pt
          Wrap(
            spacing: DWSpacing.xs, // DS: 8pt
            runSpacing: DWSpacing.xs, // DS: 8pt
            children: actions.map((action) {
              return FilledButton.tonal(
                onPressed: () => _applyAction(ref, action),
                style: FilledButton.styleFrom(
                  backgroundColor: action.color.withValues(alpha: 0.2),
                  foregroundColor: action.color,
                  padding: EdgeInsets.symmetric(
                    horizontal: DWSpacing.sm, // DS: 12pt
                    vertical: DWSpacing.xs, // DS: 8pt
                  ),
                ),
                child: Text(
                  action.label,
                  style: const TextStyle(fontSize: 12),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _applyAction(WidgetRef ref, _DebugAction action) {
    final controller = ref.read(rideTripSessionProvider.notifier);
    controller.applyEvent(action.event);
    
    // Apply chained event if present (e.g., startPayment + complete)
    if (action.chainedEvent != null) {
      controller.applyEvent(action.chainedEvent!);
    }
  }
}

/// Helper class for debug actions
class _DebugAction {
  const _DebugAction({
    required this.label,
    required this.event,
    required this.color,
    this.chainedEvent,
  });

  final String label;
  final RideTripEvent event;
  final Color color;
  final RideTripEvent? chainedEvent;
}

// ============================================================================
// Terminal Trip State View (Track B - Ticket #95)
// ============================================================================

/// Full-screen view shown when trip reaches a terminal phase (cancelled/failed).
///
/// Displays:
/// - Status icon (error/cancel)
/// - Title/body text explaining what happened
/// - CTAs to go back to home or request a new ride
///
/// Track B - Ticket #95: Cancel & Failure Flows
class _TerminalTripStateView extends StatelessWidget {
  const _TerminalTripStateView({
    required this.phase,
    required this.destination,
    required this.onBackToHome,
    required this.onRequestNewRide,
  });

  final RideTripPhase phase;
  final String destination;
  final VoidCallback onBackToHome;
  final VoidCallback onRequestNewRide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final isCancelled = phase == RideTripPhase.cancelled;
    final isFailed = phase == RideTripPhase.failed;

    // Determine icon, color, and texts based on phase
    final IconData icon;
    final Color iconColor;
    final String title;
    final String body;

    if (isCancelled) {
      icon = Icons.cancel_outlined;
      iconColor = colorScheme.error;
      title = l10n.rideActiveCancelledTitle;
      body = l10n.rideActiveCancelledBody;
    } else if (isFailed) {
      icon = Icons.error_outline;
      iconColor = colorScheme.error;
      title = l10n.rideActiveFailedTitle;
      body = l10n.rideActiveFailedBody;
    } else {
      // Fallback for other terminal phases (completed - should not reach here)
      icon = Icons.check_circle_outline;
      iconColor = colorScheme.tertiary;
      title = l10n.rideActiveHeadlineCompleted;
      body = '';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.rideActiveAppBarTitle,
          style: textTheme.titleLarge,
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(DWSpacing.lg), // DS: 24pt
          child: Column(
            children: [
              // Spacer to push content towards center
              const Spacer(flex: 2),

              // Icon
              Container(
                padding: EdgeInsets.all(DWSpacing.lg), // DS: 24pt
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 64,
                  color: iconColor,
                ),
              ),

              SizedBox(height: DWSpacing.lg), // DS: 24pt

              // Title (type.headline.h2)
              Text(
                title,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: DWSpacing.sm), // DS: 12pt

              // Body (type.body.regular)
              Text(
                body,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              // Show destination if available
              if (destination.isNotEmpty) ...[
                SizedBox(height: DWSpacing.md), // DS: 16pt
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: DWSpacing.md, // DS: 16pt
                    vertical: DWSpacing.sm, // DS: 12pt
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(DWRadius.md), // DS: 12pt
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: DWSpacing.xs), // DS: 8pt
                      Flexible(
                        child: Text(
                          destination,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Spacer
              const Spacer(flex: 3),

              // CTAs
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Primary CTA: Request new ride (for cancelled/failed)
                  if (isCancelled || isFailed)
                    DWButton.primary(
                      label: l10n.rideActiveRequestNewRideCta,
                      onPressed: onRequestNewRide,
                    ),

                  SizedBox(height: DWSpacing.sm), // DS: 12pt

                  // Secondary CTA: Back to home
                  DWButton.secondary(
                    label: l10n.rideActiveBackToHomeCta,
                    onPressed: onBackToHome,
                  ),
                ],
              ),

              SizedBox(height: DWSpacing.md), // DS: 16pt
            ],
          ),
        ),
      ),
    );
  }
}

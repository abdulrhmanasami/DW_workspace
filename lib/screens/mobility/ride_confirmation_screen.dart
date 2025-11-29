/// Ride Trip Confirmation Screen - Track B Ticket #7
/// Purpose: UI-only Trip Confirmation for Ride vertical (Screen 9)
/// Created by: Track B - Ticket #7
/// Updated by: Track B - Ticket #9 (RideDraftUiState integration)
/// Updated by: Track B - Ticket #12 (RideTrip FSM integration)
/// Updated by: Track B - Ticket #14 (RideQuote integration)
/// Updated by: Ticket #26 (Robust quote states: Loading/Error/Empty)
/// Last updated: 2025-11-28
///
/// This screen provides the Ride trip confirmation interface with:
/// - Map stub (placeholder for future maps_shims integration)
/// - Vehicle options list (dynamic from RideQuoteService)
/// - Payment method card (stub)
/// - Request Ride CTA button
/// - Trip status display (FSM phase)
/// - Robust Loading/Error/Empty states for quote fetching (Ticket #26)
///
/// NOTE: Uses MockRideQuoteService - real backend integration pending.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Canonical types from shims packages (Track B - Ticket #28)
import 'package:maps_shims/maps_shims.dart';
import 'package:mobility_shims/mobility_shims.dart';
import 'package:design_system_shims/design_system_shims.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../router/app_router.dart';
import '../../state/mobility/ride_draft_state.dart';
import '../../state/mobility/ride_trip_session.dart';
import '../../state/mobility/ride_quote_controller.dart';

/// UI-only model for ride options (maps from domain RideQuoteOption)
class RideOptionUiModel {
  const RideOptionUiModel({
    required this.id,
    required this.title,
    required this.description,
    required this.etaText,
    required this.priceText,
    required this.isRecommended,
  });

  final String id;
  final String title;
  final String description;
  final String etaText;
  final String priceText;
  final bool isRecommended;
}

/// RideConfirmationScreen - Trip confirmation with vehicle options
class RideConfirmationScreen extends ConsumerWidget {
  const RideConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // Read ride draft state
    final rideDraft = ref.watch(rideDraftProvider);

    // Read trip session state (FSM)
    final tripSession = ref.watch(rideTripSessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.rideConfirmTitle,
          style: textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Map with route preview (Track B - Ticket #28)
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.only(bottom: 260),
              child: _ConfirmationMap(rideDraft: rideDraft),
            ),
          ),

          // Confirmation sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                    color: colorScheme.shadow.withValues(alpha: 0.1),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: _RideConfirmationSheet(
                destinationLabel: rideDraft.destinationQuery,
                selectedOptionId: rideDraft.selectedOptionId,
                activeTrip: tripSession.activeTrip,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet content with vehicle options and CTA
class _RideConfirmationSheet extends ConsumerStatefulWidget {
  const _RideConfirmationSheet({
    required this.destinationLabel,
    required this.selectedOptionId,
    required this.activeTrip,
  });

  final String destinationLabel;
  final String? selectedOptionId;
  final RideTripState? activeTrip;

  @override
  ConsumerState<_RideConfirmationSheet> createState() =>
      _RideConfirmationSheetState();
}

class _RideConfirmationSheetState extends ConsumerState<_RideConfirmationSheet> {
  @override
  void initState() {
    super.initState();
    // Request quote once when the screen opens
    Future.microtask(() {
      final draft = ref.read(rideDraftProvider);
      ref.read(rideQuoteControllerProvider.notifier).refreshFromDraft(draft);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // Watch quote state
    final quoteState = ref.watch(rideQuoteControllerProvider);
    final rideDraft = ref.watch(rideDraftProvider);
    final activeTrip = widget.activeTrip;

    // Build UI options from quote
    final options = _buildUiOptions(
      l10n: l10n,
      quoteState: quoteState,
    );

    // Effective selected option: use state or fallback to first option
    final effectiveSelectedId = rideDraft.selectedOptionId ??
        (options.isNotEmpty ? options.first.id : null);

    // Ticket #26: Derive quote states for robust UI handling
    // Note: RideQuote domain model enforces options.isNotEmpty via assertion
    // so isEmpty only applies when quote is null (no response yet)
    final isLoading = quoteState.isLoading;
    final hasError = quoteState.hasError;
    final hasQuote = quoteState.hasQuote;
    final hasOptions = hasQuote && options.isNotEmpty;
    // Empty state: not loading, no error, but also no quote (rare edge case)
    final isEmptyState = !isLoading && !hasError && !hasQuote;

    // Can request ride only when:
    // - Not loading
    // - Has a valid quote with options
    // - Has a selected option
    // - No active trip
    // - No error
    final canRequestRide = !isLoading &&
        !hasError &&
        hasOptions &&
        effectiveSelectedId != null &&
        activeTrip == null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Drag handle
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),

        // Trip status chip (when active trip exists)
        if (activeTrip != null) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _phaseColor(colorScheme, activeTrip.phase),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _phaseIcon(activeTrip.phase),
                    size: 14,
                    color: colorScheme.onPrimary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _phaseLabel(l10n, activeTrip.phase),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Title & subtitle with destination
        Text(
          l10n.rideConfirmSheetTitle,
          style: textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        if (widget.destinationLabel.trim().isNotEmpty) ...[
          // Show trip summary with destination
          Row(
            children: [
              Icon(
                Icons.circle,
                size: 8,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.rideBookingPickupCurrentLocation,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 12,
                color: colorScheme.error,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.destinationLabel.trim(),
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ] else
          Text(
            l10n.rideConfirmSheetSubtitle,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        const SizedBox(height: 16),

        // Ticket #26: Robust quote state handling
        // 1. Loading state
        if (isLoading && !hasOptions) ...[
          _QuoteLoadingCard(l10n: l10n, textTheme: textTheme, colorScheme: colorScheme),
        ]
        // 2. Error state
        else if (hasError) ...[
          _QuoteErrorCard(
            l10n: l10n,
            textTheme: textTheme,
            colorScheme: colorScheme,
            onRetry: () {
              final draft = ref.read(rideDraftProvider);
              ref
                  .read(rideQuoteControllerProvider.notifier)
                  .refreshFromDraft(draft);
            },
          ),
        ]
        // 3. Empty state (no quote received - edge case)
        else if (isEmptyState) ...[
          _QuoteEmptyCard(l10n: l10n, textTheme: textTheme, colorScheme: colorScheme),
        ]
        // 4. Success state (vehicle options available)
        else if (hasOptions) ...[
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                return _RideOptionCard(
                  option: option,
                  isSelected: effectiveSelectedId != null &&
                      option.id == effectiveSelectedId,
                  onSelected: () {
                    ref
                        .read(rideDraftProvider.notifier)
                        .updateSelectedOption(option.id);
                  },
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 16),

        // Payment method (stub)
        _PaymentMethodCard(
          label: l10n.rideConfirmPaymentLabel,
          value: l10n.rideConfirmPaymentStubValue,
        ),
        const SizedBox(height: 16),

        // Request button
        SizedBox(
          width: double.infinity,
          child: DWButton.primary(
            label: activeTrip != null
                ? _phaseLabel(l10n, activeTrip.phase)
                : l10n.rideConfirmPrimaryCta,
            onPressed: !canRequestRide
                ? null
                : () {
                    final destination = rideDraft.destinationQuery.trim();

                    if (destination.isEmpty) {
                      // Safety check (BookingScreen should prevent this)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(l10n.rideBookingDestinationHint)),
                      );
                      return;
                    }

                    // Start trip session from draft (uses FSM)
                    ref
                        .read(rideTripSessionProvider.notifier)
                        .startFromDraft(rideDraft);

                    // Show confirmation message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(l10n.rideConfirmRequestedStubMessage)),
                    );

                    // Navigate to active trip screen
                    Navigator.of(context).pushNamed(RoutePaths.rideActive);
                  },
          ),
        ),
      ],
    );
  }
}

/// Converts RideQuote options to UI models
List<RideOptionUiModel> _buildUiOptions({
  required AppLocalizations l10n,
  required RideQuoteUiState quoteState,
}) {
  final quote = quoteState.quote;
  if (quote == null) return const [];

  return quote.options.map((o) {
    final String subtitle;
    switch (o.category) {
      case RideVehicleCategory.economy:
        subtitle = l10n.rideConfirmOptionEconomySubtitle;
      case RideVehicleCategory.xl:
        subtitle = l10n.rideConfirmOptionXlSubtitle;
      case RideVehicleCategory.premium:
        subtitle = l10n.rideConfirmOptionPremiumSubtitle;
    }

    final etaText = l10n.rideConfirmOptionEtaFormat(o.etaMinutes.toString());
    final priceText = l10n.rideConfirmOptionPriceApprox(o.formattedPrice);

    return RideOptionUiModel(
      id: o.id,
      title: o.displayName,
      description: subtitle,
      etaText: etaText,
      priceText: priceText,
      isRecommended: o.isRecommended,
    );
  }).toList();
}

/// Vehicle option card widget
class _RideOptionCard extends StatelessWidget {
  const _RideOptionCard({
    required this.option,
    required this.isSelected,
    required this.onSelected,
  });

  final RideOptionUiModel option;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          Icons.directions_car_filled,
          color:
              isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
        title: Text(
          option.title,
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          option.description,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              option.priceText,
              style: textTheme.titleMedium?.copyWith(
                color: isSelected ? colorScheme.primary : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              option.etaText,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        onTap: onSelected,
      ),
    );
  }
}

/// Payment method card widget (stub)
class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(Icons.payment_outlined, color: colorScheme.primary),
        title: Text(label, style: textTheme.bodyLarge),
        subtitle: Text(
          value,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_right,
          color: colorScheme.onSurfaceVariant,
        ),
        onTap: () {
          // TODO(Track B/C later): Open payment method selection from payments shim
        },
      ),
    );
  }
}

// ============================================================================
// Quote State Cards (Ticket #26)
// ============================================================================

/// Loading state card shown while fetching ride options
class _QuoteLoadingCard extends StatelessWidget {
  const _QuoteLoadingCard({
    required this.l10n,
    required this.textTheme,
    required this.colorScheme,
  });

  final AppLocalizations l10n;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.rideConfirmLoadingTitle,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.rideConfirmLoadingSubtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Error state card shown when quote loading fails
class _QuoteErrorCard extends StatelessWidget {
  const _QuoteErrorCard({
    required this.l10n,
    required this.textTheme,
    required this.colorScheme,
    required this.onRetry,
  });

  final AppLocalizations l10n;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: colorScheme.errorContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 32,
              color: colorScheme.error,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.rideConfirmErrorTitle,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.rideConfirmErrorSubtitle,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            DWButton.secondary(
              label: l10n.rideConfirmRetryCta,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state card shown when no ride options are available
class _QuoteEmptyCard extends StatelessWidget {
  const _QuoteEmptyCard({
    required this.l10n,
    required this.textTheme,
    required this.colorScheme,
  });

  final AppLocalizations l10n;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 40,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.rideConfirmEmptyTitle,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.rideConfirmEmptySubtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// FSM Phase Helpers
// ============================================================================

/// Returns a human-readable label for the given trip phase.
String _phaseLabel(AppLocalizations l10n, RideTripPhase phase) {
  switch (phase) {
    case RideTripPhase.draft:
      return l10n.ridePhaseDraftLabel;
    case RideTripPhase.quoting:
      return l10n.ridePhaseQuotingLabel;
    case RideTripPhase.requesting:
      return l10n.ridePhaseRequestingLabel;
    case RideTripPhase.findingDriver:
      return l10n.ridePhaseFindingDriverLabel;
    case RideTripPhase.driverAccepted:
      return l10n.ridePhaseDriverAcceptedLabel;
    case RideTripPhase.driverArrived:
      return l10n.ridePhaseDriverArrivedLabel;
    case RideTripPhase.inProgress:
      return l10n.ridePhaseInProgressLabel;
    case RideTripPhase.payment:
      return l10n.ridePhasePaymentLabel;
    case RideTripPhase.completed:
      return l10n.ridePhaseCompletedLabel;
    case RideTripPhase.cancelled:
      return l10n.ridePhaseCancelledLabel;
    case RideTripPhase.failed:
      return l10n.ridePhaseFailedLabel;
  }
}

/// Returns an appropriate icon for the given trip phase.
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

// ============================================================================
// Map Widget (Track B - Ticket #28)
// ============================================================================

/// Map widget showing route between pickup and destination.
class _ConfirmationMap extends StatelessWidget {
  const _ConfirmationMap({required this.rideDraft});

  final RideDraftUiState rideDraft;

  @override
  Widget build(BuildContext context) {
    // Build map config using domain helper (Track B - Ticket #28)
    final mapConfig = buildDestinationPreviewMap(
      pickup: rideDraft.pickupPlace,
      destination: rideDraft.destinationPlace,
    );

    return MapWidget(
      initialPosition: mapConfig.cameraTarget,
      markers: mapConfig.markers,
      polylines: mapConfig.polylines,
    );
  }
}

/// Returns an appropriate background color for the phase chip.
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

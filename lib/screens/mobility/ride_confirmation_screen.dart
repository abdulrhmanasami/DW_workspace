/// Ride Trip Confirmation Screen - Track B Ticket #7
/// Purpose: UI-only Trip Confirmation for Ride vertical (Screen 9)
/// Created by: Track B - Ticket #7
/// Updated by: Track B - Ticket #9 (RideDraftUiState integration)
/// Updated by: Track B - Ticket #12 (RideTrip FSM integration)
/// Updated by: Track B - Ticket #14 (RideQuote integration)
/// Updated by: Ticket #26 (Robust quote states: Loading/Error/Empty)
/// Updated by: Track B - Ticket #100 (Payment method integration)
/// Updated by: Track B - Ticket #101 (Link payment method to RideDraft)
/// Updated by: Track B - Ticket #112 (Map from RideMapCommands state)
/// Updated by: Track B - Ticket #113 (Request Ride CTA -> Active Trip navigation)
/// Updated by: Track B - Ticket #121 (RideQuoteError + InlineNotice/EmptyState)
/// Updated by: Track B - Ticket #207 (Unified map integration with RideTripMapView)
/// Last updated: 2025-12-03
///
/// This screen provides the Ride trip confirmation interface with:
/// - Map via RideTripMapView (from unified session state - mapStage/mapSnapshot)
/// - Vehicle options list (dynamic from RideQuoteService)
/// - Payment method section (from PaymentMethodsUiState)
/// - Request Ride CTA button (calls startFromDraft + navigates to Active Trip)
/// - Trip status display (FSM phase)
/// - Robust Loading/Error/Empty states for quote fetching (Ticket #26)
///
/// Track B - Ticket #113: Happy Path Flow:
/// 1. User presses "Request Ride" CTA
/// 2. Payment method is linked to draft (Ticket #101)
/// 3. startFromDraft is called on RideTripSessionController
/// 4. FSM transitions: draft -> quoting -> requesting -> findingDriver
/// 5. Navigation to Active Trip screen (RoutePaths.rideActive)
///
/// NOTE: Uses MockRideQuoteService - real backend integration pending.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Canonical types from shims packages (Track B - Ticket #28)
import 'package:mobility_shims/mobility_shims.dart';
import 'package:design_system_shims/design_system_shims.dart';
import 'package:pricing_shims/pricing_shims.dart' as pricing;

import '../../l10n/generated/app_localizations.dart';
import '../../router/app_router.dart';
import '../../state/mobility/ride_draft_state.dart';
import '../../state/mobility/ride_trip_session.dart';
// Track B - Ticket #100: Payment method integration
import '../../state/payments/payment_methods_ui_state.dart';
// Track B - Ticket #207: Use RideTripMapView for unified map integration
import '../../widgets/mobility/ride_trip_map_view.dart';
// Track B - Ticket #141: Use RideQuoteOptionsSheet
import 'ride_quote_options_sheet.dart';

/// RideConfirmationScreen - Trip confirmation with vehicle options
class RideConfirmationScreen extends ConsumerWidget {
  const RideConfirmationScreen({super.key});

  // Keys for UI testing
  static const vehicleListKey = Key('ride_confirmation_vehicle_list');
  static const paymentMethodCardKey = Key('ride_confirmation_payment_method_card');
  static const ctaRequestRideKey = Key('ride_confirmation_cta_request_ride');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // Read ride draft state
    final rideDraft = ref.watch(rideDraftProvider);

    // Read trip session state (FSM + Pricing)
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
          // Map Area (Screen 9 - top ~50% of screen)
          // Track B - Ticket #207: Use RideTripMapView for unified map integration
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.only(bottom: 260),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(DWRadius.md),
                child: const RideTripMapView(),
              ),
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
                tripSession: tripSession,
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
    required this.tripSession,
  });

  final String destinationLabel;
  final String? selectedOptionId;
  final RideTripState? activeTrip;
  final RideTripSessionUiState tripSession;

  @override
  ConsumerState<_RideConfirmationSheet> createState() =>
      _RideConfirmationSheetState();
}

class _RideConfirmationSheetState extends ConsumerState<_RideConfirmationSheet> {
  @override
  void initState() {
    super.initState();
    // Track B - Ticket #212: Prepare confirmation by saving draft and requesting quote
    Future.microtask(() {
      final draft = ref.read(rideDraftProvider);
      ref.read(rideTripSessionProvider.notifier).prepareConfirmation(draft);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // Track B - Ticket #212: Read pricing state from session
    final rideDraft = ref.watch(rideDraftProvider);
    final activeTrip = widget.activeTrip;

    // Get pricing state from session
    final tripSession = widget.tripSession;
    final isQuoting = tripSession.isQuoting;
    final activeQuote = tripSession.activeQuote;
    final lastQuoteFailure = tripSession.lastQuoteFailure;
    
    // Track B - Ticket #212: Get quote and selected option from session
    final quote = activeQuote;

    // Effective selected option: use state or fallback to first option
    final effectiveSelectedId = rideDraft.selectedOptionId ??
        (quote != null && quote.options.isNotEmpty ? quote.options.first.id : null);

    final selectedOption = quote != null && quote.options.isNotEmpty
        ? quote.options.firstWhere(
            (opt) => opt.id == effectiveSelectedId,
            orElse: () => quote.options.first,
          )
        : null;

    // Track B - Ticket #212: Derive pricing states for robust UI handling
    final hasError = lastQuoteFailure != null;
    final hasQuote = activeQuote != null;
    final hasOptions = hasQuote && (quote?.options.isNotEmpty ?? false);
    // Empty state: not quoting, no error, but also no quote (rare edge case)
    final isEmptyState = !isQuoting && !hasError && !hasQuote;

    // Can request ride only when:
    // - Not quoting
    // - Has a valid quote with options
    // - Has a selected option
    // - No active trip
    // - No error
    final canRequestRide = !isQuoting &&
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

        // Track B - Ticket #212: Robust pricing state handling
        // 1. Loading state (quoting in progress)
        if (isQuoting && !hasOptions) ...[
          _QuoteLoadingCard(l10n: l10n, textTheme: textTheme, colorScheme: colorScheme),
        ]
        // 2. Error state (pricing failure)
        else if (hasError) ...[
          _PricingErrorCard(
            l10n: l10n,
            textTheme: textTheme,
            colorScheme: colorScheme,
            failureReason: lastQuoteFailure,
            onRetry: () {
              final draft = ref.read(rideDraftProvider);
              ref.read(rideTripSessionProvider.notifier).prepareConfirmation(draft);
            },
          ),
        ]
        // 3. Empty state (no quote received - edge case)
        else if (isEmptyState) ...[
          _QuoteEmptyCard(l10n: l10n, textTheme: textTheme, colorScheme: colorScheme),
        ]
        // 4. Success state (vehicle options available)
        else if (hasOptions && quote != null) ...[
          Flexible(
            child: RideQuoteOptionsSheet(
              quote: quote,
              selectedOption: selectedOption,
              onOptionSelected: (option) {
                ref
                    .read(rideDraftProvider.notifier)
                    .updateSelectedOption(option.id);
              },
              showHandle: false, // Not a bottom sheet
              vehicleListKey: RideConfirmationScreen.vehicleListKey,
            ),
          ),
        ],
        const SizedBox(height: 16),

        // Payment method section (Track B - Ticket #100)
        _PaymentMethodSection(l10n: l10n),
        const SizedBox(height: 16),

        // Request button
        SizedBox(
          width: double.infinity,
          child: DWButton.primary(
            key: RideConfirmationScreen.ctaRequestRideKey,
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

                    // Track B - Ticket #101: Link selected payment method to draft
                    // before starting the trip session.
                    final paymentsState = ref.read(paymentMethodsUiProvider);
                    final selectedPaymentMethod = paymentsState.selectedMethod;
                    ref
                        .read(rideDraftProvider.notifier)
                        .setPaymentMethodId(selectedPaymentMethod?.id);

                    // Read updated draft with payment method
                    final updatedDraft = ref.read(rideDraftProvider);

                    // Track B - Ticket #212: Get selected option from session pricing state
                    final quote = widget.tripSession.activeQuote;
                    // effectiveSelectedId is guaranteed non-null at this point
                    // (canRequestRide requires it), find option by id or use first option
                    final selectedOpt = quote?.options.firstWhere(
                        (opt) => opt.id == effectiveSelectedId,
                        orElse: () => quote.options.firstWhere(
                          (opt) => opt.isRecommended,
                          orElse: () => quote.options.first,
                        ),
                      );

                    if (selectedOpt == null) {
                      // Should not happen if canRequestRide validation is correct
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.rideQuoteErrorGeneric),
                        ),
                      );
                      return;
                    }

                    // Track B - Ticket #156: Start trip session from quote (Happy Path)
                    // FSM transitions: draft -> quoting -> requesting -> findingDriver
                    // Use startRideFromQuote for cleaner API
                    ref.read(rideTripSessionProvider.notifier).startRideFromQuote(
                          selectedOption: selectedOpt,
                          draft: updatedDraft,
                        );

                    // Track B - Ticket #113: Show confirmation message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(l10n.rideConfirmRequestedStubMessage)),
                    );

                    // Track B - Ticket #113: Navigate to Active Trip screen
                    Navigator.of(context).pushNamed(RoutePaths.rideActive);
                  },
          ),
        ),
      ],
    );
  }
}



/// Payment method section widget
/// Track B - Ticket #100: Shows selected payment method from PaymentMethodsUiState
class _PaymentMethodSection extends ConsumerWidget {
  const _PaymentMethodSection({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    
    // Track B - Ticket #100: Get selected payment method from provider
    final paymentsState = ref.watch(paymentMethodsUiProvider);
    final selectedMethod = paymentsState.selectedMethod;

    // Determine display values
    final displayName = selectedMethod?.displayName ?? l10n.paymentsMethodTypeCash;
    final typeLabel = selectedMethod?.type == PaymentMethodUiType.card
        ? l10n.paymentsMethodTypeCard
        : l10n.paymentsMethodTypeCash;
    final icon = selectedMethod?.type == PaymentMethodUiType.card
        ? Icons.credit_card
        : Icons.payments_outlined;

    return Card(
      key: RideConfirmationScreen.paymentMethodCardKey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: colorScheme.primary),
        title: Text(
          l10n.rideTripConfirmationPaymentSectionTitle,
          style: textTheme.bodyLarge,
        ),
        subtitle: Row(
          children: [
            Text(
              displayName,
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              ' · $typeLabel',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.keyboard_arrow_right,
          color: colorScheme.onSurfaceVariant,
        ),
        onTap: () {
          // Track B - Ticket #100: Tapping navigates to Payments tab
          // For now, show a snackbar indicating the payment method is selected
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$displayName selected'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 1),
            ),
          );
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


/// Empty state card shown when no ride options are available
/// Empty state card shown when no ride options are available
///
/// Track B - Ticket #121: Updated to use new localization keys for
/// empty state messaging.
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
              // Track B - Ticket #121: Use new localization key
              l10n.rideQuoteEmptyTitle,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              // Track B - Ticket #121: Use new localization key
              l10n.rideQuoteEmptyDescription,
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

/// Track B - Ticket #212: Error state card for pricing failures
///
/// Shows appropriate error messages based on RideQuoteFailureReason.
class _PricingErrorCard extends StatelessWidget {
  const _PricingErrorCard({
    required this.l10n,
    required this.textTheme,
    required this.colorScheme,
    required this.failureReason,
    required this.onRetry,
  });

  final AppLocalizations l10n;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final pricing.RideQuoteFailureReason failureReason;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    // Track B - Ticket #212: Map failure reason to localized message
    final (errorTitle, errorMessage) = _mapFailureToMessages(failureReason, l10n);

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
              errorTitle,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              errorMessage,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            DWButton.secondary(
              label: l10n.rideQuoteRetryCta,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }

  /// Maps RideQuoteFailureReason to localized title and message.
  (String, String) _mapFailureToMessages(
      pricing.RideQuoteFailureReason reason, AppLocalizations l10n) {
    return switch (reason) {
      pricing.RideQuoteFailureReason.networkError => (
          l10n.rideConfirmErrorTitle,
          'حدث خطأ في الاتصال، حاول مرة أخرى'
        ),
      pricing.RideQuoteFailureReason.invalidRequest => (
          l10n.rideQuoteErrorTitle,
          l10n.rideConfirmErrorSubtitle
        ),
      _ => (
          l10n.rideConfirmErrorTitle,
          l10n.rideConfirmErrorSubtitle
        ),
    };
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

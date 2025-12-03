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
/// Last updated: 2025-12-01
///
/// This screen provides the Ride trip confirmation interface with:
/// - Map via RideMapCommands (from session state or draft state)
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

import '../../l10n/generated/app_localizations.dart';
import '../../router/app_router.dart';
import '../../state/mobility/ride_draft_state.dart';
import '../../state/mobility/ride_trip_session.dart';
import '../../state/mobility/ride_quote_controller.dart';
import '../../state/mobility/ride_map_commands_builder.dart';
// Track B - Ticket #100: Payment method integration
import '../../state/payments/payment_methods_ui_state.dart';
// Track B - Ticket #112: Map from RideMapCommands
import '../../widgets/ride_map_from_commands.dart';
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
          // Map Area (Screen 9 - top ~50% of screen)
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.only(bottom: 260),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(DWRadius.md),
                child: _ConfirmationMap(rideDraft: rideDraft),
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

    // Get the quote and options directly from domain model
    final quote = quoteState.quote;
    
    // Effective selected option: use state or fallback to first option
    final effectiveSelectedId = rideDraft.selectedOptionId ??
        (quote != null && quote.options.isNotEmpty ? quote.options.first.id : null);
    
    final selectedOption = quote != null && quote.options.isNotEmpty
        ? quote.options.firstWhere(
            (opt) => opt.id == effectiveSelectedId,
            orElse: () => quote.options.first,
          )
        : null;

    // Ticket #26: Derive quote states for robust UI handling
    // Note: RideQuote domain model enforces options.isNotEmpty via assertion
    // so isEmpty only applies when quote is null (no response yet)
    final isLoading = quoteState.isLoading;
    final hasError = quoteState.hasError;
    final hasQuote = quoteState.hasQuote;
    final hasOptions = hasQuote && (quote?.options.isNotEmpty ?? false);
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

        // Ticket #26 + #121: Robust quote state handling with structured errors
        // 1. Loading state
        if (isLoading && !hasOptions) ...[
          _QuoteLoadingCard(l10n: l10n, textTheme: textTheme, colorScheme: colorScheme),
        ]
        // 2. Error state (Track B - Ticket #121: Use structured RideQuoteError)
        else if (hasError) ...[
          _QuoteErrorCard(
            l10n: l10n,
            textTheme: textTheme,
            colorScheme: colorScheme,
            error: quoteState.error,
            onRetry: () {
              final draft = ref.read(rideDraftProvider);
              ref
                  .read(rideQuoteControllerProvider.notifier)
                  .retryFromDraft(draft);
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

                    // Track B - Ticket #105: Get selected option for trip summary
                    final quoteState = ref.read(rideQuoteControllerProvider);
                    final quote = quoteState.quote;
                    // effectiveSelectedId is guaranteed non-null at this point
                    // (canRequestRide requires it), but quote.optionById may return null
                    final selectedOpt = quote == null
                        ? null
                        : quote.optionById(effectiveSelectedId) ??
                            quote.recommendedOption;

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

/// Error state card shown when quote loading fails
///
/// Track B - Ticket #121: Updated to use structured [RideQuoteError] and
/// new localization keys for granular error messages.
class _QuoteErrorCard extends StatelessWidget {
  const _QuoteErrorCard({
    required this.l10n,
    required this.textTheme,
    required this.colorScheme,
    required this.onRetry,
    this.error,
  });

  final AppLocalizations l10n;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final VoidCallback onRetry;
  final RideQuoteError? error;

  @override
  Widget build(BuildContext context) {
    // Track B - Ticket #121: Map error type to localized message
    final errorMessage = _mapErrorToMessage(error, l10n);
    final errorTitle = _mapErrorToTitle(error, l10n);

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

  /// Maps [RideQuoteError] to a localized title.
  String _mapErrorToTitle(RideQuoteError? error, AppLocalizations l10n) {
    if (error == null) return l10n.rideConfirmErrorTitle;

    return switch (error) {
      RideQuoteErrorNoOptionsAvailable() => l10n.rideQuoteEmptyTitle,
      RideQuoteErrorPricingFailed() => l10n.rideQuoteErrorTitle,
      RideQuoteErrorUnexpected() => l10n.rideConfirmErrorTitle,
    };
  }

  /// Maps [RideQuoteError] to a localized message.
  String _mapErrorToMessage(RideQuoteError? error, AppLocalizations l10n) {
    if (error == null) return l10n.rideConfirmErrorSubtitle;

    return switch (error) {
      RideQuoteErrorNoOptionsAvailable() => l10n.rideQuoteErrorNoOptions,
      RideQuoteErrorPricingFailed() => l10n.rideQuoteErrorGeneric,
      RideQuoteErrorUnexpected() => l10n.rideConfirmErrorSubtitle,
    };
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
// Map Widget (Track B - Ticket #28, Updated: Ticket #112)
// ============================================================================

/// Map widget showing route between pickup and destination.
///
/// Track B - Ticket #112: Now uses RideMapCommands from state when available,
/// with fallback to draft-based commands for backward compatibility.
class _ConfirmationMap extends ConsumerWidget {
  const _ConfirmationMap({required this.rideDraft});

  final RideDraftUiState rideDraft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Track B - Ticket #112: Try to get map commands from session state first
    final tripSession = ref.watch(rideTripSessionProvider);
    final sessionCommands = tripSession.draftMapCommands;

    // If session has draftSnapshot (via startFromDraft), use it
    if (sessionCommands != null) {
      return RideMapFromCommands(commands: sessionCommands);
    }

    // Fallback: Build commands directly from current draft
    // This handles the case before trip starts (no frozen snapshot yet)
    final draftCommands = buildDraftMapCommands(rideDraft);

    // If commands have markers, show the map
    if (draftCommands.setContent.markers.isNotEmpty) {
      return RideMapFromCommands(commands: draftCommands);
    }

    // No location data: show placeholder without loading indicator
    // (to avoid duplicate spinners with quote loading card)
    return const RideMapPlaceholder(
      showLoadingIndicator: false,
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

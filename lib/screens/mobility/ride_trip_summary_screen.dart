/// Ride Trip Summary Screen - Track B Ticket #23, #62, #63, #92, #96, #98, #107, #118, #124
/// Purpose: Display trip summary/receipt with driver rating
/// Created by: Track B - Ticket #23
/// Updated by: Track B - Ticket #62 (Receipt breakdown, comment field)
/// Updated by: Track B - Ticket #63 (Domain-level pricing integration)
/// Updated by: Ticket #92 (Full receipt UI + Design System Tokens + L10n)
/// Updated by: Ticket #96 (Archive trip to history before clear)
/// Updated by: Ticket #98 (Support viewing history trips from Orders)
/// Updated by: Ticket #107 (Use completionSummary as source of truth)
/// Updated by: Ticket #118 (Use completeCurrentTrip + historyTrips as single source of truth)
/// Updated by: Ticket #124 (Connect driver rating to historyTrips via setRatingForMostRecentTrip)
/// Last updated: 2025-12-01
///
/// This screen shows the trip summary interface (Screen 11 in Hi-Fi Mockups):
/// - Trip completed status header with ID and timestamp
/// - Route summary (from/to)
/// - Fare/receipt summary with full breakdown
/// - Driver info and rating with 5-star system
/// - Done CTA to return home
///
/// NOTE: Driver rating is stored in-memory via FSM. Backend integration later.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Shims only - no direct SDKs
import 'package:mobility_shims/mobility_shims.dart';
import 'package:design_system_shims/design_system_shims.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../widgets/dw_app_shell.dart';
import '../../state/mobility/ride_draft_state.dart';
import '../../state/mobility/ride_trip_session.dart';
import '../../state/mobility/ride_quote_controller.dart';
// Track B - Ticket #107: Payment method integration for completion summary
import '../../state/payments/payment_methods_ui_state.dart';

/// Arguments for navigating to RideTripSummaryScreen from history
/// Track B - Ticket #98
class RideTripSummaryArgs {
  const RideTripSummaryArgs({this.historyEntry});
  
  final RideHistoryEntry? historyEntry;
}

/// Trip Summary Screen - Shows receipt, driver rating, and Done CTA
/// 
/// Track B - Ticket #98: Now supports two modes:
/// 1. Active trip mode (default): Shows summary for current active trip
/// 2. History mode: Shows summary for a past trip from Orders History
///
/// Track B - Ticket #118: Refactored to use completeCurrentTrip() + historyTrips:
/// - Active trip mode: calls completeCurrentTrip() on init, reads from historyTrips.first
/// - History mode: reads directly from the passed historyEntry (unchanged)
class RideTripSummaryScreen extends ConsumerStatefulWidget {
  const RideTripSummaryScreen({
    super.key,
    this.historyEntry,
  });
  
  /// Optional history entry when viewing from Orders History
  /// Track B - Ticket #98
  final RideHistoryEntry? historyEntry;

  @override
  ConsumerState<RideTripSummaryScreen> createState() => _RideTripSummaryScreenState();
}

class _RideTripSummaryScreenState extends ConsumerState<RideTripSummaryScreen> {
  bool _completedTrip = false;

  @override
  void initState() {
    super.initState();
    // Track B - Ticket #118: Complete the trip on screen open (for active trip mode)
    if (widget.historyEntry == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _completeActiveTripIfNeeded();
      });
    }
  }

  /// Track B - Ticket #118: Complete the active trip and archive it to history
  void _completeActiveTripIfNeeded() {
    if (_completedTrip) return; // Idempotent guard
    
    final sessionState = ref.read(rideTripSessionProvider);
    final controller = ref.read(rideTripSessionProvider.notifier);
    
    // Only complete if there's an active trip
    if (sessionState.activeTrip != null) {
      // Get data from frozen snapshots before completing
      final draftSnapshot = sessionState.draftSnapshot;
      final tripSummary = sessionState.tripSummary;
      
      // Track B - Ticket #118: Get payment method label
      final paymentsState = ref.read(paymentMethodsUiProvider);
      final paymentMethodId = tripSummary?.selectedPaymentMethodId;
      final paymentMethod = paymentMethodId != null
          ? paymentsState.methods
              .where((m) => m.id == paymentMethodId)
              .firstOrNull
          : paymentsState.selectedMethod;
      final paymentMethodLabel = paymentMethod?.displayName;
      
      controller.completeCurrentTrip(
        destinationLabel: draftSnapshot?.destinationQuery,
        originLabel: draftSnapshot?.pickupLabel ?? draftSnapshot?.pickupPlace?.label,
        amountFormatted: tripSummary?.fareDisplayText,
        serviceName: tripSummary?.selectedServiceName,
        paymentMethodLabel: paymentMethodLabel,
      );
      
      setState(() {
        _completedTrip = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Track B - Ticket #98: Check if viewing from history (passed via navigator)
    final fromHistory = widget.historyEntry != null;
    
    // Track B - Ticket #118: Get the history entry to display
    final RideHistoryEntry? effectiveEntry;
    
    if (fromHistory) {
      effectiveEntry = widget.historyEntry;
    } else {
      final tripSession = ref.watch(rideTripSessionProvider);
      // After completeCurrentTrip(), the trip is in historyTrips
      effectiveEntry = tripSession.historyTrips.isNotEmpty 
          ? tripSession.historyTrips.first 
          : null;
    }

    // Defensive fallback: if no entry available yet (waiting for completion)
    if (effectiveEntry == null) {
      return DWAppShell(
        appBar: AppBar(
          title: Text(l10n.rideTripSummaryTitle),
        ),
        applyPadding: false,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final draft = ref.watch(rideDraftProvider);
    final quoteState = ref.watch(rideQuoteControllerProvider);

    return DWAppShell(
      appBar: AppBar(
        title: Text(l10n.rideTripSummaryTitle),
        automaticallyImplyLeading: fromHistory, // Show back button when from history
        leading: fromHistory
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      applyPadding: false,
      useSafeArea: true,
      body: _RideTripSummaryBody(
        trip: effectiveEntry.trip,
          draft: draft,
          quoteState: quoteState,
          fromHistory: fromHistory,
          historyCompletedAt: effectiveEntry.completedAt,
          historyDestinationLabel: effectiveEntry.destinationLabel,
          historyAmountFormatted: effectiveEntry.amountFormatted,
          // Track B - Ticket #118: historyEntry has all the data we need
          historyServiceName: effectiveEntry.serviceName,
          historyOriginLabel: effectiveEntry.originLabel,
          historyPaymentMethodLabel: effectiveEntry.paymentMethodLabel,
          // Track B - Ticket #124: Pass driver rating from history entry
          historyDriverRating: effectiveEntry.driverRating,
        ),
    );
  }
}

/// Body content for Trip Summary Screen
class _RideTripSummaryBody extends ConsumerStatefulWidget {
  const _RideTripSummaryBody({
    required this.trip,
    required this.draft,
    required this.quoteState,
    this.fromHistory = false,
    this.historyCompletedAt,
    this.historyDestinationLabel,
    this.historyAmountFormatted,
    this.historyServiceName,
    this.historyOriginLabel,
    this.historyPaymentMethodLabel,
    this.historyDriverRating,
  });

  final RideTripState trip;
  final RideDraftUiState draft;
  final RideQuoteUiState quoteState;
  
  /// Track B - Ticket #98: Whether viewing from history
  final bool fromHistory;
  final DateTime? historyCompletedAt;
  final String? historyDestinationLabel;
  final String? historyAmountFormatted;
  
  /// Track B - Ticket #118: Additional history entry fields
  final String? historyServiceName;
  final String? historyOriginLabel;
  final String? historyPaymentMethodLabel;

  /// Track B - Ticket #124: Driver rating from history entry
  final double? historyDriverRating;

  @override
  ConsumerState<_RideTripSummaryBody> createState() =>
      _RideTripSummaryBodyState();
}

class _RideTripSummaryBodyState extends ConsumerState<_RideTripSummaryBody> {
  late int _currentRating;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Track B - Ticket #124: Initialize rating from history entry if available
    _currentRating = widget.historyDriverRating?.round() ?? 0;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DWSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header - Trip Completed with ID and timestamp (Ticket #92)
          _CompletedHeader(
            trip: widget.trip,
            l10n: l10n,
            textTheme: textTheme,
            colorScheme: colorScheme,
            completedAt: widget.historyCompletedAt,
          ),
          const SizedBox(height: DWSpacing.lg),

          // Route Summary Card
          _RouteSummaryCard(
            draft: widget.draft,
            l10n: l10n,
            textTheme: textTheme,
            colorScheme: colorScheme,
            historyDestinationLabel: widget.historyDestinationLabel,
          ),
          const SizedBox(height: DWSpacing.md),

          // Fare Summary Card with full breakdown (Ticket #92, #107, #118)
          _FareSummaryCard(
            quoteState: widget.quoteState,
            draft: widget.draft,
            l10n: l10n,
            textTheme: textTheme,
            colorScheme: colorScheme,
            // Track B - Ticket #118: Use history entry data instead of completionSummary
            historyAmountFormatted: widget.historyAmountFormatted,
            historyServiceName: widget.historyServiceName,
            historyPaymentMethodLabel: widget.historyPaymentMethodLabel,
          ),
          const SizedBox(height: DWSpacing.md),

          // Driver Rating Card (Ticket #62: Added comment field)
          _DriverRatingCard(
            currentRating: _currentRating,
            onRatingChanged: _onRatingChanged,
            commentController: _commentController,
            l10n: l10n,
            textTheme: textTheme,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: DWSpacing.xl),

          // Done CTA Button (Ticket #25: DWButton)
          // Track B - Ticket #98: Different behavior for history vs active flow
          SizedBox(
              width: double.infinity,
              child: DWButton.primary(
                label: l10n.rideTripSummaryDoneCta,
                onPressed: () => widget.fromHistory
                  ? _onDonePressedFromHistory(context)
                  : _onDonePressed(context),
            ),
          ),
        ],
      ),
    );
  }

  void _onRatingChanged(int rating) {
    setState(() {
      _currentRating = rating;
    });
    // Track B - Ticket #124: Persist rating to historyTrips for active flow
    // For history mode, we don't modify the rating (read-only view)
    if (!widget.fromHistory) {
      // Persist rating into historyTrips (single source of truth)
      ref
          .read(rideTripSessionProvider.notifier)
          .setRatingForMostRecentTrip(rating.toDouble());
    }
  }
  
  /// Track B - Ticket #98: Done handler when viewing from Orders History
  /// Simply pops back to the Orders screen
  void _onDonePressedFromHistory(BuildContext context) {
    Navigator.of(context).pop();
  }

  void _onDonePressed(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Show thank you snackbar (Ticket #62)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.rideSummaryThankYouSnackbar),
      ),
    );
    
    // Track B - Ticket #118: Trip is already archived in historyTrips via completeCurrentTrip()
    // in initState. No need to call archiveTrip() or clear() here - just navigate home.
    // historyTrips persists across navigation.
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

/// Header showing trip completed status with ID and timestamp (Ticket #92)
/// Track B - Ticket #120: Header widget that shows appropriate title/icon based on trip phase.
/// Supports completed, cancelled, and failed states.
class _CompletedHeader extends StatelessWidget {
  const _CompletedHeader({
    required this.trip,
    required this.l10n,
    required this.textTheme,
    required this.colorScheme,
    this.completedAt,
  });

  final RideTripState trip;
  final AppLocalizations l10n;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  
  /// Track B - Ticket #98: Optional timestamp from history entry
  final DateTime? completedAt;

  @override
  Widget build(BuildContext context) {
    // Format completion timestamp (Ticket #92, #98)
    // Track B - Ticket #98: Use history timestamp if available
    final effectiveCompletedAt = completedAt ?? DateTime.now();
    final dateFormat = DateFormat.yMMMd(Localizations.localeOf(context).languageCode);
    final timeFormat = DateFormat.jm(Localizations.localeOf(context).languageCode);
    final formattedDate = dateFormat.format(effectiveCompletedAt);
    final formattedTime = timeFormat.format(effectiveCompletedAt);

    // Track B - Ticket #120, #122: Determine header content based on trip phase
    // Now supports completed, cancelled, and failed states with proper l10n.
    final bool isCancelled = trip.phase == RideTripPhase.cancelled;
    final bool isFailed = trip.phase == RideTripPhase.failed;
    
    final String headerTitle;
    final String headerSubtitle;
    final IconData headerIcon;
    final Color headerIconColor;
    
    if (isCancelled) {
      headerTitle = l10n.rideTripSummaryCancelledTitle;
      headerSubtitle = l10n.rideTripSummaryCancelledSubtitle;
      headerIcon = Icons.cancel_outlined;
      headerIconColor = colorScheme.error;
    } else if (isFailed) {
      // Track B - Ticket #122: Use proper l10n for failed state
      headerTitle = l10n.rideTripSummaryFailedTitle;
      headerSubtitle = l10n.rideTripSummaryFailedSubtitle;
      headerIcon = Icons.error_outline;
      headerIconColor = colorScheme.error;
    } else {
      headerTitle = l10n.rideTripSummaryCompletedTitle;
      headerSubtitle = l10n.rideTripSummaryCompletedSubtitle;
      headerIcon = Icons.check_circle_outline;
      headerIconColor = colorScheme.primary;
    }
    
    final Color headerBackgroundColor = isCancelled || isFailed
        ? colorScheme.errorContainer.withValues(alpha: 0.3)
        : colorScheme.primaryContainer.withValues(alpha: 0.3);

    return Card(
      elevation: 0,
      color: headerBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DWRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DWSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(DWSpacing.sm),
              decoration: BoxDecoration(
                color: headerIconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(DWRadius.md),
              ),
              child: Icon(
                headerIcon,
                size: 32,
                color: headerIconColor,
              ),
            ),
            const SizedBox(width: DWSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    headerTitle,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: DWSpacing.xxs),
                  Text(
                    headerSubtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: DWSpacing.xs),
                  // Trip ID and timestamp (Ticket #92)
                  Text(
                    l10n.rideReceiptTripIdLabel(trip.tripId),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: DWSpacing.xxs),
                  Text(
                    l10n.rideReceiptCompletedAt(formattedDate, formattedTime),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card showing route summary (from/to) - Ticket #92: Design System Tokens
class _RouteSummaryCard extends StatelessWidget {
  const _RouteSummaryCard({
    required this.draft,
    required this.l10n,
    required this.textTheme,
    required this.colorScheme,
    this.historyDestinationLabel,
  });

  final RideDraftUiState draft;
  final AppLocalizations l10n;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  
  /// Track B - Ticket #98: Optional destination label from history entry
  final String? historyDestinationLabel;

  @override
  Widget build(BuildContext context) {
    final pickupLabel = draft.pickupPlace?.label ?? draft.pickupLabel;
    // Track B - Ticket #98: Use history destination if available
    final destinationLabel = historyDestinationLabel ??
        draft.destinationPlace?.label ?? draft.destinationQuery;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DWRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DWSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.rideTripSummaryRouteSectionTitle,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DWSpacing.sm),

            // Pickup row with label (Ticket #92)
            _RouteRow(
              icon: Icons.circle,
              iconColor: colorScheme.primary,
              label: l10n.rideReceiptFromLabel,
              value: pickupLabel,
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),

            // Connecting line
            Container(
              margin: const EdgeInsets.only(left: 4, top: DWSpacing.xxs, bottom: DWSpacing.xxs),
              width: 2,
              height: 20,
              color: colorScheme.outlineVariant,
            ),

            // Destination row with label (Ticket #92)
            _RouteRow(
              icon: Icons.location_on,
              iconColor: colorScheme.error,
              label: l10n.rideReceiptToLabel,
              value: destinationLabel,
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
          ],
        ),
      ),
    );
  }
}

/// Route row widget for From/To display (Ticket #92)
class _RouteRow extends StatelessWidget {
  const _RouteRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.textTheme,
    required this.colorScheme,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 10, color: iconColor),
        const SizedBox(width: DWSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: DWSpacing.xxs),
              Text(
                value,
                style: textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Card showing fare/receipt summary with full breakdown (Ticket #62, #63, #92, #107, #118)
///
/// Track B - Ticket #63: Now uses [RidePriceBreakdown] from domain layer
/// for consistent pricing between Screen 9 and Screen 10.
/// Ticket #92: Added full breakdown (Base, Distance, Time, Fees) + Design Tokens
/// Ticket #107: Uses completionSummary as source of truth when available
/// Ticket #118: Uses historyEntry fields as single source of truth
class _FareSummaryCard extends ConsumerWidget {
  const _FareSummaryCard({
    required this.quoteState,
    required this.draft,
    required this.l10n,
    required this.textTheme,
    required this.colorScheme,
    this.historyAmountFormatted,
    this.historyServiceName,
    this.historyPaymentMethodLabel,
  });

  final RideQuoteUiState quoteState;
  final RideDraftUiState draft;
  final AppLocalizations l10n;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  
  /// Track B - Ticket #118: Data from history entry
  final String? historyAmountFormatted;
  final String? historyServiceName;
  final String? historyPaymentMethodLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get price from selected option or recommended option
    final quote = quoteState.quote;
    final selectedOptionId = draft.selectedOptionId;
    final selectedOption = quote == null
        ? null
        : (selectedOptionId != null
            ? quote.optionById(selectedOptionId) ?? quote.recommendedOption
            : quote.recommendedOption);

    final currency = selectedOption?.currencyCode ?? 'SAR';
    
    // Track B - Ticket #63: Use RidePriceBreakdown from domain layer
    final breakdown = selectedOption?.priceBreakdown;
    
    // Format values from breakdown or fallback to total-based calculation (Ticket #92)
    final String baseFareAmount;
    final String distanceAmount;
    final String timeAmount;
    final String feesAmount;
    final String totalAmount;
    
    if (breakdown != null) {
      // Use domain-level breakdown (deterministic from MockRidePricingService)
      baseFareAmount = breakdown.formattedBaseFare;
      distanceAmount = breakdown.formattedDistanceComponent;
      timeAmount = breakdown.formattedTimeComponent;
      feesAmount = breakdown.formattedFees;
      totalAmount = breakdown.formattedTotal;
    } else {
      // Fallback for backward compatibility (when priceBreakdown is null)
      final priceMinorUnits = selectedOption?.priceMinorUnits ?? 0;
      baseFareAmount = ((priceMinorUnits * 0.3) / 100).toStringAsFixed(2);
      distanceAmount = ((priceMinorUnits * 0.4) / 100).toStringAsFixed(2);
      timeAmount = ((priceMinorUnits * 0.2) / 100).toStringAsFixed(2);
      feesAmount = ((priceMinorUnits * 0.1) / 100).toStringAsFixed(2);
      totalAmount = selectedOption?.formattedPrice ?? '0.00';
    }
    
    // Track B - Ticket #118: Use history entry payment label, or fallback to payments state
    final paymentsState = ref.watch(paymentMethodsUiProvider);
    final paymentDisplayName = historyPaymentMethodLabel ?? 
        paymentsState.selectedMethod?.displayName ?? 
        l10n.rideTripConfirmationPaymentMethodCash;
    final isCardPayment = paymentDisplayName.contains('••');

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DWRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DWSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Track B - Ticket #118: Service name from history entry
            if (historyServiceName != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.directions_car_filled,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: DWSpacing.xs),
                  Text(
                    l10n.rideTripCompletionServiceLabel(historyServiceName!),
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DWSpacing.md),
            ],
            
            Text(
              l10n.rideReceiptFareSectionTitle,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DWSpacing.md),

            // Base fare row (Ticket #92)
            _ReceiptRow(
              label: l10n.rideReceiptBaseFareLabel,
              value: '$baseFareAmount $currency',
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: DWSpacing.xs),

            // Distance row (Ticket #92)
            _ReceiptRow(
              label: l10n.rideReceiptDistanceFareLabel,
              value: '$distanceAmount $currency',
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: DWSpacing.xs),

            // Time row (Ticket #92)
            _ReceiptRow(
              label: l10n.rideReceiptTimeFareLabel,
              value: '$timeAmount $currency',
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: DWSpacing.xs),

            // Fees row
            _ReceiptRow(
              label: l10n.rideReceiptFeesLabel,
              value: '$feesAmount $currency',
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),

            const Divider(height: DWSpacing.lg),

            // Total row (emphasized)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.rideReceiptTotalLabel,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  // Track B - Ticket #118: Use history entry fare if available
                  historyAmountFormatted ?? '$totalAmount $currency',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),

            const Divider(height: DWSpacing.lg),

            // Payment method row (Track B - Ticket #118: Use history entry payment)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.rideTripConfirmationPaymentSectionTitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      isCardPayment ? Icons.credit_card : Icons.payments_outlined,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: DWSpacing.xs),
                    Text(
                      paymentDisplayName,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Receipt row widget for fare breakdown (Ticket #62)
class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.label,
    required this.value,
    required this.textTheme,
    required this.colorScheme,
  });

  final String label;
  final String value;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Card showing driver info and rating (Ticket #62, #92: Design System Tokens)
class _DriverRatingCard extends StatelessWidget {
  const _DriverRatingCard({
    required this.currentRating,
    required this.onRatingChanged,
    required this.commentController,
    required this.l10n,
    required this.textTheme,
    required this.colorScheme,
  });

  final int currentRating;
  final ValueChanged<int> onRatingChanged;
  final TextEditingController commentController;
  final AppLocalizations l10n;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DWRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DWSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title (Ticket #92)
            Text(
              l10n.rideReceiptDriverSectionTitle,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DWSpacing.md),

            // Driver info row
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    color: colorScheme.onPrimaryContainer,
                    size: 28,
                  ),
                ),
                const SizedBox(width: DWSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.rideDriverMockName, // TODO: Real driver name from backend
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: DWSpacing.xxs),
                      Text(
                        l10n.rideDriverMockCarInfo, // TODO: Real car info
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Driver rating badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DWSpacing.xs,
                    vertical: DWSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(DWRadius.sm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 14, color: colorScheme.tertiary),
                      const SizedBox(width: DWSpacing.xxs),
                      Text(
                        l10n.rideDriverMockRating, // TODO: Real rating from backend
                        style: textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: DWSpacing.lg),

            // Rating section title (Ticket #92)
            Text(
              l10n.rideReceiptRateDriverTitle,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DWSpacing.xxs),
            Text(
              l10n.rideReceiptRateDriverSubtitle,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: DWSpacing.md),

            // Star rating row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                final isSelected = starIndex <= currentRating;
                return GestureDetector(
                  onTap: () => onRatingChanged(starIndex),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: DWSpacing.xxs),
                    child: Icon(
                      isSelected ? Icons.star : Icons.star_border,
                      size: 44,
                      color: isSelected
                          ? colorScheme.tertiary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: DWSpacing.md),

            // Optional comment field (Ticket #62)
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.rideSummaryCommentPlaceholder,
                hintStyle: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
                filled: true,
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DWRadius.sm),
                  borderSide: BorderSide(
                    color: colorScheme.outlineVariant,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DWRadius.sm),
                  borderSide: BorderSide(
                    color: colorScheme.outlineVariant,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DWRadius.sm),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.all(DWSpacing.sm),
              ),
            ),
            // TODO(Track B): Wire up rating submission to mobility_shims backend adapter (Stub only).
          ],
        ),
      ),
    );
  }
}


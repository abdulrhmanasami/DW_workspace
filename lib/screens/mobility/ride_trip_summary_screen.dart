/// Ride Trip Summary Screen - Track B Ticket #23, #62, #63, #92, #96, #98
/// Purpose: Display trip summary/receipt with driver rating
/// Created by: Track B - Ticket #23
/// Updated by: Track B - Ticket #62 (Receipt breakdown, comment field)
/// Updated by: Track B - Ticket #63 (Domain-level pricing integration)
/// Updated by: Ticket #92 (Full receipt UI + Design System Tokens + L10n)
/// Updated by: Ticket #96 (Archive trip to history before clear)
/// Updated by: Ticket #98 (Support viewing history trips from Orders)
/// Last updated: 2025-11-30
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
import '../../state/mobility/ride_draft_state.dart';
import '../../state/mobility/ride_trip_session.dart';
import '../../state/mobility/ride_quote_controller.dart';

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
class RideTripSummaryScreen extends ConsumerWidget {
  const RideTripSummaryScreen({
    super.key,
    this.historyEntry,
  });
  
  /// Optional history entry when viewing from Orders History
  /// Track B - Ticket #98
  final RideHistoryEntry? historyEntry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    // Track B - Ticket #98: Check if viewing from history
    final fromHistory = historyEntry != null;

    // If from history, use the history entry's trip
    // Otherwise, use active trip from session
    final RideTripState? effectiveTrip;
    final DateTime? completedAt;
    final String? historyDestinationLabel;
    final String? historyAmountFormatted;
    
    if (fromHistory) {
      effectiveTrip = historyEntry!.trip;
      completedAt = historyEntry!.completedAt;
      historyDestinationLabel = historyEntry!.destinationLabel;
      historyAmountFormatted = historyEntry!.amountFormatted;
    } else {
      final tripSession = ref.watch(rideTripSessionProvider);
      effectiveTrip = tripSession.activeTrip;
      completedAt = null;
      historyDestinationLabel = null;
      historyAmountFormatted = null;
    }

    // Defensive fallback: if no trip available
    if (effectiveTrip == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      });
      return const SizedBox.shrink();
    }
    
    // For active trips, require completed phase; for history, allow any terminal phase
    if (!fromHistory && effectiveTrip.phase != RideTripPhase.completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      });
      return const SizedBox.shrink();
    }

    final draft = ref.watch(rideDraftProvider);
    final quoteState = ref.watch(rideQuoteControllerProvider);

    return Scaffold(
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
      body: SafeArea(
        child: _RideTripSummaryBody(
          trip: effectiveTrip,
          draft: draft,
          quoteState: quoteState,
          fromHistory: fromHistory,
          historyCompletedAt: completedAt,
          historyDestinationLabel: historyDestinationLabel,
          historyAmountFormatted: historyAmountFormatted,
        ),
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
  });

  final RideTripState trip;
  final RideDraftUiState draft;
  final RideQuoteUiState quoteState;
  
  /// Track B - Ticket #98: Whether viewing from history
  final bool fromHistory;
  final DateTime? historyCompletedAt;
  final String? historyDestinationLabel;
  final String? historyAmountFormatted;

  @override
  ConsumerState<_RideTripSummaryBody> createState() =>
      _RideTripSummaryBodyState();
}

class _RideTripSummaryBodyState extends ConsumerState<_RideTripSummaryBody> {
  int _currentRating = 0;
  final TextEditingController _commentController = TextEditingController();

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
      padding: EdgeInsets.all(DWSpacing.lg),
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
          SizedBox(height: DWSpacing.lg),

          // Route Summary Card
          _RouteSummaryCard(
            draft: widget.draft,
            l10n: l10n,
            textTheme: textTheme,
            colorScheme: colorScheme,
            historyDestinationLabel: widget.historyDestinationLabel,
          ),
          SizedBox(height: DWSpacing.md),

          // Fare Summary Card with full breakdown (Ticket #92)
          _FareSummaryCard(
            quoteState: widget.quoteState,
            draft: widget.draft,
            l10n: l10n,
            textTheme: textTheme,
            colorScheme: colorScheme,
          ),
          SizedBox(height: DWSpacing.md),

          // Driver Rating Card (Ticket #62: Added comment field)
          _DriverRatingCard(
            currentRating: _currentRating,
            onRatingChanged: _onRatingChanged,
            commentController: _commentController,
            l10n: l10n,
            textTheme: textTheme,
            colorScheme: colorScheme,
          ),
          SizedBox(height: DWSpacing.xl),

          // Done CTA Button (Ticket #25: DWButton)
          // Track B - Ticket #98: Different behavior for history vs active flow
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: DWButton.primary(
                label: l10n.rideTripSummaryDoneCta,
                onPressed: () => widget.fromHistory
                    ? _onDonePressedFromHistory(context)
                    : _onDonePressed(context),
              ),
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
    // Only persist rating for active trips (not history)
    if (!widget.fromHistory) {
      ref.read(rideTripSessionProvider.notifier).rateCurrentTrip(rating);
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
    
    // Track B - Ticket #96: Archive trip to history before clearing
    final controller = ref.read(rideTripSessionProvider.notifier);
    
    // Get formatted amount from quote if available
    String? amountFormatted;
    final quote = widget.quoteState.quote;
    final selectedId = widget.draft.selectedOptionId;
    if (quote != null) {
      final option = selectedId != null
          ? quote.optionById(selectedId) ?? quote.recommendedOption
          : quote.recommendedOption;
      amountFormatted = '${option.currencyCode} ${(option.priceMinorUnits / 100).toStringAsFixed(2)}';
    }
    
    controller.archiveTrip(
      destinationLabel: widget.draft.destinationQuery.isNotEmpty
          ? widget.draft.destinationQuery
          : (widget.draft.destinationPlace?.label ?? ''),
      amountFormatted: amountFormatted,
    );
    
    // Clear trip session and return to home
    controller.clear();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

/// Header showing trip completed status with ID and timestamp (Ticket #92)
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

    return Card(
      elevation: 0,
      color: colorScheme.primaryContainer.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DWRadius.lg),
      ),
      child: Padding(
        padding: EdgeInsets.all(DWSpacing.md),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(DWSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(DWRadius.md),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 32,
                color: Colors.green,
              ),
            ),
            SizedBox(width: DWSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.rideTripSummaryCompletedTitle,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: DWSpacing.xxs),
                  Text(
                    l10n.rideTripSummaryCompletedSubtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: DWSpacing.xs),
                  // Trip ID and timestamp (Ticket #92)
                  Text(
                    l10n.rideReceiptTripIdLabel(trip.tripId),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: DWSpacing.xxs),
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
        padding: EdgeInsets.all(DWSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.rideTripSummaryRouteSectionTitle,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: DWSpacing.sm),

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
              margin: EdgeInsets.only(left: 4, top: DWSpacing.xxs, bottom: DWSpacing.xxs),
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
        SizedBox(width: DWSpacing.sm),
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
              SizedBox(height: DWSpacing.xxs),
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

/// Card showing fare/receipt summary with full breakdown (Ticket #62, #63, #92)
///
/// Track B - Ticket #63: Now uses [RidePriceBreakdown] from domain layer
/// for consistent pricing between Screen 9 and Screen 10.
/// Ticket #92: Added full breakdown (Base, Distance, Time, Fees) + Design Tokens
class _FareSummaryCard extends StatelessWidget {
  const _FareSummaryCard({
    required this.quoteState,
    required this.draft,
    required this.l10n,
    required this.textTheme,
    required this.colorScheme,
  });

  final RideQuoteUiState quoteState;
  final RideDraftUiState draft;
  final AppLocalizations l10n;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
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

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DWRadius.lg),
      ),
      child: Padding(
        padding: EdgeInsets.all(DWSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.rideReceiptFareSectionTitle,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: DWSpacing.md),

            // Base fare row (Ticket #92)
            _ReceiptRow(
              label: l10n.rideReceiptBaseFareLabel,
              value: '$baseFareAmount $currency',
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
            SizedBox(height: DWSpacing.xs),

            // Distance row (Ticket #92)
            _ReceiptRow(
              label: l10n.rideReceiptDistanceFareLabel,
              value: '$distanceAmount $currency',
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
            SizedBox(height: DWSpacing.xs),

            // Time row (Ticket #92)
            _ReceiptRow(
              label: l10n.rideReceiptTimeFareLabel,
              value: '$timeAmount $currency',
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
            SizedBox(height: DWSpacing.xs),

            // Fees row
            _ReceiptRow(
              label: l10n.rideReceiptFeesLabel,
              value: '$feesAmount $currency',
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),

            Divider(height: DWSpacing.lg),

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
                  '$totalAmount $currency',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),

            Divider(height: DWSpacing.lg),

            // Payment method row
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
                      Icons.payments_outlined,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: DWSpacing.xs),
                    Text(
                      l10n.rideTripConfirmationPaymentMethodCash,
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
        padding: EdgeInsets.all(DWSpacing.md),
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
            SizedBox(height: DWSpacing.md),

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
                SizedBox(width: DWSpacing.md),
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
                      SizedBox(height: DWSpacing.xxs),
                      Text(
                        'Toyota Camry • ABC 1234', // TODO: Real car info
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Driver rating badge
                Container(
                  padding: EdgeInsets.symmetric(
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
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      SizedBox(width: DWSpacing.xxs),
                      Text(
                        '4.9', // TODO: Real rating from backend
                        style: textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: DWSpacing.lg),

            // Rating section title (Ticket #92)
            Text(
              l10n.rideReceiptRateDriverTitle,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: DWSpacing.xxs),
            Text(
              l10n.rideReceiptRateDriverSubtitle,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: DWSpacing.md),

            // Star rating row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                final isSelected = starIndex <= currentRating;
                return GestureDetector(
                  onTap: () => onRatingChanged(starIndex),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: DWSpacing.xxs),
                    child: Icon(
                      isSelected ? Icons.star : Icons.star_border,
                      size: 44,
                      color: isSelected
                          ? Colors.amber
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }),
            ),

            SizedBox(height: DWSpacing.md),

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
                contentPadding: EdgeInsets.all(DWSpacing.sm),
              ),
            ),
            // TODO(Track B): Wire up rating submission to mobility_shims backend adapter (Stub only).
          ],
        ),
      ),
    );
  }
}


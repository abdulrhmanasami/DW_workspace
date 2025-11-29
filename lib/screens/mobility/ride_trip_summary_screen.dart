/// Ride Trip Summary Screen - Track B Ticket #23
/// Purpose: Display trip summary/receipt with driver rating
/// Created by: Track B - Ticket #23
/// Last updated: 2025-11-28
///
/// This screen shows the trip summary interface (Screen 11 in Hi-Fi Mockups):
/// - Trip completed status header
/// - Route summary (from/to)
/// - Fare/receipt summary
/// - Driver info and rating
/// - Done CTA to return home
///
/// NOTE: Driver rating is stored in-memory via FSM. Backend integration later.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Shims only - no direct SDKs
import 'package:mobility_shims/mobility_shims.dart';
import 'package:design_system_shims/design_system_shims.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../state/mobility/ride_draft_state.dart';
import '../../state/mobility/ride_trip_session.dart';
import '../../state/mobility/ride_quote_controller.dart';

/// Trip Summary Screen - Shows receipt, driver rating, and Done CTA
class RideTripSummaryScreen extends ConsumerWidget {
  const RideTripSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final tripSession = ref.watch(rideTripSessionProvider);
    final activeTrip = tripSession.activeTrip;

    // Defensive fallback: if no completed trip, return to Home
    if (activeTrip == null || activeTrip.phase != RideTripPhase.completed) {
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
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: _RideTripSummaryBody(
          trip: activeTrip,
          draft: draft,
          quoteState: quoteState,
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
  });

  final RideTripState trip;
  final RideDraftUiState draft;
  final RideQuoteUiState quoteState;

  @override
  ConsumerState<_RideTripSummaryBody> createState() =>
      _RideTripSummaryBodyState();
}

class _RideTripSummaryBodyState extends ConsumerState<_RideTripSummaryBody> {
  int _currentRating = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header - Trip Completed
          _CompletedHeader(l10n: l10n, textTheme: textTheme, colorScheme: colorScheme),
          const SizedBox(height: 24),

          // Route Summary Card
          _RouteSummaryCard(
            draft: widget.draft,
            l10n: l10n,
            textTheme: textTheme,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 16),

          // Fare Summary Card
          _FareSummaryCard(
            quoteState: widget.quoteState,
            draft: widget.draft,
            l10n: l10n,
            textTheme: textTheme,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 16),

          // Driver Rating Card
          _DriverRatingCard(
            currentRating: _currentRating,
            onRatingChanged: _onRatingChanged,
            l10n: l10n,
            textTheme: textTheme,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 32),

          // Done CTA Button (Ticket #25: DWButton)
          SizedBox(
            width: double.infinity,
            child: DWButton.primary(
              label: l10n.rideTripSummaryDoneCta,
              onPressed: () => _onDonePressed(context),
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
    // Persist rating in FSM
    ref.read(rideTripSessionProvider.notifier).rateCurrentTrip(rating);
  }

  void _onDonePressed(BuildContext context) {
    // Clear trip session and return to home
    ref.read(rideTripSessionProvider.notifier).clear();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

/// Header showing trip completed status
class _CompletedHeader extends StatelessWidget {
  const _CompletedHeader({
    required this.l10n,
    required this.textTheme,
    required this.colorScheme,
  });

  final AppLocalizations l10n;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.check_circle_outline,
            size: 32,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
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
              const SizedBox(height: 4),
              Text(
                l10n.rideTripSummaryCompletedSubtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Card showing route summary (from/to)
class _RouteSummaryCard extends StatelessWidget {
  const _RouteSummaryCard({
    required this.draft,
    required this.l10n,
    required this.textTheme,
    required this.colorScheme,
  });

  final RideDraftUiState draft;
  final AppLocalizations l10n;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final pickupLabel = draft.pickupPlace?.label ?? draft.pickupLabel;
    final destinationLabel =
        draft.destinationPlace?.label ?? draft.destinationQuery;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.rideTripSummaryRouteSectionTitle,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Pickup row
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    pickupLabel,
                    style: textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Connecting line
            Container(
              margin: const EdgeInsets.only(left: 3, top: 4, bottom: 4),
              width: 2,
              height: 20,
              color: colorScheme.outlineVariant,
            ),

            // Destination row
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    destinationLabel,
                    style: textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Card showing fare/receipt summary
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

    final formattedPrice = selectedOption?.formattedPrice ?? '0.00';
    final currency = selectedOption?.currencyCode ?? 'SAR';

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.rideTripSummaryFareSectionTitle,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Total row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.rideTripSummaryTotalLabel,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$formattedPrice $currency',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

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
                    const SizedBox(width: 6),
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

/// Card showing driver info and rating
class _DriverRatingCard extends StatelessWidget {
  const _DriverRatingCard({
    required this.currentRating,
    required this.onRatingChanged,
    required this.l10n,
    required this.textTheme,
    required this.colorScheme,
  });

  final int currentRating;
  final ValueChanged<int> onRatingChanged;
  final AppLocalizations l10n;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.rideTripSummaryDriverSectionTitle,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

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
                const SizedBox(width: 14),
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
                      Text(
                        'Toyota Camry • ABC 1234', // TODO: Real car info
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Rating section
            Text(
              l10n.rideTripSummaryRatingLabel,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),

            // Star rating row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                final isSelected = starIndex <= currentRating;
                return GestureDetector(
                  onTap: () => onRatingChanged(starIndex),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      isSelected ? Icons.star : Icons.star_border,
                      size: 40,
                      color: isSelected
                          ? Colors.amber
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}


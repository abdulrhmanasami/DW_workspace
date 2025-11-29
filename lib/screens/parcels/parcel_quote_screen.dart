/// Parcel Quote Screen
/// Created by: Track C - Ticket #43
/// Purpose: Display pricing options for parcel shipments
/// Last updated: 2025-11-28 (Ticket #44 - Added Confirm integration)

import 'package:design_system_shims/design_system_shims.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parcels_shims/parcels_shims.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../router/app_router.dart';
import '../../state/parcels/parcel_draft_state.dart';
import '../../state/parcels/parcel_orders_state.dart';
import '../../state/parcels/parcel_quote_state.dart';

/// Screen for displaying parcel pricing options (Step 3 of parcel shipment flow).
class ParcelQuoteScreen extends ConsumerStatefulWidget {
  const ParcelQuoteScreen({super.key});

  @override
  ConsumerState<ParcelQuoteScreen> createState() => _ParcelQuoteScreenState();
}

class _ParcelQuoteScreenState extends ConsumerState<ParcelQuoteScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger pricing on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final draft = ref.read(parcelDraftProvider);
      ref.read(parcelQuoteControllerProvider.notifier).refreshFromDraft(draft);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final quoteState = ref.watch(parcelQuoteControllerProvider);
    final draft = ref.watch(parcelDraftProvider);
    final draftController = ref.read(parcelDraftProvider.notifier);

    final quote = quoteState.quote;
    final options = quote?.options ?? const <ParcelQuoteOption>[];

    final isLoading = quoteState.isLoading;
    final hasError = quoteState.hasError;
    final hasOptions = quote != null && options.isNotEmpty;

    final selectedId = draft.selectedQuoteOptionId;
    final canConfirm =
        !isLoading && !hasError && hasOptions && selectedId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.parcelsQuoteTitle ?? 'Shipment pricing',
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DWSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n?.parcelsQuoteSubtitle ??
                    'Choose how fast you want it delivered and how much you want to pay.',
                style: textTheme.bodyLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: DWSpacing.lg),

              // Content based on state (loading / error / empty / success)
              Expanded(
                child: _buildContent(
                  context: context,
                  l10n: l10n,
                  quoteState: quoteState,
                  options: options,
                  selectedId: selectedId,
                  onOptionSelected: (id) {
                    draftController.updateSelectedQuoteOptionId(id);
                  },
                ),
              ),

              const SizedBox(height: DWSpacing.md),

              DWButton.primary(
                label: l10n?.parcelsQuoteConfirmCta ?? 'Confirm shipment',
                onPressed: canConfirm
                    ? () => _onConfirmPressed(context, ref)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required AppLocalizations? l10n,
    required ParcelQuoteUiState quoteState,
    required List<ParcelQuoteOption> options,
    required String? selectedId,
    required ValueChanged<String> onOptionSelected,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (quoteState.isLoading && !quoteState.hasQuote) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: DWSpacing.md),
            Text(
              l10n?.parcelsQuoteLoadingTitle ?? 'Fetching price options...',
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    if (quoteState.hasError) {
      return _QuoteErrorCard(
        l10n: l10n,
        textTheme: textTheme,
        colors: colors,
        onRetry: () {
          final draft = ref.read(parcelDraftProvider);
          ref
              .read(parcelQuoteControllerProvider.notifier)
              .refreshFromDraft(draft);
        },
      );
    }

    if (options.isEmpty) {
      return _QuoteEmptyCard(
        l10n: l10n,
        textTheme: textTheme,
        colors: colors,
      );
    }

    return ListView.separated(
      itemCount: options.length,
      separatorBuilder: (_, __) => const SizedBox(height: DWSpacing.sm),
      itemBuilder: (context, index) {
        final option = options[index];
        final isSelected = option.id == selectedId;

        return _QuoteOptionTile(
          option: option,
          isSelected: isSelected,
          onTap: () => onOptionSelected(option.id),
        );
      },
    );
  }

  void _onConfirmPressed(BuildContext context, WidgetRef ref) {
    final draft = ref.read(parcelDraftProvider);
    final quoteState = ref.read(parcelQuoteControllerProvider);
    final quote = quoteState.quote;
    final selectedId = draft.selectedQuoteOptionId;

    // Guard rail - should not reach here without these
    if (quote == null || selectedId == null) {
      return;
    }

    // Find the selected option
    final selectedOption = quote.options.firstWhere(
      (o) => o.id == selectedId,
      orElse: () => quote.options.first,
    );

    // 1) Create Parcel and store in session
    ref.read(parcelOrdersProvider.notifier).createParcelFromDraft(
          draft: draft,
          quote: quote,
          selectedOption: selectedOption,
        );

    // 2) Clean up draft + quote state
    ref.read(parcelDraftProvider.notifier).reset();
    ref.read(parcelQuoteControllerProvider.notifier).reset();

    // 3) Navigate back to Parcels Home
    Navigator.of(context).popUntil((route) {
      final name = route.settings.name;
      if (name == RoutePaths.parcelsHome) return true;
      return route.isFirst;
    });
  }
}

/// Error card widget for displaying pricing errors.
class _QuoteErrorCard extends StatelessWidget {
  const _QuoteErrorCard({
    required this.l10n,
    required this.textTheme,
    required this.colors,
    required this.onRetry,
  });

  final AppLocalizations? l10n;
  final TextTheme textTheme;
  final ColorScheme colors;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DWSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: colors.error),
            const SizedBox(height: DWSpacing.sm),
            Text(
              l10n?.parcelsQuoteErrorTitle ??
                  "We couldn't load price options",
              style: textTheme.titleMedium?.copyWith(
                color: colors.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DWSpacing.xs),
            Text(
              l10n?.parcelsQuoteErrorSubtitle ??
                  'Please check your connection and try again.',
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DWSpacing.md),
            DWButton.secondary(
              label: l10n?.parcelsQuoteRetryCta ?? 'Retry',
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state card when no options are available.
class _QuoteEmptyCard extends StatelessWidget {
  const _QuoteEmptyCard({
    required this.l10n,
    required this.textTheme,
    required this.colors,
  });

  final AppLocalizations? l10n;
  final TextTheme textTheme;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DWSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, color: colors.onSurfaceVariant),
            const SizedBox(height: DWSpacing.sm),
            Text(
              l10n?.parcelsQuoteEmptyTitle ?? 'No options available',
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DWSpacing.xs),
            Text(
              l10n?.parcelsQuoteEmptySubtitle ??
                  'Please adjust the parcel details and try again.',
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Tile widget for displaying a single quote option.
class _QuoteOptionTile extends StatelessWidget {
  const _QuoteOptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final ParcelQuoteOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Format price (convert cents to SAR with 2 decimal places)
    final priceFormatted =
        '${(option.totalAmountCents / 100).toStringAsFixed(2)} ${option.currencyCode}';

    // Format ETA
    final etaFormatted = '~${option.estimatedMinutes} min';

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DWRadius.md),
        side: BorderSide(
          color: isSelected ? colors.primary : colors.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(DWRadius.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(DWSpacing.md),
          child: Row(
            children: [
              Icon(
                Icons.local_shipping_outlined,
                color: isSelected ? colors.primary : colors.onSurfaceVariant,
              ),
              const SizedBox(width: DWSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: DWSpacing.xs),
                    Text(
                      etaFormatted,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: DWSpacing.sm),
              Text(
                priceFormatted,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


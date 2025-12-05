/// Parcel Quote Screen
/// Created by: Track C - Ticket #43
/// Purpose: Display pricing options for parcel shipments
/// Last updated: 2025-12-05 (Ticket C-1 - Navigate to list after confirmation)

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

    // Get the selected option for total display
    final selectedOption = selectedId != null
        ? options.firstWhere(
            (o) => o.id == selectedId,
            orElse: () => options.first,
          )
        : null;

    return ListView(
      children: [
        // Summary card showing shipment details
        _QuoteSummaryCard(l10n: l10n),
        const SizedBox(height: DWSpacing.md),

        // Pricing options list
        ...options.map((option) {
          final isSelected = option.id == selectedId;
          return Padding(
            padding: const EdgeInsets.only(bottom: DWSpacing.sm),
            child: _QuoteOptionTile(
              option: option,
              isSelected: isSelected,
              onTap: () => onOptionSelected(option.id),
            ),
          );
        }),

        // Total display when option is selected
        if (selectedOption != null) ...[
          const SizedBox(height: DWSpacing.md),
          _QuoteTotalRow(
            l10n: l10n,
            option: selectedOption,
            textTheme: textTheme,
            colors: colors,
          ),
        ],

        // Stub note about estimated pricing
        const SizedBox(height: DWSpacing.md),
        _QuoteStubNote(l10n: l10n, textTheme: textTheme, colors: colors),
      ],
    );
  }

  void _onConfirmPressed(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
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

    // 3) Show success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n?.parcelsQuoteSuccessMessage ?? 'Shipment created successfully!',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // 4) Track C - Ticket C-1: Navigate to list to show new shipment
    // Removes all wizard screens (destination, details, quote), keeps root
    Navigator.of(context).pushNamedAndRemoveUntil(
      RoutePaths.parcelsList,
      (route) => route.isFirst,
    );
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

/// Summary card showing shipment details (pickup, dropoff, weight, size).
/// Track C - Ticket #77
class _QuoteSummaryCard extends ConsumerWidget {
  const _QuoteSummaryCard({required this.l10n});

  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final draft = ref.watch(parcelDraftProvider);

    // Format size label
    String sizeLabel(ParcelSize? size) {
      if (size == null) return '-';
      switch (size) {
        case ParcelSize.small:
          return 'Small';
        case ParcelSize.medium:
          return 'Medium';
        case ParcelSize.large:
          return 'Large';
        case ParcelSize.oversize:
          return 'Oversize';
      }
    }

    // Track C - Ticket C-1: Format sender/receiver display
    String formatAddressWithName(String name, String address) {
      if (name.isNotEmpty && address.isNotEmpty) {
        return '$name\n$address';
      } else if (address.isNotEmpty) {
        return address;
      } else if (name.isNotEmpty) {
        return name;
      }
      return '-';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DWSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.parcelsQuoteSummaryTitle ?? 'Shipment summary',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: DWSpacing.sm),
            _SummaryRow(
              icon: Icons.location_on_outlined,
              label: l10n?.parcelsQuoteFromLabel ?? 'From',
              value: formatAddressWithName(draft.senderName, draft.pickupAddress),
              colors: colors,
              textTheme: textTheme,
            ),
            const SizedBox(height: DWSpacing.xs),
            _SummaryRow(
              icon: Icons.flag_outlined,
              label: l10n?.parcelsQuoteToLabel ?? 'To',
              value: formatAddressWithName(draft.receiverName, draft.dropoffAddress),
              colors: colors,
              textTheme: textTheme,
            ),
            const Divider(height: DWSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _SummaryRow(
                    icon: Icons.scale_outlined,
                    label: l10n?.parcelsQuoteWeightLabel ?? 'Weight',
                    value: draft.weightText.isNotEmpty
                        ? '${draft.weightText} kg'
                        : '-',
                    colors: colors,
                    textTheme: textTheme,
                  ),
                ),
                const SizedBox(width: DWSpacing.md),
                Expanded(
                  child: _SummaryRow(
                    icon: Icons.inventory_2_outlined,
                    label: l10n?.parcelsQuoteSizeLabel ?? 'Size',
                    value: sizeLabel(draft.size),
                    colors: colors,
                    textTheme: textTheme,
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

/// Helper widget for summary row
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.colors,
    required this.textTheme,
  });

  final IconData icon;
  final String label;
  final String value;
  final ColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: colors.onSurfaceVariant),
        const SizedBox(width: DWSpacing.xs),
        Text(
          '$label: ',
          style: textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Widget showing total price when an option is selected.
/// Track C - Ticket #77
class _QuoteTotalRow extends StatelessWidget {
  const _QuoteTotalRow({
    required this.l10n,
    required this.option,
    required this.textTheme,
    required this.colors,
  });

  final AppLocalizations? l10n;
  final ParcelQuoteOption option;
  final TextTheme textTheme;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final priceFormatted =
        '${(option.totalAmountCents / 100).toStringAsFixed(2)} ${option.currencyCode}';

    return Container(
      padding: const EdgeInsets.all(DWSpacing.md),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(DWRadius.md),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n?.parcelsQuoteTotalLabel(priceFormatted).split(':').first ??
                'Total',
            style: textTheme.titleMedium?.copyWith(
              color: colors.onPrimaryContainer,
            ),
          ),
          Text(
            priceFormatted,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

/// Stub note about estimated pricing.
/// Track C - Ticket #77
class _QuoteStubNote extends StatelessWidget {
  const _QuoteStubNote({
    required this.l10n,
    required this.textTheme,
    required this.colors,
  });

  final AppLocalizations? l10n;
  final TextTheme textTheme;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline,
          size: 16,
          color: colors.onSurfaceVariant,
        ),
        const SizedBox(width: DWSpacing.xs),
        Expanded(
          child: Text(
            l10n?.parcelsQuoteBreakdownStubNote ??
                'This is an estimated price. Final price may change after integration with the live pricing service.',
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
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


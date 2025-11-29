/// Parcel Details Screen
/// Created by: Track C - Ticket #42
/// Purpose: Second step in create-shipment flow (size, weight, contents, fragile).
/// Last updated: 2025-11-28 (Ticket #43 - Navigate to ParcelQuoteScreen)

import 'package:design_system_shims/design_system_shims.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parcels_shims/parcels_shims.dart' show ParcelSize;

import '../../l10n/generated/app_localizations.dart';
import '../../router/app_router.dart';
import '../../state/parcels/parcel_draft_state.dart';

/// Step 2 of the parcel shipment flow: capture parcel details.
class ParcelDetailsScreen extends ConsumerStatefulWidget {
  const ParcelDetailsScreen({super.key});

  @override
  ConsumerState<ParcelDetailsScreen> createState() =>
      _ParcelDetailsScreenState();
}

class _ParcelDetailsScreenState extends ConsumerState<ParcelDetailsScreen> {
  late final TextEditingController _weightController;
  late final TextEditingController _contentsController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(parcelDraftProvider);
    _weightController = TextEditingController(text: draft.weightText);
    _contentsController =
        TextEditingController(text: draft.contentsDescription);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _contentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final draft = ref.watch(parcelDraftProvider);
    final controller = ref.read(parcelDraftProvider.notifier);

    final hasSize = draft.size != null;
    final hasWeight = draft.weightText.trim().isNotEmpty;
    final hasContents = draft.contentsDescription.trim().isNotEmpty;

    final canContinue = hasSize && hasWeight && hasContents;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.parcelsDetailsTitle ?? 'Parcel details',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(DWSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n?.parcelsDetailsSubtitle ??
                          'Tell us more about your parcel to get accurate pricing.',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: DWSpacing.lg),

                    // Size section
                    Text(
                      l10n?.parcelsDetailsSizeLabel ?? 'Size',
                      style: textTheme.labelLarge,
                    ),
                    const SizedBox(height: DWSpacing.xs),
                    _SizeSelector(
                      selected: draft.size,
                      onSelected: (size) => controller.updateSize(size),
                    ),

                    const SizedBox(height: DWSpacing.md),

                    // Weight section
                    Text(
                      l10n?.parcelsDetailsWeightLabel ?? 'Weight',
                      style: textTheme.labelLarge,
                    ),
                    const SizedBox(height: DWSpacing.xs),
                    DWTextField(
                      controller: _weightController,
                      hintText: l10n?.parcelsDetailsWeightHint ?? 'e.g. 2.5 kg',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) => controller.updateWeightText(value),
                    ),

                    const SizedBox(height: DWSpacing.md),

                    // Contents section
                    Text(
                      l10n?.parcelsDetailsContentsLabel ??
                          'What are you sending?',
                      style: textTheme.labelLarge,
                    ),
                    const SizedBox(height: DWSpacing.xs),
                    DWTextField(
                      controller: _contentsController,
                      hintText: l10n?.parcelsDetailsContentsHint ??
                          'Briefly describe the contents',
                      maxLines: 3,
                      onChanged: (value) =>
                          controller.updateContentsDescription(value),
                    ),

                    const SizedBox(height: DWSpacing.md),

                    // Fragile toggle
                    Row(
                      children: [
                        Switch(
                          value: draft.isFragile,
                          onChanged: (_) => controller.toggleFragile(),
                        ),
                        const SizedBox(width: DWSpacing.sm),
                        Expanded(
                          child: Text(
                            l10n?.parcelsDetailsFragileLabel ??
                                'This parcel is fragile',
                            style: textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(DWSpacing.lg),
              child: DWButton.primary(
                label:
                    l10n?.parcelsDetailsContinueCta ?? 'Continue to pricing',
                onPressed:
                    canContinue ? () => _onContinuePressed(context) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onContinuePressed(BuildContext context) {
    // Track C - Ticket #43: Navigate to ParcelQuoteScreen
    Navigator.of(context).pushNamed(RoutePaths.parcelsQuote);
  }
}

/// Widget for selecting parcel size.
class _SizeSelector extends StatelessWidget {
  const _SizeSelector({
    required this.selected,
    required this.onSelected,
  });

  final ParcelSize? selected;
  final ValueChanged<ParcelSize> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final items = <ParcelSize, String>{
      ParcelSize.small: 'Small',
      ParcelSize.medium: 'Medium',
      ParcelSize.large: 'Large',
      ParcelSize.oversize: 'Oversize',
    };

    return Wrap(
      spacing: DWSpacing.sm,
      runSpacing: DWSpacing.sm,
      children: items.entries.map((entry) {
        final size = entry.key;
        final label = entry.value;
        final bool isSelected = selected == size;

        return ChoiceChip(
          label: Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              color: isSelected ? colors.onPrimary : colors.onSurface,
            ),
          ),
          selected: isSelected,
          onSelected: (_) => onSelected(size),
        );
      }).toList(),
    );
  }
}


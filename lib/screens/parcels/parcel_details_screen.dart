/// Parcel Details Screen (Step 2 - Wizard)
/// Created by: Track C - Ticket #42
/// Purpose: Second step in create-shipment flow (size, weight, contents, fragile).
/// Last updated: 2025-11-29 (Ticket #76 - Alignment + Validation MVP)

import 'package:design_system_shims/design_system_shims.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parcels_shims/parcels_shims.dart' show ParcelSize;

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/router/app_router.dart';
import 'package:delivery_ways_clean/state/parcels/parcel_draft_state.dart';

/// Step 2 of the parcel shipment flow: capture parcel details.
/// Track C - Ticket #76: Aligned with DS + Validation MVP.
class ParcelDetailsScreen extends ConsumerStatefulWidget {
  const ParcelDetailsScreen({super.key});

  @override
  ConsumerState<ParcelDetailsScreen> createState() =>
      _ParcelDetailsScreenState();
}

class _ParcelDetailsScreenState extends ConsumerState<ParcelDetailsScreen> {
  late final TextEditingController _weightController;
  late final TextEditingController _contentsController;

  // Track C - Ticket #76: Validation error states
  String? _weightError;
  String? _contentsError;
  String? _sizeError;
  bool _hasAttemptedSubmit = false;

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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.parcelsDetailsTitle ?? 'Parcel details',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DWSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Subtitle
              Text(
                l10n?.parcelsDetailsSubtitle ??
                    'Tell us more about your parcel to get accurate pricing.',
                style: textTheme.bodyLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: DWSpacing.lg),

              // Track C - Ticket #76: Section Header - Parcel Details
              _buildSectionHeader(
                l10n?.parcelsDetailsSectionParcelTitle ?? 'Parcel details',
                textTheme,
              ),
              const SizedBox(height: DWSpacing.md),

              // Size section
              Text(
                l10n?.parcelsDetailsSizeLabel ?? 'Size',
                style: textTheme.labelLarge,
              ),
              const SizedBox(height: DWSpacing.xs),
              _SizeSelector(
                selected: draft.size,
                onSelected: (size) {
                  controller.updateSize(size);
                  if (_hasAttemptedSubmit) {
                    setState(() => _sizeError = null);
                  }
                },
              ),
              // Track C - Ticket #76: Size error message
              if (_sizeError != null) ...[
                const SizedBox(height: DWSpacing.xs),
                Text(
                  _sizeError!,
                  style: textTheme.bodySmall?.copyWith(color: colors.error),
                ),
              ],

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
                errorText: _weightError,
                onChanged: (value) {
                  controller.updateWeightText(value);
                  if (_hasAttemptedSubmit) {
                    setState(() => _weightError = _validateWeight(value, l10n));
                  }
                },
              ),

              const SizedBox(height: DWSpacing.md),

              // Contents section
              Text(
                l10n?.parcelsDetailsContentsLabel ?? 'What are you sending?',
                style: textTheme.labelLarge,
              ),
              const SizedBox(height: DWSpacing.xs),
              DWTextField(
                controller: _contentsController,
                hintText: l10n?.parcelsDetailsContentsHint ??
                    'Briefly describe the contents',
                maxLines: 3,
                errorText: _contentsError,
                onChanged: (value) {
                  controller.updateContentsDescription(value);
                  if (_hasAttemptedSubmit) {
                    setState(
                        () => _contentsError = _validateContents(value, l10n));
                  }
                },
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

              const SizedBox(height: DWSpacing.xxl),
            ],
          ),
        ),
      ),
      // Track C - Ticket #76: Bottom CTA with validation guard
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(DWSpacing.md),
        child: SizedBox(
          width: double.infinity,
          child: DWButton.primary(
            label: l10n?.parcelsDetailsContinueCta ?? 'Review price',
            onPressed: () => _onContinuePressed(context, draft, l10n),
          ),
        ),
      ),
    );
  }

  /// Track C - Ticket #76: Build section header widget
  Widget _buildSectionHeader(String title, TextTheme textTheme) {
    return Text(
      title,
      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  /// Track C - Ticket #76: Validate weight field
  String? _validateWeight(String? value, AppLocalizations? l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n?.parcelsDetailsErrorWeightRequired ??
          'Please enter the parcel weight';
    }
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) {
      return l10n?.parcelsDetailsErrorPositiveNumber ??
          'Enter a valid positive number';
    }
    return null;
  }

  /// Track C - Ticket #76: Validate contents field
  String? _validateContents(String? value, AppLocalizations? l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n?.parcelsDetailsErrorContentsRequired ??
          'Please describe what you are sending';
    }
    return null;
  }

  /// Track C - Ticket #76: Validate size selection
  String? _validateSize(ParcelSize? size, AppLocalizations? l10n) {
    if (size == null) {
      return l10n?.parcelsDetailsErrorSizeRequired ??
          'Please select a parcel size';
    }
    return null;
  }

  /// Track C - Ticket #76: CTA handler with validation
  void _onContinuePressed(
    BuildContext context,
    ParcelDraftUiState draft,
    AppLocalizations? l10n,
  ) {
    setState(() {
      _hasAttemptedSubmit = true;
      _weightError = _validateWeight(_weightController.text, l10n);
      _contentsError = _validateContents(_contentsController.text, l10n);
      _sizeError = _validateSize(draft.size, l10n);
    });

    // Check if all validations pass
    if (_weightError != null || _contentsError != null || _sizeError != null) {
      return;
    }

    _proceedToQuote(context);
  }

  /// Track C - Ticket #76: Navigate to Quote screen
  void _proceedToQuote(BuildContext context) {
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

    // Track C - Ticket #76: Size labels (using hardcoded strings as per existing pattern)
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

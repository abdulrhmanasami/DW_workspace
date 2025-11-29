import 'package:design_system_shims/design_system_shims.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../state/parcels/parcel_draft_state.dart';
import 'parcel_details_screen.dart';

/// Parcel Destination Screen
/// Created by: Track C - Ticket #41
/// Purpose: First step in create-shipment flow (pickup & dropoff addresses).
class ParcelDestinationScreen extends ConsumerStatefulWidget {
  const ParcelDestinationScreen({super.key});

  @override
  ConsumerState<ParcelDestinationScreen> createState() =>
      _ParcelDestinationScreenState();
}

class _ParcelDestinationScreenState
    extends ConsumerState<ParcelDestinationScreen> {
  late final TextEditingController _pickupController;
  late final TextEditingController _dropoffController;
  final FocusNode _pickupFocusNode = FocusNode();
  final FocusNode _dropoffFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final draft = ref.read(parcelDraftProvider);
    _pickupController = TextEditingController(text: draft.pickupAddress);
    _dropoffController = TextEditingController(text: draft.dropoffAddress);
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    _pickupFocusNode.dispose();
    _dropoffFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colors = theme.colorScheme;

    final draft = ref.watch(parcelDraftProvider);
    final controller = ref.read(parcelDraftProvider.notifier);

    final bool canContinue = draft.pickupAddress.trim().isNotEmpty &&
        draft.dropoffAddress.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.parcelsDestinationTitle ?? 'Create shipment',
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DWSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n?.parcelsDestinationSubtitle ??
                    'Enter where to pick up and where to deliver your parcel.',
                style: textTheme.bodyLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: DWSpacing.lg),

              // Pickup field
              Text(
                l10n?.parcelsDestinationPickupLabel ?? 'Pickup address',
                style: textTheme.labelLarge,
              ),
              const SizedBox(height: DWSpacing.xs),
              DWTextField(
                controller: _pickupController,
                focusNode: _pickupFocusNode,
                hintText: l10n?.parcelsDestinationPickupHint ??
                    'Enter pickup address',
                prefixIcon: const Icon(Icons.my_location),
                textInputAction: TextInputAction.next,
                onChanged: (value) {
                  controller.updatePickupAddress(value);
                },
                onSubmitted: (_) {
                  _dropoffFocusNode.requestFocus();
                },
              ),

              const SizedBox(height: DWSpacing.md),

              // Dropoff field
              Text(
                l10n?.parcelsDestinationDropoffLabel ?? 'Delivery address',
                style: textTheme.labelLarge,
              ),
              const SizedBox(height: DWSpacing.xs),
              DWTextField(
                controller: _dropoffController,
                focusNode: _dropoffFocusNode,
                hintText: l10n?.parcelsDestinationDropoffHint ??
                    'Enter delivery address',
                prefixIcon: const Icon(Icons.place_outlined),
                textInputAction: TextInputAction.done,
                onChanged: (value) {
                  controller.updateDropoffAddress(value);
                },
                onSubmitted: (_) {
                  if (canContinue) {
                    _onContinuePressed(context);
                  }
                },
              ),

              const Spacer(),

              DWButton.primary(
                label: l10n?.parcelsDestinationContinueCta ?? 'Continue',
                onPressed: canContinue ? () => _onContinuePressed(context) : null,
              ),
              const SizedBox(height: DWSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }

  void _onContinuePressed(BuildContext context) {
    // Track C - Ticket #42:
    // Navigate to ParcelDetailsScreen (Step 2).
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ParcelDetailsScreen(),
      ),
    );
  }
}


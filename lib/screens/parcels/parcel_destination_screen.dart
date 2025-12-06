/// Parcel Destination Screen (Create Shipment - Screen 11)
/// Created by: Track C - Ticket #41
/// Purpose: First step in create-shipment flow matching Screen 11 mockups.
/// Last updated: 2025-12-05 (Ticket C-1 - Draft initialization + contact info)

import 'package:design_system_shims/design_system_shims.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/router/app_router.dart';
import 'package:delivery_ways_clean/state/parcels/parcel_draft_state.dart';

/// Parcel Destination Screen Widget.
/// Track C - Ticket #75: Aligned with Screen 11 mockups.
/// Track C - Ticket C-1: Added draft reset and contact info storage.
class ParcelDestinationScreen extends ConsumerStatefulWidget {
  const ParcelDestinationScreen({super.key});

  @override
  ConsumerState<ParcelDestinationScreen> createState() =>
      _ParcelDestinationScreenState();
}

class _ParcelDestinationScreenState
    extends ConsumerState<ParcelDestinationScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Sender controllers
  late final TextEditingController _senderNameController;
  late final TextEditingController _pickupController;

  // Receiver controllers
  late final TextEditingController _receiverNameController;
  late final TextEditingController _dropoffController;

  // Focus nodes
  final FocusNode _senderNameFocusNode = FocusNode();
  final FocusNode _pickupFocusNode = FocusNode();
  final FocusNode _receiverNameFocusNode = FocusNode();
  final FocusNode _dropoffFocusNode = FocusNode();

  /// Track C - Ticket C-1: Whether draft has been initialized for this session.
  bool _draftInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with empty values initially.
    // Draft will be reset on first frame to ensure clean state.
    _senderNameController = TextEditingController();
    _pickupController = TextEditingController();
    _receiverNameController = TextEditingController();
    _dropoffController = TextEditingController();

    // Reset draft on first frame to ensure clean state for new shipment.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDraft();
    });
  }

  /// Track C - Ticket C-1: Initialize draft for new shipment flow.
  void _initializeDraft() {
    if (_draftInitialized) return;
    _draftInitialized = true;

    // Reset draft to start fresh
    ref.read(parcelDraftProvider.notifier).reset();
  }

  @override
  void dispose() {
    _senderNameController.dispose();
    _pickupController.dispose();
    _receiverNameController.dispose();
    _dropoffController.dispose();
    _senderNameFocusNode.dispose();
    _pickupFocusNode.dispose();
    _receiverNameFocusNode.dispose();
    _dropoffFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.parcelsCreateShipmentTitle ?? 'New Shipment',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(DWSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ========== SENDER SECTION ==========
                _buildSectionHeader(
                  l10n?.parcelsCreateSenderSectionTitle ?? 'Sender',
                  textTheme,
                ),
                const SizedBox(height: DWSpacing.sm),
                _buildTextFormField(
                  controller: _senderNameController,
                  focusNode: _senderNameFocusNode,
                  label: l10n?.parcelsCreateSenderNameLabel ?? 'Sender name',
                  prefixIcon: const Icon(Icons.person_outline),
                  textInputAction: TextInputAction.next,
                  validator: (value) => _requiredValidator(value, l10n),
                  // Track C - Ticket C-1: Save sender name to draft
                  onChanged: (value) {
                    ref.read(parcelDraftProvider.notifier).updateSenderName(value);
                  },
                  onFieldSubmitted: (_) {
                    _pickupFocusNode.requestFocus();
                  },
                ),
                const SizedBox(height: DWSpacing.sm),
                _buildTextFormField(
                  controller: _pickupController,
                  focusNode: _pickupFocusNode,
                  label: l10n?.parcelsDestinationPickupLabel ?? 'Pickup address',
                  prefixIcon: const Icon(Icons.my_location),
                  textInputAction: TextInputAction.next,
                  validator: (value) => _requiredValidator(value, l10n),
                  onChanged: (value) {
                    ref.read(parcelDraftProvider.notifier).updatePickupAddress(value);
                  },
                  onFieldSubmitted: (_) {
                    _receiverNameFocusNode.requestFocus();
                  },
                ),
                const SizedBox(height: DWSpacing.lg),

                // ========== RECEIVER SECTION ==========
                _buildSectionHeader(
                  l10n?.parcelsCreateReceiverSectionTitle ?? 'Receiver',
                  textTheme,
                ),
                const SizedBox(height: DWSpacing.sm),
                _buildTextFormField(
                  controller: _receiverNameController,
                  focusNode: _receiverNameFocusNode,
                  label: l10n?.parcelsCreateReceiverNameLabel ?? 'Receiver name',
                  prefixIcon: const Icon(Icons.person_outline),
                  textInputAction: TextInputAction.next,
                  validator: (value) => _requiredValidator(value, l10n),
                  // Track C - Ticket C-1: Save receiver name to draft
                  onChanged: (value) {
                    ref.read(parcelDraftProvider.notifier).updateReceiverName(value);
                  },
                  onFieldSubmitted: (_) {
                    _dropoffFocusNode.requestFocus();
                  },
                ),
                const SizedBox(height: DWSpacing.sm),
                _buildTextFormField(
                  controller: _dropoffController,
                  focusNode: _dropoffFocusNode,
                  label: l10n?.parcelsDestinationDropoffLabel ?? 'Delivery address',
                  prefixIcon: const Icon(Icons.place_outlined),
                  textInputAction: TextInputAction.done,
                  validator: (value) => _requiredValidator(value, l10n),
                  onChanged: (value) {
                    ref.read(parcelDraftProvider.notifier).updateDropoffAddress(value);
                  },
                  onFieldSubmitted: (_) {
                    _onGetEstimatePressed();
                  },
                ),
                const SizedBox(height: DWSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(DWSpacing.md),
        child: SizedBox(
          width: double.infinity,
          child: DWButton.primary(
            label: l10n?.parcelsCreateShipmentCtaGetEstimate ?? 'Get estimate',
            onPressed: _onGetEstimatePressed,
          ),
        ),
      ),
    );
  }

  /// Build section header text widget.
  Widget _buildSectionHeader(String title, TextTheme textTheme) {
    return Text(
      title,
      style: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Build a TextFormField with consistent styling.
  Widget _buildTextFormField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    Widget? prefixIcon,
    TextInputAction textInputAction = TextInputAction.next,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon,
        border: const OutlineInputBorder(),
      ),
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
    );
  }

  /// Validator for required fields.
  String? _requiredValidator(String? value, AppLocalizations? l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n?.parcelsCreateErrorRequired ?? 'This field is required';
    }
    return null;
  }

  /// Handle Get Estimate button press with validation.
  void _onGetEstimatePressed() {
    final form = _formKey.currentState;
    if (form == null) return;

    if (!form.validate()) {
      // Validation failed – errors are shown in fields
      return;
    }

    // Track C - Ticket #75:
    // After successful validation, proceed to next step.
    _proceedToNextStep();
  }

  /// Navigate to the next step (ParcelDetailsScreen).
  /// Track C - Ticket C-1: Using named route for consistency.
  void _proceedToNextStep() {
    Navigator.of(context).pushNamed(RoutePaths.parcelsDetails);
  }
}
